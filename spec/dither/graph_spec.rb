
require File.expand_path('../../spec_helper.rb', __FILE__)

describe Dither::Graph do
  let(:raw_graph) do
    {
      :edges => [
        {
          :name => :a,
          :src_vertex => :origin,
          :dst_vertex => 1,
        },
        {
          :name => :b,
          :src_vertex => :origin,
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
          :dst_vertex => :origin,
        }
      ]
    }
  end


  let(:raw_graph_infinite_cycle) do
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
          :src_vertex => 1,
          :dst_vertex => 2,
        },
        {
          :name => :c,
          :src_vertex => 2,
          :dst_vertex => 1,
        },
      ]
    }
  end

  it 'can run random walk' do
    graph = Dither::Graph.create(raw_graph)
    graph.rand = Random.new 0
    graph.each do |path|
      first = path.map(&:name)
      expect(first).to eql([:a, :d, :f])
      break
    end
  end

  it 'can skip at skip condition' do
    graph = Dither::Graph.create(raw_graph_infinite_cycle)
    stop_cond = 'stop_cond'
    def stop_cond.stop?(graph)
      @count ||= 0
      @count += 1
      @count > 2
    end
    skip_cond = double("skip_cond", :skip? => true)
    graph.add_skip_condition(skip_cond)
    graph.add_stop_condition(stop_cond)
    count = 0
    graph.each do |a|
      count += 1
    end

    expect(count).to eql(0)
  end

  it 'can stop at stop condition' do
    graph = Dither::Graph.create(raw_graph_infinite_cycle)
    cond = double("stop_cond", :stop? => true)
    graph.add_stop_condition(cond)
    count = 0
    graph.each { |a| count += 1 }

    expect(count).to eql(0)
  end

  it 'infinite cycle terminates at max_depth' do
    graph = Dither::Graph.create(raw_graph_infinite_cycle)
    graph.random_walk { |a| }

    edge_count = graph.edges.map(&:count).reduce(&:+)
    expect(edge_count).to eql(graph.max_depth)
  end

  it 'raise error when invalid stop condition' do
    graph = Dither::Graph.new

    expect { graph.add_stop_condition("hi") }.to raise_error
  end

  it 'raise error when invalid skip condition' do
    graph = Dither::Graph.new

    expect { graph.add_skip_condition("hi") }.to raise_error
  end
end
