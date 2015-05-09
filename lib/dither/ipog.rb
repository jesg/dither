
module Dither
  class IPOG
    attr_reader :params, :t, :prng
    private :params, :t, :prng

    def initialize(params, t)
      @params = params
      @t = t
      @prng = Random.new
      raise 't must be >= 2' if t < 2
      raise 't must be <= params.length' if t > params.length
      params.each do |param|
        raise 'param length must be > 1' if param.length < 2
      end
    end

    def run
      ts = comb((0...t))
      (t...params.length).each do |i|
        ts = ts.zip(params[i].cycle).map { |a| a[0] << Param.new(i, a[1]) }

        comb_i(i).each do |a|
          in_ts = ts.any? { |test| a.subset?(test) }

          next if in_ts
          existing_test = false
          ts.select { |c| c.length <= i }
            .each do |b|

            unbound = find_unbound(a, b)

            if unbound
              unbound.each { |c| b << c }
              existing_test = true
              break
            end
          end

          ts << a unless existing_test
        end
      end

      ts.map { |a| fill_unbound(a) }
    end

    def comb(range)
      range.to_a.combination(t).to_a.inject([]) do |result, a|
        result + a[1..-1]
                 .inject((0...params[a[0]].length).map { |b| Param.new(0, b) }) { |p, i| p.product((0...params[i].length).to_a.map { |b| Param.new(i, b) }) }
                 .map(&:flatten)
                 .map(&:to_set)
      end
    end

    def comb_i(param_i)
      values = (0...param_i).to_a.combination((t-1)).to_a
      values.each do |a|
        a << param_i
      end
      result = []
      values.each do |a|
        result += a[1..-1]
                 .inject((0...params[a[0]].length).map { |b| Param.new(0, b) }) { |p, i| p.product((0...params[i].length).to_a.map { |b| Param.new(i, b) }) }
                 .map(&:flatten)
                 .map(&:to_set)
      end
      result
    end

    private

    def fill_unbound(data)
      arr = Array.new(params.length)
      data.each do |param|
        arr[param.i] = params[param.i][param.j]
      end

      arr.each_with_index do |e, i|
        arr[i] = params[i][prng.rand(0...params[i].length)] if e.nil?
      end
      arr
    end

    def find_unbound(param_array, stuff)
      data = {}
      stuff.each do |param|
        data[param.i] = param.j
      end

      unbound = []
      param_array.each do |param|
        case data[param.i]
        when param.j
        when nil
          unbound << param
        else
          unbound = nil
          break
        end
      end
      unbound
    end
  end
end
