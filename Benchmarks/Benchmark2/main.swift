import Benchmark
import Foundation
import MT19937
import RedBlackTreeModule

var mt = mt19937_64(seed: 0)

typealias Fixture = RedBlackTreeSet

#if !ALLOCATION_DRILL || !USE_UNSAFE_TREE
  print("needs define ALLOCATION_DRILL and USE_UNSAFE_TREE")
  fatalError()
#endif

print("Benchmark2")
print()
#if USE_UNSAFE_TREE
  print("UNSAFE_TREE")
#else
  print("ARRAY_TREE")
#endif
print(Date.now)
print()

#if true
for count in (0..<10).map({ 1 << $0 }) {
  for allocSize in (0..<32).map({ 1 << $0 }) {
    benchmark("reserveCapacity \(count) / \(allocSize)") {
      var f = Fixture<Int>()
      for _ in 0..<max(1, count / allocSize) {
        f.pushFreshBucket(capacity: allocSize)
      }
    }
  }
}
#endif

#if false
for count in (4..<8).map({ 1 << $0 }) {
  for allocSize in (0..<32).map({ 1 << $0 }) {
    benchmark("reserveCapacity \(count) / \(allocSize)") {
      var f = Fixture<Int>()
      for _ in 0..<max(1, count / allocSize) {
        f.pushFreshBucket(capacity: allocSize)
      }
    }
  }
}
#endif

#if false
for count in (16..<22).map({ 1 << $0 }) {
  for allocSize in (0..<32).map({ 1 << $0 }) {
    benchmark("reserveCapacity \(count) / \(allocSize)") {
      var f = Fixture<Int>()
      for _ in 0..<max(1, count / allocSize) {
        f.pushFreshBucket(capacity: allocSize)
      }
    }
  }
}
#endif

Benchmark.main()
