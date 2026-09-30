import RedBlackTreeCollections
import XCTest

/// `RedBlackTreeKeyOnlyRangeView`(`Set`/`MultiSet`のRangeViewが返す型)の仕様。
/// ジェネリックな共有Viewのため、代表としてSetのインスタンスで検証する。
#if !COMPATIBLE_ATCODER_2025
  final class RedBlackTreeKeyOnlyRangeViewTests: RedBlackTreeTestCase {

    func test_sorted_returnsElementsAlreadyInOrder() {
      let set: RedBlackTreeSet = [3, 1, 2]
      let view = set[...]

      XCTAssertEqual(view.sorted(), [1, 2, 3])
    }

    func test_reversed_returnsElementsInDescendingOrder() {
      let set: RedBlackTreeSet = [1, 2, 3]
      let view = set[...]

      XCTAssertEqual(view.reversed(), [3, 2, 1])
    }

    func test_removeFirstAndRemoveLast_removeEndpointsAndReturnRemovedElement() {
      var set: RedBlackTreeSet = [1, 2, 3]

      XCTAssertEqual(set[...].removeFirst(), 1)
      XCTAssertEqual(Array(set), [2, 3])

      XCTAssertEqual(set[...].removeLast(), 3)
      XCTAssertEqual(Array(set), [2])
    }

    func test_eraseWhere_onStandaloneViewRemovesOnlyMatchingElements() {
      var set: RedBlackTreeSet = [1, 2, 3, 4]

      set[...].erase(where: { $0.isMultiple(of: 2) })

      XCTAssertEqual(Array(set), [1, 3])
    }

    func test_isElementAndIsEnd_describeIndexValidity() {
      let set: RedBlackTreeSet = [1, 2, 3]
      let view = set[...]
      let middle = set.firstIndex(of: 2)!

      XCTAssertTrue(view.isElement(at: middle))
      XCTAssertFalse(view.isElement(at: view.endIndex))
      XCTAssertTrue(view.isEnd(view.endIndex))
      XCTAssertFalse(view.isEnd(middle))
    }
  }
#endif
