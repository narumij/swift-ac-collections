import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetRemovalTests: RedBlackTreeTestCase {

  func test_popFirstAndPopLast_removeOneExtremeMember() {
    var multiset = RedBlackTreeMultiSet([1, 1, 2, 3, 3])

    XCTAssertEqual(multiset.popFirst(), 1)
    #if !COMPATIBLE_ATCODER_2025
      XCTAssertEqual(multiset.popLast(), 3)
      XCTAssertEqual(Array(multiset), [1, 2, 3])
    #endif

    var empty = RedBlackTreeMultiSet<Int>()
    XCTAssertNil(empty.popFirst())
    #if !COMPATIBLE_ATCODER_2025
      XCTAssertNil(empty.popLast())
    #endif
  }

  /// 空集合への削除操作はトラップしない以上、無駄なCoW(共有される空シングルトン
  /// バッファからの退避)も発生させないこと。
  func test_popFirstAndPopLast_onEmptyMultiSet_doNotTriggerCopyOnWrite() {
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      var empty = RedBlackTreeMultiSet<Int>()
      XCTAssertEqual(empty._copyCount, 0)

      XCTAssertNil(empty.popFirst())
      XCTAssertEqual(empty._copyCount, 0)

      #if !COMPATIBLE_ATCODER_2025
        XCTAssertNil(empty.popLast())
        XCTAssertEqual(empty._copyCount, 0)
      #endif
    #endif
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

    func test_eraseMulti_handlesFullWidthIntValues() {
      var members: RedBlackTreeMultiSet = [Int.min, Int.min, Int.max, Int.max]

      XCTAssertEqual(members.count, 4)
      XCTAssertEqual(members.eraseMulti(Int.min), 2)
      XCTAssertEqual(members.count, 2)
      XCTAssertEqual(members.eraseMulti(Int.max), 2)
      XCTAssertEqual(members.count, 0)
    }

    func test_eraseUsingLowerAndUpperBound_removesOnlyThatDuplicateValue() {
      var multiset = RedBlackTreeMultiSet([0, 1, 2, 2, 3, 4])
      let lower = multiset.lowerBound(2)
      let upper = multiset.upperBound(2)

      _ = multiset.erase(lower..<upper)

      XCTAssertEqual(Array(multiset), [0, 1, 3, 4])
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
