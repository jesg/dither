
require 'set'

module Dither

  class Error < StandardError; end

  def self.all_pairs(params, t = 2, opts = {})
    IPOG.new(params, t, opts).run
  end

  def self.mipog(params, t = 2, opts = {})
    MIPOG.new(params, t, opts).run
  end
end # Dither

require 'dither/param'
require 'dither/unbound_param'
require 'dither/test_case'
require 'dither/ipog_helper'
require 'dither/ipog'
require 'dither/mipog'
