import Benchmark
import RedBlackTreeModule
import MT19937
import Foundation
import Collections

var mt = mt19937_64(seed: 0)

typealias Fixture = RedBlackTreeSet

print(Date.now)
print()

print("\(RedBlackTreeSet<Int>.buildInfo)")
print()

for count in [0, 32, 1024, 8192, 1024 * 32, 1024 * 128] {
  benchmark("init RBT with Range \(count)") {
    var fixture = Fixture<Int>(0..<count)
  }
}

for count in [0, 32, 1024, 8192, 1024 * 32, 1024 * 128] {
  benchmark("init Heap with Range \(count)") {
    var fixture = Heap<Int>(0..<count)
  }
}

for count in [0, 32, 1024, 8192, 1024 * 32, 1024 * 128] {
  benchmark("init Deque with Range \(count)") {
    var fixture = Deque<Int>(0..<count)
  }
}

for count in [0, 32, 1024, 8192, 1024 * 32, 1024 * 128] {
  var fixture = Fixture<Int>(0..<count)
  benchmark("RBT copy \(count)") {
    var f = fixture
    f.reserveCapacity(f.count + 1)
  }
}

for count in [0, 32, 1024, 8192, 1024 * 32, 1024 * 128] {
  var fixture = Heap<Int>(0..<count)
  benchmark("Heap copy \(count)") {
    var f = fixture
    f.reserveCapacity(f.count + 1)
  }
}

for count in [0, 32, 1024, 8192, 1024 * 32, 1024 * 128] {
  var fixture = Deque<Int>(0..<count)
  benchmark("Deque copy \(count)") {
    var f = fixture
    f.reserveCapacity(f.count + 1)
  }
}

for count in [0, 32, 1024, 8192, 1024 * 32, 1024 * 128] {
  let ii = (0..<count).shuffled(using: &mt)
  benchmark("RBT insert \(count)") {
    var fixture = Fixture<Int>()
    for i in ii {
      fixture.insert(i)
    }
  }
}

for count in [0, 32, 1024, 8192, 1024 * 32, 1024 * 128] {
  let ii = (0..<count).shuffled(using: &mt)
  benchmark("Heap insert \(count)") {
    var fixture = Heap<Int>()
    for i in ii {
      fixture.insert(i)
    }
  }
}

for count in [0, 32, 1024, 8192, 1024 * 32, 1024 * 128] {
  let ii = (0..<count).shuffled(using: &mt)
  benchmark("Deque insert \(count)") {
    var fixture = Deque<Int>()
    for i in ii {
      fixture.append(i)
    }
  }
}

Benchmark.main()
