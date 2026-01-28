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

#if false
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
#endif

for count in [0, 32, 1024, 8192, 1024 * 32, 1024 * 128, 1024 * 1024] {
  let fixture = Fixture<Int>(0..<count)
  benchmark("RBT first index of \(count)") {
    let _ = fixture.firstIndex(of: (0..<count).randomElement() ?? 0)
  }
}

for count in [0, 32, 1024, 8192, 1024 * 32, 1024 * 128, 1024 * 1024] {
  let fixture = Array<Int>(0..<count)
  benchmark("Array first index of \(count)") {
    let _ = fixture.firstIndex(of: (0..<count).randomElement() ?? 0)
  }
}

for count in [0, 32, 1024, 8192, 1024 * 32] {
  let fixture = Deque<Int>(0..<count)
  benchmark("Deque first index of \(count)") {
    let _ = fixture.firstIndex(of: (0..<count).randomElement() ?? 0)
  }
}

for count in [1000000] {
  var fixture = Fixture<Int>(0..<count)
  var shuffled = (0..<count).shuffled()
  benchmark("RBT remove \(count)") {
    let _ = fixture.remove(shuffled.popLast() ?? 0)
  }
}

for count in [1000000] {
  var fixture = Array<Int>(0..<count)
  var shuffled = (0..<count).shuffled()
  benchmark("Array remove \(count)") {
    let _ = fixture.remove(at: fixture.firstIndex(of: shuffled.popLast() ?? 0) ?? 0)
  }
}

for count in [1000000] {
  var fixture = Deque<Int>(0..<count)
  var shuffled = (0..<count).shuffled()
  benchmark("Deque remove \(count)") {
    let _ = fixture.remove(at: fixture.firstIndex(of: shuffled.popLast() ?? 0) ?? 0)
  }
}

#if COMPATIBLE_ATCODER_2025
for count in [1000000] {
  var fixture = Fixture<Int>(0..<count)
  benchmark("RBT popFirst \(count)") {
    let _ = fixture.popFirst()
  }
}
#else
for count in [1000000] {
  var fixture = Fixture<Int>(0..<count)
  benchmark("RBT popMin \(count)") {
    let _ = fixture.popMin()
  }
}
#endif

for count in [1000000] {
  var fixture = Array<Int>(0..<count)
  benchmark("Array popLast \(count)") {
    let _ = fixture.popLast()
  }
}

for count in [1000000] {
  var fixture = Heap<Int>(0..<count)
  benchmark("Heap popMin \(count)") {
    let _ = fixture.popMin()
  }
}

for count in [1000000] {
  var fixture = Deque<Int>(0..<count)
  benchmark("Deque popMin \(count)") {
    let _ = fixture.popFirst()
  }
}

Benchmark.main()
