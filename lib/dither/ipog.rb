# coding: utf-8

module Dither
  class IPOG
    include IPOGHelper

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
          if test_set.any? { |b| a.subset?(b) }
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
  end # IPOG
end # Dither
