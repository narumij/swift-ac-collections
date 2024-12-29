// Instrumentsでの計測用の作業コマンド

import Foundation
import RedBlackTreeModule

#if DEBUG
let count = 500_000
#else
let count = 2_000_000
//let count = 1_000_000
#endif

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
var tree = RedBlackTreeSet<Int>(0 ..< count)
for v in tree {
  tree.remove(v)
}
#elseif false
var xy: [Int:RedBlackTreeSet<Int>] = [1: .init(0 ..< count)]
for i in xy[1, default: []] {
  xy[1, default: []].remove(i)
//  xy[1, default: []].remove(i)
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
#elseif true
var xy: RedBlackTreeDictionary<Int, RedBlackTreeSet<Int>> = [1: .init(0 ..< count)]
let N = 1000
for i in 0 ..< count / N {
  xy[1]?[(i * N) ..< (i * N + N)].enumerated().forEach { i, v in
    xy[1]?.remove(at: i)
  }
//     let hi = xy[1]?.upperBound(i * N + N) {
////    xy[1]?.removeSubrange(lo ..< hi)
//    xy[1, default: []].removeSubrange(lo ..< hi)
//  }
}
#elseif true
var xy: RedBlackTreeDictionary<Int,RedBlackTreeSet<Int>> = [1: []]
for i in 0 ..< 2_000_000 {
  xy[1, default: []].insert(i)
//  xy[1, default: []].remove(i)
}
#elseif false
var xy: [Int:RedBlackTreeSet<Int>] = [1: []]
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
#elseif true
var xy: RedBlackTreeDictionary<Int,RedBlackTreeSet<Int>> = [1: .init(0 ..< 2_000_000)]
for i in 0 ..< 2_000_000 {
//  _ = xy[1]?.lowerBound(i)
  xy[1]?.removeAndForEach(0 ..< i) { e in
    _ = e + 1
  }
}
#else
var xy: [Int:[Int]] = [1:(0 ..< 2_000_000) + []]
  for i in 0 ..< 2_000_000 {
    _ = xy[1]?[i] = 100
    _ = 1 + (xy[1]?[i / 2] ?? 0)
  }
#endif
print("Hola!")


extension RedBlackTreeSet {

  @inlinable
  public subscript(bounds: Range<Element>) -> SubSequence {
    self[lowerBound(bounds.lowerBound) ..< upperBound(bounds.upperBound)]
  }
  
  @inlinable
  public mutating func removeAndForEach(
    _ range: Range<Element>,
    _ action: (Element) throws -> ()) rethrows {
    try ___remove(
      from: ___ptr_lower_bound(range.lowerBound),
      to: ___ptr_upper_bound(range.upperBound),
      forEach: action)
  }
}
