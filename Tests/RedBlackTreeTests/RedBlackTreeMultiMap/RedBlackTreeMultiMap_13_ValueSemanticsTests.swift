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

  /// コピーした後、元の側とコピーの側をそれぞれクロージャの中で変更しても、互いに影響しないこと
  func test_copyOnWrite_mutatingInsideClosuresKeepsCopiesIndependent() {
    var original: RedBlackTreeMultiMap = [1: "a", 2: "b", 2: "b2", 3: "c"]
    original.insert(key: 0, value: "o")
    var copy = original

    // 変更はassertionの@autoclosureの中で行う。Swift 6.4の`-O`では、この形でCoWが壊れる型が
    // あった(`NextPermutationsSequence`、2026-10-07)。赤黒木では再現しなかった
    XCTAssertTrue(original.insert(key: 99, value: "z").inserted)
    XCTAssertTrue(copy.insert(key: 99, value: "z").inserted)

    XCTAssertEqual(Array(original.map(\.key)), [0, 1, 2, 2, 3, 99])
    XCTAssertEqual(Array(copy.map(\.key)), [0, 1, 2, 2, 3, 99])
  }
}
