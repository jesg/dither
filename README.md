# Dither
Collection of combinatorial test generation strategies.

# Usage

Use 2-Way IPOG
```ruby
require 'dither'

results = Dither.all_pairs([[true, false],
                            [:cat, :dog, :mouse],
                            (0...3).to_a])

results.each { |a| puts "#{a}" }

# output
[true,  :cat, 0]
[true,  :dog, 1]
[true,  :mouse, 2]
[false, :cat, 0]
[false, :dog, 1]
[false, :mouse, 2]
[true,  :cat, 0]
[true,  :dog, 1]
[true,  :mouse, 2]
```

Use 3-Way IPOG
```ruby
require 'dither'
results = Dither.all_pairs([[true, false],
                            [true, false],
                            [:cat, :dog, :mouse],
                            (0...5).to_a], 3)

results.each { |a| puts "#{a}" }

# output
[true, true, :cat, 0]
...
```

# Copyright
Copyright (c) 2015 Jason Gowan See LICENSE for details.
