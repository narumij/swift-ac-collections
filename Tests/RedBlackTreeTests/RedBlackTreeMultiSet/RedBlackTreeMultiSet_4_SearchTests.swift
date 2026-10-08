import RedBlackTreeCollections
import XCTest

// RedBlackTreeMultiSet_N_* の連番テスト群は、現行の公開APIについての Test as Spec の正本。
final class RedBlackTreeMultiSetSearchTests: RedBlackTreeTestCase {

  func test_containsAndCount_distinguishMultiplicity() {
    let multiset = RedBlackTreeMultiSet([1, 2, 2, 2, 3])

    XCTAssertTrue(multiset.contains(2))
    XCTAssertEqual(multiset.count(of: 2), 3)
    XCTAssertFalse(multiset.contains(4))
    XCTAssertEqual(multiset.count(of: 4), 0)
  }

  func test_lowerAndUpperBound_encloseAllDuplicates() {
    let multiset = RedBlackTreeMultiSet([1, 2, 2, 2, 3])
    let lower = multiset.lowerBound(2)
    let upper = multiset.upperBound(2)

    XCTAssertEqual(multiset[lower], 2)
    XCTAssertEqual(multiset.distance(from: lower, to: upper), 3)
    XCTAssertEqual(multiset[upper], 3)
  }

  func test_equalRange_enclosesAllDuplicates() {
    let multiset = RedBlackTreeMultiSet([1, 2, 2, 2, 3])
    let range = multiset.equalRange(2)

    #if DEBUG
      XCTAssertEqual(multiset.distance(from: range.lower, to: range.upper), 3)
      XCTAssertEqual(multiset[range.lower], 2)
    #endif
  }

  func test_firstIndex_returnsFirstMatchingPosition() {
    let multiset = RedBlackTreeMultiSet([1, 2, 2, 3])

    XCTAssertEqual(multiset.firstIndex(of: 2), multiset.lowerBound(2))
    XCTAssertNil(multiset.firstIndex(of: 4))
  }

  func test_firstLastMinAndMax_coverEmptyAndNonEmptyMultisets() {
    let multiset = RedBlackTreeMultiSet([3, 1, 3, 2])
    let empty = RedBlackTreeMultiSet<Int>()

    XCTAssertEqual(multiset.first, 1)
    XCTAssertEqual(multiset.last, 3)
    XCTAssertEqual(multiset.min(), 1)
    XCTAssertEqual(multiset.max(), 3)
    XCTAssertNil(empty.first)
    XCTAssertNil(empty.last)
    XCTAssertNil(empty.min())
    XCTAssertNil(empty.max())
  }
}

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeMultiSetFindTests: RedBlackTreeTestCase {

    /// `find(_:)`は同値要素のうち先頭の位置を返し、無ければ`endIndex`を返すこと。
    func testFindReturnsFirstEquivalentOrEndIndex() {
      let m = RedBlackTreeMultiSet<Int>([1, 2, 2, 2, 3])
      let i = m.find(2)
      XCTAssertEqual(m[i], 2)
      XCTAssertEqual(i, m.lowerBound(2))
      XCTAssertEqual(m.find(9), m.endIndex)
      XCTAssertEqual(RedBlackTreeMultiSet<Int>().find(0), RedBlackTreeMultiSet<Int>().endIndex)
    }
  }
#endif
