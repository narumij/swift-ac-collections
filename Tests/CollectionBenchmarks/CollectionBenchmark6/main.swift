import Collections
import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

var benchmark = Benchmark(title: "removeAll Benchmark")

// MARK: - RedBlackTreeSet

benchmark.add(
  title: "RedBlackTreeSet<Int> removeAll",
  input: Int.self
) { size in

  return { timer in

    timer.measure {

      var set = RedBlackTreeSet<Int>()

      for i in 0..<size {
        set.insert(i)
      }

      set.removeAll()

      blackHole(set)
    }
  }
}

// MARK: - SortedSet

benchmark.add(
  title: "SortedSet<Int> removeAll",
  input: Int.self
) { size in

  return { timer in

    timer.measure {

      var set = SortedSet<Int>()

      for i in 0..<size {
        set.insert(i)
      }

      set.removeAll()

      blackHole(set)
    }
  }
}

// MARK: - Set

benchmark.add(
  title: "Set<Int> removeAll",
  input: Int.self
) { size in

  return { timer in

    var set = Set<Int>()

    for i in 0..<size {
      set.insert(i)
    }

    timer.measure {

      set.removeAll()

      blackHole(set)
    }
  }
}

// MARK: - OrderedSet

benchmark.add(
  title: "OrderedSet<Int> removeAll",
  input: Int.self
) { size in

  return { timer in

    var set = OrderedSet<Int>()

    for i in 0..<size {
      set.append(i)
    }

    timer.measure {

      set.removeAll()

      blackHole(set)
    }
  }
}

// MARK: - Deque

benchmark.add(
  title: "Deque<Int> removeAll",
  input: Int.self
) { size in

  return { timer in

    var deque = Deque<Int>()

    for i in 0..<size {
      deque.append(i)
    }

    timer.measure {

      deque.removeAll()

      blackHole(deque)
    }
  }
}

benchmark.main()

// swift run -c release CollectionBenchmark6 run results6 --cycles 5
// swift run -c release CollectionBenchmark6 render results6 chart.removeAll.png
