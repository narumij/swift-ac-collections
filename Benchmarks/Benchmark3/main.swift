import Benchmark
import RedBlackTreeModule
import MT19937
import Foundation

var mt = mt19937_64(seed: 0)

typealias Fixture = RedBlackTreeSet

print("Benchmark3")
print()
print("UNSAFE_TREE_V2")
print(Date.now)
print()

let limit = 25

for count in (0..<limit).filter({ $0 % 2 == 1 }).map({ 1 << $0 }) {
  benchmark("reserveCapacity \(count)") {
    var fixture = Fixture<Int>()
    for i in 0..<count {
      fixture.reserveCapacity(i)
    }
  }
}

for count in (0..<limit).filter({ $0 % 2 == 1 }).map({ 1 << $0 }) {
  let x = 16
  benchmark("reserveCapacity \(count) x \(x)") {
    var fixtures = Array<Fixture<Int>>(repeating: .init(), count: x)
    for i in 0..<count {
      for j in 0..<x {
        fixtures[j].reserveCapacity(i)
      }
    }
  }
}

for count in (0..<limit).filter({ $0 % 2 == 1 }).map({ 1 << $0 }) {
  benchmark("init with range \(count)") {
    let fixture = Fixture<Int>(0..<count)
  }
}

for count in (0..<limit).filter({ $0 % 2 == 1 }).map({ 1 << $0 }) {
  benchmark("copy \(count)") {
    var fixture = Fixture<Int>(0..<count)
    fixture.insert(-1)
  }
}

for count in (0..<limit).filter({ $0 % 2 == 1 }).map({ 1 << $0 }) {
  benchmark("removeAll(keepingCapacity: true) \(count)") {
    var fixture = Fixture<Int>(0..<count)
    fixture.removeAll(keepingCapacity: true)
  }
}

for count in (0..<limit).filter({ $0 % 2 == 1 }).map({ 1 << $0 }) {
  let x = 16
  benchmark("removeAll(keepingCapacity: false) \(count)") {
    var fixture = Fixture<Int>(0..<count)
    fixture.removeAll(keepingCapacity: false)
  }
}

Benchmark.main()
