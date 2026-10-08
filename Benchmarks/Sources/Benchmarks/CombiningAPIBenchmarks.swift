//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

// Added for Maintanance/CLAUDE_TASK.md Task 2 (Combining API evidence gap).
// Compares the insertion-loop path (merge / insert(contentsOf:)) against the
// linear meld path (formUnion / meld) across sorted vs shuffled other,
// unique vs duplicate-heavy other, reserved vs unreserved destination
// capacity, and unique vs shared destination storage.
//
// Methodology (see Maintanance/Archived/CombiningAPIPerformanceEvidence.md):
// - The outer closure runs once per size; the inner closure runs once per
//   sample and only `timer.measure` is timed. Every sample therefore builds a
//   fresh destination (outside the timed region) so that no sample starts
//   from a destination that already contains `other`, and so that the
//   destination does not silently share storage with a captured value.
//   Only the "shared storage" cases share storage, intentionally.
// - Shuffled inputs use a fixed-seed generator so runs are reproducible.
// - The final state is validated after the timed region.

import CollectionsBenchmark
import RedBlackTreeModule

/// SplitMix64. Deterministic generator for reproducible shuffled inputs.
private struct CombiningBenchmarkRNG: RandomNumberGenerator {
  var state: UInt64

  init(seed: UInt64) { state = seed }

  mutating func next() -> UInt64 {
    state &+= 0x9E37_79B9_7F4A_7C15
    var z = state
    z = (z ^ (z &>> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z &>> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z &>> 31)
  }
}

private func seededShuffled(_ range: Range<Int>) -> [Int] {
  var rng = CombiningBenchmarkRNG(seed: 0x5EED_0000 &+ UInt64(range.count))
  return Array(range).shuffled(using: &rng)
}

/// Validates the final state outside the timed region.
private func validate(
  _ result: RedBlackTreeSet<Int>, count: Int, first: Int, last: Int
) {
  precondition(
    result.count == count && result.first == first && result.last == last,
    "Combining benchmark produced an unexpected final state")
}

private func validate(
  _ result: RedBlackTreeMultiSet<Int>, count: Int, first: Int, last: Int
) {
  precondition(
    result.count == count && result.first == first && result.last == last,
    "Combining benchmark produced an unexpected final state")
}

extension Benchmark {
  public mutating func addCombiningAPIBenchmarks() {

    // MARK: - RedBlackTreeSet: merge (O(n log(m+n))) vs formUnion (O(n+m))

    self.add(
      title: "RedBlackTreeSet<Int> merge with sorted other",
      input: Int.self
    ) { size in
      let other = RedBlackTreeSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        timer.measure {
          a.merge(other)
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> merge with shuffled other",
      input: Int.self
    ) { size in
      let other = RedBlackTreeSet(seededShuffled(size..<(2 * size)))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        timer.measure {
          a.merge(other)
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> formUnion with sorted other",
      input: Int.self
    ) { size in
      let other = RedBlackTreeSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        timer.measure {
          a.formUnion(identity(other))
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> formUnion with shuffled other",
      input: Int.self
    ) { size in
      let other = RedBlackTreeSet(seededShuffled(size..<(2 * size)))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        timer.measure {
          a.formUnion(identity(other))
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    // Duplicate-heavy: other overlaps 90% with base.
    self.add(
      title: "RedBlackTreeSet<Int> merge with duplicate-heavy other",
      input: Int.self
    ) { size in
      let start = size / 10
      let other = RedBlackTreeSet(start..<(start + size))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        timer.measure {
          a.merge(other)
        }
        validate(a, count: start + size, first: 0, last: start + size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> formUnion with duplicate-heavy other",
      input: Int.self
    ) { size in
      let start = size / 10
      let other = RedBlackTreeSet(start..<(start + size))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        timer.measure {
          a.formUnion(identity(other))
        }
        validate(a, count: start + size, first: 0, last: start + size - 1)
        blackHole(a)
      }
    }

    // Reserved vs unreserved destination capacity, same sorted other for both.
    self.add(
      title: "RedBlackTreeSet<Int> merge, unreserved capacity",
      input: Int.self
    ) { size in
      let other = RedBlackTreeSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        timer.measure {
          a.merge(other)
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> merge, reserving capacity",
      input: Int.self
    ) { size in
      let other = RedBlackTreeSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        a.reserveCapacity(2 * size)
        timer.measure {
          a.merge(other)
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> formUnion, unreserved capacity",
      input: Int.self
    ) { size in
      let other = RedBlackTreeSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        timer.measure {
          a.formUnion(identity(other))
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> formUnion, reserving capacity",
      input: Int.self
    ) { size in
      let other = RedBlackTreeSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        a.reserveCapacity(2 * size)
        timer.measure {
          a.formUnion(identity(other))
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    // Unique vs shared destination storage (forces CoW before the operation).
    self.add(
      title: "RedBlackTreeSet<Int> merge, unique storage",
      input: Int.self
    ) { size in
      let other = RedBlackTreeSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        timer.measure {
          a.merge(other)
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> merge, shared storage",
      input: Int.self
    ) { size in
      let other = RedBlackTreeSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        let copy = a
        timer.measure {
          a.merge(other)
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        validate(copy, count: size, first: 0, last: size - 1)
        blackHole(a)
        blackHole(copy)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> formUnion, unique storage",
      input: Int.self
    ) { size in
      let other = RedBlackTreeSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        timer.measure {
          a.formUnion(identity(other))
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> formUnion, shared storage",
      input: Int.self
    ) { size in
      let other = RedBlackTreeSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeSet(0..<size)
        let copy = a
        timer.measure {
          a.formUnion(identity(other))
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        validate(copy, count: size, first: 0, last: size - 1)
        blackHole(a)
        blackHole(copy)
      }
    }

    // MARK: - RedBlackTreeMultiSet: insert(contentsOf:) vs meld

    self.add(
      title: "RedBlackTreeMultiSet<Int> insert(contentsOf:) with sorted other",
      input: Int.self
    ) { size in
      let other = RedBlackTreeMultiSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeMultiSet(0..<size)
        timer.measure {
          a.insert(contentsOf: other)
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeMultiSet<Int> insert(contentsOf:) with shuffled other",
      input: Int.self
    ) { size in
      let other = RedBlackTreeMultiSet(seededShuffled(size..<(2 * size)))
      return { timer in
        var a = RedBlackTreeMultiSet(0..<size)
        timer.measure {
          a.insert(contentsOf: other)
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeMultiSet<Int> meld with sorted other",
      input: Int.self
    ) { size in
      let other = RedBlackTreeMultiSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeMultiSet(0..<size)
        timer.measure {
          a.meld(identity(other))
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeMultiSet<Int> meld with shuffled other",
      input: Int.self
    ) { size in
      let other = RedBlackTreeMultiSet(seededShuffled(size..<(2 * size)))
      return { timer in
        var a = RedBlackTreeMultiSet(0..<size)
        timer.measure {
          a.meld(identity(other))
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeMultiSet<Int> insert(contentsOf:), unreserved capacity",
      input: Int.self
    ) { size in
      let other = RedBlackTreeMultiSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeMultiSet(0..<size)
        timer.measure {
          a.insert(contentsOf: other)
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeMultiSet<Int> insert(contentsOf:), reserving capacity",
      input: Int.self
    ) { size in
      let other = RedBlackTreeMultiSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeMultiSet(0..<size)
        a.reserveCapacity(2 * size)
        timer.measure {
          a.insert(contentsOf: other)
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeMultiSet<Int> meld, unreserved capacity",
      input: Int.self
    ) { size in
      let other = RedBlackTreeMultiSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeMultiSet(0..<size)
        timer.measure {
          a.meld(identity(other))
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeMultiSet<Int> meld, reserving capacity",
      input: Int.self
    ) { size in
      let other = RedBlackTreeMultiSet(size..<(2 * size))
      return { timer in
        var a = RedBlackTreeMultiSet(0..<size)
        a.reserveCapacity(2 * size)
        timer.measure {
          a.meld(identity(other))
        }
        validate(a, count: 2 * size, first: 0, last: 2 * size - 1)
        blackHole(a)
      }
    }
  }
}
