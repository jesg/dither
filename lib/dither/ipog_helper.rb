# coding: utf-8

module Dither
  module IPOGHelper
    attr_reader :params, :t, :constraints, :test_set, :orig_params, :unbound_param_pool
    private :params, :t, :constraints, :test_set, :orig_params, :unbound_param_pool

    def initialize(params, opts = {})
      init_params(params)
      @t = opts[:t]
      unless opts[:constraints].nil?
        @constraints = opts[:constraints].map(&:to_a)
                       .map { |a| a.map { |b| @params[@map_to_orig_index.key(b[0])][b[1]] } }
                       .map(&:to_set)
      end

      raise Dither::Error, 't must be >= 2' if opts[:t] < 2
      raise Dither::Error, 't must be <= params.length' if opts[:t] > params.length
      params.each do |param|
        raise Dither::Error, 'param length must be > 1' if param.length < 2
      end
    end

    def init_params(user_params)
      tmp = []
      @input_params = user_params
      user_params.each_with_index { |e, i| tmp << [i, e] }
      @orig_params = tmp.sort_by { |a| a[1].length }
                     .reverse!

      @map_to_orig_index = {}
      @orig_params.each_with_index do |e, i|
        @map_to_orig_index[i] = e[0]
      end

      @params = []
      @unbound_param_pool = []
      orig_params.each_with_index do |e, i|
        @params << (0...e[1].length).map { |j| Param.new(i, j) }
        @unbound_param_pool << UnboundParam.new(i)
      end
      params
    end

    # return nil if unable to satisfy constraints
    def maximize_coverage(i, test_case, pi)
      current_max = 0
      current_max_j = 0
      current_matches = []

      (0...params[i].length).each do |j|
        current_param = params[i][j]
        test_case << current_param
        unless violates_constraints?(test_case)
          matches = pi.select { |a| a.subset?(test_case) }
          count = matches.count

          if count > current_max
            current_max = count
            current_max_j = j
            current_matches = matches
          end
        end
        test_case.delete(current_param)
      end

      return nil if violates_constraints?(test_case)
      test_case << params[i][current_max_j]

      current_matches
    end

    def violates_constraints?(params)
      return false if constraints.nil?
      constraints.any? { |b| b.subset?(params) }
    end

    private

    def comb
      ranges = (0...t).to_a.inject([]) do |a, i|
        a << (0...params[i].length).map { |j| params[i][j] }
      end

      products = ranges[1..-1].inject(ranges[0]) do |a, b|
        a = a.product(b)
      end

      result = products.map(&:flatten)
        .map { |a| TestCase.create(params, unbound_param_pool, a) }
      result
    end

    def comb_i(param_i)
      values = (0...param_i).to_a.combination((t-1)).to_a
      values.each do |a|
        a << param_i
      end
      result = []
      values.each do |a|
        result += a[1..-1]
                 .inject((0...params[a[0]].length).map { |b| params[a[0]][b] }) { |p, i| p.product((0...params[i].length).to_a.map { |c| params[i][c] }) }
                 .map(&:flatten)
                 .map { |a| TestCase.create(params, unbound_param_pool, a) }
      end
      result.to_set
    end


    def fill_unbound(data)
      arr = Array.new(params.length)
      data.each do |param|
        unless param.unbound?
          i = @map_to_orig_index[param.i]
          arr[i] = @input_params[i][param.j]
        end
      end

      arr.each_with_index do |e, i|
        next unless e.nil?

        orig_param = @input_params[i]
        (0...orig_param.length).each do |j|
          data << params[@map_to_orig_index.key(i)][j]
          if violates_constraints?(data)
            data.delete(params[@map_to_orig_index.key(i)][j])
            next
          else
            arr[i] = orig_param[j]
            break
          end
        end
        return nil if arr[i].nil?
      end

      return nil if violates_constraints?(data)

      arr
    end
  end # IPOGHelper
end # Dither
