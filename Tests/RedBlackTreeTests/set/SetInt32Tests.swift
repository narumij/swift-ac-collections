//
//  SetInt32Tests.swift
//  swift-ac-collections
//

import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetInt32Tests: RedBlackTreeTestCase {

  func testInt32ReadAndWrite() {
    let values: [Int32] = [
      .max,
      1,
      0,
      -1,
      .min,
    ]
    let expected = values.sorted()

    var set = RedBlackTreeSet<Int32>()
    for value in values {
      let result = set.insert(value)
      XCTAssertTrue(result.inserted)
      XCTAssertEqual(result.memberAfterInsert, value)
    }

    XCTAssertEqual(Array(set), expected)
    XCTAssertEqual(set.elements, expected)

    for (offset, value) in expected.enumerated() {
      XCTAssertTrue(set.contains(value))
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: offset)], value)
    }
  }

  func testInt32MutationAndCopyOnWrite() {
    let original: RedBlackTreeSet<Int32> = [.min, -1, 0, 1, .max]
    var copy = original

    XCTAssertEqual(copy.remove(0), 0)
    XCTAssertTrue(copy.insert(42).inserted)

    XCTAssertEqual(Array(original), [.min, -1, 0, 1, .max])
    XCTAssertEqual(Array(copy), [.min, -1, 1, 42, .max])
    XCTAssertTrue(original.contains(0))
    XCTAssertFalse(copy.contains(0))
  }
}
