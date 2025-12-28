//
//  ReferenceTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/28.
//

import RedBlackTreeModule
import XCTest

final class ReferenceTests: XCTestCase {

  nonisolated(unsafe) static var count: Int = 0

  class Dummy: Comparable {
    static func < (lhs: ReferenceTests.Dummy, rhs: ReferenceTests.Dummy) -> Bool {
      lhs.num < rhs.num
    }

    static func == (lhs: ReferenceTests.Dummy, rhs: ReferenceTests.Dummy) -> Bool {
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
    // Put setup code here. This method is called before the invocation of each test method in the class.
    Self.count = 0
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    Self.count = 0
  }

  func testExample() throws {
    throw XCTSkip("まだしばらく通らないので")
    var a = RedBlackTreeSet<Dummy>((0..<3).map { Dummy(num: $0) })
    XCTAssertEqual(Self.count, 3)
    for i in a.indices {
      a.remove(at: i)
    }
    XCTAssertEqual(Self.count, 0)
  }

  func testExample2() throws {
    throw XCTSkip("まだしばらく通らないので")
    var a = RedBlackTreeSet<Dummy>((0..<3).map { Dummy(num: $0) })
    XCTAssertEqual(Self.count, 3)
    a.removeAll(keepingCapacity: true)
    XCTAssertEqual(Self.count, 0)
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
