import Collections
import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

var benchmark = Benchmark(title: "lowerBound Benchmark")

func makeValues(_ size: Int) -> [Int] {
  Array(0..<size)
}

func makeTargets(_ size: Int) -> [Int] {
  (0..<100).map { ($0 &* 9973) % max(size, 1) }
}

// MARK: - RedBlackTreeSet

benchmark.add(
  title: "RedBlackTreeSet<Int> lowerBound",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let targets = makeTargets(size)

    let set = RedBlackTreeSet(values)

    timer.measure {

      var sum = 0

      for target in targets {
        let index = set.lowerBound(target)

        if index != set.endIndex {
          sum += 1
        }
      }

      blackHole(sum)
    }
  }
}

benchmark.add(
  title: "RedBlackTreeSet<Int> [.lowerBound(_:)]",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let targets = makeTargets(size)

    let set = RedBlackTreeSet(values)

    timer.measure {

      var sum = 0

      for target in targets {
        let num = set[.lowerBound(target)]

        sum += 1
      }

      blackHole(sum)
    }
  }
}
// MARK: - Array

benchmark.add(
  title: "Array<Int> lowerBound",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let targets = makeTargets(size)

    timer.measure {

      var sum = 0

      for target in targets {
        var low = 0
        var high = values.count

        while low < high {
          let mid = (low + high) >> 1

          if values[mid] < target {
            low = mid + 1
          } else {
            high = mid
          }
        }

        if low != values.count {
          sum += 1
        }
      }

      blackHole(sum)
    }
  }
}

// MARK: - OrderedSet

benchmark.add(
  title: "OrderedSet<Int> lowerBound-like",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let targets = makeTargets(size)

    let set = OrderedSet(values)

    timer.measure {

      var sum = 0

      for target in targets {
        var low = 0
        var high = set.count

        while low < high {
          let mid = (low + high) >> 1

          if set[mid] < target {
            low = mid + 1
          } else {
            high = mid
          }
        }

        if low != set.count {
          sum += 1
        }
      }

      blackHole(sum)
    }
  }
}

// MARK: - SortedSet

benchmark.add(
  title: "SortedSet<Int> lowerBound-like",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let targets = makeTargets(size)

    let set = SortedSet(values)
    let array = Array(set)

    timer.measure {

      var sum = 0

      for target in targets {
        var low = 0
        var high = array.count

        while low < high {
          let mid = (low + high) >> 1

          if array[mid] < target {
            low = mid + 1
          } else {
            high = mid
          }
        }

        if low != array.count {
          sum += 1
        }
      }

      blackHole(sum)
    }
  }
}

benchmark.main()

// swift run -c release CollectionBenchmark12 run results12 --cycles 5
// swift run -c release CollectionBenchmark12 render results12 chart.lowerBound.png
