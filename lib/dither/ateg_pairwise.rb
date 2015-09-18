
module Dither
  module Ateg
    class Pairwise
      include Ateg

      attr_reader :scratch, :n, :random, :t, :params, :constraints, :pair_cache, :comb

      Pair = Struct.new(:i, :j)

      module Pairs

        def in_test_case?(test_case)
          self.all? { |pair| pair.j == test_case[pair.i] }
        end

        alias_method :orig_method_missing, :method_missing

        def method_missing(method, *args, &block)
          if method == :cached_hash
            orig_hash = hash
            self.class.define_method(:cached_hash) do
              orig_hash
            end
          end
          orig_method_missing(method, *args, &block)
        end
      end

      def initialize(params, opts = {})

        raise Dither::Error, 't must be >= 2' if opts[:t] < 2
        raise Dither::Error, 't must be <= params.length' if opts[:t] > params.length
        params.each do |param|
          raise Dither::Error, 'param length must be > 1' if param.length < 2
        end
        @params = params
        @n = 50
        @scratch = Array.new(@n)
        seed = opts[:seed] || Random.new.seed
        @random = Random.new(seed)
        @constraints = nil
        @pair_cache = Array.new(params.length)
        params.each_with_index do |param, i|
          pair_cache[i] = (0...param.length).map { |j| Pair.new(i, j).freeze }
        end
        @comb = []
        @t = opts[:t]
        (0...params.length).to_a.combination(t).each do |a|
          car, *cdr = a.map { |b| pair_cache[b] }
          @comb.push(*car.product(*cdr).each { |b| b.extend(Pairs) })
        end
      end

      def generate
        (0...n).each do |i|
          scratch[i] = params.map { |a| random.rand(a.length) }
        end
      end

      def filter
        return unless constraints
      end

      def best_fit
        max, _ = scratch.map { |a| [a, comb.count { |b| b.in_test_case?(a) }] }
          .max { |a, b| a[1] <=> b[1] }
        comb.delete_if { |a| a.in_test_case?(max) }
        max
      end

      def stop?
        comb.empty?
      end
    end
  end
end
