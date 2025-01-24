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

  func testRemove() throws {
    var set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set.remove(0), 0)
    XCTAssertFalse(set.elements.isEmpty)
    XCTAssertEqual(set.remove(1), 1)
    XCTAssertFalse(set.elements.isEmpty)
    XCTAssertEqual(set.remove(2), 2)
    XCTAssertFalse(set.elements.isEmpty)
    XCTAssertEqual(set.remove(3), 3)
    XCTAssertFalse(set.elements.isEmpty)
    XCTAssertEqual(set.remove(4), 4)
    XCTAssertTrue(set.elements.isEmpty)
    XCTAssertEqual(set.remove(0), nil)
    XCTAssertTrue(set.elements.isEmpty)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertTrue(set.elements.isEmpty)
    XCTAssertEqual(set.remove(2), nil)
    XCTAssertTrue(set.elements.isEmpty)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertTrue(set.elements.isEmpty)
    XCTAssertEqual(set.remove(4), nil)
    XCTAssertTrue(set.elements.isEmpty)
  }

  #if DEBUG
    func testRemoveAt() throws {
      var set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set.___remove(at: set._tree.__begin_node), 0)
      XCTAssertEqual(set.elements, [1, 2, 3, 4])
      XCTAssertEqual(set.___remove(at: set._tree.__begin_node), 1)
      XCTAssertEqual(set.elements, [2, 3, 4])
      XCTAssertEqual(set.___remove(at: set._tree.__begin_node), 2)
      XCTAssertEqual(set.elements, [3, 4])
      XCTAssertEqual(set.___remove(at: set._tree.__begin_node), 3)
      XCTAssertEqual(set.elements, [4])
      XCTAssertEqual(set.___remove(at: set._tree.__begin_node), 4)
      XCTAssertEqual(set.elements, [])
      XCTAssertEqual(set.___remove(at: set._tree.__begin_node), nil)
    }
  #endif

  func testRemove0() throws {
    var s: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let i = s.firstIndex(of: 2)!
    s.remove(at: i)
  }

  func testSmokeRemove0() throws {
    var s: RedBlackTreeSet<Int> = .init(0..<5_000)
    for i in s {
      s.remove(i)
    }
  }

  func testSmokeRemove1() throws {
    var s: RedBlackTreeSet<Int> = .init(0..<5_000)
    for i in s[0..<10_000] {
      s.remove(i)
    }
  }

  func testSmokeRemove2() throws {
    var s: RedBlackTreeSet<Int> = .init(0..<5_000)
    for i in s[0..<10_000].map({ $0 }) {
      s.remove(i)
    }
  }

  func testSmokeRemove3() throws {
    var s: RedBlackTreeSet<Int> = .init(0..<5_000)
    for (i, _) in s.enumerated() {
      s.remove(at: i)
    }
  }

  func testSmokeRemove4() throws {
    var s: RedBlackTreeSet<Int> = .init(0..<5_000)
    for (i, _) in s[0..<10_000].enumerated() {
      s.remove(at: i)
    }
  }

  func testRedBlackTreeSetRemove() throws {
    var s: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    XCTAssertEqual(s.first, 1)
    let i = s.firstIndex(of: 2)!
    XCTAssertEqual(s.last, 4)
    s.remove(at: i)
    XCTAssertEqual(s.map { $0 }, [1, 3, 4])
    s.removeAll(keepingCapacity: true)
    XCTAssertEqual(s.map { $0 }, [])
    XCTAssertGreaterThanOrEqual(s.capacity, 3)
    s.removeAll(keepingCapacity: false)
    XCTAssertEqual(s.map { $0 }, [])
    XCTAssertGreaterThanOrEqual(s.capacity, 0)
    // Attempting to access Set elements using an invalid index
    //      s.remove(at: i)
    //      s.remove(at: s.endIndex)
    XCTAssertNil(s.first)
    XCTAssertNil(s.last)
    //      s.removeFirst()
  }

  func testRemoveLast() throws {
    var members: RedBlackTreeSet = [1, 3, 5, 7, 9]
    XCTAssertEqual(members.removeLast(), 9)
    XCTAssertEqual(members.removeLast(), 7)
    XCTAssertEqual(members.removeLast(), 5)
    XCTAssertEqual(members.removeLast(), 3)
    XCTAssertEqual(members.removeLast(), 1)
  }

  func testRemoveSubrange() throws {
    var members: RedBlackTreeSet = [1, 3, 5, 7, 9]
    members.removeSubrange(members.lowerBound(2)..<members.upperBound(6))
    XCTAssertEqual(members, [1, 7, 9])
  }

  func testRemoveLimit() throws {
    var members: RedBlackTreeSet = [Int.min, Int.max]
    XCTAssertEqual(members.count, 2)
    members.remove(Int.min)
    XCTAssertEqual(members.count, 1)
    members.remove(Int.max)
    XCTAssertEqual(members.count, 0)
  }
  
  func testRemoveWithIndices() throws {
    var members = RedBlackTreeSet(0 ..< 10)
    for i in members.indices() {
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0 }, [])
  }
  
  func testRemoveWithSubIndices() throws {
    var members =  RedBlackTreeSet(0 ..< 10)
    for i in members[2 ..< 8].indices() {
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0 }, [0,1,8,9])
  }
}
