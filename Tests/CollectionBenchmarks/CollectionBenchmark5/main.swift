import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

var benchmark = Benchmark(title: "Dictionary Default Benchmark")

// MARK: - Set Value

benchmark.add(
  title: "RedBlackTreeDictionary<Int, Int> default set",
  input: Int.self
) { size in

  return { timer in

    let keys = Array(0..<size)

    timer.measure {

      var dict = RedBlackTreeDictionary<Int, Int>()

      for k in keys {
        dict[k, default: 0] = k
      }

      blackHole(dict)
    }
  }
}

benchmark.add(
  title: "Dictionary<Int, Int> default set",
  input: Int.self
) { size in

  return { timer in

    let keys = Array(0..<size)

    timer.measure {

      var dict = Dictionary<Int, Int>()

      for k in keys {
        dict[k, default: 0] = k
      }

      blackHole(dict)
    }
  }
}

// MARK: - Update Value

benchmark.add(
  title: "RedBlackTreeDictionary<Int, Int> default update",
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
        dict[k, default: 0] = k + 1
      }

      blackHole(dict)
    }
  }
}

benchmark.add(
  title: "Dictionary<Int, Int> default update",
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
        dict[k, default: 0] = k + 1
      }

      blackHole(dict)
    }
  }
}

// MARK: - Get Value

benchmark.add(
  title: "RedBlackTreeDictionary<Int, Int> default get",
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
        sum += dict[k, default: 0]
      }

      blackHole(sum)
    }
  }
}

benchmark.add(
  title: "Dictionary<Int, Int> default get",
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
        sum += dict[k, default: 0]
      }

      blackHole(sum)
    }
  }
}

benchmark.main()


// swift run -c release CollectionBenchmark5 run results5 --cycles 5
// swift run -c release CollectionBenchmark5 render results5 chart.dictionary.default.png
