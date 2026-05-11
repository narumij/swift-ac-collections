import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

var benchmark = Benchmark(title: "Demo Benchmark")

//benchmark.addSimple(
//  title: "Array<Int> sorted",
//  input: [Int].self
//) { input in
//  blackHole(input.sorted())
//}

benchmark.add(
  title: "Set<Int> contains",
  input: ([Int], [Int]).self
) { input, lookups in
  let set = Set(input)
  return { timer in
    for value in lookups {
      precondition(set.contains(value))
    }
  }
}

benchmark.add(
  title: "RedBlackTreeSet<Int> contains",
  input: ([Int], [Int]).self
) { input, lookups in
  let set = RedBlackTreeSet(input)
  return { timer in
    for value in lookups {
      precondition(set.contains(value))
    }
  }
}

benchmark.add(
  title: "SortedSet<Int> contains",
  input: ([Int], [Int]).self
) { input, lookups in
  let set = SortedSet(input)
  return { timer in
    for value in lookups {
      precondition(set.contains(value))
    }
  }
}

benchmark.main()

// swift run -c release CollectionBenchmark0 run results --cycles 5
// swift run -c release CollectionBenchmark0 render results chart.png

