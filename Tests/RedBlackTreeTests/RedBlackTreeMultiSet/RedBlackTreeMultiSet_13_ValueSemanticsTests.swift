import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetValueSemanticsTests: RedBlackTreeTestCase {

  /// コピーを変更しても元の集合は変更されないこと
  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original: RedBlackTreeMultiSet = [1, 2, 2, 3]
    var copy = original

    copy.insert(99)
      copy.eraseMulti(2)

    XCTAssertEqual(Array(original), [1, 2, 2, 3])
    XCTAssertEqual(Array(copy), [1, 3, 99])
  }

  /// コピーした後、元の側とコピーの側をそれぞれクロージャの中で変更しても、互いに影響しないこと
  func test_copyOnWrite_mutatingInsideClosuresKeepsCopiesIndependent() {
    var original: RedBlackTreeMultiSet = [1, 2, 2, 3]
    original.insert(0)
    var copy = original

    // 変更はassertionの@autoclosureの中で行う。Swift 6.4の`-O`では、この形でCoWが壊れる型が
    // あった(`NextPermutationsSequence`、2026-10-07)。赤黒木では再現しなかった
    XCTAssertTrue(original.insert(99).inserted)
    XCTAssertTrue(copy.insert(99).inserted)

    XCTAssertEqual(Array(original), [0, 1, 2, 2, 3, 99])
    XCTAssertEqual(Array(copy), [0, 1, 2, 2, 3, 99])
  }
}
