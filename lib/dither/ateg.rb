
module Dither
  module Ateg

    def run
      result = []
      until stop?
        generate
        filter
        result << best_fit
      end
      result
    end
  end # Ateg
end # Dither
