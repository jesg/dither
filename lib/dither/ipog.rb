# coding: utf-8

module Dither
  class IPOG
    attr_reader :params, :t, :constraints, :test_set, :orig_params, :unbound_param_pool
    private :params, :t, :constraints, :test_set, :orig_params

    def initialize(params, t, opts = {})
      init_params(params)
      @t = t
      unless opts[:constraints].nil?
        @constraints = opts[:constraints].map(&:to_a)
                       .map { |a| a.map { |b| @params[@map_to_orig_index.key(b[0])][b[1]] } }
                       .map(&:to_set)
      end

      raise 't must be >= 2' if t < 2
      raise 't must be <= params.length' if t > params.length
      params.each do |param|
        raise 'param length must be > 1' if param.length < 2
      end
    end

    def init_params(user_params)
      tmp = []
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

      test_case << params[i][current_max_j]
      return nil if violates_constraints?(test_case)

      current_matches
    end

    def run
      # add into test set a test for each combination of values
      # of the first t parameter
      test_set = comb

      (t...params.length).each do |i|
        # let pi
        # be the set of t-way combinations of values involving
        # parameter Pi and t -1 parameters among the first i – 1
        # parameters
        pi = comb_i(i)

        # horizontal extension for parameter i
        test_set.each do |test_case|
          cover = maximize_coverage(i, test_case, pi)

          if cover.nil?
            test_set.delete(test_case)
          else
            pi -= cover
          end
        end

        # vertical extension for parameter i
        pi.each do |a|
          if test_set.any? { |test_case| a.subset?(test_case) }
            pi.delete(a)
          else

            test_case = nil
            test_set.each do |b|
              test_case = b.merge_without_conflict(i, a) do |a|
                violates_constraints?(a)
              end
              break unless test_case.nil?
            end

            if test_case.nil?
              test_set << a.create_unbound(i)
            end
            pi.delete(a)
          end
        end
      end

      test_set.map { |a| fill_unbound(a) }
        .delete_if(&:nil?)
        .to_a
    end

    def violates_constraints?(params)
      return false if constraints.nil?
      constraints.any? { |b| b.subset?(params) }
    end

    def comb
      ranges = (0...t).to_a.inject([]) do |a, i|
        a << (0...params[i].length).map { |j| params[i][j] }
      end

      products = ranges[1..-1].inject(ranges[0]) do |a, b|
        a = a.product(b)
      end

      products.map(&:flatten)
        .map { |a| TestCase.create(params, unbound_param_pool, a) }
    end

    def comb_i(param_i)
      values = (0...param_i).to_a.combination((t-1)).to_a
      values.each do |a|
        a << param_i
      end
      result = []
      values.each do |a|
        result += a[1..-1]
                 .inject((0...params[a[0]].length).map { |b| params[0][b] }) { |p, i| p.product((0...params[i].length).to_a.map { |b| params[i][b] }) }
                 .map(&:flatten)
                 .map { |a| TestCase.create(params, unbound_param_pool, a) }
      end
      result
    end

    private

    def fill_unbound(data)
      arr = Array.new(params.length)
      data.each do |param|
        unless param.unbound?
          orig_param = orig_params[param.i]
          arr[orig_param[0]] = orig_param[1][param.j]
        end
      end

      arr.each_with_index do |e, i|
        if e.nil?
          j = 0
          orig_param = orig_params.find { |a| a[0] = i }
          arr[i] = orig_param[1][j]
        end
      end

      return nil if violates_constraints?(data)
      arr
    end

    def find_unbound(param_array, stuff)
      data = {}
      stuff.each do |param|
        data[param.i] = param.j
      end

      unbound = []
      param_array.each do |param|
        case data[param.i]
        when param.j
        when nil
          unbound << param
        else
          unbound = nil
          break
        end
      end
      unbound
    end
  end
end
