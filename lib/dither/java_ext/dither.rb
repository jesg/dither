
module Dither

  def self.ipog(params, opts = {})
    opts = DEFUALT_OPTS.dup.merge(opts)
    constraints = constraints_to_java(params.length, opts[:constraints])
    com.github.jesg.dither.Dither.ipog(
      opts[:t].to_java(:int),
      params.map(&:to_java).to_java,
      constraints).to_a
  rescue com.github.jesg.dither.DitherError => e
    raise Dither::Error.new(e.message)
  end

  private

  def self.constraints_to_java(param_length, constraints)
    return [].to_java if constraints.nil?
    result = []
    constraints.each do |constraint|
      new_constraint = Array.new(param_length)
      constraint.each do |k, v|
        new_constraint[k] = v
      end
      result << new_constraint
    end
    result.map { |a| a.to_java(java.lang.Integer) }.to_java
  end
end
