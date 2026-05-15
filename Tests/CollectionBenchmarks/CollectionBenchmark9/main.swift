import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections
import Collections

var benchmark = Benchmark(title: "Gradual reserveCapacity Benchmark")

// MARK: - Parameters

let step = 1

// MARK: - Set

benchmark.add(
  title: "RedBlackTreeSet<Int> gradual reserveCapacity",
  input: Int.self
) { size in

  return { timer in

    timer.measure {

      var set = RedBlackTreeSet<Int>()

      var current = 0

      while current < size {
        current += step
        set.reserveCapacity(current)
      }

      blackHole(set)
    }
  }
}

benchmark.add(
  title: "Set<Int> gradual reserveCapacity",
  input: Int.self
) { size in

  return { timer in

    timer.measure {

      var set = Set<Int>()

      var current = 0

      while current < size {
        current += step
        set.reserveCapacity(current)
      }

      blackHole(set)
    }
  }
}

benchmark.add(
  title: "OrderedSet<Int> gradual reserveCapacity",
  input: Int.self
) { size in

  return { timer in

    timer.measure {

      var set = OrderedSet<Int>()

      var current = 0

      while current < size {
        current += step
        set.reserveCapacity(current)
      }

      blackHole(set)
    }
  }
}

// MARK: - Dictionary

benchmark.add(
  title: "RedBlackTreeDictionary<Int, Int> gradual reserveCapacity",
  input: Int.self
) { size in

  return { timer in

    timer.measure {

      var dict = RedBlackTreeDictionary<Int, Int>()

      var current = 0

      while current < size {
        current += step
        dict.reserveCapacity(current)
      }

      blackHole(dict)
    }
  }
}

benchmark.add(
  title: "Dictionary<Int, Int> gradual reserveCapacity",
  input: Int.self
) { size in

  return { timer in

    timer.measure {

      var dict = Dictionary<Int, Int>()

      var current = 0

      while current < size {
        current += step
        dict.reserveCapacity(current)
      }

      blackHole(dict)
    }
  }
}

benchmark.add(
  title: "OrderedDictionary<Int, Int> gradual reserveCapacity",
  input: Int.self
) { size in

  return { timer in

    timer.measure {

      var dict = OrderedDictionary<Int, Int>()

      var current = 0

      while current < size {
        current += step
        dict.reserveCapacity(current)
      }

      blackHole(dict)
    }
  }
}

benchmark.main()

// swift run -c release CollectionBenchmark9 run results9 --cycles 5
// swift run -c release CollectionBenchmark9 render results9 chart.reserveCapacity.gradual.png
