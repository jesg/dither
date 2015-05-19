
module Dither
  UnboundParam = Struct.new(:i) do
    def <=>(param)
      return -1 unless param.unbound?
      i <=> param.i
    end

    def unbound?
      true
    end

    def create_params(j)
      (0...j).map { |a| Param.new(i, a) }
    end
  end # UnboundParam
end # Dither
