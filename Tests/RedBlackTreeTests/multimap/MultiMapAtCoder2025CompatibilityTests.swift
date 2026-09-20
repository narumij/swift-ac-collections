import RedBlackTreeCollections
import XCTest

#if COMPATIBLE_ATCODER_2025
  final class MultiMapAtCoder2025CompatibilityTests: RedBlackTreeTestCase {
    func testRemoveContentsOfRange() {
      var multiMap: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
      multiMap.remove(contentsOf: "b"..."c")
      XCTAssertFalse(multiMap.contains(key: "b"))
      XCTAssertFalse(multiMap.contains(key: "c"))
      XCTAssertTrue(multiMap.contains(key: "a"))
      XCTAssertTrue(multiMap.contains(key: "d"))
    }
  }
#endif
