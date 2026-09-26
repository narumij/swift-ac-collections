//
//  SetInt128Tests.swift
//  swift-ac-collections
//

import RedBlackTreeCollections
import XCTest

@available(macOS 15.0, *)
final class RedBlackTreeSetInt128Tests: RedBlackTreeTestCase {

  func testInt128ReadAndWrite() {
    let beyondInt64 = Int128(Int64.max) + 1
    let values: [Int128] = [
      .max,
      beyondInt64,
      1,
      0,
      -1,
      -beyondInt64,
      .min,
    ]
    let expected = values.sorted()

    var set = RedBlackTreeSet<Int128>()
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

  func testInt128MutationAndCopyOnWrite() {
    let low = -(Int128(1) << 100)
    let middle = Int128(1) << 80
    let high = Int128(1) << 120

    let original: RedBlackTreeSet<Int128> = [low, middle, high]
    var copy = original

    XCTAssertEqual(copy.remove(middle), middle)
    XCTAssertTrue(copy.insert(.min).inserted)
    XCTAssertTrue(copy.insert(.max).inserted)

    XCTAssertEqual(Array(original), [low, middle, high])
    XCTAssertEqual(Array(copy), [.min, low, high, .max])
    XCTAssertTrue(original.contains(middle))
    XCTAssertFalse(copy.contains(middle))
  }
}
