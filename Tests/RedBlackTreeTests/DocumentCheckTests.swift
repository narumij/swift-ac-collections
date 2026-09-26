//
//  DocumentCheckTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/26.
//

import RedBlackTreeCollections
import XCTest

final class DocumentCheckTests: RedBlackTreeTestCase {

  func testExample1() throws {
    var numbers = RedBlackTreeSet<Int>(0..<10)
    numbers[numbers.startIndex..<numbers.find(5)].erase()
    print(numbers)  // -> [5,6,7,8,9]
    XCTAssertEqual(numbers.sorted(), (5..<10) + [])
  }

  func testExample2() throws {
    var numbers = RedBlackTreeSet<Int>(0..<10)
    var it = numbers.startIndex
    let end = numbers.find(5)
    while it != end {
      it = numbers.erase(it)
    }
    print(numbers)  // -> [5,6,7,8,9]
    XCTAssertEqual(numbers.sorted(), (5..<10) + [])
  }

  func testExample3() throws {
    let numbers = RedBlackTreeSet<Int>(0..<10)
    let number = numbers[.start.after]
    print(number!)  // -> 1
    XCTAssertEqual(number, 1)
  }

  func testExample4() throws {
    let numbers = RedBlackTreeSet<Int>(0..<10)
    let number = numbers[.lowerBound(20).before.advanced(by: -1)]
    print(number!) // -> 8
    XCTAssertEqual(number, 8)
  }
}
