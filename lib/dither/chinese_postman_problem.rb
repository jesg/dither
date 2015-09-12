
# implement thimbleby's solution to the chinese @postman problem
# http://www.cs.swansea.ac.uk/~csharold/cv/files/cpp.pdf

module Dither
  module Cpp
    class Graph

      attr_accessor :n, :neg, :pos, :degree, :path, :edges, :cheapest_edge, :f, :defined, :label, :c, :initialized, :origin

      Edge = Struct.new(:name, :src_vertex, :dst_vertex)

      def initialize(n)

        @n = n
        @degree = Array.new(n).fill(0)
        @defined = Array.new(n).fill { |_| Array.new(n).fill(false) }
        @label = Array.new(n).fill { |_| Array.new(n).fill { |_| [] } }
        @c = Array.new(n).fill { |_| Array.new(n).fill(0.0) }
        @f = Array.new(n).fill { |_| Array.new(n).fill(0) }
        @edges = Array.new(n).fill { |_| Array.new(n).fill(0) }
        @cheapest_edge = Array.new(n).fill { |_| Array.new(n).fill(0) }
        @path = Array.new(n).fill { |_| Array.new(n).fill(0) }
        @initialized = true
      end


      def cpp
        initialized?
        least_cost_paths
        check_valid
        find_feasible
        while improvments do
        end
        print(origin)
      end

      def self.create(raw_graph)
        vertices = [].to_set
        raw_graph[:edges].each do |edge|
          vertices << edge[:src_vertex]
          vertices << edge[:dst_vertex]
        end

        graph = Graph.new(vertices.length)

        raw_graph[:edges].each do |edge|
          graph.add_edge(edge[:name], edge[:src_vertex], edge[:dst_vertex], 1)
        end
        graph.origin = raw_graph[:origin]
        graph
      end

      def add_edge(lab, u, v, cost)
        @label[u][v] = [] unless defined[u][v]
        @label[u][v] << lab
        if !defined[u][v] || c[u][v] > cost
          @c[u][v] = cost
          @cheapest_edge[u][v] = edges[u][v]
          @defined[u][v] = true
          @path[u][v] = v
        end
        @edges[u][v] += 1
        @degree[u] += 1
        @degree[v] -= 1
        self
      end

      def check_valid
        (0...n).each do |i|
          raise Dither::Error, 'negative cycle' if c[i][i] < 0
          (0...n).each do |j|
            raise Dither::Error, 'not strongly connected' unless defined[i][j]
          end
        end
      end

      def least_cost_paths
        (0...n).each do |k|
          (0...n).each do |i|
            if defined[i][k]
              (0...n).each do |j|
                if defined[k][j] && (!defined[i][j] || c[i][j] > c[i][k]+c[k][j])
                  @defined[i][j] = true
                  @path[i][j] = path[i][k]
                  @c[i][j] = c[i][k] + c[k][j]
                  # negative cycle
                  return if i == j && c[i][j] < 0
                end
              end
            end
          end
        end
      end

      def find_feasible
        nn, np = 0, 0
        (0...n).each do |i|
          if degree[i] < 0
            nn += 1
          elsif degree[i] > 0
            np += 1
          end
        end

        @neg = Array.new(nn)
        @pos = Array.new(np)
        nn, np = 0, 0
        (0...n).each do |i|
          if degree[i] < 0
            @neg[nn] = i
            nn += 1
          elsif degree[i] > 0
            @pos[np] = i
            np += 1
          end
        end

        (0...nn).each do |u|
          i = neg[u]
          (0...np).each do |v|
            j = pos[v]
            @f[i][j] = -degree[i] < degree[j] ? -degree[i] : degree[j]
            @degree[i] += f[i][j]
            @degree[j] -= f[i][j]
          end
        end
      end

      def improvments
        r = Graph.new(n)
        (0...neg.length).each do |u|
          i = neg[u]
          (0...pos.length).each do |v|
            j = pos[v]
            if edges[i][j] > 0
              r.add_edge(nil, i, j, c[i][j])
            end
            if f[i][j] != 0
              r.add_edge(nil, j, i, -c[i][j])
            end
          end
        end

        r.least_cost_paths
        (0...n).each do |i|
          if r.c[i][i] < 0
            k = 0
            kunset = true
            u = i
            begin
              v = r.path[u][i]
              if r.c[u][v] < 0 && (kunset || k > f[v][u])
                k = f[v][u]
                kunset = false
              end
              u = v
            end while u != i
            u = i
            begin
              v = r.path[u][i]
              if r.c[u][v] < 0
                @f[v][u] -= k
              else
                @f[u][v] += k
              end
              u = v
            end while u != i
            return true
          end
        end
        false
      end

      def print(start)
        result = []
        v = start
        loop do
          skip = false
          u = v
          (0...n).each do |i|
            if f[u][i] > 0
              v = i
              @f[u][v] -= 1
              while u != v
                p = path[u][v]
                result << Edge.new(label[u][p][cheapest_edge[u][p]], u, p)
                u = p
              end
              skip = true
            end
          end

          next if skip

          v = -1
          (0...n).each do |i|
            if edges[u][i] > 0
              v = i if v == -1 || i != path[u][start]
            end
          end
          return result if v == -1
          result << Edge.new(label[u][v][edges[u][v] - 1], u, v)
          @edges[u][v] -= 1
        end
        result
      end

      def initialized?
        raise Dither::Error, 'graph not initialized' unless initialized
        raise Dither::Error, 'origin not set' unless origin
        @initialized = false
      end
    end # Graph
  end # Cpp

  def self.all_edges(raw_graph)
    Dither::Cpp::Graph.create(raw_graph).cpp
  end
end # Dither
