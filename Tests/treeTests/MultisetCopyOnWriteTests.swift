//
//  RedBlackTreeCopyOnWriteTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/12/31.
//

import RedBlackTreeModule
import XCTest

#if AC_COLLECTIONS_INTERNAL_CHECKS
final class MultisetCopyOnWriteTests: XCTestCase {

  let count = 2_000_000

  func testSet1() throws {
    var set = RedBlackTreeMultiset<Int>()
    XCTAssertEqual(set._copyCount, 0)
    set.insert(0)
    XCTAssertGreaterThanOrEqual(set._copyCount, 1) // 挿入に備え、かつ消費
    set.insert(0)
    XCTAssertGreaterThanOrEqual(set._copyCount, 2) // 挿入に備え、かつ消費
    set.insert(0)
    XCTAssertGreaterThanOrEqual(set._copyCount, 3) // 挿入に備え、かつ消費
  }

  func testSet2() throws {
    var set = RedBlackTreeMultiset<Int>(minimumCapacity: 1)
    XCTAssertEqual(set._copyCount, 0)
    set.insert(0)
    XCTAssertEqual(set._copyCount, 0)
    set.remove(0)
    XCTAssertEqual(set._copyCount, 0)
    _ = set.lowerBound(0)
    _ = set.upperBound(0)
    for s in set {
      print(s)
    }
    set.forEach {
      print($0)
    }
    print(set.map{ $0 })
    print(set.filter{ $0 != 0 })
    print(set.reduce(0, +))
    print(set.reduce(into: []) { $0.append($1) })
    XCTAssertEqual(set._copyCount, 0)
  }
  
  func testSet3() throws {
    var tree = RedBlackTreeMultiset<Int>(0 ..< 20)
    tree._copyCount = 0
    for v in tree {
      tree.remove(v) // strong ensure unique
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 1) // multi setの場合、インデックスを破壊するので1とする
  }
  
  func testSet3_2() throws {
    var tree = RedBlackTreeMultiset<Int>(0 ..< 20)
    tree._copyCount = 0
    for v in tree.map({ $0 }) {
      tree.remove(v) // strong ensure unique
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0) // mapで操作が済んでいるので、インデックス破壊の心配がない
  }

  func testSet4() throws {
    var tree = RedBlackTreeMultiset<Int>(0 ..< 20)
    tree._copyCount = 0
    tree.forEach { v in
      tree.remove(v)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 1)
  }

  func testSet5() throws {
    var tree = RedBlackTreeMultiset<Int>(0 ..< 20)
    tree._copyCount = 0
    for v in tree.map({ $0}) {
      tree.remove(v)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0)
  }
  
  func testSet6() throws {
    var tree = RedBlackTreeMultiset<Int>(0 ..< 20)
    tree._copyCount = 0
    for v in tree.filter({ _ in true }) {
      tree.remove(v)
    }
    XCTAssertEqual(tree.count, 0)
    XCTAssertEqual(tree._copyCount, 0)
  }

  func testSet3000() throws {
    let count = 1500
    var loopCount = 0
    var xy: [Int: RedBlackTreeMultiset<Int>] = [1: .init(0 ..< count)]
    xy[1]?._copyCount = 0
    let N = 100
    for i in 0 ..< count / N {
      loopCount += 1
      if let lo = xy[1]?.lowerBound(i * N),
         let hi = xy[1]?.upperBound(i * N + N) {
        xy[1]?.removeSubrange(lo ..< hi)
      }
    }
    XCTAssertTrue(xy[1]!._checkUnique())
    XCTAssertEqual(xy[1]!.count, 0)
    XCTAssertEqual(xy[1]!._copyCount, 0)
    XCTAssertEqual(loopCount, count / N)
  }

  func testSet4000() throws {
    let count = 1500
    var xy: [Int: RedBlackTreeMultiset<Int>] = [1: .init(0 ..< count)]
    xy[1]?._copyCount = 0
    let N = 100
    var loopCount = 0
    for i in 0 ..< count / N {
      loopCount += 1
      xy[1]?[(i * N) ..< (i * N + N)].enumerated().forEach { i, v in
        xy[1]?.remove(at: i)
      }
    }
    XCTAssertTrue(xy[1]!._checkUnique())
    XCTAssertEqual(xy[1]!.count, 0)
    XCTAssertEqual(xy[1]!._copyCount, 0)
    XCTAssertEqual(loopCount, count / N)
  }
}
#endif
