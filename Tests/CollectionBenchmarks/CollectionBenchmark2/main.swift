import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

var benchmark = Benchmark(title: "Remove Benchmark")

benchmark.add(
  title: "RedBlackTreeSet<Int> remove",
  input: [Int].self
) { input in

  return { timer in
    timer.measure {

      var tree = RedBlackTreeSet<Int>()

      for x in input {
        tree.insert(x)
      }

      for x in input {
        tree.remove(x)
      }

      blackHole(tree)
    }
  }
}

benchmark.add(
  title: "SortedSet<Int> remove",
  input: [Int].self
) { input in

  return { timer in
    timer.measure {

      var tree = SortedSet<Int>()

      for x in input {
        tree.insert(x)
      }

      for x in input {
        tree.remove(x)
      }

      blackHole(tree)
    }
  }
}

benchmark.add(
  title: "Set<Int> remove",
  input: [Int].self
) { input in

  return { timer in
    timer.measure {

      var set = Set<Int>()

      for x in input {
        set.insert(x)
      }

      for x in input {
        set.remove(x)
      }

      blackHole(set)
    }
  }
}

#if false
benchmark.addSimpleInput(
  title: "Random unique Int",
  input: { size in
    Array(0..<size).shuffled()
  }
)
#endif

benchmark.main()

// swift run -c release CollectionBenchmark2 run results --cycles 5
// swift run -c release CollectionBenchmark2 render results chart.png
