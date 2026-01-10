import RedBlackTreeModule
import Collections

#if DEBUG
let N = 50
#else
let N = 2000
//let N = 1_000_000
#endif


#if true
var fixtures: [RedBlackTreeSet<Int>] = .init(repeating: .init(), count: N)
//var fixtures: [Deque<Int>] = .init(repeating: .init(), count: N)
//var fixtures: [Set<Int>] = .init(repeating: .init(), count: N)

var flag = false
for _ in 0..<2 {
  for j in 0..<N {
    for i in 0..<N {
//      fixtures[i].insert(j)
    fixtures[i].insert(j)
//      fixtures[i].append(j)
    }
  }
  for j in 0..<N {
    for i in 0..<N {
      fixtures[i].remove(j)
      flag = fixtures[i].count % 2 == 0
//    fixtures[j].remove(contentsOf: 0..<N)
//      _ = fixtures[i].popFirst()
    }
  }
  for i in 0..<N {
//    for i in 0..<N {
      fixtures[i].removeAll()
//    }
  }
}
#elseif true
var fixtures: [RedBlackTreeSet<Int>] = .init(repeating: .init(), count: N)
for k in 0..<1 {
  for i in 0..<150 {
    for j in 0..<1_000_000 {
      fixtures[i].reserveCapacity(j)
    }
  }
  for i in 0..<N {
      fixtures[i].removeAll()
  }
}
#else
enum Base<K,V>: ValueComparer {
  static func __key(_: V) -> K {
    fatalError()
  }
  static func value_comp(_: K, _: K) -> Bool {
    fatalError()
  }
  typealias _Key = K
  typealias _Value = V
}

struct Fixture<B,K> where B: ValueComparer, B._Key == K, K: Comparable {
  
  func comp(l: K, r: K) -> Bool {
    l < r
  }
}

var fixture = Fixture<Base<Int,Int>,Int>()

var result = false
for _ in 0..<10000000 {
  let l = Int.random(in: 0..<Int.max)
  let r = Int.random(in: 0..<Int.max)
  result = fixture.comp(l: l, r: r)
}
print(result)

#endif

