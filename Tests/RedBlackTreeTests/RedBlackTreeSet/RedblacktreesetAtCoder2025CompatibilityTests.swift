import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSetIndexRangeTests {
    /// indices() がすべてのインデックスを列挙すること
    func test_indices_forEach() {
      // 事前条件: 集合に[10,20,30]
      let set = RedBlackTreeSet([10, 20, 30])

      // 実行: indices() を取得して forEach
      var elements: [Int] = []
      set.indices.forEach { rawIndex in
        // RawIndexを使用して要素取得
        elements.append(set[rawIndex])
      }

      // 事後条件:
      // - elementsに全要素が含まれていること（順序保証あり）
      XCTAssertEqual(elements, [10, 20, 30])
    }
  }

  extension RedBlackTreeSetIndexRangeTests {
    /// indices().makeIterator() で正しく列挙できること
    func test_indices_makeIterator() {
      // 事前条件: 集合に[1,2,3,4]
      let set = RedBlackTreeSet([1, 2, 3, 4])
      var iter = set.indices.makeIterator()

      var collected: [Int] = []
      while let rawIndex = iter.next() {
        collected.append(set[rawIndex])
      }

      // 事後条件:
      // - collectedに全要素が含まれていること
      XCTAssertEqual(collected, [1, 2, 3, 4])
    }
  }

  extension RedBlackTreeSetRemoveTests {
    /// removeLast() が最後の要素を削除すること
    func test_removeLast() {
      var set = RedBlackTreeSet([1, 2, 3])
      let removed = set.removeLast()
      XCTAssertEqual(removed, 3, "最後の要素を削除すること")
      XCTAssertFalse(set.contains(3), "削除後、最後の要素はセットに含まれないこと")
    }
  }

  extension RedBlackTreeSetRemoveTests {
    /// remove(contentsOf:) が指定範囲の要素を削除すること（Range版）
    func test_remove_contentsOf_Range() {
      var set = RedBlackTreeSet([1, 2, 3, 4, 5])
      set.remove(contentsOf: 2..<5)
      XCTAssertEqual(set.sorted(), [1, 5], "指定Range内の要素を削除すること")
    }

    /// remove(contentsOf:) が指定範囲の要素を削除すること（ClosedRange版）
    func test_remove_contentsOf_ClosedRange() {
      var set = RedBlackTreeSet([1, 2, 3, 4, 5])
      set.remove(contentsOf: 2...4)
      XCTAssertEqual(set.sorted(), [1, 5], "指定ClosedRange内の要素を削除すること")
    }
  }

  extension RedBlackTreeSetSearchTests {
    /// firstIndex(where:) が条件を満たす最初の要素位置を返すこと
    func test_firstIndex_where_shouldReturnCorrectIndex() {
      let set = RedBlackTreeSet([1, 2, 3, 4, 5])

      let index = set.firstIndex { $0 % 2 == 0 }  // 偶数
      XCTAssertNotNil(index)
      XCTAssertEqual(set[index!], 2)

      let noMatchIndex = set.firstIndex { $0 > 10 }
      XCTAssertNil(noMatchIndex)
    }
  }
  extension RedBlackTreeSetRemoveTests {
  func test_removeSubrange() {
    var set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let start = set.index(after: set.startIndex)
    let end = set.index(start, offsetBy: 3)
    #if COMPATIBLE_ATCODER_2025
      set.removeSubrange(start..<end)
    #else
      set.erase(start..<end)
    #endif
    XCTAssertEqual(set.sorted(), [1, 5], "指定範囲の要素を削除すること")
  }
  }

  extension RedBlackTreeSetRemoveTests {
  func test_removeAll() {
    var set = RedBlackTreeSet([1, 2, 3])
    #if COMPATIBLE_ATCODER_2025
      set.removeAll()
    #else
      set.removeAll()
    #endif
    XCTAssertTrue(set.isEmpty, "removeAll() 実行後、セットは空になること")
  }
  }
#endif
