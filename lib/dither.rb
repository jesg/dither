
require 'set'

module Dither

  def self.all_pairs(params, t = 2, opts = {})
    IPOG.new(params, t, opts).run
  end
end

require 'dither/param'
require 'dither/ipog'
