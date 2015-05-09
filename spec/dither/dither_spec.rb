require File.expand_path('../../spec_helper.rb', __FILE__)

describe Dither do

  it 't must be >= 2' do
    expect { Dither.all_pairs([], 0) }.to raise_error('t must be >= 2')
  end

  it 't must be <= params.length' do
    expect { Dither.all_pairs((0...3).to_a, 4) }.to raise_error('t must be <= params.length')
  end

  it 'param length must be > 1' do
    expect { Dither.all_pairs([[], []], 2) }.to raise_error('param length must be > 1')
  end

  it 'can compute 2-way ipog' do
    params = [(0...2).to_a, (0..3).to_a]
    expect(Dither.all_pairs(params)).to eq([
                                             [0, 0],
                                             [0, 1],
                                             [0, 2],
                                             [0, 3],
                                             [1, 0],
                                             [1, 1],
                                             [1, 2],
                                             [1, 3],
                                           ])
  end

  it 'can compute 3-way ipog' do
    params = [(0...2).to_a, (0...2).to_a, (0..3).to_a]
    expect(Dither.all_pairs(params, 3)).to eq([[0, 0, 0],
                                               [0, 0, 1],
                                               [0, 0, 2],
                                               [0, 0, 3],
                                               [0, 1, 0],
                                               [0, 1, 1],
                                               [0, 1, 2],
                                               [0, 1, 3],
                                               [1, 0, 0],
                                               [1, 0, 1],
                                               [1, 0, 2],
                                               [1, 0, 3],
                                               [1, 1, 0],
                                               [1, 1, 1],
                                               [1, 1, 2],
                                               [1, 1, 3]])
  end
end
