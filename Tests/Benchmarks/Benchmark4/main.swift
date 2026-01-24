import Benchmark
import Foundation
import MT19937
import RedBlackTreeModule

var mt = mt19937_64(seed: 0)

typealias Fixture = RedBlackTreeSet

#if !ALLOCATION_DRILL || !USE_UNSAFE_TREE
  print("needs define ALLOCATION_DRILL and USE_UNSAFE_TREE")
  fatalError()
#else

  print("Benchmark4")
  print()
  print("UNSAFE_TREE_V2")
  print(Date.now)
  print()

#if false
  let settings: [(numer: Int, denom: Int, minimum: Int)] = []

  for count in (8..<12).map({ 1 << $0 }) {
    for (numer, denom, minimum) in ((1...99).filter{ $0 % 2 == 0 }.map{ ($0, 100, 1) }) {
      growSetting = (numer, denom, minimum)
      benchmark("\(numer)/\(denom) - \(minimum) capacity to \(count)") {
        var fixture = Fixture<Int>()
        for i in 0..<count {
          fixture.insert(i)
        }
      }
    }
  }
#endif

do {
  for count in (8..<12).map({ 1 << $0 }) {
    let rounds = 200
    let hi = count
    let lo = count / 2
    
    for (numer, denom, minimum) in ((1...10).map{ ($0, 10, 1) }) {
      benchmark("\(numer)/\(denom) - \(minimum) swing \(count)") {
        var fixture = Fixture<Int>()
        
        for _ in 0..<rounds {
          // grow to hi
          for i in 0..<hi {
            fixture.insert(i)
          }
          // shrink to lo
          for i in 0..<lo {
            fixture.remove(i)
          }
        }
      }
    }
  }

  do {
    for count in (8..<12).map({ 1 << $0 }) {
      
      let R = 200_000
      var targets = [Int](repeating: 0, count: R)
      for i in 0..<R {
        targets[i] = Int(mt.next() % UInt64(count))
      }
      
      for (numer, denom, minimum) in ((1...10).map{ ($0, 10, 1) }) {
        benchmark("\(numer)/\(denom) - \(minimum) random \(count)") {
          var fixture = Fixture<Int>()
          var cur = 0
          
          for k in targets {
            while cur < k {
              fixture.insert(cur)
              cur += 1
            }
            while cur > k {
              cur -= 1
              fixture.remove(cur)
            }
          }
        }
      }
    }
    
    do {
      
      for count in (8..<12).map({ 1 << $0 }) {

        for (numer, denom, minimum) in ((1...10).map{ ($0, 10, 1) }) {
          
          benchmark("\(numer)/\(denom) - \(minimum) lookup \(count)") {
            var fixture = Fixture<Int>()
            for i in 0..<count { fixture.insert(i) }
            for i in 0..<count/2 { fixture.remove(i) }
            
            for _ in 0..<1_000_000 {
              _ = fixture.contains(Int(mt.next() % UInt64(count)))
            }
          }
        }
      }
    }

  }
}
#endif

Benchmark.main()
