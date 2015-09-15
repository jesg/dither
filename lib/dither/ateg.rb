
module Dither
  module Ateg

    def run
      until stop?
        generate
        filter
        best_fit
      end
      result
    end
  end # Ateg
end # Dither
