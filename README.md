# Dither
Collection of combinatorial test generation strategies.

# Requirements
a c++ compiler is required when installing on mri.  tested on gcc 4.6 and gcc 5.3.

# Usage

## Pairwise Testing
IPOG (In-Parameter-Order-General) is an efficient deterministic alogrithm.
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

# 3-way with constraints and previously tested cases
Dither.ipog([[true, false],
             [true, false],
             [:cat, :dog, :mouse],
             (0...5).to_a],
            :t => 3,
            :constraints => [
              { 1 => 0, 2 => 0 }, # exclude true and cat
              { 1 => 0, 2 => 1, 3 => 4 }, # exclude true :dog 4 combinations
            ],
			:previously_tested => [[true, true, :cat, 0]])

```

AETG non-deterministic alogrithm for pairwise testing.
```ruby
require 'dither'

# 2-way
Dither.aetg([[true, false],
             [:cat, :dog, :mouse],
             (0...3).to_a])

# 3-way
Dither.aetg([[true, false],
             [true, false],
             [:cat, :dog, :mouse],
             (0...5).to_a],
            :t => 3,
            :seed => 0, # set the seed on the random number generator
            :constraints => [
              { 1 => 0, 2 => 0 }, # exclude true and cat
              { 1 => 0, 2 => 1, 3 => 4 }, # exclude true :dog 4 combinations
            ],
			:previously_tested => [[true, true, :cat, 0]])
```

## Graph Models (Experimental)
```ruby
raw_graph = {
      :origin => 0,
      :edges => [
        {
          :name => :a,
          :src_vertex => 0,
          :dst_vertex => 1,
        },
        {
          :name => :b,
          :src_vertex => 0,
          :dst_vertex => 2,
        },
        {
          :name => :c,
          :src_vertex => 1,
          :dst_vertex => 2,
        },
        {
          :name => :d,
          :src_vertex => 1,
          :dst_vertex => 3,
        },
        {
          :name => :e,
          :src_vertex => 2,
          :dst_vertex => 3,
        },
        {
          :name => :f,
          :src_vertex => 3,
          :dst_vertex => 0,
        }
      ]
    }

# shortest path to cover all edges at least once
Dither.all_edges(raw_graph)
```

Random walk on a graph.  Each edge has equal weight.
```ruby
raw_graph = {
      :origin => 0,
      :edges => [
        {
          :name => :a,
          :src_vertex => 0,
          :dst_vertex => 1,
        },
        {
          :name => :b,
          :src_vertex => 0,
          :dst_vertex => 2,
        },
        {
          :name => :c,
          :src_vertex => 1,
          :dst_vertex => 2,
        },
        {
          :name => :d,
          :src_vertex => 1,
          :dst_vertex => 3,
        },
        {
          :name => :e,
          :src_vertex => 2,
          :dst_vertex => 3,
        },
        {
          :name => :f,
          :src_vertex => 3,
          :dst_vertex => 0,
        }
      ]
    }

graph = Dither::Graph.create(raw_graph)

# infinite sequence of random walks
graph.each do |path|
  puts path.map(&:name).to_s
end
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
