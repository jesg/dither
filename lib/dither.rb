
require 'set'

module Dither

  def self.all_pairs(params, t = 2, opts = {})
    IPOG.new(params, t, opts).run
  end
end # Dither

require 'dither/param'
require 'dither/unbound_param'
require 'dither/test_case'
require 'dither/ipog_helper'
require 'dither/ipog'
