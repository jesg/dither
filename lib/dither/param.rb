
module Dither
  Param = Struct.new(:i, :j) do
    def <=>(param)
      return 1 if param.unbound?

      a = i <=> param.i
      if a == 0
        return j <=> param.j
      else
        return a
      end
    end

    def unbound?
      false
    end
  end # Param
end # Dither
