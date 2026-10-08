#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeSetRemovalStressTests: RedBlackTreeTestCase {

    func testRemovingEveryElementWhileIteratingASetEmptiesIt() {
      var set = RedBlackTreeSet(0..<5_000)

      for element in set {
        set.remove(element)
      }

      XCTAssertTrue(set.isEmpty)
    }

    func testRemovingEveryElementWhileIteratingAnElementRangeEmptiesIt() {
      var set = RedBlackTreeSet(0..<5_000)

      for element in set.elements(in: 0..<10_000) {
        set.remove(element)
      }

      XCTAssertTrue(set.isEmpty)
    }

    func testRemovingMaterializedElementRangeEmptiesSet() {
      var set = RedBlackTreeSet(0..<5_000)

      for element in set.elements(in: 0..<10_000) + [] {
        set.remove(element)
      }

      XCTAssertTrue(set.isEmpty)
    }
  }
#endif
