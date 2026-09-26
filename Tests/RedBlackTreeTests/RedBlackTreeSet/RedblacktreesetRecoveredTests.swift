import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

extension RedBlackTreeSetRemoveTests {
    func test_removeLast() {
      var set = RedBlackTreeSet([1, 2, 3])
      let removed = set.removeLast()
      XCTAssertEqual(removed, 3, "最後の要素を削除すること")
      XCTAssertFalse(set.contains(3), "削除後、最後の要素はセットに含まれないこと")
    }
}

