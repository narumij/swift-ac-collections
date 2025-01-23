import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class MultisetRemoveTests: XCTestCase {

  func testRemove() throws {
    var set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set.remove(0), 0)
    XCTAssertFalse(set.sorted().isEmpty)
    XCTAssertEqual(set.remove(1), 1)
    XCTAssertFalse(set.sorted().isEmpty)
    XCTAssertEqual(set.remove(2), 2)
    XCTAssertFalse(set.sorted().isEmpty)
    XCTAssertEqual(set.remove(3), 3)
    XCTAssertFalse(set.sorted().isEmpty)
    XCTAssertEqual(set.remove(4), 4)
    XCTAssertTrue(set.sorted().isEmpty)
    XCTAssertEqual(set.remove(0), nil)
    XCTAssertTrue(set.sorted().isEmpty)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertTrue(set.sorted().isEmpty)
    XCTAssertEqual(set.remove(2), nil)
    XCTAssertTrue(set.sorted().isEmpty)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertTrue(set.sorted().isEmpty)
    XCTAssertEqual(set.remove(4), nil)
    XCTAssertTrue(set.sorted().isEmpty)
  }

#if false
  func testRemoveAt() throws {
    var set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
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

  func testSetRemove() throws {
    var s: Set<Int> = [1, 2, 3, 4]
    let i = s.firstIndex(of: 2)!

    s.remove(at: i)
    // Attempting to access Set elements using an invalid index
    //      s.remove(at: i)
    //      s.remove(at: s.endIndex)
  }

  func testSmokeRemove0() throws {
    var s: RedBlackTreeMultiset<Int> = .init((0..<2_000).flatMap { [$0, $0] })
    XCTAssertEqual(s.map { $0 }, (0..<2_000).flatMap { [$0, $0] })
    for i in s {
      s.remove(i)
    }
  }

  func testSmokeRemove1() throws {
    var s: RedBlackTreeMultiset<Int> = .init((0..<2_000).flatMap { [$0, $0] })
    let b = s.lowerBound(0)
    let e = s.lowerBound(10_000)
    XCTAssertEqual(s[b ..< e].map { $0 }, (0..<2_000).flatMap { [$0, $0] })
    XCTAssertEqual(s[0..<10_000].map { $0 }, (0..<2_000).flatMap { [$0, $0] })
    for i in s[0..<10_000] {
      s.remove(i)
    }
  }

  func testSmokeRemove2() throws {
    var s: RedBlackTreeMultiset<Int> = .init((0..<2_000).flatMap { [$0, $0] })
    for i in s[0..<10_000].map({ $0 }) {
      s.remove(i)
    }
  }
  
  func testSmokeRemove00() throws {
    var s: RedBlackTreeMultiset<Int> = .init((0..<2_000).flatMap { [$0, $0] })
    XCTAssertEqual(s.map { $0 }, (0..<2_000).flatMap { [$0, $0] })
    for i in s {
      s.remove(_unsafe: i)
    }
  }

  func testSmokeRemove10() throws {
    var s: RedBlackTreeMultiset<Int> = .init((0..<2_000).flatMap { [$0, $0] })
    let b = s.lowerBound(0)
    let e = s.lowerBound(10_000)
    XCTAssertEqual(s[b ..< e].map { $0 }, (0..<2_000).flatMap { [$0, $0] })
    XCTAssertEqual(s[0..<10_000].map { $0 }, (0..<2_000).flatMap { [$0, $0] })
    for i in s[0..<10_000] {
      s.remove(_unsafe: i)
    }
  }

  func testSmokeRemove20() throws {
    var s: RedBlackTreeMultiset<Int> = .init((0..<2_000).flatMap { [$0, $0] })
    for i in s[0..<10_000].map({ $0 }) {
      s.remove(_unsafe: i)
    }
  }

  func testSmokeRemove3() throws {
    var s: RedBlackTreeMultiset<Int> = .init((0..<2_000).flatMap { [$0, $0] })
    for (i, _) in s.enumerated() {
      s.remove(at: i)
    }
  }

  func testSmokeRemove4() throws {
    var s: RedBlackTreeMultiset<Int> = .init((0..<2_000).flatMap { [$0, $0] })
    for (i, _) in s[0..<10_000].enumerated() {
      s.remove(at: i)
    }
  }

  func testRedBlackTreeSetRemove() throws {
    var s: RedBlackTreeMultiset<Int> = [1, 2, 3, 4]
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

  func testRemoveLimit() throws {
    var members: RedBlackTreeMultiset = [Int.min, Int.min, Int.max, Int.max]
    XCTAssertEqual(members.count, 4)
    members.remove(Int.min)
    XCTAssertEqual(members.count, 2)
    members.remove(Int.max)
    XCTAssertEqual(members.count, 0)
  }
  
  func testRemoveLast() throws {
    var members: RedBlackTreeMultiset = [1, 3, 5, 7, 9]
    XCTAssertEqual(members.removeLast(), 9)
    XCTAssertEqual(members.removeLast(), 7)
    XCTAssertEqual(members.removeLast(), 5)
    XCTAssertEqual(members.removeLast(), 3)
    XCTAssertEqual(members.removeLast(), 1)
  }
}
