#if DEBUG
  @testable import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeMultiMapIndexValidityXCTests: RedBlackTreeTestCase {

    func testEmptyArrayLiteralUsesReadOnlyStorage() {
      let multiMap: RedBlackTreeMultiMap<Int, Int> = []

      XCTAssertTrue(multiMap.__tree_.isReadOnly)
    }

    func testEmptyDictionaryLiteralUsesReadOnlyStorage() {
      let multiMap: RedBlackTreeMultiMap<Int, Int> = [:]

      XCTAssertTrue(multiMap.__tree_.isReadOnly)
    }

    func testUnsafeRawIndicesAreValidOnlyForLiveNodes() {
      let multiMap: RedBlackTreeMultiMap = [(1, "a"), (2, "b"), (3, "c"), (4, "d"), (5, "e")]
      typealias Index = RedBlackTreeMultiMap<Int, String>.Index

      XCTAssertEqual(Index.unsafe(tree: multiMap.__tree_, rawTag: .end).value, .end)
      XCTAssertEqual(Index.unsafe(tree: multiMap.__tree_, rawTag: 5).value, .nullptr)
      XCTAssertFalse(
        multiMap.isElement(at: .unsafe(tree: multiMap.__tree_, rawTag: .nullptr as _TrackingTag)))
      for rawTag in 0..<5 {
        XCTAssertTrue(multiMap.isElement(at: .unsafe(tree: multiMap.__tree_, rawTag: rawTag)))
      }
      XCTAssertFalse(multiMap.isElement(at: .unsafe(tree: multiMap.__tree_, rawTag: 5)))
    }

    func testSubrangeRejectsRawIndicesOutsideItsBounds() {
      let base: RedBlackTreeMultiMap = [
        (1, "a"), (2, "b"), (3, "c"), (4, "d"), (5, "e"), (6, "f"), (7, "g"),
      ]
      let range = base.elements(in: 2..<6)
      typealias Index = RedBlackTreeMultiMap<Int, String>.Index

      XCTAssertEqual(Index.unsafe(tree: range.__tree_, rawTag: .end).value, .end)
      XCTAssertEqual(Index.unsafe(tree: range.__tree_, rawTag: 5).value, 5)
      XCTAssertFalse(
        range.isValid(index: .unsafe(tree: range.__tree_, rawTag: .nullptr as _TrackingTag)))
      XCTAssertFalse(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: 0)))
      for rawTag in 1...5 {
        XCTAssertTrue(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: rawTag)))
      }
      XCTAssertFalse(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: 6)))
    }

    func testStaleIndexAfterSlotRecycledWithNewGenerationIsRejected() {
      var multiMap = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (0..<10).map { ($0, $0) })
      let stale = multiMap.index(after: multiMap.startIndex)  // 1を指す

      multiMap.eraseMulti(1)
      multiMap.insert(key: 1, value: 1)  // 同じスロットが新しい世代で再利用される可能性がある

      XCTAssertFalse(multiMap.isElement(at: stale))
    }

    #if ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
      /// `RedBlackTreeMultiMap_3`のF3仕様テストの前提: 生き残ったCoWコピーがあっても、
      /// 発行元のバッファが解放されたIndexは本当にdetachedになっていること。
      /// これが崩れると、F3/F4の仕様テストはdetachedでない経路を通って成功してしまう。
      func testIndexFromFreedOriginIsDetachedWhileCopySurvives() {
        typealias Collection = RedBlackTreeMultiMap<Int, String>

        @inline(never)
        func makeSurvivingCopyAndIndex() -> (Collection, Collection.Index) {
          let source: Collection = [(0, "a"), (1, "b"), (1, "c"), (2, "d")]
          var copy = source
          copy.insert((3, "e"))
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
        typealias Collection = RedBlackTreeMultiMap<Int, String>

        @inline(never)
        func makeSurvivingCopyAndIndex() -> (Collection, Collection.Index) {
          let source: Collection = [(0, "a"), (1, "b"), (1, "c"), (2, "d")]
          var copy = source
          copy.remove(at: copy.firstIndex(of: 1)!)
          copy.insert((1, "z"))
          return (copy, source.firstIndex(of: 1)!)
        }

        let (copy, index) = makeSurvivingCopyAndIndex()

        XCTAssertTrue(index.lazyDetach.isDetached)
        XCTAssertEqual(copy.count, 4, "削除したslotは再利用され、copyの要素数は元と同じ")
        XCTAssertFalse(copy.isElement(at: index))
      }
    #endif
  }
#endif
