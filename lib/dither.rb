
require 'set'

module Dither

  class Error < StandardError; end

  def self.all_pairs(params, t = 2, opts = {})
    IPOG.new(params, t, opts).run
  end

  def self.mipog(params, t = 2, opts = {})
    raise Error, 'mipog does not support constraints' if opts.key?(:constraints)
    MIPOG.new(params, t, opts).run
  end
end # Dither

require 'dither/param'
require 'dither/unbound_param'
require 'dither/test_case'
require 'dither/ipog_helper'
require 'dither/ipog'
require 'dither/mipog'

if RUBY_PLATFORM =~ /java/
  require 'java'
  require 'dither.jar'

  require 'dither/java_ext/dither'
end
