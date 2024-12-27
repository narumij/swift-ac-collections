// Instrumentsでの計測用の作業コマンド

import Foundation
import RedBlackTreeModule

#if false
var tree = RedBlackTreeSet<Int>()
//let tree = RedBlackTree.Storage<Int>()
tree.reserveCapacity(1_000_000)
for i in 0 ..< 1_000_000 {
    _ = tree.__insert_unique(i)
}
for i in 0 ..< 1_000_000 {
  _ = tree.remove(i)
}
#elseif false
var tree = RedBlackTreeSet<Int>(0 ..< 10_000_000)
for v in 0..<10_000_000 {
  tree.remove(v)
}
#elseif false
var xy: RedBlackTreeDictionary<Int,RedBlackTreeSet<Int>> = [:]
for i in 0 ..< 2_000_000 {
  xy[1, default: []].insert(i)
}
#elseif false
var xy: RedBlackTreeDictionary<Int,RedBlackTreeSet<Int>> = [1: .init(0 ..< 2_000_000)]
for i in 0 ..< 200_000 {
  // 不正なインデックスに関する修正が必要そう
  xy[1]?.removeSubrange(.node(i) ..< .node(i + 10))
}
#elseif false
var xy: RedBlackTreeDictionary<Int, RedBlackTreeSet<Int>> = [1: .init(0 ..< 2_000_000)]
let N = 1000
for i in 0 ..< 2_000_000 / N {
  if let lo = xy[1]?.lowerBound(i * N),
     let hi = xy[1]?.upperBound(i * N + N) {
//    xy[1]?.removeSubrange(lo ..< hi)
    xy[1, default: []].removeSubrange(lo ..< hi)
  }
}
#elseif false
var xy: RedBlackTreeDictionary<Int,RedBlackTreeSet<Int>> = [1: []]
for i in 0 ..< 2_000_000 {
  xy[1]?.insert(i)
//  xy[1, default: []].remove(i)
}
#elseif false
var xy: RedBlackTreeDictionary<Int,RedBlackTreeSet<Int>> = [1: .init(0 ..< 2_000_000)]
for i in 0 ..< 2_000_000 {
  xy[1]?.remove(i)
//  xy[1, default: []].remove(i)
}
#elseif false
var xy: [Int:RedBlackTreeSet<Int>] = [1: .init(0 ..< 2_000_000)]
for i in 0 ..< 2_000_000 {
  xy[1]?.remove(i)
//  xy[1, default: []].remove(i)
}
#elseif false
var xy: RedBlackTreeDictionary<Int,RedBlackTreeSet<Int>> = [1: .init(0 ..< 2_000_000)]
for i in 0 ..< 2_000_000 {
  _ = xy[1]?.lowerBound(i)
}
#elseif true
var x = Container(minimumCapacity: 0)
for i in 0 ..< 1_000_000 {
  x.insert(i)
}
for i in 0 ..< 1_000_000 {
  x.remove(i)
}
#else
var xy: [Int:[Int]] = [1:(0 ..< 2_000_000) + []]
  for i in 0 ..< 2_000_000 {
    _ = xy[1]?[i] = 100
    _ = 1 + (xy[1]?[i / 2] ?? 0)
  }
#endif
print("Hola!")

