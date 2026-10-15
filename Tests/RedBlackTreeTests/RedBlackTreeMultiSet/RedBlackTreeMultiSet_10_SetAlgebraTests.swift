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
  /// form系の集合演算は変更するコピーだけを変え、バッファを共有していた元のmultisetと相手を変えないこと。
  /// どの演算も受け手の重複数が実際に変わる入力を使う（RBT-043 M5）
  func test_formOperations_changeOnlyTheReceiver() {
    let original = RedBlackTreeMultiSet([1, 2, 2, 3])
    let other = RedBlackTreeMultiSet([2, 3, 3, 4])
    let cases: [(name: String, operation: (inout RedBlackTreeMultiSet<Int>, RedBlackTreeMultiSet<Int>) -> Void, expected: [Int])] = [
      ("formUnion", { $0.formUnion($1) }, [1, 2, 2, 2, 3, 3, 3, 4]),
      ("formIntersection", { $0.formIntersection($1) }, [2, 3]),
      ("formDifference", { $0.formDifference($1) }, [1, 2]),
      ("formSymmetricDifference", { $0.formSymmetricDifference($1) }, [1, 2, 3, 4]),
    ]

    for (name, operation, expected) in cases {
      var receiver = original
      operation(&receiver, other)
      XCTAssertEqual(Array(receiver), expected, name)
      XCTAssertEqual(Array(original), [1, 2, 2, 3], name)
      XCTAssertEqual(Array(other), [2, 3, 3, 4], name)
    }
  }
}
