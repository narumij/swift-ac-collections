#if DEBUG && !COMPATIBLE_ATCODER_2025
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
  }
#endif
