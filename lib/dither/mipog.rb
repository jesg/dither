# coding: utf-8

module Dither
  class MIPOG
    include Dither::IPOGHelper

    def maximize_unbound_coverage(i, test_case, pi)
      all_unbound = test_case.unbound
                    .map { |a| a.create_params(params[a.i].length) }
                    .flatten

      current_max = 0
      current_max_j = 0
      current_outer_param = all_unbound[0]
      current_matches = []

      all_unbound.each do |outer_param|
        test_case << outer_param

        (0...params[i].length).each do |j|
          current_param = params[i][j]
          test_case << current_param
          count = pi.count { |a| a.subset?(test_case) }

          if count > current_max
            current_max = count
            current_max_j = j
            current_outer_param = outer_param
          end
          test_case.delete(current_param)
        end
        test_case.delete(outer_param)
      end

      test_case << params[i][current_max_j]
      test_case << current_outer_param
      test_case.delete(unbound_param_pool[current_outer_param.i])

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
          if !test_case.contains_unbound?
            cover = maximize_coverage(i, test_case, pi)
          else
            cover = maximize_unbound_coverage(i, test_case, pi)
          end

          # remove covered combinations
          pi -= cover
        end

        # vertical extension for parameter i
        until pi.empty?
          pi.sort!
          test_case, coverage = maximize_vertical_coverage(i, pi[0].dup, pi)
          test_set << test_case.create_unbound(i)
          pi -= coverage
        end
      end
      test_set.map { |a| fill_unbound(a) }
    end

    def maximize_vertical_coverage(i, test_case, pi)
      coverage = [pi[0]]
      pi[1..-1].each do |a|
        coverage << a unless test_case.merge_without_conflict(i, a).nil?
      end
      [test_case, coverage]
    end
  end # MIPOG
end # Dither
