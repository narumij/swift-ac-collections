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
tree.reserveCapacity(count)
for i in 0 ..< count {
  _ = tree.insert(i)
}
for i in 0 ..< count {
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
var tree = RedBlackTreeSet<Int>(0 ..< count)
for i in tree[tree.startIndex ..< tree.endIndex] {
  tree.remove(i)
}
#elseif false
var tree = RedBlackTreeSet<Int>(0 ..< count)
for (i,_) in tree.enumerated() {
  tree.remove(at: i)
}
#elseif false
var tree = RedBlackTreeSet<Int>(0 ..< count)
for (i,v) in tree[tree.startIndex ..< tree.endIndex].enumerated() {
  tree.remove(at: i)
}
#elseif false
var tree = RedBlackTreeSet<Int>(0 ..< count)
tree[tree.startIndex ..< tree.endIndex].forEach { i in
  tree.remove(i)
}
#elseif false
var tree = RedBlackTreeSet<Int>(0 ..< count)
tree.enumerated().forEach { i, v in
  tree.remove(at: i)
}
#elseif false
var tree = RedBlackTreeSet<Int>(0 ..< count)
tree[tree.startIndex ..< tree.endIndex].enumerated().forEach { i, v in
  tree.remove(at: i)
}
#elseif false
var tree = RedBlackTreeSet<Int>(0 ..< count)
tree[0 ..< count].enumerated().forEach { i, v in
  tree.remove(at: i)
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
// これがいまだにCoW過剰発火している
//var xy: RedBlackTreeDictionary<Int, RedBlackTreeSet<Int>> = [1: .init(0 ..< 2_000_000)]
var xy: [Int: RedBlackTreeSet<Int>] = [1: .init(0 ..< 2_000_000)]
print("initialized")
let N = 1000
for i in 0 ..< 2_000_000 / N {
  if let lo = xy[1]?.lowerBound(i * N),
     let hi = xy[1]?.upperBound(i * N + N) {
    xy[1]?.removeSubrange(lo ..< hi)
//    xy[1, default: []].removeSubrange(lo ..< hi)
  }
}
#elseif false
// これがいまだにCoW過剰発火している
//var xy: RedBlackTreeDictionary<Int, RedBlackTreeSet<Int>> = [1: .init(0 ..< 2_000_000)]
var xy: [Int: RedBlackTreeSet<Int>] = [1: .init(0 ..< 2_000)]
print("initialized")
let N = 1000
for i in 0 ..< 10_000 / N {
  
//  print("1)",xy[1]?.checkUnique() != true ? "NG" : "OK") // OK
  
//  let lo = xy[1]?._ptr_lowerBound(i * N) // OK

//  let lo = xy[1]?._idx_lowerBound(i * N) // OK

  let lo = xy[1]?.startIndex
  
  print("2)", xy[1]?.checkUnique() != true ? "NG" : "OK") // NG
//  print("3)", xy[1]?.checkUnique2() != true ? "NG" : "OK") // NG
}
#elseif false
// これもまだ
//var xy: RedBlackTreeDictionary<Int, RedBlackTreeSet<Int>> = [1: .init(0 ..< count)]
var xy: [Int: RedBlackTreeSet<Int>] = [1: .init(0 ..< count)]
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
// これもまだ
var xy: RedBlackTreeDictionary<Int, RedBlackTreeSet<Int>> = [1: .init(0 ..< count)]
//var xy: [Int: RedBlackTreeSet<Int>] = [1: .init(0 ..< count)]
let N = 1000
for i in 0 ..< count / N {

//  let a = xy[1]
//  let a = xy[1]?[(i * N) ..< (i * N + N)]
//  let a = xy[1]?[(i * N) ..< (i * N + N)].enumerated()

//  print("0)", xy[1]?.checkUnique() != true ? "NG" : "OK") // NG

  xy[1]?[(i * N) ..< (i * N + N)].enumerated().forEach { i, v in
    print("0)", xy[1]?.checkUnique() != true ? "NG" : "OK") // NG
//    xy[1]?.ensureUnique()
    xy[1]?.remove(at: i)
  }
//     let hi = xy[1]?.upperBound(i * N + N) {
////    xy[1]?.removeSubrange(lo ..< hi)
//    xy[1, default: []].removeSubrange(lo ..< hi)
//  }
}#elseif false
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
#elseif false
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
