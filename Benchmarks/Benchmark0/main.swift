import Benchmark
import RedBlackTreeModule
import MT19937

var mt = mt19937_64(seed: 0)

typealias Fixture = RedBlackTreeSet

#if USE_UNSAFE_TREE
print("UNSAFE_TREE")
#else
print("ARRAY_TREE")
#endif
print()

for count in [0, 32, 1024, 8192] {
  var fixture = Fixture<Int>(0..<count)
  benchmark("insert already presents \(count)") {
    fixture.insert((0..<count).randomElement(using: &mt) ?? 0)
  }
}

for count in [0, 32, 1024, 8192] {
  let fixture = Fixture<Int>()
  benchmark("insert new \(count)") {
    var f = fixture
    f.insert((0..<count).randomElement(using: &mt) ?? 0)
  }
}

for count in [0, 32, 1024, 8192] {
  benchmark("insert \(count)") {
    var fixture = Fixture<Int>()
    for i in 0..<count {
      fixture.insert(i)
    }
  }
}

do {
  let count = 100000
  benchmark("insert \(count)") {
    var fixture = Fixture<Int>()
    for i in 0..<count {
      fixture.insert(i)
    }
  }
}

benchmark("insert 1000000") {
  var fixture = Fixture<Int>()
  for i in 0..<1000000 {
    fixture.insert(i)
  }
}

do {
  for count in [0, 32, 1024, 8192] {
    let ii = (0..<count).shuffled(using: &mt)
    benchmark("insert shuffled \(count)") {
      var fixture = Fixture<Int>()
      for i in ii {
        fixture.insert(i)
      }
    }
  }
}

do {
  let count = 100000
  var fixture = Fixture<Int>((0..<count).map { $0 * 2 - 1})
  let ii = (0..<count).shuffled(using: &mt)
  benchmark("insert shuffled \(count)") {
    for i in ii {
      fixture.insert(i)
    }
  }
}

do {
  var fixture = Fixture<Int>((0..<1000000).map { $0 * 2 - 1})
  let ii = (0..<1000000).shuffled(using: &mt)
  benchmark("insert shuffled 1000000") {
    for i in ii {
      fixture.insert(i)
    }
  }
}

do {
  var fixture = Fixture<Int>(0..<1000)
  benchmark("remove 1000") {
    for i in 0..<1000 {
      fixture.remove(i)
    }
  }
}

do {
  var fixture = Fixture<Int>(0..<1000000)
  benchmark("remove 1000000") {
    for i in 0..<1000000 {
      fixture.remove(i)
    }
  }
}

do {
  for count in [0, 32, 1024, 8192] {
    benchmark("randomElement \(count)") {
      _ = (0..<count).randomElement() ?? 0
    }
  }
}

do {
  for count in [32, 1024, 8192] {
    var i = 0
    benchmark("sequencial element \(count)") {
      i = (i + 1) % count
    }
  }
}

do {
  for count in [32, 1024, 8192] {
    let fixture = Fixture<Int>(0..<count)
    var i = 0
    benchmark("lower bound \(count)") {
      _ = fixture.lowerBound((0..<count)[i])
      i = (i + 1) % count
    }
  }
}

do {
  for count in [32, 1024, 8192] {
    let fixture = Fixture<Int>(0..<count)
    var i = 0
    benchmark("upper bound \(count)") {
      _ = fixture.upperBound((0..<count)[i])
      i = (i + 1) % count
    }
  }
}

do {
  for count in [32, 1024, 8192] {
    let fixture = Fixture<Int>(0..<count)
    var i = 0
    benchmark("first index \(count)") {
      _ = fixture.firstIndex(of: i)
      i = (i + 1) % count
    }
  }
}

Benchmark.main()
