//
//  SetBaseTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/08.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class SetBaseTests: RedBlackTreeTestCase {

  typealias Fixture = RedBlackTreeSet<Int>
  typealias SUT = Fixture.Base

  #if DEBUG
    func testExample() throws {
      let fixture = Fixture(0..<5)
      XCTAssertTrue(SUT.___ptr_range_comp(fixture._end, fixture._end, fixture._end))
      XCTAssertTrue(SUT.___ptr_range_comp(fixture._start, fixture._end, fixture._end))
      XCTAssertTrue(
        SUT.___ptr_range_comp(fixture._start, __tree_next_iter(fixture._start), fixture._end))
    }
  #endif

  func testExample2() throws {

    XCTAssertEqual(SUT.__element_(Int.min), Int.min)
    XCTAssertEqual(SUT.__element_(0), 0)
    XCTAssertEqual(SUT.__element_(Int.max), Int.max)
  }
}
