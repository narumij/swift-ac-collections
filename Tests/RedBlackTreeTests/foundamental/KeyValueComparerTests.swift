//
//  KeyValueComparerTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/09/29.
//

import RedBlackTreeModule
import XCTest

final class KeyValueComparerTests: RedBlackTreeTestCase, KeyValueTrait, CompareUniqueTrait, _UnsafeNodePtrType {
  
  static func __get_value(_ p: UnsafeMutablePointer<UnsafeNode>) -> _Key {
    p.__value_(as: _PayloadValue.self).pointee.key
  }
  
  static func __value_(_ p: UnsafeMutablePointer<RedBlackTreeModule.UnsafeNode>) -> (key: _Key, value: _MappedValue) {
    fatalError()
  }

  static func value_comp(_ l: _Key, _ r: _Key) -> Bool {
    l.internalKey < r.internalKey
  }
  typealias _MappedValue = Int
  struct _Key {
    var internalKey: Int
  }
  typealias _PayloadValue = (key: _Key, value: _MappedValue)

  let keys: [_Key] = (0..<3).map { .init(internalKey: $0) }

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

extension KeyValueComparerTests._Key: Comparable {
  static func < (lhs: KeyValueComparerTests._Key, rhs: KeyValueComparerTests._Key) -> Bool {
    lhs.internalKey < rhs.internalKey
  }
}
