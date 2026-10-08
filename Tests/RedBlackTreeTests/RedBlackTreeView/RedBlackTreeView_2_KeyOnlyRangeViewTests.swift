import RedBlackTreeCollections
import XCTest

/// `RedBlackTreeKeyOnlyRangeView`(`Set`/`MultiSet`のRangeViewが返す型)の仕様。
/// ジェネリックな共有Viewのため、代表としてSetのインスタンスで検証する。
#if !COMPATIBLE_ATCODER_2025
  final class RedBlackTreeKeyOnlyRangeViewTests: RedBlackTreeTestCase {

    func test_sorted_returnsElementsAlreadyInOrder() {
      let set: RedBlackTreeSet = [3, 1, 2]
      let view = set[...]

      XCTAssertEqual(view.sorted(), [1, 2, 3])
    }

    func test_reversed_returnsElementsInDescendingOrder() {
      let set: RedBlackTreeSet = [1, 2, 3]
      let view = set[...]

      XCTAssertEqual(view.reversed(), [3, 2, 1])
    }

    func test_removeFirstAndRemoveLast_removeEndpointsAndReturnRemovedElement() {
      var set: RedBlackTreeSet = [1, 2, 3]

      XCTAssertEqual(set[...].removeFirst(), 1)
      XCTAssertEqual(Array(set), [2, 3])

      XCTAssertEqual(set[...].removeLast(), 3)
      XCTAssertEqual(Array(set), [2])
    }

    /// 空のビューに対する削除系操作は、トラップしない以上、無駄なCoW
    /// (共有される空シングルトンバッファからの退避)も発生させないこと。
    func test_removalMethods_onEmptyView_doNotTriggerCopyOnWrite() {
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        var empty = RedBlackTreeSet<Int>()
        XCTAssertEqual(empty._copyCount, 0)

        XCTAssertNil(empty[...].popFirst())
        XCTAssertEqual(empty._copyCount, 0)

        XCTAssertNil(empty[...].popLast())
        XCTAssertEqual(empty._copyCount, 0)

        empty[...].erase()
        XCTAssertEqual(empty._copyCount, 0)

        empty[...].erase(where: { _ in true })
        XCTAssertEqual(empty._copyCount, 0)
      #endif
    }

    func test_eraseWhere_onStandaloneViewRemovesOnlyMatchingElements() {
      var set: RedBlackTreeSet = [1, 2, 3, 4]

      set[...].erase(where: { $0.isMultiple(of: 2) })

      XCTAssertEqual(Array(set), [1, 3])
    }

    func test_isElementAndIsEnd_describeIndexValidity() {
      let set: RedBlackTreeSet = [1, 2, 3]
      let view = set[...]
      let middle = set.firstIndex(of: 2)!

      XCTAssertTrue(view.isElement(at: middle))
      XCTAssertFalse(view.isElement(at: view.endIndex))
      XCTAssertTrue(view.isEnd(view.endIndex))
      XCTAssertFalse(view.isEnd(middle))
    }

    func test_isElementAndIsEnd_respectViewBounds() {
      let set = RedBlackTreeSet(0..<5)
      let lower = set.index(after: set.startIndex)
      let inside = set.index(after: lower)
      let upper = set.index(before: set.endIndex)
      let view = set[lower..<upper]

      XCTAssertFalse(view.isElement(at: set.startIndex))
      XCTAssertTrue(view.isElement(at: lower))
      XCTAssertTrue(view.isElement(at: inside))
      XCTAssertFalse(view.isElement(at: upper))
      XCTAssertFalse(view.isElement(at: set.endIndex))

      XCTAssertFalse(view.isEnd(lower))
      XCTAssertTrue(view.isEnd(upper))
      XCTAssertFalse(view.isEnd(set.endIndex))
    }

    func test_elementsEqual_trueForSameElementsInOrder() {
      let set: RedBlackTreeSet = [1, 2, 3]
      let view = set[...]

      XCTAssertTrue(view.elementsEqual([1, 2, 3]))
    }

    func test_lexicographicallyPrecedes_comparesLengthAfterCommonPrefix() {
      let shorter = (RedBlackTreeSet([1, 2]))[...]
      let longer = (RedBlackTreeSet([1, 2, 3]))[...]

      XCTAssertTrue(shorter.lexicographicallyPrecedes(longer))
      XCTAssertFalse(longer.lexicographicallyPrecedes(shorter))
    }

    /// popFirst/popLast/erase()/erase(where:)が、保持していた参照型要素を
    /// 正しく解放すること(二重解放やリークがないこと)
    func test_variousRemovalMethods_releaseRetainedReferenceElementsExactlyOnce() {
      final class DeinitializeCounter: Comparable {
        static func < (lhs: DeinitializeCounter, rhs: DeinitializeCounter) -> Bool {
          lhs.num < rhs.num
        }
        static func == (lhs: DeinitializeCounter, rhs: DeinitializeCounter) -> Bool {
          lhs.num == rhs.num
        }
        nonisolated(unsafe) static var count = 0
        let num: Int
        init(num: Int) {
          self.num = num
          Self.count += 1
        }
        deinit { Self.count -= 1 }
      }

      var set = RedBlackTreeSet<DeinitializeCounter>((0..<4).map { DeinitializeCounter(num: $0) })
      XCTAssertEqual(DeinitializeCounter.count, 4)

      _ = set[...].popFirst()
      XCTAssertEqual(DeinitializeCounter.count, 3)

      _ = set[...].popLast()
      XCTAssertEqual(DeinitializeCounter.count, 2)

      set[...].erase(where: { $0.num == 1 })
      XCTAssertEqual(DeinitializeCounter.count, 1)

      _ = set[...].erase()
      XCTAssertEqual(DeinitializeCounter.count, 0)
    }
  }
#endif
