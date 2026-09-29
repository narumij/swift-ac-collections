import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryValueSemanticsTests: RedBlackTreeTestCase {

  /// コピーを変更しても元の辞書は変更されないこと
  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
    var copy = original

    copy[99] = "z"
    copy.removeValue(forKey: 2)

    XCTAssertEqual(Array(original.map(\.key)), [1, 2, 3])
    XCTAssertEqual(Array(copy.map(\.key)), [1, 3, 99])
  }
}
