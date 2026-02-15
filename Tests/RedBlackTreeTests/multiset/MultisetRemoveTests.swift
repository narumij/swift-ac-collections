import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class MultisetRemoveTests: RedBlackTreeTestCase {

  func testRemove1() throws {
    var set = RedBlackTreeMultiSet<Int>([0, 0, 1, 1, 2])
    XCTAssertEqual(set.remove(0), 0)
    XCTAssertFalse(set.sorted().isEmpty)
    XCTAssertEqual(set.remove(0), 0)
    XCTAssertFalse(set.sorted().isEmpty)
    XCTAssertEqual(set.remove(1), 1)
    XCTAssertFalse(set.sorted().isEmpty)
    XCTAssertEqual(set.remove(1), 1)
    XCTAssertFalse(set.sorted().isEmpty)
    XCTAssertEqual(set.remove(2), 2)
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

  func testRemoveAll() throws {
    var set = RedBlackTreeMultiSet<Int>([0, 0, 1, 1, 2])
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(set.removeAll(0), 0)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(0), nil)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(1), 1)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(1), nil)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(2), 2)
      XCTAssertTrue(set.sorted().isEmpty)
    #else
      XCTAssertEqual(set.eraseMulti(0), 0)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(0), nil)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(1), 1)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(1), nil)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(2), 2)
      XCTAssertTrue(set.sorted().isEmpty)
    #endif
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

  #if COMPATIBLE_ATCODER_2025 && !USE_SIMPLE_COPY_ON_WRITE
    func testSmokeRemove0() throws {
      var s: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })
      XCTAssertEqual(s + [], (0..<2_000).flatMap { [$0, $0] })
      for i in s {
        s.removeAll(i)
      }
    }

    func testSmokeRemove1() throws {
      var s: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })
      let b = s.lowerBound(0)
      let e = s.lowerBound(10_000)
      XCTAssertEqual(s[b..<e] + [], (0..<2_000).flatMap { [$0, $0] })
      XCTAssertEqual(s.elements(in: 0..<10_000) + [], (0..<2_000).flatMap { [$0, $0] })
      for i in s.elements(in: 0..<10_000) {
        s.removeAll(i)
      }
    }
  #endif

  #if !USE_SIMPLE_COPY_ON_WRITE
    func testSmokeRemove2() throws {
      var s: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })
      for i in s.elements(in: 0..<10_000) + [] {
        s.removeAll(i)
      }
    }
  #endif

  func testSmokeRemove00() throws {
    throw XCTSkip("いままでまぐれで通っていたんだと思う。")
    var s: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })
    XCTAssertEqual(s + [], (0..<2_000).flatMap { [$0, $0] })
    for i in s {
      #if COMPATIBLE_ATCODER_2025
        s.removeAll(_unsafe: i)
      #endif
    }
  }

  func testSmokeRemove10() throws {
    throw XCTSkip("いままでまぐれで通っていたんだと思う。")
    var s: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })
    let b = s.lowerBound(0)
    let e = s.lowerBound(10_000)
    XCTAssertEqual(s[b..<e] + [], (0..<2_000).flatMap { [$0, $0] })
    XCTAssertEqual(s.elements(in: 0..<10_000) + [], (0..<2_000).flatMap { [$0, $0] })
    for i in s.elements(in: 0..<10_000) {
      #if COMPATIBLE_ATCODER_2025
        s.removeAll(_unsafe: i)
      #endif
    }
  }

  func testSmokeRemove20() throws {
    var s: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })
    for i in s.elements(in: 0..<10_000) + [] {
      #if COMPATIBLE_ATCODER_2025
        s.removeAll(_unsafe: i)
      #endif
    }
  }

  func testRedBlackTreeSetRemove() throws {
    var s: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4]
    XCTAssertEqual(s.first, 1)
    let i = s.firstIndex(of: 2)!
    XCTAssertEqual(s.last, 4)
    s.remove(at: i)
    XCTAssertEqual(s + [], [1, 3, 4])
    s.removeAll(keepingCapacity: true)
    XCTAssertEqual(s + [], [])
    XCTAssertGreaterThanOrEqual(s.capacity, 3)
    s.removeAll(keepingCapacity: false)
    XCTAssertEqual(s + [], [])
    XCTAssertGreaterThanOrEqual(s.capacity, 0)
    // Attempting to access Set elements using an invalid index
    //      s.remove(at: i)
    //      s.remove(at: s.endIndex)
    XCTAssertNil(s.first)
    XCTAssertNil(s.last)
    //      s.removeFirst()
  }

  func testRemoveLimit() throws {
    var members: RedBlackTreeMultiSet = [Int.min, Int.min, Int.max, Int.max]
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(members.count, 4)
      members.removeAll(Int.min)
      XCTAssertEqual(members.count, 2)
      members.removeAll(Int.max)
      XCTAssertEqual(members.count, 0)
    #else
      XCTAssertEqual(members.count, 4)
      members.eraseMulti(Int.min)
      XCTAssertEqual(members.count, 2)
      members.eraseMulti(Int.max)
      XCTAssertEqual(members.count, 0)
    #endif
  }

  func testRemoveFirst() throws {
    var members: RedBlackTreeMultiSet = [1, 3, 5, 7, 9]
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
    var members: RedBlackTreeMultiSet = [1, 3, 5, 7, 9]
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

  #if COMPATIBLE_ATCODER_2025
    func testRemoveSubrange() throws {
      for l in 0..<10 {
        for h in l...10 {
          var members: RedBlackTreeMultiSet = [1, 1, 3, 3, 5, 7, 9, 9]
          members.removeSubrange(members.lowerBound(l)..<members.upperBound(h))
          XCTAssertEqual(
            members.map { $0 }, [1, 1, 3, 3, 5, 7, 9, 9].filter { !(l...h).contains($0) })
        }
      }
    }

    func testRemoveWithIndices() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      for i in members.indices {
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices2() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      members.indices.forEach { i in
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices3() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      for i in members.indices.reversed() {
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices4() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      members.indices.reversed().forEach { i in
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }
  #endif

  #if DEBUG
    func testRemoveWith___Indices() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      for i in members.___node_positions() {
        members._unchecked_remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWith___Indices2() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      members.___node_positions().forEach { i in
        members._unchecked_remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWith___Indices3() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      members.___node_positions().reversed().forEach { i in
        members._unchecked_remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }
  #endif

  #if COMPATIBLE_ATCODER_2025
    func testRemoveWithSubIndices() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      for i in members.elements(in: 2..<8).indices {
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices2() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      members.elements(in: 2..<8).indices.forEach { i in
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices3() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      for i in members.elements(in: 2..<8).indices.reversed() {
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices4() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      members.elements(in: 2..<8).indices.reversed().forEach { i in
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }
  #endif

  #if DEBUG && COMPATIBLE_ATCODER_2025
    func testRemoveWithSub___Indices() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      for i in members.elements(in: 2..<8).___node_positions() {
        members._unchecked_remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSub___Indices2() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      members.elements(in: 2..<8).___node_positions().forEach { i in
        members._unchecked_remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSub___Indices4() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      members.elements(in: 2..<8).___node_positions().reversed().forEach { i in
        members._unchecked_remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }
  #endif
}
