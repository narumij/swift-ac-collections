//
//  ConvenienceTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/09/16.
//

import RedBlackTreeCollections
import XCTest

final class ConvenienceTests: RedBlackTreeTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
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
    XCTAssertEqual(set, [1, 6])
  }

  func testSetErase2() throws {
    var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    var it = set.lowerBound(2)
    let end = set.upperBound(5)
    while it != end {
      it = set.erase(at: it)
    }
    XCTAssertEqual(set, [1, 6])
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
    XCTAssertEqual(set, [1, 3, 4])
  }

  #if !COMPATIBLE_ATCODER_2025
  func testSetIndexRange0() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    #if COMPATIBLE_ATCODER_2025
      XCTAssertTrue(set.startIndex < set.endIndex)
      XCTAssertFalse(set.startIndex > set.endIndex)
    #endif
    XCTAssertFalse(set.startIndex == set.endIndex)
    _ = set.startIndex..<set.endIndex
    XCTAssertNotEqual(set[set.startIndex..<set.endIndex] + [], [])

    #if COMPATIBLE_ATCODER_2025
      XCTAssertTrue(set.lowerBound(2) < set.upperBound(4))
      XCTAssertFalse(set.lowerBound(2) > set.upperBound(4))
    #endif
    XCTAssertFalse(set.lowerBound(2) == set.upperBound(4))
    _ = set.lowerBound(2)..<set.upperBound(4)
  }
  #endif

  func testSetIndexRange() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    XCTAssertEqual(set[set.startIndex..<set.endIndex] + [], [1, 2, 3, 4, 5, 6])
    XCTAssertEqual(set[set.lowerBound(2)..<set.upperBound(4)].map { $0 }, [2, 3, 4])
    XCTAssertEqual(set[set.startIndex..<set.startIndex].map { $0 }, [])
    XCTAssertEqual(set[set.endIndex..<set.endIndex].map { $0 }, [])
    //    XCTAssertNotEqual((set[set.startIndex ..< set.endIndex] as RedBlackTreeSet<Int>.ElementSequence ).map{ $0 }, [])

    //    XCTAssertNotEqual((set[set.startIndex ..< set.endIndex] as RedBlackTreeSet<Int>.UnfoldElementSequence ).map{ $0 }, [])
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

  #if !COMPATIBLE_ATCODER_2025
  func testSubSeq2() throws {
    let count = 10_000
    let set: RedBlackTreeSet<Int> = .init((0..<count).reversed())
    for _ in 0..<1 {
      var (a, b) = ((0..<count).randomElement()!, (0..<count).randomElement()!)
      if a > b { swap(&a, &b) }
      let lo = set.lowerBound(a)
      let hi = set.upperBound(b)
      #if COMPATIBLE_ATCODER_2025
        guard lo > hi, a < b else { continue }
      #endif
      // 数値比較で大小が逆転している場合、標準のdistance実装では迷子になってクラッシュする
      // distanceを実装することで、クラッシュせずに動く
      //      let seq: RedBlackTreeSet<Int>.___SubSequence = set[a ..< b]
      let seq = set.elements(in: a..<b)
      #if COMPATIBLE_ATCODER_2025
        XCTAssertNotEqual(seq + [], [])
      #endif
      XCTAssertEqual(seq + [], seq.sorted())
      XCTAssertEqual((seq + []).reversed(), seq.reversed())
      XCTAssertTrue(seq.allSatisfy { $0 >= a })
    }
  }
  #endif

  func testRemoveSubrange1() throws {
    var set: RedBlackTreeSet<Int> = [2, 4, 6, 8, 10]
    set.removeSubrange(3..<8)
    XCTAssertEqual(set + [], [2, 8, 10])
  }

  func testRemoveSubrange2() throws {
    var set: RedBlackTreeSet<Int> = [2, 4, 6, 8, 10]
    set.removeSubrange(3...8)
    XCTAssertEqual(set + [], [2, 10])
  }
}
