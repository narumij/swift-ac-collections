import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections
import Collections

var benchmark = Benchmark(title: "CoW Benchmark")

// MARK: - Parameters

func makeArray(_ size: Int) -> [Int] {
  Array(0..<size)
}

// MARK: - Set CoW

benchmark.add(
  title: "RedBlackTreeSet<Int> CoW insert",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)

    var original = RedBlackTreeSet<Int>()

    for v in values {
      original.insert(v)
    }

    timer.measure {

      var copied = original

      copied.insert(-1)

      blackHole(copied)
    }
  }
}

benchmark.add(
  title: "Set<Int> CoW insert",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)

    var original = Set<Int>()

    for v in values {
      original.insert(v)
    }

    timer.measure {

      var copied = original

      copied.insert(-1)

      blackHole(copied)
    }
  }
}

benchmark.add(
  title: "OrderedSet<Int> CoW insert",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)

    var original = OrderedSet<Int>()

    for v in values {
      original.append(v)
    }

    timer.measure {

      var copied = original

      copied.append(-1)

      blackHole(copied)
    }
  }
}

// MARK: - Dictionary CoW

benchmark.add(
  title: "RedBlackTreeDictionary<Int, Int> CoW update",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)

    var original = RedBlackTreeDictionary<Int, Int>()

    for v in values {
      original[v] = v
    }

    timer.measure {

      var copied = original

      copied[-1] = -1

      blackHole(copied)
    }
  }
}

benchmark.add(
  title: "Dictionary<Int, Int> CoW update",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)

    var original = Dictionary<Int, Int>()

    for v in values {
      original[v] = v
    }

    timer.measure {

      var copied = original

      copied[-1] = -1

      blackHole(copied)
    }
  }
}

benchmark.add(
  title: "OrderedDictionary<Int, Int> CoW update",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)

    var original = OrderedDictionary<Int, Int>()

    for v in values {
      original[v] = v
    }

    timer.measure {

      var copied = original

      copied[-1] = -1

      blackHole(copied)
    }
  }
}

benchmark.main()

// swift run -c release CollectionBenchmark10 run results10 --cycles 5
// swift run -c release CollectionBenchmark10 render results10 chart.cow.png
