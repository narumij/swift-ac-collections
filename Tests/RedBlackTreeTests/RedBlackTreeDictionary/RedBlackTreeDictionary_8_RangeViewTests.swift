import RedBlackTreeCollections
import XCTest

  final class RedBlackTreeDictionaryRangeViewTests: RedBlackTreeTestCase {

    func test_unboundedRangeView_containsEveryEntryInKeyOrder() {
      let dictionary: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b", 4: "d"]
      let view = dictionary[...]

      XCTAssertTrue(dictionary.containsSubrange(...))
      XCTAssertEqual(view.map(\.key), [1, 2, 3, 4])
      XCTAssertEqual(view.map(\.value), ["a", "b", "c", "d"])
    }

    func test_boundedRangeView_usesIndexPositions() {
      let dictionary: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b", 4: "d"]
      let lower = dictionary.index(after: dictionary.startIndex)
      let upper = dictionary.index(before: dictionary.endIndex)
      let view = dictionary[lower..<upper]

      XCTAssertTrue(dictionary.containsSubrange(lower..<upper))
      XCTAssertEqual(view.map(\.key), [2, 3])
      XCTAssertTrue(view.isElement(at: lower))
      XCTAssertFalse(view.isElement(at: dictionary.startIndex))
      XCTAssertFalse(view.isElement(at: upper))
    }

    func test_emptyRangeView_recognizesItsOwnEnd() {
      let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b"]
      let index = dictionary.index(after: dictionary.startIndex)
      let view = dictionary[index..<index]

      XCTAssertTrue(view.isEmpty)
      XCTAssertFalse(view.isElement(at: index))
      XCTAssertTrue(view.isEnd(view.startIndex))
      XCTAssertTrue(view.isEnd(view.endIndex))
    }

    func test_closedAndPartialRangeViews_useIndexBounds() {
      let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c", 4: "d"]
      let lower = dictionary.index(after: dictionary.startIndex)
      let upper = dictionary.index(lower, offsetBy: 1)

      XCTAssertEqual(dictionary[lower...upper].map(\.key), [2, 3])
      XCTAssertEqual(dictionary[..<upper].map(\.key), [1, 2])
      XCTAssertEqual(dictionary[...upper].map(\.key), [1, 2, 3])
      XCTAssertEqual(dictionary[upper...].map(\.key), [3, 4])
    }

    func test_mutatingRangeView_removesOnlyEntryInsideView() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c", 4: "d"]
      let lower = dictionary.index(after: dictionary.startIndex)
      let upper = dictionary.index(before: dictionary.endIndex)

      XCTAssertEqual(dictionary[lower..<upper].popFirst()?.key, 2)
      XCTAssertEqual(dictionary.map(\.key), [1, 3, 4])
    }

    func test_eraseRangeAndPredicate_modifyOnlySelectedEntries() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      let lower = dictionary.index(after: dictionary.startIndex)
      let upper = dictionary.index(before: dictionary.endIndex)

      dictionary.erase(lower..<upper) { $0.key.isMultiple(of: 2) }

      XCTAssertEqual(dictionary.map(\.key), [1, 3, 5])
      dictionary[dictionary.equalRange(3)].erase()
      XCTAssertEqual(dictionary.map(\.key), [1, 5])
    }

    func test_containsSubrangeAndSubscript_acceptEqualRangeIndexRangeValue() {
      let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
      let range = dictionary.equalRange(2)

      XCTAssertTrue(dictionary.containsSubrange(range))
      XCTAssertEqual(dictionary[range].map(\.key), [2])
    }

    func test_eraseUnboundedRange_removesEveryEntry() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]

      dictionary.erase(...)

      XCTAssertTrue(dictionary.isEmpty)
    }

    func test_eraseEqualRangeIndexRange_removesOnlyThatEntry() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]

      dictionary.erase(dictionary.equalRange(2))

      XCTAssertEqual(dictionary.map(\.key), [1, 3])
    }

    func test_eraseEqualRangeIndexRangeWithPredicate_removesOnlyWhenPredicateMatches() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]

      dictionary.erase(dictionary.equalRange(2)) { $0.key.isMultiple(of: 2) == false }
      XCTAssertEqual(dictionary.map(\.key), [1, 2, 3], "predicateが偽なので削除されない")

      dictionary.erase(dictionary.equalRange(2)) { $0.key.isMultiple(of: 2) }
      XCTAssertEqual(dictionary.map(\.key), [1, 3])
    }
  }
