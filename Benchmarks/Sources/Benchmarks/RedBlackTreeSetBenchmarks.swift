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

// modified by narumij

import CollectionsBenchmark
import RedBlackTreeModule

extension Benchmark {
  public mutating func addRedBlackTreeSetBenchmarks() {

    self.addSimple(
      title: "RedBlackTreeSet<Int> init from range",
      input: Int.self
    ) { size in
      blackHole(RedBlackTreeSet(0..<size))
    }

    self.addSimple(
      title: "RedBlackTreeSet<Int> init from unsafe buffer",
      input: [Int].self
    ) { input in
      input.withUnsafeBufferPointer { buffer in
        blackHole(RedBlackTreeSet(buffer))
      }
    }
    
    self.addSimple(
      title: "RedBlackTreeSet<Int> init from sorted",
      input: [Int].self
    ) { input in
      input.withUnsafeBufferPointer { buffer in
        blackHole(RedBlackTreeSet(buffer.sorted()))
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> sequential iteration",
      input: Int.self
    ) { size in
      let set = RedBlackTreeSet(0..<size)
      return { timer in
        for i in set {
          blackHole(i)
        }
      }
    }

    #if false
      self.add(
        title: "RedBlackTreeSet<Int> sequential iteration, indices",
        input: Int.self
      ) { size in
        let set = RedBlackTreeSet(0..<size)
        return { timer in
          for i in set.indices {
            blackHole(set[i])
          }
        }
      }
    #endif

    self.add(
      title: "RedBlackTreeSet<Int> successful contains",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let set = RedBlackTreeSet(input)
      return { timer in
        for i in lookups {
          precondition(set.contains(i))
        }
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> unsuccessful contains",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let set = RedBlackTreeSet(input)
      let lookups = lookups.map { $0 + input.count }
      return { timer in
        for i in lookups {
          precondition(!set.contains(i))
        }
      }
    }

    self.addSimple(
      title: "RedBlackTreeSet<Int> insert",
      input: [Int].self
    ) { input in
      var set: RedBlackTreeSet<Int> = []
      for i in input {
        set.insert(i)
      }
      precondition(set.count == input.count)
      blackHole(set)
    }

    self.addSimple(
      title: "RedBlackTreeSet<Int> insert, reserving capacity",
      input: [Int].self
    ) { input in
      var set: RedBlackTreeSet<Int> = []
      set.reserveCapacity(input.count)
      for i in input {
        set.insert(i)
      }
      precondition(set.count == input.count)
      blackHole(set)
    }

    self.addSimple(
      title: "RedBlackTreeSet<Int> insert, shared",
      input: [Int].self
    ) { input in
      var set: RedBlackTreeSet<Int> = []
      for i in input {
        let copy = set
        set.insert(i)
        blackHole(copy)
      }
      precondition(set.count == input.count)
      blackHole(set)
    }

    self.add(
      title: "RedBlackTreeSet<Int> insert one + subtract, shared",
      input: [Int].self
    ) { input in
      let original = RedBlackTreeSet(input)
      let newMember = input.count
      return { timer in
        var copy = original
        copy.insert(newMember)
        let diff = copy.subtracting(original)
        precondition(diff.count == 1 && diff.first == newMember)
        blackHole(copy)
      }
    }

    self.addSimple(
      title: "RedBlackTreeSet<Int> model diffing",
      input: Int.self
    ) { input in
      typealias Model = RedBlackTreeSet<Int>

      var _state: Model = []  // Private
      func updateState(
        with model: Model
      ) -> (insertions: Model, removals: Model) {
        let insertions = model.subtracting(_state)
        let removals = _state.subtracting(model)
        _state = model
        return (insertions, removals)
      }

      var model: Model = []
      for i in 0..<input {
        model.insert(i)
        let r = updateState(with: model)
        precondition(r.insertions.count == 1 && r.removals.count == 0)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> remove",
      input: ([Int], [Int]).self
    ) { input, removals in
      return { timer in
        var set = RedBlackTreeSet(input)
        for i in removals {
          set.remove(i)
        }
        precondition(set.isEmpty)
        blackHole(set)
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> remove, shared",
      input: ([Int], [Int]).self
    ) { input, removals in
      return { timer in
        var set = RedBlackTreeSet(input)
        for i in removals {
          let copy = set
          set.remove(i)
          blackHole(copy)
        }
        precondition(set.isEmpty)
        blackHole(set)
      }
    }

    let overlaps: [(String, (Int) -> Int)] = [
      ("0%", { c in c }),
      ("25%", { c in 3 * c / 4 }),
      ("50%", { c in c / 2 }),
      ("75%", { c in c / 4 }),
      ("100%", { c in 0 }),
    ]

    // RedBlackTreeSetAlgebra operations with Self
    do {
      for (percentage, start) in overlaps {
        self.add(
          title: "RedBlackTreeSet<Int> union with Self (\(percentage) overlap)",
          input: [Int].self
        ) { input in
          let start = start(input.count)
          let a = RedBlackTreeSet(input)
          let b = RedBlackTreeSet(start..<start + input.count)
          return { timer in
            blackHole(a.union(identity(b)))
          }
        }
      }

      for (percentage, start) in overlaps {
        self.add(
          title: "RedBlackTreeSet<Int> intersection with Self (\(percentage) overlap)",
          input: [Int].self
        ) { input in
          let start = start(input.count)
          let a = RedBlackTreeSet(input)
          let b = RedBlackTreeSet(start..<start + input.count)
          return { timer in
            blackHole(a.intersection(identity(b)))
          }
        }
      }

      for (percentage, start) in overlaps {
        self.add(
          title: "RedBlackTreeSet<Int> symmetricDifference with Self (\(percentage) overlap)",
          input: [Int].self
        ) { input in
          let start = start(input.count)
          let a = RedBlackTreeSet(input)
          let b = RedBlackTreeSet(start..<start + input.count)
          return { timer in
            blackHole(a.symmetricDifference(identity(b)))
          }
        }
      }

      for (percentage, start) in overlaps {
        self.add(
          title: "RedBlackTreeSet<Int> subtracting Self (\(percentage) overlap)",
          input: [Int].self
        ) { input in
          let start = start(input.count)
          let a = RedBlackTreeSet(input)
          let b = RedBlackTreeSet(start..<start + input.count)
          return { timer in
            blackHole(a.subtracting(identity(b)))
          }
        }
      }
    }

    // RedBlackTreeSetAlgebra mutations with Self
    do {
      for (percentage, start) in overlaps {
        self.add(
          title: "RedBlackTreeSet<Int> formUnion with Self (\(percentage) overlap)",
          input: [Int].self
        ) { input in
          let start = start(input.count)
          let b = RedBlackTreeSet(start..<start + input.count)
          return { timer in
            var a = RedBlackTreeSet(input)
            timer.measure {
              a.formUnion(identity(b))
            }
            blackHole(a)
          }
        }
      }

      for (percentage, start) in overlaps {
        self.add(
          title: "RedBlackTreeSet<Int> formIntersection with Self (\(percentage) overlap)",
          input: [Int].self
        ) { input in
          let start = start(input.count)
          let b = RedBlackTreeSet(start..<start + input.count)
          return { timer in
            var a = RedBlackTreeSet(input)
            timer.measure {
              a.formIntersection(identity(b))
            }
            blackHole(a)
          }
        }
      }

      for (percentage, start) in overlaps {
        self.add(
          title: "RedBlackTreeSet<Int> formSymmetricDifference with Self (\(percentage) overlap)",
          input: [Int].self
        ) { input in
          let start = start(input.count)
          let b = RedBlackTreeSet(start..<start + input.count)
          return { timer in
            var a = RedBlackTreeSet(input)
            timer.measure {
              a.formSymmetricDifference(identity(b))
            }
            blackHole(a)
          }
        }
      }

      for (percentage, start) in overlaps {
        self.add(
          title: "RedBlackTreeSet<Int> subtract Self (\(percentage) overlap)",
          input: [Int].self
        ) { input in
          let start = start(input.count)
          let b = RedBlackTreeSet(start..<start + input.count)
          return { timer in
            var a = RedBlackTreeSet(input)
            timer.measure {
              a.subtract(identity(b))
            }
            blackHole(a)
          }
        }
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> equality, unique",
      input: Int.self
    ) { size in
      return { timer in
        let left = RedBlackTreeSet(0..<size)
        let right = RedBlackTreeSet(0..<size)
        timer.measure {
          precondition(left == right)
        }
      }
    }

    self.add(
      title: "RedBlackTreeSet<Int> equality, shared",
      input: Int.self
    ) { size in
      return { timer in
        let left = RedBlackTreeSet(0..<size)
        let right = left
        timer.measure {
          precondition(left == right)
        }
      }
    }

    #if true
      self.add(
        title: "RedBlackTreeSet<Int> successful find",
        input: ([Int], [Int]).self
      ) { input, lookups in
        let set = RedBlackTreeSet(input)
        return { timer in
          for i in lookups {
            precondition(set.find(i) != set.endIndex)
          }
        }
      }

      self.add(
        title: "RedBlackTreeSet<Int> unsuccessful find",
        input: ([Int], [Int]).self
      ) { input, lookups in
        let set = RedBlackTreeSet(input)
        let lookups = lookups.map { $0 + input.count }
        return { timer in
          for i in lookups {
            precondition(set.find(i) == set.endIndex)
          }
        }
      }

      self.add(
        title: "RedBlackTreeSet<Int> successful [.find(:)]",
        input: ([Int], [Int]).self
      ) { input, lookups in
        let set = RedBlackTreeSet(input)
        return { timer in
          for i in lookups {
            precondition(set[.find(i)] != nil)
          }
        }
      }

      self.add(
        title: "RedBlackTreeSet<Int> unsuccessful [.find(:)]",
        input: ([Int], [Int]).self
      ) { input, lookups in
        let set = RedBlackTreeSet(input)
        let lookups = lookups.map { $0 + input.count }
        return { timer in
          for i in lookups {
            precondition(set[.find(i)] == nil)
          }
        }
      }

      self.add(
        title: "RedBlackTreeSet<Int> successful __raw_find",
        input: ([Int], [Int]).self
      ) { input, lookups in
        let set = RedBlackTreeSet(input)
        return { timer in
          for i in lookups {
            precondition(set.__raw_find(i) != set.__raw_end)
            //          precondition(set.__raw_safe_find(i).exists)
            //          precondition(set.__value_find(i) == i)
          }
        }
      }

      self.add(
        title: "RedBlackTreeSet<Int> unsuccessful __raw_find",
        input: ([Int], [Int]).self
      ) { input, lookups in
        let set = RedBlackTreeSet(input)
        let lookups = lookups.map { $0 + input.count }
        return { timer in
          for i in lookups {
            precondition(set.__raw_find(i) == set.__raw_end)
            //          precondition(!set.__raw_safe_find(i).exists)
            //          precondition(set.__value_find(i) == nil)
          }
        }
      }
    #else
      self.add(
        title: "RedBlackTreeSet<Int> successful find",
        input: ([Int], [Int]).self
      ) { input, lookups in
        let set = RedBlackTreeSet(input)
        return { timer in
          for i in lookups {
            precondition(set.firstIndex(of: i) != nil)
          }
        }
      }

      self.add(
        title: "RedBlackTreeSet<Int> unsuccessful find",
        input: ([Int], [Int]).self
      ) { input, lookups in
        let set = RedBlackTreeSet(input)
        let lookups = lookups.map { $0 + input.count }
        return { timer in
          for i in lookups {
            precondition(set.firstIndex(of: i) == nil)
          }
        }
      }
    #endif
  }
}
