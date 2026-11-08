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

  /// コピーした後、元の側とコピーの側をそれぞれクロージャの中で変更しても、互いに影響しないこと
  func test_copyOnWrite_mutatingInsideClosuresKeepsCopiesIndependent() {
    var original: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
    original[0] = "o"
    var copy = original

    // 変更はassertionの@autoclosureの中で行う。Swift 6.4の`-O`では、この形でCoWが壊れる型が
    // あった(`NextPermutationsSequence`、2026-10-07)。赤黒木では再現しなかった
    XCTAssertNil(original.updateValue("z", forKey: 99))
    XCTAssertNil(copy.updateValue("z", forKey: 99))

    XCTAssertEqual(Array(original.map(\.key)), [0, 1, 2, 3, 99])
    XCTAssertEqual(Array(copy.map(\.key)), [0, 1, 2, 3, 99])
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionaryValueSemanticsTests {
    /// dict[k]?.mutatingが値をコピーせずにその場で変更すること（コピーするとappendの繰り返しがO(n^2)になる）。
    func test_optionalChainingModify_doesNotCopyValue() {
      final class Ref {}
      struct Probe {
        var ref = Ref()
        mutating func isUnique() -> Bool { isKnownUniquelyReferenced(&ref) }
      }
      var dictionary: RedBlackTreeDictionary<Int, Probe> = [0: Probe()]
      XCTAssertEqual(dictionary[0]?.isUnique(), true)
    }
  }
#endif
