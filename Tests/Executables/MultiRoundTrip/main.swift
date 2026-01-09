import RedBlackTreeModule

#if DEBUG
let N = 50
#else
let N = 2000
//let N = 300_000
#endif

var fixtures: [RedBlackTreeSet<Int>] = .init(repeating: .init(minimumCapacity: N), count: N)

#if true
for _ in 0..<1 {
  for j in 0..<N {
    for i in 0..<N {
      fixtures[i].insert(j)
    }
  }
//  for j in 0..<N {
//    for i in 0..<N {
//      fixtures[i].remove(j)
//    }
//  }
}
#endif
