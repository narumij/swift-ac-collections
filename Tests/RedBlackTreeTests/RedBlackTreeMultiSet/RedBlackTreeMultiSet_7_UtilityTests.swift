import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetUtilityTests: RedBlackTreeTestCase {

  func test_isEmptyCountAndCapacity_describeStoredMembers() {
    let empty = RedBlackTreeMultiSet<Int>()
    let multiset = RedBlackTreeMultiSet([1, 2, 2, 3])

    XCTAssertTrue(empty.isEmpty)
    XCTAssertEqual(empty.count, 0)
    XCTAssertFalse(multiset.isEmpty)
    XCTAssertEqual(multiset.count, 4)
    XCTAssertGreaterThanOrEqual(multiset.capacity, multiset.count)
  }

  func test_indexRangeSubscript_preservesDuplicatePositions() {
    let multiset = RedBlackTreeMultiSet([1, 2, 2, 3, 4, 4, 5])
    let lower = multiset.lowerBound(2)
    let upper = multiset.upperBound(4)

    XCTAssertEqual(Array(multiset[lower..<upper]), [2, 2, 3, 4, 4])
    XCTAssertEqual(Array(multiset[..<lower]), [1])
    XCTAssertEqual(Array(multiset[upper...]), [5])
  }

  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original = RedBlackTreeMultiSet([1, 2, 2, 3])
    var copy = original

    copy.insert(2)
    #if !COMPATIBLE_ATCODER_2025
      XCTAssertTrue(copy.eraseUnique(1))
    #endif

    XCTAssertEqual(Array(original), [1, 2, 2, 3])
    #if !COMPATIBLE_ATCODER_2025
      XCTAssertEqual(Array(copy), [2, 2, 2, 3])
    #endif
  }

  func test_insertingContentsOf_returnsChangedCopy() {
    let original = RedBlackTreeMultiSet([1, 2])

    let result = original.inserting(contentsOf: [2, 3, 3])

    XCTAssertEqual(Array(original), [1, 2])
    XCTAssertEqual(Array(result), [1, 2, 2, 3, 3])
  }

  func test_meldAndMelding_preserveEveryMember() {
    let lhs = RedBlackTreeMultiSet([1, 2, 2])
    let rhs = RedBlackTreeMultiSet([2, 3])
    var mutated = lhs

    mutated.meld(rhs)
    let copied = lhs.melding(rhs)

    XCTAssertEqual(Array(mutated), [1, 2, 2, 2, 3])
    XCTAssertEqual(Array(copied), [1, 2, 2, 2, 3])
    XCTAssertEqual(Array(lhs), [1, 2, 2])
  }
}
