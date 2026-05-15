import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections
import Collections

var benchmark = Benchmark(title: "CoW remove Benchmark")

// MARK: - Parameters

func makeArray(_ size: Int) -> [Int] {
  Array(0..<size)
}

// MARK: - Set CoW

benchmark.add(
  title: "RedBlackTreeSet<Int> CoW remove",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)
    let target = size >> 1

    var original = RedBlackTreeSet<Int>()

    for v in values {
      original.insert(v)
    }

    timer.measure {

      var copied = original

      if size > 0 {
        copied.remove(target)
      }

      blackHole(copied)
    }
  }
}

benchmark.add(
  title: "Set<Int> CoW remove",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)
    let target = size >> 1

    var original = Set<Int>()

    for v in values {
      original.insert(v)
    }

    timer.measure {

      var copied = original

      if size > 0 {
        copied.remove(target)
      }

      blackHole(copied)
    }
  }
}

benchmark.add(
  title: "OrderedSet<Int> CoW remove",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)
    let target = size >> 1

    var original = OrderedSet<Int>()

    for v in values {
      original.append(v)
    }

    timer.measure {

      var copied = original

      if size > 0 {
        copied.remove(target)
      }

      blackHole(copied)
    }
  }
}

benchmark.add(
  title: "SortedSet<Int> CoW remove",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)
    let target = size >> 1

    var original = SortedSet<Int>()

    for v in values {
      original.insert(v)
    }

    timer.measure {

      var copied = original

      if size > 0 {
        copied.remove(target)
      }

      blackHole(copied)
    }
  }
}

// MARK: - Dictionary CoW

benchmark.add(
  title: "RedBlackTreeDictionary<Int, Int> CoW removeValue",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)
    let target = size >> 1

    var original = RedBlackTreeDictionary<Int, Int>()

    for v in values {
      original[v] = v
    }

    timer.measure {

      var copied = original

      if size > 0 {
        copied.removeValue(forKey: target)
      }

      blackHole(copied)
    }
  }
}

benchmark.add(
  title: "Dictionary<Int, Int> CoW removeValue",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)
    let target = size >> 1

    var original = Dictionary<Int, Int>()

    for v in values {
      original[v] = v
    }

    timer.measure {

      var copied = original

      if size > 0 {
        copied.removeValue(forKey: target)
      }

      blackHole(copied)
    }
  }
}

benchmark.add(
  title: "OrderedDictionary<Int, Int> CoW removeValue",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)
    let target = size >> 1

    var original = OrderedDictionary<Int, Int>()

    for v in values {
      original[v] = v
    }

    timer.measure {

      var copied = original

      if size > 0 {
        copied.removeValue(forKey: target)
      }

      blackHole(copied)
    }
  }
}

benchmark.add(
  title: "SortedDictionary<Int, Int> CoW removeValue",
  input: Int.self
) { size in

  return { timer in

    let values = makeArray(size)
    let target = size >> 1

    var original = SortedDictionary<Int, Int>()

    for v in values {
      original[v] = v
    }

    timer.measure {

      var copied = original

      if size > 0 {
        _ = copied.removeValue(forKey: target)
      }

      blackHole(copied)
    }
  }
}

benchmark.main()

// swift run -c release CollectionBenchmark10 run results10 --cycles 5
// swift run -c release CollectionBenchmark10 render results10 chart.cow.remove.png
