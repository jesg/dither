
module Dither
  class Graph
    include Enumerable

    attr_accessor :rand, :max_depth, :origin_name
    attr_reader :vertices, :edges, :stop_conditions, :skip_conditions
    Edge = Struct.new(:name, :src_vertex, :dst_vertex, :count)
    Vertex = Struct.new(:name, :edges, :count)

    def initialize
      @vertices = {}
      @edges = []
      @stop_conditions = []
      @skip_conditions = []
      @rand = Random.new
      @max_depth = 10
			@origin_name = :origin
    end

    def self.create(hash)
      edges = hash[:edges]
      graph = Graph.new
			graph.origin_name = hash[:origin] if hash.has_key?(:origin)

      edges.each do |edge|
        graph.add_edge(edge[:name], edge[:src_vertex], edge[:dst_vertex])
      end
      graph
    end

    def add_edge(name, src_vertex_name, dst_vertex_name)
      # check & create vertexes if they do not exist
      vertices[src_vertex_name] ||= Vertex.new(src_vertex_name, [], 0)
      vertices[dst_vertex_name] ||= Vertex.new(dst_vertex_name, [], 0)

      # add edge to src_vertex
      src_vertex = vertices[src_vertex_name]
      dst_vertex = vertices[dst_vertex_name]
      edge = Edge.new(name, src_vertex, dst_vertex, 0)
      src_vertex.edges << edge
      edges << edge

      self
    end

    def add_skip_condition(cond)
      raise Dither::Error, "#{cond} does not respond to skip?" unless cond.respond_to? :skip?
      skip_conditions << cond
    end

    def add_stop_condition(cond)
      raise Dither::Error, "#{cond} does not respond to stop?" unless cond.respond_to? :stop?
      stop_conditions << cond
    end

    def origin
      vertices[origin_name]
    end

    def random_walk
      current_edge = origin.edges.sample(:random => rand)
      current_max_depth = max_depth - 1
      loop do
        current_edge.src_vertex.count += 1
        current_edge.count += 1
        yield current_edge
        current_edge = current_edge.dst_vertex.edges.sample(:random => rand)
        current_max_depth -= 1
        break if current_max_depth < 0 || current_edge.src_vertex.name == origin_name
      end
    end

    def each
      loop do
        break if stop?
        path = []
        random_walk { |a| path << a }
        next if skip?
        yield path
      end
    end

    def stop?
      stop_conditions.any? { |cond| cond.stop?(self) }
    end

    def skip?
      skip_conditions.any? { |cond| cond.skip?(self) }
    end

    def vertices_covered
      b = vertices.count { |a| a.count > 0 }
      b/vertices.length.to_f
    end

    def edges_covered
      b = edges.count { |a| a.count > 0 }
      b/edges.length.to_f
    end
  end
end
