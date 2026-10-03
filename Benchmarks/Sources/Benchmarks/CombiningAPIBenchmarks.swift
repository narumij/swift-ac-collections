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

import CollectionsBenchmark
import RedBlackTreeModule

extension Benchmark {
  public mutating func addCombiningAPIBenchmarks() {

    // MARK: - RedBlackTreeSet: merge (O(n log(m+n))) vs formUnion (O(n+m))

    self.add(
      title: "RedBlackTreeSet<Int> merge with sorted other",
      input: Int.self
    ) { size in
      let base = RedBlackTreeSet(0..<size)
      let other = RedBlackTreeSet(size..<(2 * size))
      return { timer in
        var a = base
        timer.measure {
          a.merge(other)
        }
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> merge with shuffled other",
      input: Int.self
    ) { size in
      let base = RedBlackTreeSet(0..<size)
      let otherValues = Array(size..<(2 * size)).shuffled()
      let other = RedBlackTreeSet(otherValues)
      return { timer in
        var a = base
        timer.measure {
          a.merge(other)
        }
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> formUnion with sorted other",
      input: Int.self
    ) { size in
      let base = RedBlackTreeSet(0..<size)
      let other = RedBlackTreeSet(size..<(2 * size))
      return { timer in
        var a = base
        timer.measure {
          a.formUnion(identity(other))
        }
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> formUnion with shuffled other",
      input: Int.self
    ) { size in
      let base = RedBlackTreeSet(0..<size)
      let otherValues = Array(size..<(2 * size)).shuffled()
      let other = RedBlackTreeSet(otherValues)
      return { timer in
        var a = base
        timer.measure {
          a.formUnion(identity(other))
        }
        blackHole(a)
      }
    }

    // Duplicate-heavy: other overlaps 90% with base.
    self.add(
      title: "RedBlackTreeSet<Int> merge with duplicate-heavy other",
      input: Int.self
    ) { size in
      let base = RedBlackTreeSet(0..<size)
      let start = size / 10
      let other = RedBlackTreeSet(start..<(start + size))
      return { timer in
        var a = base
        timer.measure {
          a.merge(other)
        }
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> formUnion with duplicate-heavy other",
      input: Int.self
    ) { size in
      let base = RedBlackTreeSet(0..<size)
      let start = size / 10
      let other = RedBlackTreeSet(start..<(start + size))
      return { timer in
        var a = base
        timer.measure {
          a.formUnion(identity(other))
        }
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
        blackHole(a)
        blackHole(copy)
      }
    }

    // MARK: - RedBlackTreeMultiSet: insert(contentsOf:) vs meld

    self.add(
      title: "RedBlackTreeMultiSet<Int> insert(contentsOf:) with sorted other",
      input: Int.self
    ) { size in
      let base = RedBlackTreeMultiSet(0..<size)
      let other = RedBlackTreeMultiSet(size..<(2 * size))
      return { timer in
        var a = base
        timer.measure {
          a.insert(contentsOf: other)
        }
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeMultiSet<Int> insert(contentsOf:) with shuffled other",
      input: Int.self
    ) { size in
      let base = RedBlackTreeMultiSet(0..<size)
      let otherValues = Array(size..<(2 * size)).shuffled()
      let other = RedBlackTreeMultiSet(otherValues)
      return { timer in
        var a = base
        timer.measure {
          a.insert(contentsOf: other)
        }
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeMultiSet<Int> meld with sorted other",
      input: Int.self
    ) { size in
      let base = RedBlackTreeMultiSet(0..<size)
      let other = RedBlackTreeMultiSet(size..<(2 * size))
      return { timer in
        var a = base
        timer.measure {
          a.meld(identity(other))
        }
        blackHole(a)
      }
    }

    self.add(
      title: "RedBlackTreeMultiSet<Int> meld with shuffled other",
      input: Int.self
    ) { size in
      let base = RedBlackTreeMultiSet(0..<size)
      let otherValues = Array(size..<(2 * size)).shuffled()
      let other = RedBlackTreeMultiSet(otherValues)
      return { timer in
        var a = base
        timer.measure {
          a.meld(identity(other))
        }
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
        blackHole(a)
      }
    }
  }
}
