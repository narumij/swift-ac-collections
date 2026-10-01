import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if COMPATIBLE_ATCODER_2025
  // Compatibility-only coverage is intentionally collected in this file so it can be
  // deleted together when COMPATIBLE_ATCODER_2025 support is removed.
  extension RedBlackTreeMultisetSubSequenceTests {
    func testSliceIndexOffsetting() {
      let m: RedBlackTreeMultiSet = [5, 5, 6, 7, 7, 8]
      let slice = m.elements(in: 5...7)  // 5,5,6,7,7

      let idx = slice.index(slice.startIndex, offsetBy: 3)
      XCTAssertEqual(slice[idx], 7)

      // limitedBy: 成功
      let ok = slice.index(
        slice.startIndex, offsetBy: 4,
        limitedBy: slice.endIndex)
      XCTAssertNotNil(ok)
      XCTAssertEqual(slice[ok!], 7)

      // limitedBy: 失敗 → nil
      let fail = slice.index(
        slice.startIndex, offsetBy: 10,
        limitedBy: slice.endIndex)
      XCTAssertNil(fail)
    }

    // MARK: 距離の対称性 ---------------------------------------------------

    func testDistanceSymmetry() {
      let ms: RedBlackTreeMultiSet = [0, 1, 1, 2, 3, 3, 4, 4, 4]
      let slice = ms.elements(in: 1...3)  // 1,1,2,3,3
      let i = slice.index(slice.startIndex, offsetBy: 1)  // 2番目 (1)
      let j = slice.index(slice.startIndex, offsetBy: 4)  // 5番目 (3)
      XCTAssertEqual(slice.distance(from: i, to: j), 3)
      XCTAssertEqual(slice.distance(from: j, to: i), -3)
    }

    // MARK: index invalidation after base mutation ------------------------

    func testIndexInvalidationAfterBaseMutation() throws {
      #if !USE_OLD_FIND
        throw XCTSkip("挙動が変わるためスキップ")
      #endif

      var base: RedBlackTreeMultiSet = [1, 1, 2, 2, 3]
      let slice = base.elements(in: 1...2)  // 1,1,2,2

      let idx = slice.firstIndex(of: 1)!  // 指すノードは 1
      _ = base.remove(1)  // 重複 1 個削除 (木再構成)

      XCTAssertFalse(base.isValid(index: idx))

      throw XCTSkip("setと統一の動作ならばFalseだが、multiset特有の事情でCoWが発生するため、未対応")

      //    XCTAssertFalse(slice.isValid(index: idx))
    }
  }

  final class RedBlackTreeMultisetPointerAtCoder2025LegacyTests: RedBlackTreeTestCase {

    var members: RedBlackTreeMultiSet<Int> = []

    override func setUpWithError() throws {
      try super.setUpWithError()
      members = [0, 0, 1, 2, 2]
    }

    override func tearDownWithError() throws {
      members = .init()
      try super.tearDownWithError()
    }

    func testPointerNext() throws {
      XCTAssertEqual(members.startIndex.pointee, 0)
      XCTAssertEqual(members.startIndex.next?.pointee, 0)
      XCTAssertEqual(members.startIndex.next?.next?.pointee, 1)
      XCTAssertEqual(members.startIndex.next?.next?.next?.pointee, 2)
      XCTAssertEqual(members.startIndex.next?.next?.next?.next?.pointee, 2)
      XCTAssertEqual(members.startIndex.next?.next?.next?.next?.next, members.endIndex)
      XCTAssertNil(members.startIndex.next?.next?.next?.next?.next?.next)
      XCTAssertNil(members.endIndex.next)
    }

    func testPointer2() throws {
      if let it = members.startIndex.next {
        XCTAssertFalse(members.___is_garbaged(it))
        XCTAssertEqual(it.pointee, 0)
        XCTAssertNotNil(it.previous)
        XCTAssertNotNil(it.next)
        members.remove(at: it)
        XCTAssertTrue(members.___is_garbaged(it))
        throw XCTSkip("CoWの挙動変更のため")
        XCTAssertNil(it.pointee)
        XCTAssertNil(it.previous)
        XCTAssertNil(it.next)
      }
    }

    func testPointerPrev() throws {
      XCTAssertNil(members.endIndex.pointee)
      XCTAssertEqual(members.endIndex.previous?.pointee, 2)
      XCTAssertEqual(members.endIndex.previous?.previous?.pointee, 2)
      XCTAssertEqual(members.endIndex.previous?.previous?.previous?.pointee, 1)
      XCTAssertEqual(members.endIndex.previous?.previous?.previous?.previous?.pointee, 0)
      XCTAssertEqual(members.endIndex.previous?.previous?.previous?.previous?.previous?.pointee, 0)
      XCTAssertEqual(
        members.endIndex.previous?.previous?.previous?.previous?.previous, members.startIndex)
      XCTAssertNil(members.endIndex.previous?.previous?.previous?.previous?.previous?.previous)
      XCTAssertNil(members.startIndex.previous)
    }

    func testPointerOffset0() throws {
      XCTAssertEqual((members.startIndex).pointee, 0)
      XCTAssertEqual(members.startIndex.advanced(by: 1).pointee, 0)
      XCTAssertEqual(members.startIndex.advanced(by: 2).pointee, 1)
      XCTAssertEqual(members.startIndex.advanced(by: 3).pointee, 2)
      XCTAssertEqual(members.startIndex.advanced(by: 4).pointee, 2)
      XCTAssertNil(members.startIndex.advanced(by: 5).pointee)
      XCTAssertEqual(members.startIndex.advanced(by: 5), members.endIndex)
      XCTAssertNil(members.startIndex.advanced(by: 6).pointee)
    }

    func testPointerOffset2() throws {
      XCTAssertNil((members.endIndex).pointee)
      XCTAssertEqual(members.endIndex.advanced(by: -1).pointee, 2)
      XCTAssertEqual(members.endIndex.advanced(by: -2).pointee, 2)
      XCTAssertEqual(members.endIndex.advanced(by: -3).pointee, 1)
      XCTAssertEqual(members.endIndex.advanced(by: -4).pointee, 0)
      XCTAssertEqual(members.endIndex.advanced(by: -5).pointee, 0)
      XCTAssertEqual(members.endIndex.advanced(by: -5), members.startIndex)
      XCTAssertNil(members.startIndex.advanced(by: -6).pointee)
    }
  }

  final class RedBlackTreeMultisetEtcLegacyTests: RedBlackTreeTestCase {
    func testForEach_enumeration() throws {
      let source = [0, 1, 2, 3, 4, 5]
      let a = RedBlackTreeMultiSet<Int>(naive: source)
      var p: RedBlackTreeMultiSet<Int>.Index? = a.startIndex
      a.forEach { i, v in
        XCTAssertEqual(i, p)
        XCTAssertEqual(a[p!], v)
        p = p?.next
      }
    }
  }

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    extension RedBlackTreeMultiSetCopyOnWriteTests {
      func testSet4000() throws {
        let count = 1500
        var xy: [Int: RedBlackTreeMultiSet<Int>] = [1: .init(0..<count)]
        xy[1]?._copyCount = 0
        let N = 100
        var loopCount = 0
        for i in 0..<count / N {
          loopCount += 1
          xy[1]?.elements(in: (i * N)..<(i * N + N)).forEach { i, v in
            xy[1]?.remove(at: i)
          }
        }
        XCTAssertEqual(xy[1]!.count, 0)
        XCTAssertEqual(xy[1]!._copyCount, 1, "CoW挙動変更に伴い修正")
        XCTAssertEqual(loopCount, count / N)
      }
    }
  #endif

  extension RedBlackTreeMultisetSubSequenceTests {
  }

  extension RedBlackTreeMultiSetRemovalTests {

    /// 互換モード専用のremove(_:)/removeAll(_:)も、見つからない場合はトラップしない以上、
    /// 無駄なCoWを発生させないこと。
    func test_removeAndRemoveAll_notFound_doNotTriggerCopyOnWrite() {
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        var multiset = RedBlackTreeMultiSet<Int>()
        XCTAssertEqual(multiset._copyCount, 0)

        XCTAssertNil(multiset.remove(1))
        XCTAssertEqual(multiset._copyCount, 0)

        XCTAssertNil(multiset.removeAll(1))
        XCTAssertEqual(multiset._copyCount, 0)
      #endif
    }
  }

  final class RedBlackTreeMultisetIndexRemovalLegacyTests: RedBlackTreeTestCase {
    func testRemovingAtIndicesForwardAndReversedEmptiesMultiSet() throws {
      var forward = RedBlackTreeMultiSet<Int>(0..<10)
      for i in forward.indices {
        forward.remove(at: i)
      }
      XCTAssertEqual(forward + [], [])

      var reversed = RedBlackTreeMultiSet<Int>(0..<10)
      for i in reversed.indices.reversed() {
        reversed.remove(at: i)
      }
      XCTAssertEqual(reversed + [], [])
    }

    func testRemovingAtSubrangeIndicesRemovesOnlyThatPortion() throws {
      var forward = RedBlackTreeMultiSet<Int>(0..<10)
      for i in forward.elements(in: 2..<8).indices {
        forward.remove(at: i)
      }
      XCTAssertEqual(forward + [], [0, 1, 8, 9])

      var reversed = RedBlackTreeMultiSet<Int>(0..<10)
      for i in reversed.elements(in: 2..<8).indices.reversed() {
        reversed.remove(at: i)
      }
      XCTAssertEqual(reversed + [], [0, 1, 8, 9])
    }

    #if DEBUG
      func testUncheckedRemovalViaNodePositionsEmptiesMultiSet() throws {
        var forward = RedBlackTreeMultiSet<Int>(0..<10)
        for i in forward.___node_positions() {
          forward.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(forward + [], [])

        var reversed = RedBlackTreeMultiSet<Int>(0..<10)
        for i in reversed.___node_positions().reversed() {
          reversed.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(reversed + [], [])
      }

      func testUncheckedRemovalViaNodePositionsInSubrangeRemovesOnlyThatPortion() throws {
        var forward = RedBlackTreeMultiSet<Int>(0..<10)
        for i in forward.elements(in: 2..<8).___node_positions() {
          forward.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(forward + [], [0, 1, 8, 9])

        var reversed = RedBlackTreeMultiSet<Int>(0..<10)
        for i in reversed.elements(in: 2..<8).___node_positions().reversed() {
          reversed.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(reversed + [], [0, 1, 8, 9])
      }
    #endif
  }

  #if ENABLE_PERFORMANCE_TESTING
    // firstIndex(where:) はMultiSetでは COMPATIBLE_ATCODER_2025 専用API(+Deprecated.swift参照)
    extension RedBlackTreeMultiSetPerformanceTests {
      func testPerformanceFirstIndex4() throws {
        let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 - 1 }), s.index(before: s.endIndex))
        }
      }

      func testPerformanceFirstIndex5() throws {
        let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 0 }), s.startIndex)
        }
      }

      func testPerformanceFirstIndex6() throws {
        let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 }), nil)
        }
      }
    }
  #endif

#endif
