import RedBlackTreeCollections
import XCTest

// COMPATIBLE_ATCODER_2025 専用APIのテストを集約するファイル。
// 互換モードを廃止するときは、このファイルを一括削除する。
#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSetIndexRangeTests {

    /// indices がすべてのインデックスを列挙すること
    func test_indices_forEach() {
      let set = RedBlackTreeSet([10, 20, 30])
      var elements: [Int] = []

      set.indices.forEach { index in
        elements.append(set[index])
      }

      XCTAssertEqual(elements, [10, 20, 30])
    }

    /// indices.makeIterator() で正しく列挙できること
    func test_indices_makeIterator() {
      let set = RedBlackTreeSet([1, 2, 3, 4])
      var iterator = set.indices.makeIterator()
      var elements: [Int] = []

      while let index = iterator.next() {
        elements.append(set[index])
      }

      XCTAssertEqual(elements, [1, 2, 3, 4])
    }
  }

  extension RedBlackTreeSetSearchTests {

    /// firstIndex(where:) が条件を満たす最初の要素位置を返すこと
    func test_firstIndex_where_shouldReturnCorrectIndex() {
      let set = RedBlackTreeSet([1, 2, 3, 4, 5])

      let index = set.firstIndex { $0.isMultiple(of: 2) }
      XCTAssertNotNil(index)
      if let index {
        XCTAssertEqual(set[index], 2)
      }

      XCTAssertNil(set.firstIndex { $0 > 10 })
    }
  }

  extension RedBlackTreeSetRemoveTests {

    /// remove(contentsOf:) が半開範囲内の要素を削除すること
    func test_remove_contentsOf_Range() {
      var set = RedBlackTreeSet([1, 2, 3, 4, 5])

      set.remove(contentsOf: 2..<5)

      XCTAssertEqual(set + [], [1, 5])
    }

    /// remove(contentsOf:) が閉範囲内の要素を削除すること
    func test_remove_contentsOf_ClosedRange() {
      var set = RedBlackTreeSet([1, 2, 3, 4, 5])

      set.remove(contentsOf: 2...4)

      XCTAssertEqual(set + [], [1, 5])
    }

    /// 互換モード専用のpopFirst()も、空集合ではトラップしない以上、無駄なCoWを発生させないこと。
    func test_popFirst_onEmptySet_doesNotTriggerCopyOnWrite() {
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        var set = RedBlackTreeSet<Int>()
        XCTAssertEqual(set._copyCount, 0)

        XCTAssertNil(set.popFirst())
        XCTAssertEqual(set._copyCount, 0)
      #endif
    }
  }
#endif
