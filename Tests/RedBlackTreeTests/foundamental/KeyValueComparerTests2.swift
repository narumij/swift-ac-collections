//
//  KeyValueComparerTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/09/29.
//

import RedBlackTreeModule
import XCTest

final class KeyValueComparerTests2: RedBlackTreeTestCase, KeyValueComparer, CompareUniqueTrait {
  
  static func __get_value(_ p: UnsafeMutablePointer<UnsafeNode>) -> _Key {
    p.__value_(as: _PayloadValue.self).pointee.key
  }

  static func __value_(_ p: UnsafeMutablePointer<RedBlackTreeModule.UnsafeNode>) -> (key: _Key, value: _MappedValue) {
    fatalError()
  }

  typealias _MappedValue = Int
  typealias _Key = Int
  typealias _PayloadValue = (key: _Key, value: _MappedValue)

  let keys: [_Key] = (0..<3) + []

  func testExample() throws {

    XCTAssertTrue(Self.value_comp(keys[0], keys[1]))
    XCTAssertTrue(Self.value_comp(keys[1], keys[2]))
    XCTAssertTrue(Self.value_comp(keys[0], keys[2]))

    XCTAssertFalse(Self.value_comp(keys[0], keys[0]))
    XCTAssertFalse(Self.value_comp(keys[1], keys[1]))
    XCTAssertFalse(Self.value_comp(keys[2], keys[2]))

    XCTAssertFalse(Self.value_comp(keys[1], keys[0]))
    XCTAssertFalse(Self.value_comp(keys[2], keys[1]))
    XCTAssertFalse(Self.value_comp(keys[2], keys[0]))
  }
}
