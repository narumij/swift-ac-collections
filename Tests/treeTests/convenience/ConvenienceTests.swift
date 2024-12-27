//
//  ConvenienceTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/09/16.
//

import XCTest
import RedBlackTreeModule

final class ConvenienceTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
#if DEBUG
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
    var set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
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

  func test_Multiset_LE_GE() throws {
    var set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
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
#endif
  
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
      it = set.erase(at: it)
    }
    XCTAssertEqual(set, [1,6])
  }
  
  func testMultietErase() throws {
    var set: RedBlackTreeMultiset<Int> = [1, 2, 2, 2, 3, 4]
    var it = set.lowerBound(2)
    let end = set.upperBound(2)
    while it != end {
      it = set.erase(at: it)
    }
    XCTAssertEqual(set, [1,3,4])
  }

  func testSetIndexRange() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    XCTAssertEqual(set[set.startIndex ..< set.endIndex], [1, 2, 3, 4, 5, 6])
    XCTAssertEqual(set[set.lowerBound(2) ..< set.upperBound(4)], [2, 3, 4])
    XCTAssertEqual(set[set.startIndex ..< set.startIndex], [])
    XCTAssertEqual(set[set.endIndex ..< set.endIndex], [])

//    XCTAssertNotEqual((set[set.startIndex ..< set.endIndex] as RedBlackTreeSet<Int>.ElementSequence ).map{ $0 }, [])

//    XCTAssertNotEqual((set[set.startIndex ..< set.endIndex] as RedBlackTreeSet<Int>.UnfoldElementSequence ).map{ $0 }, [])
  }
  
  func testEnumerate() throws {
    var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    set
      .enumerated()
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
    var it: IndexingIterator<RedBlackTreeSet<Int>> = set.makeIterator()
    while let element = it.next() {
      set.remove(element)
    }
    XCTAssertEqual(set, [])
  }

  func testReduce() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    XCTAssertEqual(set.reduce(0) { $0 + $1 }, 21)
  }
}
