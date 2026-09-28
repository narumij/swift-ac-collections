#if DEBUG && !COMPATIBLE_ATCODER_2025
  @testable import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeSetRemovalInternalXCTests: RedBlackTreeTestCase {

    func testUncheckedRemovalAdvancesTheBeginNodeUntilEmpty() {
      var set = RedBlackTreeSet(0..<5)

      for expected in 0..<5 {
        let removed = set.__tree_._unchecked_remove(at: set.__tree_.__begin_node_)
        XCTAssertEqual(removed.payload, expected)
        XCTAssertEqual(set + [], Array((expected + 1)..<5))
      }

      XCTAssertTrue(set.isEmpty)
    }
  }
#endif
