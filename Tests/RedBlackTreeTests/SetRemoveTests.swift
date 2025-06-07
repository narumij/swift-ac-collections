//
//  SortedSetTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/09/16.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class SetRemoveTests: XCTestCase {

  var members: RedBlackTreeSet<Int> = []

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    members = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testRemove() throws {
    XCTAssertEqual(members.remove(0), 0)
    XCTAssertFalse(members.elements.isEmpty)
    XCTAssertEqual(members.count, 4)
    XCTAssertEqual(members.remove(1), 1)
    XCTAssertFalse(members.elements.isEmpty)
    XCTAssertEqual(members.count, 3)
    XCTAssertEqual(members.remove(2), 2)
    XCTAssertFalse(members.elements.isEmpty)
    XCTAssertEqual(members.count, 2)
    XCTAssertEqual(members.remove(3), 3)
    XCTAssertFalse(members.elements.isEmpty)
    XCTAssertEqual(members.count, 1)
    XCTAssertEqual(members.remove(4), 4)
    XCTAssertTrue(members.elements.isEmpty)
    XCTAssertEqual(members.count, 0)
    XCTAssertEqual(members.remove(0), nil)
    XCTAssertTrue(members.elements.isEmpty)
    XCTAssertEqual(members.remove(1), nil)
    XCTAssertTrue(members.elements.isEmpty)
    XCTAssertEqual(members.remove(2), nil)
    XCTAssertTrue(members.elements.isEmpty)
    XCTAssertEqual(members.remove(3), nil)
    XCTAssertTrue(members.elements.isEmpty)
    XCTAssertEqual(members.remove(4), nil)
    XCTAssertTrue(members.elements.isEmpty)
  }

  #if DEBUG
    func testRemoveAt() throws {
      XCTAssertEqual(members.___remove(at: members.__tree_.__begin_node), 0)
      XCTAssertEqual(members.elements, [1, 2, 3, 4])
      XCTAssertEqual(members.count, 4)
      XCTAssertEqual(members.___remove(at: members.__tree_.__begin_node), 1)
      XCTAssertEqual(members.elements, [2, 3, 4])
      XCTAssertEqual(members.count, 3)
      XCTAssertEqual(members.___remove(at: members.__tree_.__begin_node), 2)
      XCTAssertEqual(members.elements, [3, 4])
      XCTAssertEqual(members.count, 2)
      XCTAssertEqual(members.___remove(at: members.__tree_.__begin_node), 3)
      XCTAssertEqual(members.elements, [4])
      XCTAssertEqual(members.count, 1)
      XCTAssertEqual(members.___remove(at: members.__tree_.__begin_node), 4)
      XCTAssertEqual(members.elements, [])
      XCTAssertEqual(members.count, 0)
      XCTAssertEqual(members.___remove(at: members.__tree_.__begin_node), nil)
    }
  #endif

  func testRemove0() throws {
    let i = members.firstIndex(of: 2)!
    members.remove(at: i)
  }

  func testRedBlackTreeSetRemove() throws {
    XCTAssertEqual(members.first, 0)
    let i = members.firstIndex(of: 2)!
    XCTAssertEqual(members.last, 4)
    members.remove(at: i)
    XCTAssertEqual(members + [], [0, 1, 3, 4])
    members.removeAll(keepingCapacity: true)
    XCTAssertEqual(members + [], [])
    XCTAssertGreaterThanOrEqual(members.capacity, 3)
    members.removeAll(keepingCapacity: false)
    XCTAssertEqual(members + [], [])
    XCTAssertGreaterThanOrEqual(members.capacity, 0)
    // Attempting to access Set elements using an invalid index
    //      s.remove(at: i)
    //      s.remove(at: s.endIndex)
    XCTAssertNil(members.first)
    XCTAssertNil(members.last)
    //      s.removeFirst()
  }

  func testRemoveFirst() throws {
    members = [1, 3, 5, 7, 9]
    XCTAssertEqual(members.removeFirst(), 1)
    XCTAssertEqual(members.count, 4)
    XCTAssertEqual(members.removeFirst(), 3)
    XCTAssertEqual(members.count, 3)
    XCTAssertEqual(members.removeFirst(), 5)
    XCTAssertEqual(members.count, 2)
    XCTAssertEqual(members.removeFirst(), 7)
    XCTAssertEqual(members.count, 1)
    XCTAssertEqual(members.removeFirst(), 9)
    XCTAssertEqual(members.count, 0)
  }

  func testRemoveLast() throws {
    members = [1, 3, 5, 7, 9]
    XCTAssertEqual(members.removeLast(), 9)
    XCTAssertEqual(members.count, 4)
    XCTAssertEqual(members.removeLast(), 7)
    XCTAssertEqual(members.count, 3)
    XCTAssertEqual(members.removeLast(), 5)
    XCTAssertEqual(members.count, 2)
    XCTAssertEqual(members.removeLast(), 3)
    XCTAssertEqual(members.count, 1)
    XCTAssertEqual(members.removeLast(), 1)
    XCTAssertEqual(members.count, 0)
  }

  func testRemoveSubrange() throws {
    for l in 0..<10 {
      for h in l...10 {
        members = [1, 3, 5, 7, 9]
        members.removeSubrange(members.lowerBound(l)..<members.upperBound(h))
        XCTAssertEqual(members + [], [1, 3, 5, 7, 9].filter { !(l...h).contains($0) })
      }
    }
  }

  func testRemoveLimit() throws {
    members = [Int.min, Int.max]
    XCTAssertEqual(members.count, 2)
    members.remove(Int.min)
    XCTAssertEqual(members.count, 1)
    members.remove(Int.max)
    XCTAssertEqual(members.count, 0)
  }
}

final class SetRemoveTest_5000: XCTestCase {

  var members: RedBlackTreeSet<Int> = []

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    members = .init(0..<5_000)
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testSmokeRemove0() throws {
    for i in members {
      members.remove(i)
    }
  }

  func testSmokeRemove1() throws {
    for i in members.elements(in: 0..<10_000) {
      members.remove(i)
    }
  }

  func testSmokeRemove2() throws {
    for i in members.elements(in: 0..<10_000) + [] {
      members.remove(i)
    }
  }
}

final class SetRemoveTest_10: XCTestCase {

  var members: RedBlackTreeSet<Int> = []

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    members = RedBlackTreeSet(0..<10)
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testRemoveWithRange1() throws {
    for i in members.startIndex..<members.endIndex {
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [])
  }

  func testRemoveWithRange2() throws {
    (members.startIndex..<members.endIndex).forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [])
  }

  func testRemoveWithRange3() throws {
    for i in (members.startIndex..<members.endIndex).reversed() {
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [])
  }

  func testRemoveWithRange4() throws {
    (members.startIndex..<members.endIndex).reversed().forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [])
  }

  func testRemoveWithIndices1() throws {
    for i in members.indices {
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [])
  }

  func testRemoveWithIndices2() throws {
    members.indices.forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [])
  }

  func testRemoveWithIndices3() throws {
    for i in members.indices.reversed() {
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [])
  }

  func testRemoveWithIndices4() throws {
    members.indices.reversed().forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [])
  }

  func testRemoveWith___Indices() throws {
    for i in members.___rawIndices {
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [])
  }

  func testRemoveWith___Indices2() throws {
    members.___rawIndices.forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [])
  }

  func testRemoveWith___Indices3() throws {
    members.___rawIndices.reversed().forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [])
  }

  #if true
    func testRemoveWithSubIndices() throws {
      for i in members.elements(in: 2..<8).indices {
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices2() throws {
      members.elements(in: 2..<8).indices.forEach { i in
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices3() throws {
      for i in members.elements(in: 2..<8).indices.reversed() {
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices4() throws {
      members.elements(in: 2..<8).indices.reversed().forEach { i in
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }
  #endif

  func testRemoveWithSub___Indices() throws {
    for i in members.elements(in: 2..<8).___rawIndices {
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [0, 1, 8, 9])
  }

  func testRemoveWithSub___Indices2() throws {
    members.elements(in: 2..<8).___rawIndices.forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [0, 1, 8, 9])
  }

  func testRemoveWithSub___Indices4() throws {
    members.elements(in: 2..<8).___rawIndices.reversed().forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members + [], [0, 1, 8, 9])
  }
}
