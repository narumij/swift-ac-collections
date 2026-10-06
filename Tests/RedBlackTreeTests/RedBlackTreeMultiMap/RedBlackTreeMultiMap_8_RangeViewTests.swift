import RedBlackTreeCollections
import XCTest

#if !COMPATIBLE_ATCODER_2025
  final class RedBlackTreeMultiMapRangeViewTests: RedBlackTreeTestCase {

    func test_unboundedRangeView_containsEveryEntryInOrder() {
      let map: RedBlackTreeMultiMap = [(2, "c"), (1, "a"), (1, "b"), (3, "d")]
      let view = map[...]

      XCTAssertTrue(map.containsSubrange(...))
      XCTAssertEqual(view.map(\.key), [1, 1, 2, 3])
      XCTAssertEqual(view.map(\.value), ["a", "b", "c", "d"])
    }

    func test_boundedRangeView_distinguishesEqualKeysByPosition() {
      let map: RedBlackTreeMultiMap = [(0, "z"), (1, "a"), (1, "b"), (1, "c"), (2, "x")]
      let before = map.index(after: map.startIndex)
      let lower = map.index(after: before)
      let upper = map.index(map.startIndex, offsetBy: 4)
      let view = map[lower..<upper]

      XCTAssertEqual(view.map(\.value), ["b", "c"])
      XCTAssertFalse(view.isElement(at: before))
      XCTAssertTrue(view.isElement(at: lower))
      XCTAssertFalse(view.isElement(at: upper))
    }

    func test_emptyRangeView_recognizesItsOwnEnd() {
      let map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c")]
      let index = map.index(after: map.startIndex)
      let view = map[index..<index]

      XCTAssertTrue(view.isEmpty)
      XCTAssertFalse(view.isElement(at: index))
      XCTAssertTrue(view.isEnd(view.startIndex))
      XCTAssertTrue(view.isEnd(view.endIndex))
    }

    func test_closedAndPartialRangeViews_useIndexBounds() {
      let map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c"), (3, "d")]
      let lower = map.index(after: map.startIndex)
      let upper = map.index(lower, offsetBy: 1)

      XCTAssertEqual(map[lower...upper].map(\.value), ["b", "c"])
      XCTAssertEqual(map[..<upper].map(\.value), ["a", "b"])
      XCTAssertEqual(map[...upper].map(\.value), ["a", "b", "c"])
      XCTAssertEqual(map[upper...].map(\.value), ["c", "d"])
    }

    func test_equalRangeView_containsEveryEntryForKey() {
      let map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c")]
      let range = map.equalRange(1)

      XCTAssertTrue(map.containsSubrange(range))
      XCTAssertEqual(map[range].map(\.value), ["a", "b"])
    }

    func test_mutatingRangeView_removesOnlyEntryInsideView() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c"), (3, "d")]
      let lower = map.index(after: map.startIndex)
      let upper = map.index(before: map.endIndex)

      XCTAssertEqual(map[lower..<upper].popFirst()?.value, "b")
      XCTAssertEqual(map.map(\.value), ["a", "c", "d"])
    }

    func test_eraseRangeAndPredicate_modifyOnlySelectedEntries() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c"), (3, "d")]
      let range = map.equalRange(1)

      map.erase(range) { $0.value == "a" }
      XCTAssertEqual(map.map(\.value), ["b", "c", "d"])

      map[map.equalRange(1)].erase()
      XCTAssertEqual(map.map(\.value), ["c", "d"])
    }

    func test_rangeValuesSwapAt_changesOnlyValuesInsideRange() {
      var map: RedBlackTreeMultiMap = [
        (0, "outside-before"), (1, "first"), (1, "middle"), (1, "last"),
        (2, "outside-after"),
      ]
      let range = map[1]
      let first = range.startIndex
      let last = map.index(before: range.endIndex)

      map[1].swapAt(first, last)

      XCTAssertEqual(map.map(\.key), [0, 1, 1, 1, 2])
      XCTAssertEqual(
        map.map(\.value),
        ["outside-before", "last", "middle", "first", "outside-after"]
      )
    }

    func test_containsSubrange_acceptsIndexRangeExpressionValue() {
      let map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c")]
      let lower = map.index(after: map.startIndex)
      let upper = map.index(before: map.endIndex)

      XCTAssertTrue(map.containsSubrange(lower..<upper))
    }

    func test_unboundedRangeViewModify_mutatesThroughTheSubscript() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c")]

      XCTAssertEqual(map[...].popFirst()?.value, "a")
      XCTAssertEqual(map.map(\.value), ["b", "c"])
    }

    func test_eraseUnboundedRange_removesEveryEntry() {
      var map: RedBlackTreeMultiMap = [(1, "a"), (1, "b"), (2, "c")]

      map.erase(...)

      XCTAssertTrue(map.isEmpty)
    }

    func test_rangeValuesSwapAt_preservesValueSemanticsAfterCopy() {
      var map: RedBlackTreeMultiMap = [(1, "first"), (1, "middle"), (1, "last")]
      let range = map[1]
      let first = range.startIndex
      let last = map.index(before: range.endIndex)
      let copy = map

      map[1].swapAt(first, last)

      XCTAssertEqual(map.map(\.value), ["last", "middle", "first"])
      XCTAssertEqual(copy.map(\.value), ["first", "middle", "last"])
    }
  }
#endif
