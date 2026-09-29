#if DEBUG && !COMPATIBLE_ATCODER_2025
  @testable import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeSetIndexValidityXCTests: RedBlackTreeTestCase {

    func testEmptyArrayLiteralUsesReadOnlyStorage() {
      let set: RedBlackTreeSet<Int> = []

      XCTAssertTrue(set.__tree_.isReadOnly)
    }

    func testUnsafeRawIndicesAreValidOnlyForLiveNodes() {
      let set: RedBlackTreeSet = [1, 2, 3, 4, 5]
      typealias Index = RedBlackTreeSet<Int>.Index

      XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawTag: .end).value, .end)
      XCTAssertFalse(set.isValid(.unsafe(tree: set.__tree_, rawTag: .nullptr as _TrackingTag)))
      for rawTag in 0..<5 {
        XCTAssertTrue(set.isValid(.unsafe(tree: set.__tree_, rawTag: rawTag)))
      }
    }

    func testElementRangeRejectsRawIndicesOutsideItsBounds() {
      let base: RedBlackTreeSet = [1, 2, 3, 4, 5, 6, 7]
      let range = base.elements(in: 2..<6)
      typealias Index = RedBlackTreeSet<Int>.Index

      XCTAssertFalse(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: .nullptr as Int)))
      XCTAssertFalse(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: 0)))
      for rawTag in 1...5 {
        XCTAssertTrue(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: rawTag)))
      }
      XCTAssertFalse(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: 6)))
    }

    func testStaleIndexAfterSlotRecycledWithNewGenerationIsRejected() {
      var set = RedBlackTreeSet<Int>(0..<10)
      let stale = set.index(after: set.startIndex)  // 1を指す

      set.remove(1)
      set.insert(1)  // 同じスロットが新しい世代で再利用される可能性がある

      XCTAssertFalse(set.isElement(at: stale))
    }
  }
#endif
