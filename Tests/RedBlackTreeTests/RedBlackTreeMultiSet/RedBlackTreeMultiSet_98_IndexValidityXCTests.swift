#if DEBUG
  @testable import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeMultiSetIndexValidityXCTests: RedBlackTreeTestCase {

    func testEmptyArrayLiteralUsesReadOnlyStorage() {
      let multiset: RedBlackTreeMultiSet<Int> = []

      XCTAssertTrue(multiset.__tree_.isReadOnly)
    }

    func testUnsafeRawIndicesAreValidOnlyForLiveNodes() {
      let multiset: RedBlackTreeMultiSet = [1, 2, 2, 3, 4]
      typealias Index = RedBlackTreeMultiSet<Int>.Index

      XCTAssertEqual(Index.unsafe(tree: multiset.__tree_, rawTag: .end).value, .end)
      XCTAssertFalse(
        multiset.isElement(at: .unsafe(tree: multiset.__tree_, rawTag: .nullptr as _TrackingTag)))
      for rawTag in 0..<5 {
        XCTAssertTrue(multiset.isElement(at: .unsafe(tree: multiset.__tree_, rawTag: rawTag)))
      }
    }

    func testElementRangeRejectsRawIndicesOutsideItsBounds() {
      let base: RedBlackTreeMultiSet = [1, 2, 3, 4, 5, 6, 7]
      let range = base.elements(in: 2..<6)
      typealias Index = RedBlackTreeMultiSet<Int>.Index

      XCTAssertFalse(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: .nullptr as Int)))
      XCTAssertFalse(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: 0)))
      for rawTag in 1...5 {
        XCTAssertTrue(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: rawTag)))
      }
      XCTAssertFalse(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: 6)))
    }

    func testStaleIndexAfterSlotRecycledWithNewGenerationIsRejected() {
      var multiset = RedBlackTreeMultiSet<Int>(0..<10)
      let stale = multiset.index(after: multiset.startIndex)  // 1を指す

      multiset.eraseMulti(1)
      multiset.insert(1)  // 同じスロットが新しい世代で再利用される可能性がある

      XCTAssertFalse(multiset.isElement(at: stale))
    }

    #if ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
      /// `RedBlackTreeMultiSet_3`のF3仕様テストの前提: 生き残ったCoWコピーがあっても、
      /// 発行元のバッファが解放されたIndexは本当にdetachedになっていること。
      /// これが崩れると、F3/F4の仕様テストはdetachedでない経路を通って成功してしまう。
      func testIndexFromFreedOriginIsDetachedWhileCopySurvives() {
        typealias Collection = RedBlackTreeMultiSet<Int>

        @inline(never)
        func makeSurvivingCopyAndIndex() -> (Collection, Collection.Index) {
          let source: Collection = [0, 1, 1, 2]
          var copy = source
          copy.insert(3)
          let index = source.firstIndex(of: 1)!
          XCTAssertFalse(index.lazyDetach.isDetached, "発行元が生きている間はdetachedではない")
          return (copy, index)
        }

        let (copy, index) = makeSurvivingCopyAndIndex()

        XCTAssertTrue(index.lazyDetach.isDetached)
        XCTAssertTrue(copy.isElement(at: index))
      }

      /// F4の前提: copyでnodeを削除・再利用した場合も、Indexはdetachedであり、
      /// copyの対応slotは確保済みのまま存在すること(拒否が世代照合によるものであること)。
      func testIndexFromFreedOriginIsDetachedAndRejectedByGenerationInSurvivingCopy() {
        typealias Collection = RedBlackTreeMultiSet<Int>

        @inline(never)
        func makeSurvivingCopyAndIndex() -> (Collection, Collection.Index) {
          let source: Collection = [0, 1, 1, 2]
          var copy = source
          copy.remove(at: copy.firstIndex(of: 1)!)
          copy.insert(1)
          return (copy, source.firstIndex(of: 1)!)
        }

        let (copy, index) = makeSurvivingCopyAndIndex()

        XCTAssertTrue(index.lazyDetach.isDetached)
        XCTAssertEqual(copy.count, 4, "削除したslotは再利用され、copyの要素数は元と同じ")
        XCTAssertFalse(copy.isElement(at: index))
      }
    #endif

    /// `RedBlackTreeKeyOnlyRangeView`(Set/MultiSet共有)でも、コピー後の片方のCoW変異が
    /// 発行元に対するIndex有効性チェックへ影響しないこと
    func testRangeViewIndexValidityAgainstOriginIsUnaffectedByCopyThenMutateCoW() throws {
      let base = RedBlackTreeMultiSet<Int>(0..<20)
      let a = base[base.startIndex..<base.endIndex]
      var b = a

      XCTAssertTrue(b.isValid(index: a.startIndex))
      XCTAssertTrue(a.isValid(index: b.startIndex))
      XCTAssertEqual(a.startIndex, b.startIndex)

      let b0 = b.startIndex
      b.removeFirst()  // この時点でCoWが発生する

      XCTAssertTrue(b0.isValid, "発行元(a)に対するチェックは有効を示す")
      XCTAssertTrue(a.isValid(index: b0), "直感に反するが、発行元では引き続き要素として扱われる")
      XCTAssertEqual(b.sorted(), Array(1..<20))

      XCTAssertFalse(b.isValid(index: b0), "CoW後のb自身に対しては無効化されていること")
    }

    /// `RedBlackTreeKeyOnlyRangeView`でも、連続してCoW変異(removeLast→removeFirst)させた場合、
    /// 2回目以降はCoWが発生せず、Indexが正しく無効化されること
    func testRangeViewIndexValidityAfterConsecutiveMutationsWithOnlyFirstTriggeringCoW() throws {
      let base = RedBlackTreeMultiSet<Int>(0..<20)
      let a = base[base.startIndex..<base.endIndex]
      var b = a

      XCTAssertTrue(b.isValid(index: a.startIndex))
      XCTAssertTrue(a.isValid(index: b.startIndex))
      XCTAssertEqual(a.startIndex, b.startIndex)

      b.removeLast()  // この時点でCoWが発生する
      let b0 = b.startIndex
      XCTAssertNotEqual(a.startIndex, b.startIndex, "CoW発生時にインデックスも変わっている")
      b.removeFirst()  // CoWは発生しない

      XCTAssertFalse(b0.isValid, "bでは削除しているので不適格となる")
      XCTAssertFalse(b.isValid(index: b0), "すでに解放されているインデックスなので不適格")
      #if USE_LAZY_DETACH || !ALLOW_CROSS_TREE_INDEX
        XCTAssertFalse(a.isValid(index: b0), "すでに解放されているインデックスなので不適格")
      #else
        XCTAssertTrue(a.isValid(index: b0), "ソース側世代チェックが省略されているため")
      #endif
      XCTAssertEqual(b.sorted(), Array(1..<19), "先頭と末尾が削除された残りとなる")
    }
  }
#endif
