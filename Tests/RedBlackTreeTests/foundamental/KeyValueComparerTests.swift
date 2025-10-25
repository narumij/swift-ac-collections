//
//  KeyValueComparerTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/09/29.
//

import RedBlackTreeModule
import XCTest

final class KeyValueComparerTests: XCTestCase, KeyValueComparer {
  
  static func value_comp(_ l: _Key, _ r: _Key) -> Bool {
    l.internalKey < r.internalKey
  }
  typealias _MappedValue = Int
  struct _Key {
    var internalKey: Int
  }
  typealias _Value = (key: _Key, value: _MappedValue)
  
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
    
    XCTAssertFalse(Self.value_equiv(keys[0], keys[1]))
    XCTAssertFalse(Self.value_equiv(keys[1], keys[2]))
    XCTAssertFalse(Self.value_equiv(keys[0], keys[2]))
    
    XCTAssertTrue(Self.value_equiv(keys[0], keys[0]))
    XCTAssertTrue(Self.value_equiv(keys[1], keys[1]))
    XCTAssertTrue(Self.value_equiv(keys[2], keys[2]))

    XCTAssertFalse(Self.value_equiv(keys[1], keys[0]))
    XCTAssertFalse(Self.value_equiv(keys[2], keys[1]))
    XCTAssertFalse(Self.value_equiv(keys[2], keys[0]))
  }
}
