import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetRemovalTests: RedBlackTreeTestCase {

  func test_popFirstAndPopLast_removeOneExtremeMember() {
    var multiset = RedBlackTreeMultiSet([1, 1, 2, 3, 3])

    XCTAssertEqual(multiset.popFirst(), 1)
    XCTAssertEqual(multiset.popLast(), 3)
    XCTAssertEqual(Array(multiset), [1, 2, 3])

    var empty = RedBlackTreeMultiSet<Int>()
    XCTAssertNil(empty.popFirst())
    XCTAssertNil(empty.popLast())
  }

  func test_removeFirstAndRemoveLast_removeOneExtremeMember() {
    var multiset = RedBlackTreeMultiSet([1, 1, 2, 3, 3])

    XCTAssertEqual(multiset.removeFirst(), 1)
    XCTAssertEqual(multiset.removeLast(), 3)
    XCTAssertEqual(Array(multiset), [1, 2, 3])
  }

  #if !COMPATIBLE_ATCODER_2025
    func test_removeAt_removesOnlyTheSelectedDuplicate() {
      var multiset = RedBlackTreeMultiSet([1, 2, 2, 2, 3])
      let middleDuplicate = multiset.index(after: multiset.lowerBound(2))

      XCTAssertEqual(multiset.remove(at: middleDuplicate), 2)
      XCTAssertEqual(Array(multiset), [1, 2, 2, 3])
    }

    func test_erase_returnsTheFollowingIndex() {
      var multiset = RedBlackTreeMultiSet([1, 2, 2, 3])

      let next = multiset.erase(multiset.lowerBound(2))

      XCTAssertEqual(Array(multiset), [1, 2, 3])
      XCTAssertEqual(multiset[next], 2)
    }

    func test_eraseUnique_removesOneMatchingMember() {
      var multiset = RedBlackTreeMultiSet([1, 2, 2, 2, 3])

      XCTAssertTrue(multiset.eraseUnique(2))
      XCTAssertEqual(multiset.count(of: 2), 2)
      XCTAssertFalse(multiset.eraseUnique(4))
    }

    func test_eraseMulti_removesAllMatchingMembers() {
      var multiset = RedBlackTreeMultiSet([1, 2, 2, 2, 3])

      XCTAssertEqual(multiset.eraseMulti(2), 3)
      XCTAssertEqual(Array(multiset), [1, 3])
      XCTAssertEqual(multiset.eraseMulti(4), 0)
    }

    func test_eraseWhere_removesEveryMatchingMember() {
      var multiset = RedBlackTreeMultiSet([1, 2, 2, 3, 4, 4])

      multiset.erase { $0.isMultiple(of: 2) }

      XCTAssertEqual(Array(multiset), [1, 3])
    }
  #endif

  func test_removeAll_clearsElementsAndHonorsCapacityChoice() {
    var keepingCapacity = RedBlackTreeMultiSet(0..<10)
    let originalCapacity = keepingCapacity.capacity
    keepingCapacity.removeAll(keepingCapacity: true)

    XCTAssertTrue(keepingCapacity.isEmpty)
    XCTAssertEqual(keepingCapacity.capacity, originalCapacity)

    var releasingCapacity = RedBlackTreeMultiSet(0..<10)
    releasingCapacity.removeAll()
    XCTAssertTrue(releasingCapacity.isEmpty)
  }
}
