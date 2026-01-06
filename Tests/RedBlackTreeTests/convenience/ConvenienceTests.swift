//
//  ConvenienceTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/09/16.
//

import XCTest
import RedBlackTreeModule

final class ConvenienceTests: RedBlackTreeTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }
  
  func test_set_LT_GT() throws {
    var set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set.count, 5)
    XCTAssertEqual(set.lessThan(-1), nil)
    XCTAssertEqual(set.greaterThan(-1), 0)
    XCTAssertEqual(set.lessThan(0), nil)
    XCTAssertEqual(set.greaterThan(0), 1)
    XCTAssertEqual(set.lessThan(1), 0)
    XCTAssertEqual(set.greaterThan(1), 2)
    XCTAssertEqual(set.lessThan(2), 1)
    XCTAssertEqual(set.greaterThan(2), 3)
    XCTAssertEqual(set.lessThan(3), 2)
    XCTAssertEqual(set.greaterThan(3), 4)
    XCTAssertEqual(set.lessThan(4), 3)
    XCTAssertEqual(set.greaterThan(4), nil)
    XCTAssertEqual(set.lessThan(5), 4)
    XCTAssertEqual(set.greaterThan(5), nil)
    XCTAssertEqual(set.remove(1), 1)
    XCTAssertEqual(set.remove(3), 3)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertEqual(set.elements, [0, 2, 4])
    XCTAssertEqual(set.lessThan(-1), nil)
    XCTAssertEqual(set.greaterThan(-1), 0)
    XCTAssertEqual(set.lessThan(0), nil)
    XCTAssertEqual(set.greaterThan(0), 2)
    XCTAssertEqual(set.lessThan(1), 0)
    XCTAssertEqual(set.greaterThan(1), 2)
    XCTAssertEqual(set.lessThan(2), 0)
    XCTAssertEqual(set.greaterThan(2), 4)
    XCTAssertEqual(set.lessThan(3), 2)
    XCTAssertEqual(set.greaterThan(3), 4)
    XCTAssertEqual(set.lessThan(4), 2)
    XCTAssertEqual(set.greaterThan(4), nil)
    XCTAssertEqual(set.lessThan(5), 4)
    XCTAssertEqual(set.greaterThan(5), nil)
    XCTAssertEqual(set.remove(2), 2)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertEqual(set.remove(2), nil)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertEqual(set.elements, [0, 4])
    XCTAssertEqual(set.lessThan(-1), nil)
    XCTAssertEqual(set.greaterThan(-1), 0)
    XCTAssertEqual(set.lessThan(0), nil)
    XCTAssertEqual(set.greaterThan(0), 4)
    XCTAssertEqual(set.lessThan(1), 0)
    XCTAssertEqual(set.greaterThan(1), 4)
    XCTAssertEqual(set.lessThan(2), 0)
    XCTAssertEqual(set.greaterThan(2), 4)
    XCTAssertEqual(set.lessThan(3), 0)
    XCTAssertEqual(set.greaterThan(3), 4)
    XCTAssertEqual(set.lessThan(4), 0)
    XCTAssertEqual(set.greaterThan(4), nil)
    XCTAssertEqual(set.lessThan(5), 4)
    XCTAssertEqual(set.greaterThan(5), nil)
    XCTAssertEqual(set.remove(0), 0)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertEqual(set.remove(2), nil)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertEqual(set.remove(4), 4)
    XCTAssertEqual(set.lessThan(-1), nil)
    XCTAssertEqual(set.greaterThan(-1), nil)
    XCTAssertEqual(set.lessThan(0), nil)
    XCTAssertEqual(set.greaterThan(0), nil)
    XCTAssertEqual(set.lessThan(1), nil)
    XCTAssertEqual(set.greaterThan(1), nil)
    XCTAssertEqual(set.lessThan(2), nil)
    XCTAssertEqual(set.greaterThan(2), nil)
    XCTAssertEqual(set.lessThan(3), nil)
    XCTAssertEqual(set.greaterThan(3), nil)
    XCTAssertEqual(set.lessThan(4), nil)
    XCTAssertEqual(set.greaterThan(4), nil)
    XCTAssertEqual(set.lessThan(5), nil)
    XCTAssertEqual(set.greaterThan(5), nil)
    XCTAssertEqual(set.elements, [])
  }

  func test_set_LE_GE() throws {
    var set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set.count, 5)
    XCTAssertEqual(set.lessThanOrEqual(-1), nil)
    XCTAssertEqual(set.greaterThanOrEqual(-1), 0)
    XCTAssertEqual(set.lessThanOrEqual(0), 0)
    XCTAssertEqual(set.greaterThanOrEqual(0), 0)
    XCTAssertEqual(set.lessThanOrEqual(1), 1)
    XCTAssertEqual(set.greaterThanOrEqual(1), 1)
    XCTAssertEqual(set.lessThanOrEqual(2), 2)
    XCTAssertEqual(set.greaterThanOrEqual(2), 2)
    XCTAssertEqual(set.lessThanOrEqual(3), 3)
    XCTAssertEqual(set.greaterThanOrEqual(3), 3)
    XCTAssertEqual(set.lessThanOrEqual(4), 4)
    XCTAssertEqual(set.greaterThanOrEqual(4), 4)
    XCTAssertEqual(set.lessThanOrEqual(5), 4)
    XCTAssertEqual(set.greaterThanOrEqual(5), nil)
    XCTAssertEqual(set.remove(1), 1)
    XCTAssertEqual(set.remove(3), 3)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertEqual(set.elements, [0, 2, 4])
    XCTAssertEqual(set.lessThanOrEqual(-1), nil)
    XCTAssertEqual(set.greaterThanOrEqual(-1), 0)
    XCTAssertEqual(set.lessThanOrEqual(0), 0)
    XCTAssertEqual(set.greaterThanOrEqual(0), 0)
    XCTAssertEqual(set.lessThanOrEqual(1), 0)
    XCTAssertEqual(set.greaterThanOrEqual(1), 2)
    XCTAssertEqual(set.lessThanOrEqual(2), 2)
    XCTAssertEqual(set.greaterThanOrEqual(2), 2)
    XCTAssertEqual(set.lessThanOrEqual(3), 2)
    XCTAssertEqual(set.greaterThanOrEqual(3), 4)
    XCTAssertEqual(set.lessThanOrEqual(4), 4)
    XCTAssertEqual(set.greaterThanOrEqual(4), 4)
    XCTAssertEqual(set.lessThanOrEqual(5), 4)
    XCTAssertEqual(set.greaterThanOrEqual(5), nil)
    XCTAssertEqual(set.remove(2), 2)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertEqual(set.remove(2), nil)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertEqual(set.elements, [0, 4])
    XCTAssertEqual(set.lessThanOrEqual(-1), nil)
    XCTAssertEqual(set.greaterThanOrEqual(-1), 0)
    XCTAssertEqual(set.lessThanOrEqual(0), 0)
    XCTAssertEqual(set.greaterThanOrEqual(0), 0)
    XCTAssertEqual(set.lessThanOrEqual(1), 0)
    XCTAssertEqual(set.greaterThanOrEqual(1), 4)
    XCTAssertEqual(set.lessThanOrEqual(2), 0)
    XCTAssertEqual(set.greaterThanOrEqual(2), 4)
    XCTAssertEqual(set.lessThanOrEqual(3), 0)
    XCTAssertEqual(set.greaterThanOrEqual(3), 4)
    XCTAssertEqual(set.lessThanOrEqual(4), 4)
    XCTAssertEqual(set.greaterThanOrEqual(4), 4)
    XCTAssertEqual(set.lessThanOrEqual(5), 4)
    XCTAssertEqual(set.greaterThanOrEqual(5), nil)
    XCTAssertEqual(set.remove(0), 0)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertEqual(set.remove(2), nil)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertEqual(set.remove(4), 4)
    XCTAssertEqual(set.lessThanOrEqual(-1), nil)
    XCTAssertEqual(set.greaterThanOrEqual(-1), nil)
    XCTAssertEqual(set.lessThanOrEqual(0), nil)
    XCTAssertEqual(set.greaterThanOrEqual(0), nil)
    XCTAssertEqual(set.lessThanOrEqual(1), nil)
    XCTAssertEqual(set.greaterThanOrEqual(1), nil)
    XCTAssertEqual(set.lessThanOrEqual(2), nil)
    XCTAssertEqual(set.greaterThanOrEqual(2), nil)
    XCTAssertEqual(set.lessThanOrEqual(3), nil)
    XCTAssertEqual(set.greaterThanOrEqual(3), nil)
    XCTAssertEqual(set.lessThanOrEqual(4), nil)
    XCTAssertEqual(set.greaterThanOrEqual(4), nil)
    XCTAssertEqual(set.lessThanOrEqual(5), nil)
    XCTAssertEqual(set.greaterThanOrEqual(5), nil)
    XCTAssertEqual(set.elements, [])
  }

  func test_Multiset_LT_GT() throws {
    var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set.count, 5)
    XCTAssertEqual(set.lessThan(-1), nil)
    XCTAssertEqual(set.greaterThan(-1), 0)
    XCTAssertEqual(set.lessThan(0), nil)
    XCTAssertEqual(set.greaterThan(0), 1)
    XCTAssertEqual(set.lessThan(1), 0)
    XCTAssertEqual(set.greaterThan(1), 2)
    XCTAssertEqual(set.lessThan(2), 1)
    XCTAssertEqual(set.greaterThan(2), 3)
    XCTAssertEqual(set.lessThan(3), 2)
    XCTAssertEqual(set.greaterThan(3), 4)
    XCTAssertEqual(set.lessThan(4), 3)
    XCTAssertEqual(set.greaterThan(4), nil)
    XCTAssertEqual(set.lessThan(5), 4)
    XCTAssertEqual(set.greaterThan(5), nil)
    XCTAssertEqual(set.removeAll(1), 1)
    XCTAssertEqual(set.removeAll(3), 3)
    XCTAssertEqual(set.removeAll(1), nil)
    XCTAssertEqual(set.removeAll(3), nil)
    XCTAssertEqual(set.sorted(), [0, 2, 4])
    XCTAssertEqual(set.lessThan(-1), nil)
    XCTAssertEqual(set.greaterThan(-1), 0)
    XCTAssertEqual(set.lessThan(0), nil)
    XCTAssertEqual(set.greaterThan(0), 2)
    XCTAssertEqual(set.lessThan(1), 0)
    XCTAssertEqual(set.greaterThan(1), 2)
    XCTAssertEqual(set.lessThan(2), 0)
    XCTAssertEqual(set.greaterThan(2), 4)
    XCTAssertEqual(set.lessThan(3), 2)
    XCTAssertEqual(set.greaterThan(3), 4)
    XCTAssertEqual(set.lessThan(4), 2)
    XCTAssertEqual(set.greaterThan(4), nil)
    XCTAssertEqual(set.lessThan(5), 4)
    XCTAssertEqual(set.greaterThan(5), nil)
    XCTAssertEqual(set.removeAll(2), 2)
    XCTAssertEqual(set.removeAll(1), nil)
    XCTAssertEqual(set.removeAll(2), nil)
    XCTAssertEqual(set.removeAll(3), nil)
    XCTAssertEqual(set.sorted(), [0, 4])
    XCTAssertEqual(set.lessThan(-1), nil)
    XCTAssertEqual(set.greaterThan(-1), 0)
    XCTAssertEqual(set.lessThan(0), nil)
    XCTAssertEqual(set.greaterThan(0), 4)
    XCTAssertEqual(set.lessThan(1), 0)
    XCTAssertEqual(set.greaterThan(1), 4)
    XCTAssertEqual(set.lessThan(2), 0)
    XCTAssertEqual(set.greaterThan(2), 4)
    XCTAssertEqual(set.lessThan(3), 0)
    XCTAssertEqual(set.greaterThan(3), 4)
    XCTAssertEqual(set.lessThan(4), 0)
    XCTAssertEqual(set.greaterThan(4), nil)
    XCTAssertEqual(set.lessThan(5), 4)
    XCTAssertEqual(set.greaterThan(5), nil)
    XCTAssertEqual(set.removeAll(0), 0)
    XCTAssertEqual(set.removeAll(1), nil)
    XCTAssertEqual(set.removeAll(2), nil)
    XCTAssertEqual(set.removeAll(3), nil)
    XCTAssertEqual(set.removeAll(4), 4)
    XCTAssertEqual(set.lessThan(-1), nil)
    XCTAssertEqual(set.greaterThan(-1), nil)
    XCTAssertEqual(set.lessThan(0), nil)
    XCTAssertEqual(set.greaterThan(0), nil)
    XCTAssertEqual(set.lessThan(1), nil)
    XCTAssertEqual(set.greaterThan(1), nil)
    XCTAssertEqual(set.lessThan(2), nil)
    XCTAssertEqual(set.greaterThan(2), nil)
    XCTAssertEqual(set.lessThan(3), nil)
    XCTAssertEqual(set.greaterThan(3), nil)
    XCTAssertEqual(set.lessThan(4), nil)
    XCTAssertEqual(set.greaterThan(4), nil)
    XCTAssertEqual(set.lessThan(5), nil)
    XCTAssertEqual(set.greaterThan(5), nil)
    XCTAssertEqual(set.sorted(), [])
  }

  func test_Multiset_LE_GE() throws {
    var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set.count, 5)
    XCTAssertEqual(set.lessThanOrEqual(-1), nil)
    XCTAssertEqual(set.greaterThanOrEqual(-1), 0)
    XCTAssertEqual(set.lessThanOrEqual(0), 0)
    XCTAssertEqual(set.greaterThanOrEqual(0), 0)
    XCTAssertEqual(set.lessThanOrEqual(1), 1)
    XCTAssertEqual(set.greaterThanOrEqual(1), 1)
    XCTAssertEqual(set.lessThanOrEqual(2), 2)
    XCTAssertEqual(set.greaterThanOrEqual(2), 2)
    XCTAssertEqual(set.lessThanOrEqual(3), 3)
    XCTAssertEqual(set.greaterThanOrEqual(3), 3)
    XCTAssertEqual(set.lessThanOrEqual(4), 4)
    XCTAssertEqual(set.greaterThanOrEqual(4), 4)
    XCTAssertEqual(set.lessThanOrEqual(5), 4)
    XCTAssertEqual(set.greaterThanOrEqual(5), nil)
    XCTAssertEqual(set.removeAll(1), 1)
    XCTAssertEqual(set.removeAll(3), 3)
    XCTAssertEqual(set.removeAll(1), nil)
    XCTAssertEqual(set.removeAll(3), nil)
    XCTAssertEqual(set.sorted(), [0, 2, 4])
    XCTAssertEqual(set.lessThanOrEqual(-1), nil)
    XCTAssertEqual(set.greaterThanOrEqual(-1), 0)
    XCTAssertEqual(set.lessThanOrEqual(0), 0)
    XCTAssertEqual(set.greaterThanOrEqual(0), 0)
    XCTAssertEqual(set.lessThanOrEqual(1), 0)
    XCTAssertEqual(set.greaterThanOrEqual(1), 2)
    XCTAssertEqual(set.lessThanOrEqual(2), 2)
    XCTAssertEqual(set.greaterThanOrEqual(2), 2)
    XCTAssertEqual(set.lessThanOrEqual(3), 2)
    XCTAssertEqual(set.greaterThanOrEqual(3), 4)
    XCTAssertEqual(set.lessThanOrEqual(4), 4)
    XCTAssertEqual(set.greaterThanOrEqual(4), 4)
    XCTAssertEqual(set.lessThanOrEqual(5), 4)
    XCTAssertEqual(set.greaterThanOrEqual(5), nil)
    XCTAssertEqual(set.removeAll(2), 2)
    XCTAssertEqual(set.removeAll(1), nil)
    XCTAssertEqual(set.removeAll(2), nil)
    XCTAssertEqual(set.removeAll(3), nil)
    XCTAssertEqual(set.sorted(), [0, 4])
    XCTAssertEqual(set.lessThanOrEqual(-1), nil)
    XCTAssertEqual(set.greaterThanOrEqual(-1), 0)
    XCTAssertEqual(set.lessThanOrEqual(0), 0)
    XCTAssertEqual(set.greaterThanOrEqual(0), 0)
    XCTAssertEqual(set.lessThanOrEqual(1), 0)
    XCTAssertEqual(set.greaterThanOrEqual(1), 4)
    XCTAssertEqual(set.lessThanOrEqual(2), 0)
    XCTAssertEqual(set.greaterThanOrEqual(2), 4)
    XCTAssertEqual(set.lessThanOrEqual(3), 0)
    XCTAssertEqual(set.greaterThanOrEqual(3), 4)
    XCTAssertEqual(set.lessThanOrEqual(4), 4)
    XCTAssertEqual(set.greaterThanOrEqual(4), 4)
    XCTAssertEqual(set.lessThanOrEqual(5), 4)
    XCTAssertEqual(set.greaterThanOrEqual(5), nil)
    XCTAssertEqual(set.removeAll(0), 0)
    XCTAssertEqual(set.removeAll(1), nil)
    XCTAssertEqual(set.removeAll(2), nil)
    XCTAssertEqual(set.removeAll(3), nil)
    XCTAssertEqual(set.removeAll(4), 4)
    XCTAssertEqual(set.lessThanOrEqual(-1), nil)
    XCTAssertEqual(set.greaterThanOrEqual(-1), nil)
    XCTAssertEqual(set.lessThanOrEqual(0), nil)
    XCTAssertEqual(set.greaterThanOrEqual(0), nil)
    XCTAssertEqual(set.lessThanOrEqual(1), nil)
    XCTAssertEqual(set.greaterThanOrEqual(1), nil)
    XCTAssertEqual(set.lessThanOrEqual(2), nil)
    XCTAssertEqual(set.greaterThanOrEqual(2), nil)
    XCTAssertEqual(set.lessThanOrEqual(3), nil)
    XCTAssertEqual(set.greaterThanOrEqual(3), nil)
    XCTAssertEqual(set.lessThanOrEqual(4), nil)
    XCTAssertEqual(set.greaterThanOrEqual(4), nil)
    XCTAssertEqual(set.lessThanOrEqual(5), nil)
    XCTAssertEqual(set.greaterThanOrEqual(5), nil)
    XCTAssertEqual(set.sorted(), [])
  }
  
  func testRedBlackTreeConveniences() throws {
    let numbers: RedBlackTreeSet = [1, 3, 5, 7, 9]

    XCTAssertEqual(numbers.lessThan(4), 3)
    XCTAssertEqual(numbers.lessThanOrEqual(4), 3)
    XCTAssertEqual(numbers.lessThan(5), 3)
    XCTAssertEqual(numbers.lessThanOrEqual(5), 5)

    XCTAssertEqual(numbers.greaterThan(6), 7)
    XCTAssertEqual(numbers.greaterThanOrEqual(6), 7)
    XCTAssertEqual(numbers.greaterThan(5), 7)
    XCTAssertEqual(numbers.greaterThanOrEqual(5), 5)
  }
  
  func testSetErase() throws {
    var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    var it = set.lowerBound(2)
    let end = set.upperBound(5)
    while it != end {
      let i = it
      defer { set.remove(at: i) }
      it = set.index(after: it)
    }
    XCTAssertEqual(set, [1,6])
  }
  
  func testSetErase2() throws {
    var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    var it = set.lowerBound(2)
    let end = set.upperBound(5)
    while it < end {
      it = set.erase(at: it)
    }
    XCTAssertEqual(set, [1,6])
  }
  
  func testMultietErase() throws {
    var set: RedBlackTreeMultiSet<Int> = [1, 2, 2, 2, 3, 4]
    var it = set.lowerBound(2)
    let end = set.upperBound(2)
    while it != end {
      let i = it
      defer { set.remove(at: i) }
      it = set.index(after: it)
    }
    XCTAssertEqual(set, [1,3,4])
  }

  func testSetIndexRange0() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    XCTAssertTrue(set.startIndex < set.endIndex)
    XCTAssertFalse(set.startIndex > set.endIndex)
    XCTAssertFalse(set.startIndex == set.endIndex)
    _ = set.startIndex ..< set.endIndex
    XCTAssertNotEqual(set[set.startIndex ..< set.endIndex] + [], [])
    
    XCTAssertTrue(set.lowerBound(2) < set.upperBound(4))
    XCTAssertFalse(set.lowerBound(2) > set.upperBound(4))
    XCTAssertFalse(set.lowerBound(2) == set.upperBound(4))
    _ = set.lowerBound(2) ..< set.upperBound(4)
  }
  
  func testSetIndexRange() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    XCTAssertEqual(set[set.startIndex ..< set.endIndex] + [], [1, 2, 3, 4, 5, 6])
    XCTAssertEqual(set[set.lowerBound(2) ..< set.upperBound(4)].map{ $0 }, [2, 3, 4])
    XCTAssertEqual(set[set.startIndex ..< set.startIndex].map{ $0 }, [])
    XCTAssertEqual(set[set.endIndex ..< set.endIndex].map{ $0 }, [])
//    XCTAssertNotEqual((set[set.startIndex ..< set.endIndex] as RedBlackTreeSet<Int>.ElementSequence ).map{ $0 }, [])

//    XCTAssertNotEqual((set[set.startIndex ..< set.endIndex] as RedBlackTreeSet<Int>.UnfoldElementSequence ).map{ $0 }, [])
  }
  
  func testEnumerate() throws {
    var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    set
      .forEach { i, v in
      set.remove(at: i)
    }
    XCTAssertEqual(set, [])
  }
  
  func testEnumerate2() throws {
    var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    set
      .forEach { v in
      set.remove(v)
    }
    XCTAssertEqual(set, [])
  }
  
  func testEnumerate3() throws {
    var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
//    var it: IndexingIterator<RedBlackTreeSet<Int>> = set.makeIterator()
//    var it: IndexingIterator<RedBlackTreeSet<Int>.Tree> = set.makeIterator()
    var it = set.makeIterator()
    while let element = it.next() {
      set.remove(element)
    }
    XCTAssertEqual(set, [])
  }

  func testReduce() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    XCTAssertEqual(set.reduce(0) { $0 + $1 }, 21)
  }
  
  func testSubSeq() throws {
    var _: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
//    var seq: Slice<RedBlackTreeSet<Int>> = RedBlackTreeSet<Int>.SubSequence(base: set, bounds: set.startIndex ..< set.endIndex)
//    XCTAssertEqual(seq.map{ $0 }, [1, 2, 3, 4, 5, 6])
  }

  func testSubSeq2() throws {
//    throw XCTSkip()
    let set: RedBlackTreeSet<Int> = .init((0 ..< 10_000).reversed())
    for _ in 0 ..< 1000 {
      var (a,b) = ((0 ..< 10_000).randomElement()!, (0 ..< 10_000).randomElement()!)
      if a > b { swap(&a, &b) }
      let lo = set.lowerBound(a)
      let hi = set.upperBound(b)
      guard lo > hi, a < b else { continue }
      // 数値比較で大小が逆転している場合、標準のdistance実装では迷子になってクラッシュする
      // distanceを実装することで、クラッシュせずに動く
//      let seq: RedBlackTreeSet<Int>.___SubSequence = set[a ..< b]
      let seq = set.elements(in: a ..< b)
      XCTAssertNotEqual(seq + [], [])
      XCTAssertEqual(seq + [], seq.sorted())
      XCTAssertTrue(seq.allSatisfy { $0 >= a })
    }
  }
  
  func testRemoveSubrange1() throws {
    var set: RedBlackTreeSet<Int> = [2,4,6,8,10]
    set.removeSubrange(3 ..< 8)
    XCTAssertEqual(set + [], [2,8,10])
  }
  
  func testRemoveSubrange2() throws {
    var set: RedBlackTreeSet<Int> = [2,4,6,8,10]
    set.removeSubrange(3 ... 8)
    XCTAssertEqual(set + [], [2,10])
  }
}
