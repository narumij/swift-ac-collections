import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections
import Collections

var benchmark = Benchmark(title: "firstIndex(of:) Benchmark")

func makeValues(_ size: Int) -> [Int] {
  Array(0..<size)
}

func makeTargets(_ size: Int) -> [Int] {
  (0..<100).map { ($0 &* 9973) % max(size, 1) }
}

// MARK: - RedBlackTreeSet

benchmark.add(
  title: "RedBlackTreeSet<Int> firstIndex(of:)",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let targets = makeTargets(size)

    let set = RedBlackTreeSet(values)

    timer.measure {

      var sum = 0

      for target in targets {
        if set.firstIndex(of: target) != nil {
          sum += 1
        }
      }

      blackHole(sum)
    }
  }
}

// MARK: - Set

benchmark.add(
  title: "Set<Int> firstIndex(of:)",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let targets = makeTargets(size)

    let set = Set(values)

    timer.measure {

      var sum = 0

      for target in targets {
        if set.firstIndex(of: target) != nil {
          sum += 1
        }
      }

      blackHole(sum)
    }
  }
}

// MARK: - OrderedSet

benchmark.add(
  title: "OrderedSet<Int> firstIndex(of:)",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let targets = makeTargets(size)

    let set = OrderedSet(values)

    timer.measure {

      var sum = 0

      for target in targets {
        if set.firstIndex(of: target) != nil {
          sum += 1
        }
      }

      blackHole(sum)
    }
  }
}

// MARK: - SortedSet

benchmark.add(
  title: "SortedSet<Int> firstIndex(of:)",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let targets = makeTargets(size)

    let set = SortedSet(values)

    timer.measure {

      var sum = 0

      for target in targets {
        if set.firstIndex(of: target) != nil {
          sum += 1
        }
      }

      blackHole(sum)
    }
  }
}

benchmark.main()

// swift run -c release CollectionBenchmark11 run results11 --cycles 5
// swift run -c release CollectionBenchmark11 render results11 chart.firstIndex.png
