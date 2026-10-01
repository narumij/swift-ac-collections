#if DEBUG && !COMPATIBLE_ATCODER_2025
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
  }
#endif
