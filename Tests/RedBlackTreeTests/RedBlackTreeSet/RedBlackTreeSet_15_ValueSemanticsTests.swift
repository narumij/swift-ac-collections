import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetValueSemanticsTests: RedBlackTreeTestCase {

  /// コピーを変更しても元の集合は変更されないこと
  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original: RedBlackTreeSet = [1, 2, 3]
    var copy = original

    XCTAssertTrue(copy.insert(99).inserted)
    XCTAssertEqual(copy.remove(2), 2)

    XCTAssertEqual(Array(original), [1, 2, 3])
    XCTAssertEqual(Array(copy), [1, 3, 99])
  }
}
