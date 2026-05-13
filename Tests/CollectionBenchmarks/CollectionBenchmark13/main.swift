import Collections
import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

var benchmark = Benchmark(title: "sorted() Benchmark")

func makeValues(_ size: Int) -> [Int] {
  (0..<size).map { ($0 &* 9973) % max(size, 1) }
}

// MARK: - RedBlackTreeSet

benchmark.add(
  title: "RedBlackTreeSet<Int> sorted()",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let set = RedBlackTreeSet(values)

    timer.measure {
      let result = set.sorted()
      blackHole(result)
    }
  }
}

// MARK: - Swift Set

benchmark.add(
  title: "Set<Int> sorted()",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let set = Set(values)

    timer.measure {
      let result = set.sorted()
      blackHole(result)
    }
  }
}

// MARK: - Apple SortedSet

benchmark.add(
  title: "SortedSet<Int> sorted()",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let set = SortedSet(values)

    timer.measure {
      let result = set.sorted()
      blackHole(result)
    }
  }
}

benchmark.main()

// swift run -c release CollectionBenchmark13 run results13 --cycles 5
// swift run -c release CollectionBenchmark13 render results13 chart.sorted.png
