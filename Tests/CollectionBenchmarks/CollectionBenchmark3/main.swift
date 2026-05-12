import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

var benchmark = Benchmark(title: "SetAlgebra Benchmark")

benchmark.add(
  title: "RedBlackTreeSet<Int> union",
  input: Int.self
) { size in

  return { timer in

    let lhsInput = Array(0..<size)
    let rhsInput = Array(size / 2..<(size + size / 2))

    let lhs = RedBlackTreeSet(lhsInput)
    let rhs = RedBlackTreeSet(rhsInput)

    timer.measure {
      blackHole(lhs.union(rhs))
    }
  }
}

benchmark.add(
  title: "Set<Int> union",
  input: Int.self
) { size in

  return { timer in

    let lhsInput = Array(0..<size)
    let rhsInput = Array(size / 2..<(size + size / 2))

    let lhs = Set(lhsInput)
    let rhs = Set(rhsInput)

    timer.measure {
      blackHole(lhs.union(rhs))
    }
  }
}

// MARK: - intersection

benchmark.add(
  title: "RedBlackTreeSet<Int> intersection",
  input: Int.self
) { size in

  return { timer in

    let lhsInput = Array(0..<size)
    let rhsInput = Array(size / 2..<(size + size / 2))

    let lhs = RedBlackTreeSet(lhsInput)
    let rhs = RedBlackTreeSet(rhsInput)

    timer.measure {
      blackHole(lhs.intersection(rhs))
    }
  }
}

benchmark.add(
  title: "Set<Int> intersection",
  input: Int.self
) { size in

  return { timer in

    let lhsInput = Array(0..<size)
    let rhsInput = Array(size / 2..<(size + size / 2))

    let lhs = Set(lhsInput)
    let rhs = Set(rhsInput)

    timer.measure {
      blackHole(lhs.intersection(rhs))
    }
  }
}

// MARK: - symmetricDifference

benchmark.add(
  title: "RedBlackTreeSet<Int> symmetricDifference",
  input: Int.self
) { size in

  return { timer in

    let lhsInput = Array(0..<size)
    let rhsInput = Array(size / 2..<(size + size / 2))

    let lhs = RedBlackTreeSet(lhsInput)
    let rhs = RedBlackTreeSet(rhsInput)

    timer.measure {
      blackHole(lhs.symmetricDifference(rhs))
    }
  }
}

benchmark.add(
  title: "Set<Int> symmetricDifference",
  input: Int.self
) { size in

  return { timer in

    let lhsInput = Array(0..<size)
    let rhsInput = Array(size / 2..<(size + size / 2))

    let lhs = Set(lhsInput)
    let rhs = Set(rhsInput)

    timer.measure {
      blackHole(lhs.symmetricDifference(rhs))
    }
  }
}

benchmark.main()

// swift run -c release CollectionBenchmark3 run results3 --cycles 5
// swift run -c release CollectionBenchmark3 render results3 chart.setAlgebra.png
