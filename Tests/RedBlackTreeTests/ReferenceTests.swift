//
//  ReferenceTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/28.
//

import RedBlackTreeModule
import XCTest

final class ReferenceTests: RedBlackTreeTestCase {

  nonisolated(unsafe) static var count: Int = 0

  class DeinitializeCounter: Comparable {
    static func < (lhs: ReferenceTests.DeinitializeCounter, rhs: ReferenceTests.DeinitializeCounter)
      -> Bool
    {
      lhs.num < rhs.num
    }

    static func == (
      lhs: ReferenceTests.DeinitializeCounter, rhs: ReferenceTests.DeinitializeCounter
    ) -> Bool {
      lhs.num == rhs.num
    }

    internal init(num: Int) {
      self.num = num
      ReferenceTests.count += 1
    }
    deinit {
      ReferenceTests.count -= 1
    }
    var num: Int
  }

  override func setUpWithError() throws {
    try super.setUpWithError()
    Self.count = 0
  }

  override func tearDownWithError() throws {
    try super.tearDownWithError()
    Self.count = 0
  }

  #if COMPATIBLE_ATCODER_2025
    func testExample() throws {
      var a = RedBlackTreeSet<DeinitializeCounter>((0..<3).map { DeinitializeCounter(num: $0) })
      XCTAssertEqual(Self.count, 3)
      for i in a.indices {
        a.remove(at: i)
      }
      XCTAssertEqual(Self.count, 0)
    }
  #endif

  func testExample2() throws {
    var a = RedBlackTreeSet<DeinitializeCounter>((0..<3).map { DeinitializeCounter(num: $0) })
    XCTAssertEqual(Self.count, 3)
    a.removeAll(keepingCapacity: true)
    XCTAssertEqual(Self.count, 0)
  }
}
