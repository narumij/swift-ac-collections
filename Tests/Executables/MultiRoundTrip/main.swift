import RedBlackTreeModule

#if DEBUG
let N = 50
#else
let N = 2000
//let N = 300_000
#endif


#if true
var fixtures: [RedBlackTreeSet<Int>] = .init(repeating: .init(minimumCapacity: N), count: N)

for _ in 0..<1 {
  for j in 0..<N {
    for i in 0..<N {
      fixtures[i].insert(j)
    }
  }
  for j in 0..<N {
    for i in 0..<N {
      fixtures[i].remove(j)
    }
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

