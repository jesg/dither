require File.expand_path('../../spec_helper.rb', __FILE__)

describe Dither::Cpp::Graph do
  let(:raw_graph) do
    {
      :origin => 0,
      :edges => [
        {
          :name => :a,
          :src_vertex => 0,
          :dst_vertex => 1,
        },
        {
          :name => :b,
          :src_vertex => 0,
          :dst_vertex => 2,
        },
        {
          :name => :c,
          :src_vertex => 1,
          :dst_vertex => 2,
        },
        {
          :name => :d,
          :src_vertex => 1,
          :dst_vertex => 3,
        },
        {
          :name => :e,
          :src_vertex => 2,
          :dst_vertex => 3,
        },
        {
          :name => :f,
          :src_vertex => 3,
          :dst_vertex => 0,
        }
      ]
    }
  end

  it 'can compute chinese postman problem' do
    expected = [
      [:b, 0, 2],
      [:e, 2, 3],
      [:f, 3, 0],
      [:a, 0, 1],
      [:c, 1, 2],
      [:e, 2, 3],
      [:f, 3, 0],
      [:a, 0, 1],
      [:d, 1, 3],
      [:f, 3, 0]].map { |a| Dither::Cpp::Graph::Edge.new(*a) }
    expect(Dither.all_edges(raw_graph)).to eq(expected)
  end

  it 'verify origin is set' do
    raw_graph.delete(:origin)
    expect { Dither.all_edges(raw_graph) }.to raise_error
  end

  it 'raise error when calling cpp twice' do
    graph = Dither::Cpp::Graph.create(raw_graph)
    graph.cpp
    expect { graph.cpp }.to raise_error
  end

  it 'raise error when graph is not strongly connected' do
    raw_graph[:edges] << {
      :name => :w,
      :src_vertex => 23,
      :dst_vertex => 78
    }

    expect { Dither.all_edges(raw_graph) }.to raise_error
  end
end
