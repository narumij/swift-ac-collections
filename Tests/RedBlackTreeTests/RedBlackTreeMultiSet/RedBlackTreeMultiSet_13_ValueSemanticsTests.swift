import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetValueSemanticsTests: RedBlackTreeTestCase {

  /// コピーを変更しても元の集合は変更されないこと
  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original: RedBlackTreeMultiSet = [1, 2, 2, 3]
    var copy = original

    copy.insert(99)
    #if COMPATIBLE_ATCODER_2025
      copy.removeAll(2)
    #else
      copy.eraseMulti(2)
    #endif

    XCTAssertEqual(Array(original), [1, 2, 2, 3])
    XCTAssertEqual(Array(copy), [1, 3, 99])
  }
}
