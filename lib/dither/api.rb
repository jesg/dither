
require 'ffi'

# Interface to the c++ api.
module Dither
  module API
    extend FFI::Library
    LIB_DIR = File.expand_path('../..', __FILE__)
    ffi_lib %W[#{LIB_DIR}/dither.so #{LIB_DIR}/dither.dll]

    attach_function :dither_ipog_new, [:int], :pointer
    attach_function :dither_ipog_add_parameter_int, [:pointer, :int, :pointer, :int], :void
    attach_function :dither_ipog_run, [:pointer], :void
    attach_function :dither_ipog_size, [:pointer], :int
    attach_function :dither_ipog_display_raw_solution, [:pointer], :void
    attach_function :dither_ipog_fill, [:pointer, :pointer], :void
    attach_function :dither_ipog_add_constraint, [:pointer, :pointer, :int], :void
    attach_function :dither_ipog_add_previously_tested, [:pointer, :pointer, :int], :void
    # attach_function :dither_ipog_delete, [:pointer], :void
  end
end
