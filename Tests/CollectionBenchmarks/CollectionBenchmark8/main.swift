import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections
import Collections

var benchmark = Benchmark(title: "minimumCapacity Benchmark")

// MARK: - Set

benchmark.add(
  title: "RedBlackTreeSet<Int> init(minimumCapacity:)",
  input: Int.self
) { size in

  return { timer in

    timer.measure {
      let set = RedBlackTreeSet<Int>(minimumCapacity: size)
      blackHole(set)
    }
  }
}

benchmark.add(
  title: "Set<Int> init(minimumCapacity:)",
  input: Int.self
) { size in

  return { timer in

    timer.measure {
      let set = Set<Int>(minimumCapacity: size)
      blackHole(set)
    }
  }
}

benchmark.add(
  title: "OrderedSet<Int> init(minimumCapacity:)",
  input: Int.self
) { size in

  return { timer in

    timer.measure {
      let set = OrderedSet<Int>(minimumCapacity: size)
      blackHole(set)
    }
  }
}

// MARK: - Dictionary

benchmark.add(
  title: "RedBlackTreeDictionary<Int, Int> init(minimumCapacity:)",
  input: Int.self
) { size in

  return { timer in

    timer.measure {
      let dict = RedBlackTreeDictionary<Int, Int>(
        minimumCapacity: size
      )
      blackHole(dict)
    }
  }
}

benchmark.add(
  title: "Dictionary<Int, Int> init(minimumCapacity:)",
  input: Int.self
) { size in

  return { timer in

    timer.measure {
      let dict = Dictionary<Int, Int>(
        minimumCapacity: size
      )
      blackHole(dict)
    }
  }
}

benchmark.add(
  title: "OrderedDictionary<Int, Int> init(minimumCapacity:)",
  input: Int.self
) { size in

  return { timer in

    timer.measure {
      let dict = OrderedDictionary<Int, Int>(
        minimumCapacity: size
      )
      blackHole(dict)
    }
  }
}

benchmark.main()

// swift run -c release CollectionBenchmark8 run results8 --cycles 5
// swift run -c release CollectionBenchmark8 render results8 chart.minimumCapacity.png
