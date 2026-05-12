import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

var benchmark = Benchmark(title: "Insert Benchmark")

benchmark.add(
  title: "RedBlackTreeSet<Int> insert",
  input: [Int].self
) { input in

  return { timer in
    timer.measure {
      var tree = RedBlackTreeSet<Int>()

      for x in input {
        tree.insert(x)
      }

      blackHole(tree)
    }
  }
}

benchmark.add(
  title: "SortedSet<Int> insert",
  input: [Int].self
) { input in

  return { timer in
    timer.measure {
      var tree = SortedSet<Int>()

      for x in input {
        tree.insert(x)
      }

      blackHole(tree)
    }
  }
}

benchmark.add(
  title: "Set<Int> insert",
  input: [Int].self
) { input in

  return { timer in
    timer.measure {
      var set = Set<Int>()

      for x in input {
        set.insert(x)
      }

      blackHole(set)
    }
  }
}

benchmark.main()

// swift run -c release CollectionBenchmark1 run results --cycles 5
// swift run -c release CollectionBenchmark1 render results chart.png
