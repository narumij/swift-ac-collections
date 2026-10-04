import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapTransformingAndCombiningTests: RedBlackTreeTestCase {

  func test_mapValues_transformsEveryValueAndPreservesDuplicateKeys() {
    let map: RedBlackTreeMultiMap = [(1, 10), (1, 20), (2, 30)]

    let result = map.mapValues { "value=\($0)" }

    XCTAssertEqual(result.map(\.key), [1, 1, 2])
    XCTAssertEqual(result.map(\.value), ["value=10", "value=20", "value=30"])
  }

  func test_compactMapValues_omitsNilResultsWithoutCollapsingKeys() {
    let map: RedBlackTreeMultiMap = [(1, 10), (1, 20), (2, 30), (2, 40)]

    let result = map.compactMapValues { $0 >= 30 ? String($0) : nil }

    XCTAssertEqual(result.map(\.key), [2, 2])
    XCTAssertEqual(result.map(\.value), ["30", "40"])
  }

  func test_insertingContentsOf_returnsChangedCopyAndPreservesOriginal() {
    let original: RedBlackTreeMultiMap = [(1, "a"), (1, "b")]

    let result = original.inserting(contentsOf: [(1, "c"), (2, "d")])

    XCTAssertEqual(original.map(\.value), ["a", "b"])
    XCTAssertEqual(result.map(\.value), ["a", "b", "c", "d"])
  }

  func test_meld_combinesEveryEntryInPlace() {
    var lhs: RedBlackTreeMultiMap = [(1, "a"), (2, "c")]
    let rhs: RedBlackTreeMultiMap = [(1, "b"), (2, "d")]

    lhs.meld(rhs)

    XCTAssertEqual(lhs.map(\.key), [1, 1, 2, 2])
    XCTAssertEqual(lhs.map(\.value), ["a", "b", "c", "d"])
  }

  func test_melding_returnsCombinedCopyAndPreservesOperands() {
    let lhs: RedBlackTreeMultiMap = [(1, "a"), (2, "c")]
    let rhs: RedBlackTreeMultiMap = [(1, "b"), (2, "d")]

    let result = lhs.melding(rhs)

    XCTAssertEqual(result.map(\.value), ["a", "b", "c", "d"])
    XCTAssertEqual(lhs.map(\.value), ["a", "c"])
    XCTAssertEqual(rhs.map(\.value), ["b", "d"])
  }
}
