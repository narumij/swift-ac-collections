import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapInsertionTests: RedBlackTreeTestCase {

  func test_insert_preservesInsertionOrderForEquivalentKeys() {
    var map = RedBlackTreeMultiMap<Int, String>()

    map.insert((1, "a"))
    map.insert((2, "x"))
    map.insert((1, "b"))
    map.insert((1, "c"))

    XCTAssertEqual(map.map(\.key), [1, 1, 1, 2])
    XCTAssertEqual(map.filter { $0.key == 1 }.map(\.value), ["a", "b", "c"])
  }

  func test_insertContentsOf_preservesEveryKeyValuePair() {
    var map: RedBlackTreeMultiMap<Int, String> = [(1, "a")]

    map.insert(contentsOf: [(1, "b"), (2, "c"), (2, "d")])

    XCTAssertEqual(map.map(\.key), [1, 1, 2, 2])
    XCTAssertEqual(map.map(\.value), ["a", "b", "c", "d"])
  }

  #if !COMPATIBLE_ATCODER_2025
    func test_insertWithHint_handlesEquivalentGoodAndBadHints() {
      var map: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (1, "c"), (3, "x")]

      let duplicate = map.insert((1, "b"), hint: map.index(after: map.startIndex))
      XCTAssertEqual(map[duplicate].value, "b")

      let goodHint = map.firstIndex(of: 3)!
      let insertedWithGoodHint = map.insert((2, "good"), hint: goodHint)
      XCTAssertEqual(map[insertedWithGoodHint].value, "good")

      let insertedWithBadHint = map.insert((4, "bad"), hint: map.startIndex)
      XCTAssertEqual(map[insertedWithBadHint].value, "bad")
      XCTAssertEqual(map.map(\.key), [1, 1, 1, 2, 3, 4])
    }

    func test_updateValue_replacesOnlyTheSpecifiedDuplicatePosition() {
      var map: RedBlackTreeMultiMap<Int, String> = [(1, "first"), (1, "middle"), (1, "last")]
      let index = map.index(after: map.startIndex)

      let oldValue = map.updateValue("new", at: index)

      XCTAssertEqual(oldValue, "middle")
      XCTAssertEqual(map.map(\.value), ["first", "new", "last"])
    }

    func test_updateValue_rejectsEndIndex() {
      var map: RedBlackTreeMultiMap<Int, String> = [(1, "value")]

      XCTAssertNil(map.updateValue("new", at: map.endIndex))
      XCTAssertEqual(map.map(\.value), ["value"])
    }

    func test_updateValue_preservesValueSemanticsAfterCopy() {
      var map: RedBlackTreeMultiMap<Int, String> = [(1, "old")]
      let copy = map

      XCTAssertEqual(map.updateValue("new", at: map.startIndex), "old")

      XCTAssertEqual(map.first?.value, "new")
      XCTAssertEqual(copy.first?.value, "old")
    }
  #endif
}
