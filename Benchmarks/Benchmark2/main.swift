import Benchmark
import Foundation
import MT19937
import RedBlackTreeModule
import Algorithms

var mt = mt19937_64(seed: 0)

typealias Fixture = RedBlackTreeSet

#if !ALLOCATION_DRILL || !USE_UNSAFE_TREE
  print("needs define ALLOCATION_DRILL and USE_UNSAFE_TREE")
  fatalError()
#else

  print("Benchmark2")
  print()
  #if USE_UNSAFE_TREE
    print("UNSAFE_TREE")
  #else
    print("ARRAY_TREE")
  #endif
  print(Date.now)
  print()

// [1, 3, 8, 17, 35, 72, 145, 291, 584, 1169, 2339, 4680, 9361, 18723, 37448, 74897, 149795, 299592, 599185, 1198371, 2396744, 4793489, 9586979, 19173960, 38347921]

let allocaSizes = ((0..<32).map({ 1 << $0 }) + [1, 3, 8, 17, 35, 72, 145, 291, 584, 1169, 2339, 4680, 9361, 18723, 37448, 74897, 149795, 299592, 599185, 1198371, 2396744, 4793489, 9586979, 19173960, 38347921])
  .sorted().uniqued()

  #if false
    for count in (0..<10).map({ 1 << $0 }) {
      for allocSize in allocaSizes {
        benchmark("reserveCapacity \(count) / \(allocSize)") {
          var f = Fixture<Int>.allocationDrill()
          for _ in 0..<max(1, count / allocSize) {
            f.pushFreshBucket(capacity: allocSize)
          }
        }
      }
    }
  #endif

  #if false
    for count in (4..<8).map({ 1 << $0 }) {
      for allocSize in allocaSizes {
        benchmark("reserveCapacity \(count) / \(allocSize)") {
          var f = Fixture<Int>.allocationDrill()
          for _ in 0..<max(1, count / allocSize) {
            f.pushFreshBucket(capacity: allocSize)
          }
        }
      }
    }
  #endif

  #if true
    for count in (16..<22).map({ 1 << $0 }) {
      for allocSize in allocaSizes {
        benchmark("reserveCapacity \(count) / \(allocSize)") {
          var f = Fixture<Int>.allocationDrill()
          for _ in 0..<max(1, count / allocSize) {
            f.pushFreshBucket(capacity: allocSize)
          }
        }
      }
    }
  #endif

  Benchmark.main()

#endif
