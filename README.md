# Dither
Collection of combinatorial test generation strategies.

# Usage

```ruby
require 'dither'

# 2-way
Dither.ipog([[true, false],
             [:cat, :dog, :mouse],
             (0...3).to_a])
# 3-way
Dither.ipog([[true, false],
             [true, false],
             [:cat, :dog, :mouse],
             (0...5).to_a],
            :t => 3)

# 3-way with constraints
Dither.ipog([[true, false],
             [true, false],
             [:cat, :dog, :mouse],
             (0...5).to_a],
            :t => 3,
            :constraints => [
              { 1 => 0, 2 => 0 }, # exclude true and cat
              { 1 => 0, 2 => 1, 3 => 4 }, # exclude true :dog 4 combinations
            ])

```

# Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches

# Copyright
includes [dither-java](https://github.com/jesg/dither-java) Apache License, Version 2.0

Copyright (c) 2015 Jason Gowan See LICENSE for details.
