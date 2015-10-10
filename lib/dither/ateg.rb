
module Dither
  module Aetg

    def run
      result = []
      until stop?
        generate
        filter
        result << best_fit
      end
      result
    end
  end # Aetg
end # Dither
