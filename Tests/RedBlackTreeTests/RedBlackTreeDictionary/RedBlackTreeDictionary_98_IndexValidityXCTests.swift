#if DEBUG && !COMPATIBLE_ATCODER_2025
  @testable import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeDictionaryIndexValidityXCTests: RedBlackTreeTestCase {

    func testEmptyArrayLiteralUsesReadOnlyStorage() {
      let dictionary: RedBlackTreeDictionary<Int, Int> = []

      XCTAssertTrue(dictionary.__tree_.isReadOnly)
    }

    func testEmptyDictionaryLiteralUsesReadOnlyStorage() {
      let dictionary: RedBlackTreeDictionary<Int, Int> = [:]

      XCTAssertTrue(dictionary.__tree_.isReadOnly)
    }

    func testUnsafeRawIndicesAreValidOnlyForLiveNodes() {
      let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      typealias Index = RedBlackTreeDictionary<Int, String>.Index

      XCTAssertEqual(Index.unsafe(tree: dictionary.__tree_, rawTag: .end).value, .end)
      XCTAssertFalse(
        dictionary.isElement(at: .unsafe(tree: dictionary.__tree_, rawTag: .nullptr as _TrackingTag)))
      for rawTag in 0..<5 {
        XCTAssertTrue(dictionary.isElement(at: .unsafe(tree: dictionary.__tree_, rawTag: rawTag)))
      }
    }

    func testSubrangeRejectsRawIndicesOutsideItsBounds() {
      let base: RedBlackTreeDictionary = [
        1: "a", 2: "b", 3: "c", 4: "d", 5: "e", 6: "f", 7: "g",
      ]
      let range = base[2..<6]
      typealias Index = RedBlackTreeDictionary<Int, String>.Index

      XCTAssertEqual(Index.unsafe(tree: range.__tree_, rawTag: .end).value, .end)
      XCTAssertFalse(
        range.isValid(index: .unsafe(tree: range.__tree_, rawTag: .nullptr as _TrackingTag)))
      XCTAssertFalse(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: 0)))
      for rawTag in 1...5 {
        XCTAssertTrue(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: rawTag)))
      }
      XCTAssertFalse(range.isValid(index: .unsafe(tree: range.__tree_, rawTag: 6)))
    }
  }
#endif
