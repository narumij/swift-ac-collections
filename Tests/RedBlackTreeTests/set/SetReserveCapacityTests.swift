//
//  SetReserveCapacityTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/12.
//

import XCTest
import RedBlackTreeCollections

final class SetReserveCapacityTests: RedBlackTreeTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }

  func testExample1() throws {
    for i in (0..<12).map({ 1 << $0 }) {
      let set = RedBlackTreeSet<Int>(minimumCapacity: i)
      XCTAssertEqual(set.capacity, i) // 将来的に仕様を変更しても構わない
    }
  }

  func testExample2() throws {
    for i in (0..<12).map({ 1 << $0 }) {
      var set = RedBlackTreeSet<Int>()
      set.reserveCapacity(i)
      XCTAssertEqual(set.capacity, i) // 将来的に仕様を変更しても構わない
    }
  }
}
