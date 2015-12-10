require File.expand_path('../../spec_helper.rb', __FILE__)

describe Dither do

  it 't must be >= 2' do
    expect { Dither.ipog([], :t => 0) }.to raise_error(Dither::Error, 't must be >= 2')
  end

  it 't must be <= params.length' do
    expect { Dither.ipog([(0...3).to_a], :t => 4) }.to raise_error(Dither::Error,'t must be <= params.length')
  end

  it 'param length must be > 1' do
    expect { Dither.ipog([[], []], :t => 2) }.to raise_error(Dither::Error,'param length must be > 1')
  end

  it 'can compute 2-way ipog using symbols' do
    params = [[:a, :b, :c], [:d, :e, :f], [:h, :i]]
    expect(Dither.all_pairs(params)).to eq([[:c, :f, :h],
                                       [:b, :f, :i],
                                       [:a, :f, :h],
                                       [:c, :e, :i],
                                       [:b, :e, :h],
                                       [:a, :e, :i],
                                       [:c, :d, :h],
                                       [:b, :d, :i],
                                       [:a, :d, :h]])
  end

  it 'can compute 2-way ipog' do
    params = [(0...2).to_a, (0..3).to_a]
    expect(Dither.ipog(params)).to eq([
                                             [0, 0],
                                             [1, 0],
                                             [0, 1],
                                             [1, 1],
                                             [0, 2],
                                             [1, 2],
                                             [0, 3],
                                             [1, 3],
    ].reverse)
  end

  it 'can compute 3-way ipog' do
    params = [(0...2).to_a, (0...2).to_a, (0..3).to_a]
    expect(Dither.ipog(params, :t => 3).to_set).to eq([[0, 0, 0],
                                               [1, 0, 0],
                                               [0, 1, 0],
                                               [1, 1, 0],
                                               [0, 0, 1],
                                               [1, 0, 1],
                                               [0, 1, 1],
                                               [1, 1, 1],
                                               [0, 0, 2],
                                               [1, 0, 2],
                                               [0, 1, 2],
                                               [1, 1, 2],
                                               [0, 0, 3],
                                               [1, 0, 3],
                                               [0, 1, 3],
                                               [1, 1, 3],
                                              ].to_set)
  end

  it 'can compute 3-way ipog with constraints' do
    params = [[:a, :b], (0...2).to_a, (0..3).to_a]
    results = Dither.ipog(params, :t => 3,
                       :constraints => [
                         {0 => 0,
                          2 => 2},
                         {0 => 0,
                          1 => 1,
                          2 => 0}],
                        :previously_tested => [[:a, 0, 0]]
                      )
    results.each do |result|
      expect(result[0] == :a && result[1] == 1 && result[2] == 0).to be false
    end
    results.each do |result|
      expect(result[0] == :a && result[1] == 2).to be false
    end
    results.each do |result|
      expect(result[0] == :a && result[1] == 0 && result[2] == 0).to be false
    end
  end

  it 'another 3-way ipog with constraints' do
    params = [(0...2).to_a, (0...2).to_a, (0...2).to_a, (0..3).to_a]
    results = Dither.ipog(params, :t => 3,
                            :constraints => [
                              {0 => 0,
                               1 => 1,
                               2 => 0}
                            ])
    results.each do |result|
      expect(result[0] == 0 && result[1] == 1 && result[2] == 0).to be false
    end
  end

  it 'can run 2-way aetg' do
    params = [(0...2).to_a, (0...2).to_a, (0...2).to_a, (0..3).to_a]
    Dither.aetg(params)
    Dither.ateg(params)
  end

  it 'can run 4-way aetg with seed' do
    params = [(0...2).to_a, (0...2).to_a, (0...2).to_a, (0..3).to_a]
    expect(Dither.aetg(params, :t => 4, :seed => 0, :constraints => [
      { 0 => 1, 1 => 1, 2 => 1, 3 => 1 },
    ], :previously_tested => [[1,1,1,2]]).length).to eq 30
  end
end
