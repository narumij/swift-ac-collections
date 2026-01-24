import Benchmark
import RedBlackTreeModule
import MT19937
import Foundation
import Collections

var mt = mt19937_64(seed: 0)

typealias Fixture = RedBlackTreeSet

#if !BENCHMARK
  print("needs define BENCHMARK")
  fatalError()
#else
print(Date.now)
print()

print("\(RedBlackTreeSet<Int>.buildInfo)")
print()

//for count in [32, 128, 1024, 8192, 1024 * 32, 1024 * 128, 1024 * 1024, 1024 * 1024 * 2, 1024 * 1024 * 16, 1024 * 1024 * 128] {
for count in [1024 * 1024 * 2, 1024 * 1024 * 16, 1024 * 1024 * 128] {
  let fixture = Fixture<Int>(0..<count)
  let ii = fixture.indices + []
  let pair = zip(ii.shuffled(), ii.shuffled()) + []
  
  #if false
  do {
    var i = 0
    benchmark("RBT ___dual_distance \(count)") {
      let (a,b) = pair[i]
      let _ = fixture.___dual_distance(start: a,end: b)
      i += 1
      i %= count
    }
  }
  
  do {
    var i = 0
    benchmark("RBT ___comp_distance \(count)") {
      let (a,b) = pair[i]
      let _ = fixture.___comp_distance(start: a,end: b)
      i += 1
      i %= count
    }
  }
  #endif
  
  do {
    var i = 0
    benchmark("RBT ___comp_multi (1) \(count)") {
      let (a,b) = pair[i]
      let _ = fixture.___comp_mult(start: a,end: b)
      i += 1
      i %= count
    }
  }
  
  do {
    var i = 0
    benchmark("RBT ___comp_multi2 (1) \(count)") {
      let (a,b) = pair[i]
      let _ = fixture.___comp_mult2(start: a,end: b)
      i += 1
      i %= count
    }
  }
  
  do {
    var i = 0
    benchmark("RBT ___comp_bitmap (1) \(count)") {
      let (a,b) = pair[i]
      let _ = fixture.___comp_bitmap(start: a,end: b)
      i += 1
      i %= count
    }
  }
  
  do {
    var i = 0
    benchmark("RBT ___comp_multi (2) \(count)") {
      let (a,b) = pair[i]
      let _ = fixture.___comp_mult(start: a,end: b)
      i += 1
      i %= count
    }
  }

  do {
    var i = 0
    benchmark("RBT ___comp_multi2 (2) \(count)") {
      let (a,b) = pair[i]
      let _ = fixture.___comp_mult2(start: a,end: b)
      i += 1
      i %= count
    }
  }

  do {
    var i = 0
    benchmark("RBT ___comp_bitmap (2) \(count)") {
      let (a,b) = pair[i]
      let _ = fixture.___comp_bitmap(start: a,end: b)
      i += 1
      i %= count
    }
  }
}

Benchmark.main()
#endif
