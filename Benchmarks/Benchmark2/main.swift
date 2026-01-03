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
for count in (0..<4).map({ 1 << $0 }) {
  for allocSize in (0..<32).map({ 1 << $0 }) {
    allocationChunkSize = allocSize
    benchmark("reserveCapacity \(count) / \(allocationChunkSize)") {
      var f = Fixture<Int>()
      for i in 0..<count {
        f.reserveCapacity(i)
        f.insert(i)
        assert(f.capacity == i)
      }
    }
  }
}
#endif

#if false
for amount in (4..<8).map({ 1 << $0 }) {
  for allocSize in (0..<12).map({ 1 << $0 }) {
    allocationChunkSize = allocSize
    benchmark("reserveCapacity \(amount) / \(allocationChunkSize)") {
      var f = Fixture<Int>()
      for i in 0..<amount {
        f.reserveCapacity(i)
        assert(f.capacity == i)
      }
    }
  }
}
#endif

#if false
for amount in (8..<12).map({ 1 << $0 }) {
  for allocSize in (0..<12).map({ 1 << $0 }) {
    allocationChunkSize = allocSize
    benchmark("reserveCapacity \(amount) / \(allocationChunkSize)") {
      var f = Fixture<Int>()
      for i in 0..<amount {
        f.reserveCapacity(i)
        assert(f.capacity == i)
      }
    }
  }
}
#endif

#if false
for amount in (12..<16).map({ 1 << $0 }) {
  for allocSize in (0..<12).map({ 1 << $0 }) {
    allocationChunkSize = allocSize
    benchmark("reserveCapacity \(amount) / \(allocationChunkSize)") {
      var f = Fixture<Int>()
      for i in 0..<amount {
        f.reserveCapacity(i)
        assert(f.capacity == i)
      }
    }
  }
}
#endif

#if false
for amount in (16..<20).map({ 1 << $0 }) {
  for allocSize in (0..<12).map({ 1 << $0 }) {
    allocationChunkSize = allocSize
    benchmark("reserveCapacity \(amount) / \(allocationChunkSize)") {
      var f = Fixture<Int>()
      for i in 0..<amount {
        f.reserveCapacity(i)
        assert(f.capacity == i)
      }
    }
  }
}
#endif

#if false
for amount in (20..<24).map({ 1 << $0 }) {
  for allocSize in (0..<12).map({ 1 << $0 }) {
    allocationChunkSize = allocSize
    benchmark("reserveCapacity \(amount) / \(allocationChunkSize)") {
      var f = Fixture<Int>()
      for i in 0..<amount {
        f.reserveCapacity(i)
        assert(f.capacity == i)
      }
    }
  }
}
#endif

#if false
for amount in (24..<28).map({ 1 << $0 }) {
  for allocSize in (0..<12).map({ 1 << $0 }) {
    allocationChunkSize = allocSize
    benchmark("reserveCapacity \(amount) / \(allocationChunkSize)") {
      var f = Fixture<Int>()
      for i in 0..<amount {
        f.reserveCapacity(i)
        assert(f.capacity == i)
      }
    }
  }
}
#endif

//for allocSize in [2,4,8,16,32,64,128] {
//  for count in (0..<6).map({ 1 << $0 }) {
//    benchmark("insert \(count) with allocSize \(allocSize)") {
//      var f = Fixture<Int>()
//      for i in 0..<count {
//        f.insert(i)
//      }
//    }
//  }
//}

Benchmark.main()
