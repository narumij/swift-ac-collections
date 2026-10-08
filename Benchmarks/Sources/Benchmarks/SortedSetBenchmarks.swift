//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2021 - 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
//
//===----------------------------------------------------------------------===//

import CollectionsBenchmark
import SortedCollections

extension Benchmark {
  public mutating func addSortedSetBenchmarks() {
    self.addSimple(
      title: "SortedSet<Int> init from range",
      input: Int.self
    ) { size in
      blackHole(SortedSet(0..<size))
    }

    self.addSimple(
      title: "SortedSet<Int> init from unsafe buffer",
      input: [Int].self
    ) { input in
      input.withUnsafeBufferPointer { buffer in
        blackHole(SortedSet(buffer))
      }
    }

    self.add(
      title: "SortedSet<Int> sequential iteration",
      input: Int.self
    ) { size in
      let set = SortedSet(0..<size)
      return { timer in
        for element in set {
          blackHole(element)
        }
      }
    }

    self.add(
      title: "SortedSet<Int> successful find",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let set = SortedSet(input)
      return { timer in
        for element in lookups {
          precondition(set.index(of: element) != nil)
        }
      }
    }

    self.add(
      title: "SortedSet<Int> unsuccessful find",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let set = SortedSet(input)
      let lookups = lookups.map { $0 + input.count }
      return { timer in
        for element in lookups {
          precondition(set.index(of: element) == nil)
        }
      }
    }

    self.add(
      title: "SortedSet<Int> remove",
      input: ([Int], [Int]).self
    ) { input, removals in
      return { timer in
        var set = SortedSet(input)
        timer.measure {
          for element in removals {
            set.remove(element)
          }
        }
        precondition(set.isEmpty)
        blackHole(set)
      }
    }

    self.add(
      title: "SortedSet<Int> successful contains",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let set = SortedSet(input)
      return { timer in
        for element in lookups {
          precondition(set.contains(element))
        }
      }
    }

    self.add(
      title: "SortedSet<Int> unsuccessful contains",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let set = SortedSet(input)
      let lookups = lookups.map { $0 + input.count }
      return { timer in
        for element in lookups {
          precondition(!set.contains(element))
        }
      }
    }
  }
}
