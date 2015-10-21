
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

  def self.aetg(params, opts = {})
    opts = DEFUALT_OPTS.dup.merge(opts)
    Aetg::Pairwise.new(params, opts).run
  end

  class << self; alias_method :ateg, :aetg end
end # Dither

require 'dither/param'
require 'dither/unbound_param'
require 'dither/test_case'
require 'dither/ipog_helper'
require 'dither/ipog'
require 'dither/mipog'
require 'dither/chinese_postman_problem'
require 'dither/aetg'
require 'dither/aetg_pairwise'
require 'dither/graph'

if RUBY_PLATFORM =~ /java/
  require 'java'
  require 'choco-solver-3.3.1-with-dependencies.jar'
  require 'dither-0.1.3.jar'

  require 'dither/java_ext/dither'
end
