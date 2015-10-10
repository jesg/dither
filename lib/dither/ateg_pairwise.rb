
module Dither
  module Aetg
    class Pairwise
      include Aetg

      attr_reader :scratch, :n, :random, :t, :params, :constraints, :pair_cache, :comb

      Pair = Struct.new(:i, :j)

      module Pairs

        def in_test_case?(test_case)
          self.all? { |pair| pair.j == test_case[pair.i] }
        end
      end # Pairs

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

        @pair_cache = Array.new(params.length)
        params.each_with_index do |param, i|
          pair_cache[i] = (0...param.length).map { |j| Pair.new(i, j).freeze }
        end
        if opts[:previously_tested]
          opts[:constraints] = [] unless opts[:constraints]
          opts[:previously_tested].each do |a|
            arr = []
            a.each_with_index { |b,i| arr << [i, b] }
            opts[:constraints] << Hash[arr]
          end
        end
        @constraints = nil
        if opts[:constraints]
          @constraints = []
          opts[:constraints].each do |a|
            constraint = a.map { |k, v| pair_cache[k][v] }
            constraint.extend(Pairs)
            @constraints << constraint
          end
        end
        @comb = []
        @t = opts[:t]
        (0...params.length).to_a.combination(t).each do |a|
          car, *cdr = a.map { |b| pair_cache[b] }
          tmp = car.product(*cdr)
          tmp.each { |b| b.extend(Pairs) }
          tmp.reject! { |b| constraints.any? { |c| c.all? { |d| b.include?(d)} } } if constraints
          @comb.push(*tmp)
        end
      end

      def generate
        (0...n).each do |i|
          scratch[i] = params.map { |a| random.rand(a.length) }
        end
      end

      def filter
        return unless constraints
        scratch.each_with_index do |e, i|
          scratch[i] = nil if constraints.any? { |a| a.in_test_case?(e) }
        end
      end

      def best_fit
        max, _ = scratch.compact
          .map { |a| [a, comb.count { |b| b.in_test_case?(a) }] }
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
