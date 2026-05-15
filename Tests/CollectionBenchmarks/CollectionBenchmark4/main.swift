import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

var benchmark = Benchmark(title: "Dictionary Benchmark")

// MARK: - Set Value

benchmark.add(
  title: "RedBlackTreeDictionary<Int, Int> set",
  input: Int.self
) { size in

  return { timer in

    let keys = Array(0..<size)

    timer.measure {

      var dict = RedBlackTreeDictionary<Int, Int>()

      for k in keys {
        dict[k] = k
      }

      blackHole(dict)
    }
  }
}

benchmark.add(
  title: "Dictionary<Int, Int> set",
  input: Int.self
) { size in

  return { timer in

    let keys = Array(0..<size)

    timer.measure {

      var dict = Dictionary<Int, Int>()

      for k in keys {
        dict[k] = k
      }

      blackHole(dict)
    }
  }
}

// MARK: - Update Value

benchmark.add(
  title: "RedBlackTreeDictionary<Int, Int> update",
  input: Int.self
) { size in

  return { timer in

    let keys = Array(0..<size)

    var dict = RedBlackTreeDictionary<Int, Int>()

    for k in keys {
      dict[k] = k
    }

    timer.measure {

      for k in keys {
        dict[k] = k + 1
      }

      blackHole(dict)
    }
  }
}

benchmark.add(
  title: "Dictionary<Int, Int> update",
  input: Int.self
) { size in

  return { timer in

    let keys = Array(0..<size)

    var dict = Dictionary<Int, Int>()

    for k in keys {
      dict[k] = k
    }

    timer.measure {

      for k in keys {
        dict[k] = k + 1
      }

      blackHole(dict)
    }
  }
}

// MARK: - Get Value

benchmark.add(
  title: "RedBlackTreeDictionary<Int, Int> get",
  input: Int.self
) { size in

  return { timer in

    let keys = Array(0..<size)

    var dict = RedBlackTreeDictionary<Int, Int>()

    for k in keys {
      dict[k] = k
    }

    timer.measure {

      var sum = 0

      for k in keys {
        sum += dict[k]!
      }

      blackHole(sum)
    }
  }
}

benchmark.add(
  title: "Dictionary<Int, Int> get",
  input: Int.self
) { size in

  return { timer in

    let keys = Array(0..<size)

    var dict = Dictionary<Int, Int>()

    for k in keys {
      dict[k] = k
    }

    timer.measure {

      var sum = 0

      for k in keys {
        sum += dict[k]!
      }

      blackHole(sum)
    }
  }
}

benchmark.main()


// swift run -c release CollectionBenchmark4 run results4 --cycles 5
// swift run -c release CollectionBenchmark4 render results4 chart.dictionary.png
