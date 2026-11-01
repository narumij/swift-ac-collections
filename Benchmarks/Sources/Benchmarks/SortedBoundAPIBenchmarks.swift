// Strict successor/predecessor APIs, with identical seeded input on both sides.
// Build, input generation and per-query correctness checks are outside timing.
import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

extension Benchmark {
  public mutating func addSortedBoundAPIBenchmarks() {
    add(title: "RedBlackTreeSet<Int> firstIndex(after:) at keys", input: SortedPeerInput.self) { input in
      var built = RedBlackTreeSet<Int>()
      for k in input.insertionOrder { built.insert(k) }
      let set = built
      let queries = input.hitQueries
      // Check every query, plus values outside both ends, before measuring.
      for k in queries + [-1, 2 * input.size] {
        let value = k < 0 ? 0 : (k / 2 + 1) * 2
        let expected: Int? = value < 2 * input.size ? value : nil
        let actual = set.firstIndex(after: k).map { set[$0] }
        precondition(actual == expected, "successor mismatch at \(k)")
      }
      return { timer in
        var sum = 0
        var missing = 0
        for k in queries {
          if let i = set.firstIndex(after: k) { sum &+= set[i] } else { missing += 1 }
        }
        blackHole(sum)
        blackHole(missing)
      }
    }
    add(title: "SortedSet<Int> firstIndex(after:) at keys", input: SortedPeerInput.self) { input in
      var built = SortedSet<Int>()
      for k in input.insertionOrder { built.insert(k) }
      let set = built
      let queries = input.hitQueries
      // Check every query, plus values outside both ends, before measuring.
      for k in queries + [-1, 2 * input.size] {
        let value = k < 0 ? 0 : (k / 2 + 1) * 2
        let expected: Int? = value < 2 * input.size ? value : nil
        let actual = set.firstIndex(after: k).map { set[$0] }
        precondition(actual == expected, "successor mismatch at \(k)")
      }
      return { timer in
        var sum = 0
        var missing = 0
        for k in queries {
          if let i = set.firstIndex(after: k) { sum &+= set[i] } else { missing += 1 }
        }
        blackHole(sum)
        blackHole(missing)
      }
    }
    add(title: "RedBlackTreeSet<Int> firstIndex(after:) between keys", input: SortedPeerInput.self) { input in
      var built = RedBlackTreeSet<Int>()
      for k in input.insertionOrder { built.insert(k) }
      let set = built
      let queries = input.missQueries
      // Check every query, plus values outside both ends, before measuring.
      for k in queries + [-1, 2 * input.size] {
        let value = k < 0 ? 0 : (k / 2 + 1) * 2
        let expected: Int? = value < 2 * input.size ? value : nil
        let actual = set.firstIndex(after: k).map { set[$0] }
        precondition(actual == expected, "successor mismatch at \(k)")
      }
      return { timer in
        var sum = 0
        var missing = 0
        for k in queries {
          if let i = set.firstIndex(after: k) { sum &+= set[i] } else { missing += 1 }
        }
        blackHole(sum)
        blackHole(missing)
      }
    }
    add(title: "SortedSet<Int> firstIndex(after:) between keys", input: SortedPeerInput.self) { input in
      var built = SortedSet<Int>()
      for k in input.insertionOrder { built.insert(k) }
      let set = built
      let queries = input.missQueries
      // Check every query, plus values outside both ends, before measuring.
      for k in queries + [-1, 2 * input.size] {
        let value = k < 0 ? 0 : (k / 2 + 1) * 2
        let expected: Int? = value < 2 * input.size ? value : nil
        let actual = set.firstIndex(after: k).map { set[$0] }
        precondition(actual == expected, "successor mismatch at \(k)")
      }
      return { timer in
        var sum = 0
        var missing = 0
        for k in queries {
          if let i = set.firstIndex(after: k) { sum &+= set[i] } else { missing += 1 }
        }
        blackHole(sum)
        blackHole(missing)
      }
    }
    add(title: "RedBlackTreeSet<Int> lastIndex(before:) at keys", input: SortedPeerInput.self) { input in
      var built = RedBlackTreeSet<Int>()
      for k in input.insertionOrder { built.insert(k) }
      let set = built
      let queries = input.hitQueries
      // Check every query, plus values outside both ends, before measuring.
      for k in queries + [-1, 2 * input.size] {
        let value = k <= 0 ? -1 : ((k - 1) / 2) * 2
        let expected: Int? = value >= 0 ? min(value, 2 * (input.size - 1)) : nil
        let actual = set.lastIndex(before: k).map { set[$0] }
        precondition(actual == expected, "predecessor mismatch at \(k)")
      }
      return { timer in
        var sum = 0
        var missing = 0
        for k in queries {
          if let i = set.lastIndex(before: k) { sum &+= set[i] } else { missing += 1 }
        }
        blackHole(sum)
        blackHole(missing)
      }
    }
    add(title: "SortedSet<Int> lastIndex(before:) at keys", input: SortedPeerInput.self) { input in
      var built = SortedSet<Int>()
      for k in input.insertionOrder { built.insert(k) }
      let set = built
      let queries = input.hitQueries
      // Check every query, plus values outside both ends, before measuring.
      for k in queries + [-1, 2 * input.size] {
        let value = k <= 0 ? -1 : ((k - 1) / 2) * 2
        let expected: Int? = value >= 0 ? min(value, 2 * (input.size - 1)) : nil
        let actual = set.lastIndex(before: k).map { set[$0] }
        precondition(actual == expected, "predecessor mismatch at \(k)")
      }
      return { timer in
        var sum = 0
        var missing = 0
        for k in queries {
          if let i = set.lastIndex(before: k) { sum &+= set[i] } else { missing += 1 }
        }
        blackHole(sum)
        blackHole(missing)
      }
    }
    add(title: "RedBlackTreeSet<Int> lastIndex(before:) between keys", input: SortedPeerInput.self) { input in
      var built = RedBlackTreeSet<Int>()
      for k in input.insertionOrder { built.insert(k) }
      let set = built
      let queries = input.missQueries
      // Check every query, plus values outside both ends, before measuring.
      for k in queries + [-1, 2 * input.size] {
        let value = k <= 0 ? -1 : ((k - 1) / 2) * 2
        let expected: Int? = value >= 0 ? min(value, 2 * (input.size - 1)) : nil
        let actual = set.lastIndex(before: k).map { set[$0] }
        precondition(actual == expected, "predecessor mismatch at \(k)")
      }
      return { timer in
        var sum = 0
        var missing = 0
        for k in queries {
          if let i = set.lastIndex(before: k) { sum &+= set[i] } else { missing += 1 }
        }
        blackHole(sum)
        blackHole(missing)
      }
    }
    add(title: "SortedSet<Int> lastIndex(before:) between keys", input: SortedPeerInput.self) { input in
      var built = SortedSet<Int>()
      for k in input.insertionOrder { built.insert(k) }
      let set = built
      let queries = input.missQueries
      // Check every query, plus values outside both ends, before measuring.
      for k in queries + [-1, 2 * input.size] {
        let value = k <= 0 ? -1 : ((k - 1) / 2) * 2
        let expected: Int? = value >= 0 ? min(value, 2 * (input.size - 1)) : nil
        let actual = set.lastIndex(before: k).map { set[$0] }
        precondition(actual == expected, "predecessor mismatch at \(k)")
      }
      return { timer in
        var sum = 0
        var missing = 0
        for k in queries {
          if let i = set.lastIndex(before: k) { sum &+= set[i] } else { missing += 1 }
        }
        blackHole(sum)
        blackHole(missing)
      }
    }
  }
}
