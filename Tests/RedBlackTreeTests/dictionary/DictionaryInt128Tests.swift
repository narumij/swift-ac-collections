//
//  DictionaryInt128Tests.swift
//  swift-ac-collections
//

import RedBlackTreeCollections
import XCTest

@available(macOS 15.0, *)
final class RedBlackTreeDictionaryInt128Tests: RedBlackTreeTestCase {

  func testInt128KeysWithInt32Values() {
    checkReadAndWrite(
      entries: [(.min, -32), (0, 0), (.max, 32)],
      replacement: 320 as Int32)
  }

  func testInt128KeysWithIntValues() {
    checkReadAndWrite(
      entries: [(.min, -64), (0, 0), (.max, 64)],
      replacement: 640 as Int)
  }

  func testInt128KeysWithInt128Values() {
    checkReadAndWrite(
      entries: [(.min, .min), (0, 0), (.max, .max)],
      replacement: Int128(1) << 100)
  }

  private func checkReadAndWrite<Value: Equatable>(
    entries: [(key: Int128, value: Value)],
    replacement: Value
  ) {
    var dictionary = RedBlackTreeDictionary<Int128, Value>()
    for entry in entries.reversed() {
      dictionary[entry.key] = entry.value
    }

    let expected = entries.sorted { $0.key < $1.key }
    XCTAssertEqual(dictionary.map(\.key), expected.map(\.key))
    for entry in expected {
      XCTAssertEqual(dictionary[entry.key], entry.value)
    }

    let original = dictionary
    let middleKey = expected[1].key
    dictionary[middleKey] = replacement
    XCTAssertEqual(dictionary[middleKey], replacement)
    XCTAssertEqual(original[middleKey], expected[1].value)

    let firstKey = expected[0].key
    XCTAssertEqual(dictionary.removeValue(forKey: firstKey), expected[0].value)
    XCTAssertNil(dictionary[firstKey])
    XCTAssertEqual(original[firstKey], expected[0].value)
  }
}
