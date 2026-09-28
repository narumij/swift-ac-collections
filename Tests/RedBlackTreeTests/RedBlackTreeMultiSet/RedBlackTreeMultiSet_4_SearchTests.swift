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

    XCTAssertEqual(multiset.distance(from: range.lower, to: range.upper), 3)
    XCTAssertEqual(multiset[range.lower], 2)
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
