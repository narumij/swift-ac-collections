// Instrumentsでの計測用の作業コマンド

import Foundation
import RedBlackTreeModule

#if false
var tree = RedBlackTree.Container<Int>()
//let tree = RedBlackTree.Storage<Int>()

tree.reserveCapacity(1_000_000)
for i in 0 ..< 1_000_000 {
    _ = tree.__insert_unique(i)
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
// 追試が必要
var xy: RedBlackTreeDictionary<Int,RedBlackTreeSet<Int>> = [1: .init(0 ..< 2_000_000)]
for i in 0 ..< 200_000 {
  // 不正なインデックスに関する修正が必要そう
  xy[1]?.removeSubrange(.node(i) ..< .node(i + 10))
}
#elseif true
// 追試が必要
var xy: RedBlackTreeDictionary<Int, RedBlackTreeSet<Int>> = [1: .init(0 ..< 2_000_000)]
for i in 0 ..< 2_000_000 / 1000 {
  if let lo = xy[1]?.lowerBound(i * 1000),
     let hi = xy[1]?.upperBound(i * 1000 + 1000) {
    xy[1]?.removeSubrange(lo ..< hi)
  }
}
#elseif false
var xy: RedBlackTreeDictionary<Int,RedBlackTreeSet<Int>> = [1: .init(0 ..< 2_000_000)]
for i in 0 ..< 2_000_000 {
  xy[1]?.remove(i)
}
#else
var xy: RedBlackTreeDictionary<Int,RedBlackTreeSet<Int>> = [1: .init(0 ..< 2_000_000)]
for i in 0 ..< 2_000_000 {
  _ = xy[1]?.lowerBound(i)
}
#endif
print("Hola!")

