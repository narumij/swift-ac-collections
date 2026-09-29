import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapValueSemanticsTests: RedBlackTreeTestCase {

  /// コピーを変更しても元のマルチマップは変更されないこと
  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original: RedBlackTreeMultiMap = [1: "a", 2: "b", 2: "b2", 3: "c"]
    var copy = original

    copy.insert(key: 99, value: "z")
    #if COMPATIBLE_ATCODER_2025
      copy.removeAll(forKey: 2)
    #else
      copy.eraseMulti(2)
    #endif

    XCTAssertEqual(Array(original.map(\.key)), [1, 2, 2, 3])
    XCTAssertEqual(Array(copy.map(\.key)), [1, 3, 99])
  }
}
