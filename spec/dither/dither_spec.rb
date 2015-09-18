require File.expand_path('../../spec_helper.rb', __FILE__)

describe Dither do

  it 'mipog does not support constraints' do
    expect { Dither.mipog([[1,1],[1,2]], 2, :constraints => []) }.to raise_error(Dither::Error, 'mipog does not support constraints')
  end

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
    expect(Dither.ipog(params)).to eq([[:a, :d, :h],
                                            [:a, :e, :i],
                                            [:a, :f, :h],
                                            [:b, :d, :i],
                                            [:b, :e, :h],
                                            [:b, :f, :i],
                                            [:c, :d, :h],
                                            [:c, :e, :i],
                                            [:c, :f, :h]])
  end

  it 'can compute 3-way mipog' do
    params = [(0...2).to_a, (0...2).to_a, (0..3).to_a]
    expect(Dither.mipog(params, 3)).to eq([[0, 0, 0],
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
                                          ])
  end

  it 'can compute 2-way mipog using symbols' do
    params = [[:a, :b, :c], [:d, :e, :f], [:h, :i]]
    expect(Dither.mipog(params).to_set).to eq([[:a, :d, :h],
                                        [:a, :e, :i],
                                        [:a, :f, :h],
                                        [:b, :d, :i],
                                        [:b, :e, :h],
                                        [:b, :f, :i],
                                        [:c, :d, :h],
                                        [:c, :e, :i],
                                        [:c, :f, :h]].to_set)
  end

  it 'can compute 2-way mipog' do
    params = [(0...2).to_a, (0..3).to_a]
    expect(Dither.mipog(params)).to eq([
                                         [0, 0],
                                         [1, 0],
                                         [0, 1],
                                         [1, 1],
                                         [0, 2],
                                         [1, 2],
                                         [0, 3],
                                         [1, 3],
                                       ])
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
                                           ])
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
    params = [(0...2).to_a, (0...2).to_a, (0..3).to_a]
    expect(Dither.ipog(params, :t => 3,
                       :constraints => [
                         {0 => 0,
                          2 => 2},
                         {0 => 0,
                          1 => 1,
                          2 => 0}],
                        :previously_tested => [[0, 0, 0]]).to_set).to eq([
                                       [1, 0, 0],
                                       [1, 1, 0],
                                       [0, 0, 1],
                                       [1, 0, 1],
                                       [0, 1, 1],
                                       [1, 1, 1],
                                       [1, 0, 2],
                                       [1, 1, 2],
                                       [0, 0, 3],
                                       [1, 0, 3],
                                       [0, 1, 3],
                                       [1, 1, 3],
                                      ].to_set)
  end

  it 'another 3-way ipog with constraints' do
    params = [(0...2).to_a, (0...2).to_a, (0...2).to_a, (0..3).to_a]
    expect(Dither.ipog(params, :t => 3,
                            :constraints => [
                              {0 => 0,
                               1 => 1,
                               2 => 0}
                            ]).to_set).to eq([[0, 0, 0, 0],
                                       [1, 1, 0, 0],
                                       [1, 0, 1, 0],
                                       [0, 1, 1, 0],
                                       [1, 0, 0, 1],
                                       [1, 1, 0, 1],
                                       [0, 0, 1, 1],
                                       [1, 1, 1, 1],
                                       [0, 0, 0, 2],
                                       [1, 1, 0, 2],
                                       [1, 0, 1, 2],
                                       [0, 1, 1, 2],
                                       [0, 0, 0, 3],
                                       [1, 1, 0, 3],
                                       [1, 0, 1, 3],
                                       [0, 1, 1, 3],
                                       [0, 0, 0, 1],
                                       [0, 1, 1, 1]].to_set)
  end

  it 'can run 2-way ateg' do
    params = [(0...2).to_a, (0...2).to_a, (0...2).to_a, (0..3).to_a]
    Dither.ateg(params)
  end

  it 'can run 4-way ateg with seed' do
    params = [(0...2).to_a, (0...2).to_a, (0...2).to_a, (0..3).to_a]
    expect(Dither.ateg(params, :t => 4, :seed => 0).length).to eq 32
  end
end
