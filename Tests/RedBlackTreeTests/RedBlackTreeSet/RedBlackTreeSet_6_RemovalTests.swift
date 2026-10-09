import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetRemoveTests: RedBlackTreeTestCase {

  /// popFirst() が空セットの場合に nil を返すこと
  func test_popFirst_empty() {
    var set = RedBlackTreeSet<Int>()
    let popped = set.popFirst()
    XCTAssertNil(popped, "空セットの場合、popFirst() は nil を返すこと")
  }

  /// popFirst() が要素を正しく取り出し、セットが更新されること
  func test_popFirst_nonEmpty() {
    var set = RedBlackTreeSet([1, 2, 3])
    let popped = set.popFirst()
    XCTAssertNotNil(popped, "空でないセットでは popMin() が要素を返すこと")
    XCTAssertTrue([1, 2, 3].contains(popped!), "取り出した要素が元のセット内の要素であること")
    XCTAssertEqual(set.count, 2, "popFirst() 実行後、要素数が 1 減少すること")
    XCTAssertFalse(set.contains(popped!), "取り出した要素はセットから削除されていること")
  }

    /// popFirst() が空セットの場合に nil を返すこと
    func test_popLast_empty() {
      var set = RedBlackTreeSet<Int>()
      let popped = set.popLast()
      XCTAssertNil(popped, "空セットの場合、popLast() は nil を返すこと")
    }

  /// popLast() / removeLast() が要素を正しく取り出し、セットが更新されること
  func test_popLast_nonEmpty() {
    var set = RedBlackTreeSet([1, 2, 3])
      let popped = set.popLast()
    XCTAssertNotNil(popped, "空でないセットでは末尾の要素を返すこと")
    XCTAssertTrue([1, 2, 3].contains(popped!), "取り出した要素が元のセット内の要素であること")
    XCTAssertEqual(set.count, 2, "実行後、要素数が 1 減少すること")
    XCTAssertFalse(set.contains(popped!), "取り出した要素はセットから削除されていること")
  }

  /// remove(_:) が指定要素を削除し、要素数が減ること
  func test_remove_element() {
    var set = RedBlackTreeSet([1, 2, 3])
    let removed = set.remove(2)
    XCTAssertEqual(removed, 2, "指定要素が存在する場合、remove(_:) はその要素を返すこと")
    XCTAssertFalse(set.contains(2), "指定要素は削除されていること")
    XCTAssertEqual(set.count, 2, "要素数が1減ること")
  }

  /// remove(_:) が存在しない要素の場合 nil を返し、セットは変化しないこと
  func test_remove_nonexistent_element() {
    var set = RedBlackTreeSet([1, 2, 3])
    let removed = set.remove(10)
    XCTAssertNil(removed, "存在しない要素の場合、remove(_:) は nil を返すこと")
    XCTAssertEqual(set.count, 3, "要素数に変化はないこと")
  }

  /// remove(at:) が指定インデックスの要素を削除すること
  func test_remove_at() {
    var set = RedBlackTreeSet([1, 2, 3])
    let index = set.index(after: set.startIndex)
    let removed = set.remove(at: index)
    XCTAssertEqual(removed, 2, "指定インデックスの要素を正しく削除すること")
    XCTAssertFalse(set.contains(2), "指定インデックスの要素は削除されること")
  }

  /// removeFirst() が最初の要素を削除すること
  func test_removeFirst() {
    var set = RedBlackTreeSet([1, 2, 3])
    let removed = set.removeFirst()
    XCTAssertEqual(removed, 1, "最初の要素を削除すること")
    XCTAssertFalse(set.contains(1), "削除後、最初の要素はセットに含まれないこと")
  }

  /// removeLast() が最後の要素を削除すること
  func test_removeLast() {
    var set = RedBlackTreeSet([1, 2, 3])
    let removed = set.removeLast()

    XCTAssertEqual(removed, 3, "最後の要素を削除すること")
    XCTAssertEqual(set + [], [1, 2], "削除後、最後の要素はセットに含まれないこと")
  }

  /// removeSubrange() が指定範囲の要素を削除すること
  func test_removeSubrange() {
    var set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let start = set.index(after: set.startIndex)
    let end = set.index(start, offsetBy: 3)
      set.erase(start..<end)
    XCTAssertEqual(set.sorted(), [1, 5], "指定範囲の要素を削除すること")
  }

  /// removeAll() がセットを空にすること
  func test_removeAll() {
    var set = RedBlackTreeSet([1, 2, 3])
      set.removeAll()
    XCTAssertTrue(set.isEmpty, "removeAll() 実行後、セットは空になること")
  }

    /// erase(_:) が空範囲と集合の境界を含むすべての半開範囲を正しく削除すること
    func test_erase_eachBoundedRange() {
      let source = [1, 3, 5, 7, 9]

      for lowerBound in 0..<10 {
        for upperBound in lowerBound...10 {
          var set = RedBlackTreeSet(source)
          set.erase(set.lowerBound(lowerBound)..<set.upperBound(upperBound))

          XCTAssertEqual(set + [], source.filter { !(lowerBound...upperBound).contains($0) })
        }
      }
    }

    /// removeAll(keepingCapacity:) が要素を消しつつ、指定時には確保容量を維持すること
    func test_removeAllKeepingCapacity() {
      var set = RedBlackTreeSet(0..<8)
      let capacity = set.capacity

      set.removeAll(keepingCapacity: true)

      XCTAssertTrue(set.isEmpty)
      XCTAssertEqual(set.capacity, capacity)
    }

  /// removeAll(keepingCapacity:) が保持していた参照型要素を正しく解放すること(二重解放やリークがないこと)
  func test_removeAllKeepingCapacity_releasesRetainedReferenceElements() {
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

    var set = RedBlackTreeSet<DeinitializeCounter>((0..<3).map { DeinitializeCounter(num: $0) })
    XCTAssertEqual(DeinitializeCounter.count, 3)

    set.removeAll(keepingCapacity: true)

    XCTAssertEqual(DeinitializeCounter.count, 0)
  }

  /// popFirst/popLast/remove(_:)/remove(at:)/removeFirst/removeLastが、保持していた
  /// 参照型要素を正しく解放すること(二重解放やリークがないこと)
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

    var set = RedBlackTreeSet<DeinitializeCounter>((0..<6).map { DeinitializeCounter(num: $0) })
    XCTAssertEqual(DeinitializeCounter.count, 6)

    _ = set.popFirst()
    XCTAssertEqual(DeinitializeCounter.count, 5)

      _ = set.popLast()
      XCTAssertEqual(DeinitializeCounter.count, 4)

    _ = set.remove(DeinitializeCounter(num: 2))
      XCTAssertEqual(DeinitializeCounter.count, 3, "removeで検索用に新たに作った一時要素も、実際に削除された既存要素も両方解放されること")

    _ = set.removeFirst()
      XCTAssertEqual(DeinitializeCounter.count, 2)

    set.removeAll()
    XCTAssertEqual(DeinitializeCounter.count, 0)
  }

  /// 空集合への削除操作はトラップしない以上、無駄なCoW(共有される空シングルトン
  /// バッファからの退避)も発生させないこと。
  func test_removalMethods_onEmptySet_doNotTriggerCopyOnWrite() {
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      var set = RedBlackTreeSet<Int>()
      XCTAssertEqual(set._copyCount, 0)

      XCTAssertNil(set.popFirst())
      XCTAssertEqual(set._copyCount, 0)

        XCTAssertNil(set.popLast())
        XCTAssertEqual(set._copyCount, 0)

      XCTAssertNil(set.remove(1))
      XCTAssertEqual(set._copyCount, 0)

      set.removeAll(keepingCapacity: true)
      XCTAssertEqual(set._copyCount, 0, "空集合へのremoveAll(keepingCapacity: true)は退避コピーを発生させないはず")

        var predicateCalled = false
        set.erase(where: { _ in
          predicateCalled = true
          return true
        })
        XCTAssertFalse(predicateCalled, "空の集合へのerase(where:)は述語を呼ばないはず")
        XCTAssertEqual(set._copyCount, 0, "空の集合へのerase(where:)は退避コピーを発生させないはず")
    #endif
  }

  /// remove(_:) が整数型の最小値と最大値も削除できること
  func test_removeIntegerLimits() {
    var set: RedBlackTreeSet = [Int.min, Int.max]

    XCTAssertEqual(set.remove(Int.min), Int.min)
    XCTAssertEqual(set.remove(Int.max), Int.max)
    XCTAssertTrue(set.isEmpty)
  }

}

extension RedBlackTreeSetRemoveTests {

  /// removeFirstが空のときはエラーを投げること
  ///
  /// - Note: 実際にはエラーを投げず、事前条件違反としてプロセスを停止する。XCTestでは停止を
  ///   検証できないため、本文は空のままにしてある。停止の検証は
  ///   `RedBlackTreeSet_99_DeathTests.swift`の`removingFirstFromEmptySet_terminatesProcess`が行う。
  ///   `-Ounchecked`では停止しないのが仕様である(`Design-RuntimeChecks.md`)。
  func test_removeFirst_throws_whenEmpty() {
    //    var set = RedBlackTreeSet<Int>()
    //    XCTAssertThrowsError({
    //      _ = set.removeFirst()
    //    }(), "removeFirst() should preconditionFailure when empty")
  }

  /// removeFirstが1要素のとき正しく動作すること
  func test_removeFirst_singleElement() {
    var set = RedBlackTreeSet([10])
    let removed = set.removeFirst()
    XCTAssertEqual(removed, 10)
    XCTAssertTrue(set.isEmpty)
  }

  /// removeFirstが複数要素のとき先頭要素を削除すること
  func test_removeFirst_multipleElements() {
    var set = RedBlackTreeSet([1, 2, 3])
    let removed = set.removeFirst()
    XCTAssertEqual(removed, 1)
    XCTAssertEqual(set.sorted(), [2, 3])
  }

  /// removeLastが空のときはエラーを投げること
  ///
  /// - Note: 実際にはエラーを投げず、事前条件違反としてプロセスを停止する。XCTestでは停止を
  ///   検証できないため、本文は空のままにしてある。停止の検証は
  ///   `RedBlackTreeSet_99_DeathTests.swift`の`removingLastFromEmptySet_terminatesProcess`が行う。
  ///   `-Ounchecked`では停止しないのが仕様である(`Design-RuntimeChecks.md`)。
  func test_removeLast_throws_whenEmpty() {
    //    var set = RedBlackTreeSet<Int>()
    //    XCTAssertThrowsError({
    //      _ = set.removeLast()
    //    }(), "removeLast() should preconditionFailure when empty")
  }

}

extension RedBlackTreeSetRemoveTests {

    /// erase(_:) が指定インデックスの要素を削除し、次のインデックスを返すこと
    func test_erase_index_returnsNext() {
      var set = RedBlackTreeSet([1, 2, 3])
      let index = set.index(after: set.startIndex)  // element 2
      let nextIndex = set.erase(index)

      XCTAssertEqual(set.sorted(), [1, 3])
      XCTAssertEqual(set[nextIndex], 3)
    }

    /// erase(where:) が条件に合致する要素を削除すること
    func test_erase_where() {
      var set = RedBlackTreeSet([1, 2, 3, 4, 5])
      set.erase { $0 % 2 == 0 }

      XCTAssertEqual(set.sorted(), [1, 3, 5])
    }

  /// remove後にindexが無効化されること
  func test_isValid_index_afterRemoval() {
    // 事前条件: 集合に[1, 2, 3, 4, 5]
    var set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let index = set.index(after: set.startIndex)  // index pointing to element 2

    // 実行: 削除（2を削除する）
    let element = set[index]
    XCTAssertEqual(element, 2)
    _ = set.remove(element)

    // 事後条件:
    // - 削除したindexは無効になること
    XCTAssertFalse(set.isValid(index), "削除後、当該indexは無効になること")
  }
}

extension RedBlackTreeSetRemoveTests {

}
