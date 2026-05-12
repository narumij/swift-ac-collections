import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

var benchmark = Benchmark(title: "RangeExpression Init Benchmark")

// MARK: - ClosedRange

benchmark.add(
  title: "RedBlackTreeSet<Int> init ClosedRange",
  input: Int.self
) { size in

  return { timer in

    timer.measure {
      let set = RedBlackTreeSet(0...size)
      blackHole(set)
    }
  }
}

benchmark.add(
  title: "SortedSet<Int> init ClosedRange",
  input: Int.self
) { size in

  return { timer in

    timer.measure {
      let set = SortedSet(0...size)
      blackHole(set)
    }
  }
}

benchmark.add(
  title: "Set<Int> init ClosedRange",
  input: Int.self
) { size in

  return { timer in

    timer.measure {
      let set = Set(0...size)
      blackHole(set)
    }
  }
}

// MARK: - Range

benchmark.add(
  title: "RedBlackTreeSet<Int> init Range",
  input: Int.self
) { size in

  return { timer in

    timer.measure {
      let set = RedBlackTreeSet(0..<size)
      blackHole(set)
    }
  }
}

benchmark.add(
  title: "SortedSet<Int> init Range",
  input: Int.self
) { size in

  return { timer in

    timer.measure {
      let set = SortedSet(0..<size)
      blackHole(set)
    }
  }
}

benchmark.add(
  title: "Set<Int> init Range",
  input: Int.self
) { size in

  return { timer in

    timer.measure {
      let set = Set(0..<size)
      blackHole(set)
    }
  }
}

benchmark.main()

// swift run -c release CollectionBenchmark7 run results7 --cycles 5
// swift run -c release CollectionBenchmark7 render results7 chart.rangeinit.png
