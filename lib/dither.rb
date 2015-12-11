
require 'set'

module Dither

  class Error < StandardError; end

  DEFUALT_OPTS = {
    :t => 2
  }

  # deprecated
  def self.all_pairs(params, t = 2, opts = {})
    opts[:t] = t
    ipog(params, opts)
  end

  def self.ipog(params, opts = {})
    opts = DEFUALT_OPTS.dup.merge(opts)
    t = opts[:t] || 2
    if t < 2
      raise Dither::Error,'t must be >= 2'
    end
    raise Dither::Error, 'param length must be > 1' if params.any? { |a| a.size <= 1 }
    if t > params.size
      raise Dither::Error, 't must be <= params.length'
    end

    pointer = Dither::API.dither_ipog_new(t)
    c_params = (0..params.max { |a| a.size }.size).to_a
    c_int_params = FFI::MemoryPointer.new(:int, c_params.size)
    c_int_params.write_array_of_int(c_params)

    params.each_with_index do |param, i|
      Dither::API.dither_ipog_add_parameter_int(pointer, i, c_int_params, param.size)
    end

    if opts[:constraints]
      constraint_scratch = FFI::MemoryPointer.new(:int, params.size)
      opts[:constraints].each do |constraint|
        arr = Array.new(params.size, -1)
        constraint.each do |k, v|
          if k >= params.size
            raise Dither::Error, "Invalid constraint #{k} > #{params.size}"
          end
          if v >= params[k].size
            raise Dither::Error, "Invalid constraint #{k} > #{params[k].size}"

          end
          arr[k] = v
        end
        constraint_scratch.write_array_of_int(arr)
        Dither::API.dither_ipog_add_constraint(pointer, constraint_scratch, params.size)
      end
    end

    if opts[:previously_tested]
      tested_scratch = FFI::MemoryPointer.new(:int, params.size)
      opts[:previously_tested].each do |test_case|
        if test_case.size != params.size
          raise Dither::Error
        end
        arr = Array.new(params.size)
        (0...params.size).each do |i|
          arr[i] = params[i].find_index(test_case[i])
        end
        tested_scratch.write_array_of_int(arr)
        Dither::API.dither_ipog_add_previously_tested(pointer, tested_scratch, params.size)
      end
    end

    Dither::API.dither_ipog_run(pointer)
    result_size = Dither::API.dither_ipog_size(pointer)
    solution = FFI::MemoryPointer.new(:int, params.size * result_size)
    Dither::API.dither_ipog_fill(pointer, solution)

    results = solution.read_array_of_int(params.size * result_size)
      .enum_for(:each_slice, params.size)
      .map do |test_case|
      test_case.zip(params).map { |a, b| b[a] }
    end
  end

  def self.aetg(params, opts = {})
    opts = DEFUALT_OPTS.dup.merge(opts)
    Aetg::Pairwise.new(params, opts).run
  end

  class << self; alias_method :ateg, :aetg end
end # Dither

require 'dither/chinese_postman_problem'
require 'dither/aetg'
require 'dither/aetg_pairwise'
require 'dither/graph'

if RUBY_PLATFORM =~ /java/
  require 'java'
  require 'choco-solver-3.3.1-with-dependencies.jar'
  require 'dither-0.1.4.jar'

  require 'dither/java_ext/dither'
else
  require 'dither/api'
end
