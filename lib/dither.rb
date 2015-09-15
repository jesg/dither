
require 'set'

module Dither

  class Error < StandardError; end

  DEFUALT_OPTS = {
    :t => 2
  }

  # deprecated
  def self.all_pairs(params, t = 2, opts = {})
    opts[:t] = t
    IPOG.new(params, opts).run
  end

  def self.ipog(params, opts = {})
    opts = DEFUALT_OPTS.dup.merge(opts)
    IPOG.new(params, opts).run
  end

  def self.mipog(params, t = 2, opts = {})
    raise Error, 'mipog does not support constraints' if opts.key?(:constraints)
    opts[:t] = t
    MIPOG.new(params, opts).run
  end
end # Dither

require 'dither/param'
require 'dither/unbound_param'
require 'dither/test_case'
require 'dither/ipog_helper'
require 'dither/ipog'
require 'dither/mipog'
require 'dither/chinese_postman_problem'
require 'dither/ateg'

if RUBY_PLATFORM =~ /java/
  require 'java'
  require 'dither.jar'

  require 'dither/java_ext/dither'
end
