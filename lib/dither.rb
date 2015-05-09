
require 'set'

module Dither

  def self.all_pairs(params, t = 2)
    IPOG.new(params, t).run
  end
end

require 'dither/param'
require 'dither/ipog'
