import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetSetAlgebraTests: RedBlackTreeTestCase {

  func test_union_addsMultiplicities() {
    let lhs = RedBlackTreeMultiSet([1, 2, 2, 3])
    let rhs = RedBlackTreeMultiSet([2, 3, 3, 4])

    XCTAssertEqual(Array(lhs.union(rhs)), [1, 2, 2, 2, 3, 3, 3, 4])
  }

  func test_formUnion_addsMultiplicitiesInPlace() {
    var lhs = RedBlackTreeMultiSet([1, 2, 2, 3])

    lhs.formUnion(RedBlackTreeMultiSet([2, 3, 3, 4]))

    XCTAssertEqual(Array(lhs), [1, 2, 2, 2, 3, 3, 3, 4])
  }

  func test_intersection_keepsMinimumMultiplicity() {
    let lhs = RedBlackTreeMultiSet([1, 2, 2, 2, 3, 3])
    let rhs = RedBlackTreeMultiSet([2, 2, 3, 3, 3, 4])

    XCTAssertEqual(Array(lhs.intersection(rhs)), [2, 2, 3, 3])
  }

  func test_formIntersection_keepsMinimumMultiplicityInPlace() {
    var lhs = RedBlackTreeMultiSet([1, 2, 2, 2, 3, 3])

    lhs.formIntersection(RedBlackTreeMultiSet([2, 2, 3, 3, 3, 4]))

    XCTAssertEqual(Array(lhs), [2, 2, 3, 3])
  }

  func test_difference_subtractsMultiplicitiesWithoutGoingBelowZero() {
    let lhs = RedBlackTreeMultiSet([1, 2, 2, 2, 3])
    let rhs = RedBlackTreeMultiSet([2, 2, 3, 3, 4])

    XCTAssertEqual(Array(lhs.difference(rhs)), [1, 2])
  }

  func test_formDifference_subtractsMultiplicitiesInPlace() {
    var lhs = RedBlackTreeMultiSet([1, 1, 1, 2])

    lhs.formDifference(RedBlackTreeMultiSet([1, 1, 1, 1, 3]))

    XCTAssertEqual(Array(lhs), [2])
  }

  func test_symmetricDifference_keepsAbsoluteMultiplicityDifference() {
    let lhs = RedBlackTreeMultiSet([1, 2, 2, 3, 3, 3])
    let rhs = RedBlackTreeMultiSet([2, 3, 3, 4, 4])

    XCTAssertEqual(Array(lhs.symmetricDifference(rhs)), [1, 2, 3, 4, 4])
  }

  func test_formSymmetricDifference_keepsAbsoluteMultiplicityDifferenceInPlace() {
    var lhs = RedBlackTreeMultiSet([1, 1, 1, 2])

    lhs.formSymmetricDifference(RedBlackTreeMultiSet([1, 3]))

    XCTAssertEqual(Array(lhs), [1, 1, 2, 3])
  }
}
