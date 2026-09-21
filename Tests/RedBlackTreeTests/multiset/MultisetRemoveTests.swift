import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

final class MultisetRemoveTests: RedBlackTreeTestCase {

  #if !COMPATIBLE_ATCODER_2025
  func testRemove1() throws {
    var set = RedBlackTreeMultiSet<Int>([0, 0, 1, 1, 2])
    #if COMPATIBLE_ATCODER_2025
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
    #else
      XCTAssertTrue(set.eraseUnique(0))
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertTrue(set.eraseUnique(0))
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertTrue(set.eraseUnique(1))
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertTrue(set.eraseUnique(1))
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertTrue(set.eraseUnique(2))
      XCTAssertTrue(set.sorted().isEmpty)

      XCTAssertFalse(set.eraseUnique(0))
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertFalse(set.eraseUnique(1))
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertFalse(set.eraseUnique(2))
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertFalse(set.eraseUnique(3))
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertFalse(set.eraseUnique(4))
      XCTAssertTrue(set.sorted().isEmpty)
    #endif
  }
  #endif

  #if !COMPATIBLE_ATCODER_2025
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
      XCTAssertEqual(set.eraseMulti(0), 2)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(0), 0)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(1), 2)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(1), 0)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(2), 1)
      XCTAssertTrue(set.sorted().isEmpty)
    #endif
  }
  #endif

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

  #if !COMPATIBLE_ATCODER_2025
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
  #endif

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




}
