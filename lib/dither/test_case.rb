
module Dither
  class TestCase < Set

    attr_accessor :bound_param_pool, :unbound_param_pool

    def self.create(bound_param_pool, unbound_param_pool, params)
      test_case = TestCase.new(params)
      test_case.bound_param_pool = bound_param_pool
      test_case.unbound_param_pool = unbound_param_pool
      test_case
    end

    def contains_unbound?
      self.any?(&:unbound?)
    end

    def unbound
      self.select(&:unbound?)
    end

    def <=>(test_case)
      result = 0
      l = length <= test_case.length ? length : test_case.length
      self.zip(test_case)[0...l].each do |arr|
        first, second = arr
        result = first <=> second
        break if result != 0
      end
      result
    end

    def create_unbound(i)
      bound_params = self.reject(&:unbound?).map(&:i)
      ((0..i).to_a - bound_params).each do |a|
        self << unbound_param_pool[a]
      end
      self
    end

    def to_ipog_array(i)
      arr = Array.new(i)
      self.each do |param|
        arr[param.i] = param.j unless param.unbound?
      end
      arr
    end

    def self.from_array(arr)
      test_case = TestCase.new
      arr.each_with_index do |i, e|
        if e.nil?
          test_case << unbound_param_pool[i]
        else
          test_case << bound_param_pool[i][e]
        end
      end
      test_case
    end

    # return nil if there is a conflict
    # return self if no conflict
    def merge_without_conflict(i, test_case, &block)
      new_elements = []
      self.to_ipog_array(i).zip(test_case.to_ipog_array(i))
        .each_with_index do |arr, a|
        first, second = arr

        next if (first == second) || second.nil?
        if first.nil? && second.nil?
          new_elements << unbound_param_pool[a]
        elsif first.nil?
          new_elements << bound_param_pool[a][second]
        else
          return nil
        end
      end

      new_self = self.clone
      new_elements.each { |a| new_self << a }

      return nil if block_given? && block.call(new_self)
      new_self
    end
  end # TestCase
end # Dither
