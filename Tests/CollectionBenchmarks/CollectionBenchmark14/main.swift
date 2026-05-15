import Collections
import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

var benchmark = Benchmark(title: "insert + lowerBound Benchmark")

func makeValues(_ size: Int) -> [Int] {
  guard size > 0 else { return [] }

  var values = Array(0..<size)

  // Deterministic shuffle.
  for i in values.indices {
    let j = (i &* 9973 &+ 12345) % size
    values.swapAt(i, j)
  }

  return values
}

func makeTargets(_ size: Int) -> [Int] {
  let size = max(size, 1)
  return (0..<size).map { ($0 &* 7919 &+ 104729) % size }
}

// MARK: - RedBlackTreeSet

benchmark.add(
  title: "RedBlackTreeSet<Int> insert + lowerBound",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let targets = makeTargets(size)

    timer.measure {

      var set = RedBlackTreeSet<Int>()
      var sum = 0

      for i in values.indices {
        set.insert(values[i])

        let index = set.lowerBound(targets[i])

        if index != set.endIndex {
          sum &+= 1
        }
      }

      blackHole(sum)
      blackHole(set)
    }
  }
}

benchmark.add(
  title: "RedBlackTreeSet<Int> insert + [.lowerBound(_:)]",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let targets = makeTargets(size)

    timer.measure {

      var set = RedBlackTreeSet<Int>()
      var sum = 0

      for i in values.indices {
        _ = set.insert(values[i])

        _ = set[.lowerBound(targets[i])]
        sum &+= 1
      }

      blackHole(sum)
      blackHole(set)
    }
  }
}

// MARK: - Array

benchmark.add(
  title: "Array<Int> sortedInsert + lowerBound",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let targets = makeTargets(size)

    timer.measure {

      var array: [Int] = []
      array.reserveCapacity(size)

      var sum = 0

      for i in values.indices {
        let value = values[i]

        // insertion lowerBound
        var low = 0
        var high = array.count

        while low < high {
          let mid = (low + high) >> 1

          if array[mid] < value {
            low = mid + 1
          } else {
            high = mid
          }
        }

        array.insert(value, at: low)

        // query lowerBound
        low = 0
        high = array.count

        let target = targets[i]

        while low < high {
          let mid = (low + high) >> 1

          if array[mid] < target {
            low = mid + 1
          } else {
            high = mid
          }
        }

        if low != array.count {
          sum &+= 1
        }
      }

      blackHole(sum)
      blackHole(array)
    }
  }
}

// MARK: - SortedSet

benchmark.add(
  title: "SortedSet<Int> insert + lowerBound-like",
  input: Int.self
) { size in

  return { timer in

    let values = makeValues(size)
    let targets = makeTargets(size)

    timer.measure {

      var set = SortedSet<Int>()
      var sum = 0

      for i in values.indices {
        set.insert(values[i])

        let target = targets[i]

        var low = set.startIndex
        var high = set.endIndex

        while low != high {
          let d = set.distance(from: low, to: high)
          let mid = set.index(low, offsetBy: d >> 1)

          if set[mid] < target {
            low = set.index(after: mid)
          } else {
            high = mid
          }
        }

        if low != set.endIndex {
          sum &+= 1
        }
      }

      blackHole(sum)
      blackHole(set)
    }
  }
}

benchmark.main()

// swift run -c release CollectionBenchmark14 run results14 --cycles 5
// swift run -c release CollectionBenchmark14 render results14 chart.insert.lowerBound.png
