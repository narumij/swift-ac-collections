import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetSetAlgebraTests: RedBlackTreeTestCase {

  // 互換モードのunion（個数の和）はRedBlackTreeMultiSetAtCoder2025CompatibilityTests.swiftで確認する
  #if !COMPATIBLE_ATCODER_2025
    func test_union_keepsMaximumMultiplicity() {
      let lhs = RedBlackTreeMultiSet([1, 2, 2, 3])
      let rhs = RedBlackTreeMultiSet([2, 3, 3, 4])

      XCTAssertEqual(Array(lhs.union(rhs)), [1, 2, 2, 3, 3, 4])
    }

    func test_formUnion_keepsMaximumMultiplicityInPlace() {
      var lhs = RedBlackTreeMultiSet([1, 2, 2, 3])

      lhs.formUnion(RedBlackTreeMultiSet([2, 3, 3, 4]))

      XCTAssertEqual(Array(lhs), [1, 2, 2, 3, 3, 4])
    }

    /// std::set_unionと同じく、同値要素は左の全要素と、右の末尾max(n − m, 0)個を残すこと（RBT-074）
    func test_union_keepsSameOccurrencesAsSetUnion() {
      struct Tagged: Comparable {
        let key: Int
        let tag: String
        static func < (a: Self, b: Self) -> Bool { a.key < b.key }
        static func == (a: Self, b: Self) -> Bool { a.key == b.key }
      }
      func tagged(_ pairs: [(Int, String)]) -> RedBlackTreeMultiSet<Tagged> {
        RedBlackTreeMultiSet(pairs.map { Tagged(key: $0.0, tag: $0.1) })
      }
      let cases: [(lhs: [(Int, String)], rhs: [(Int, String)], expected: [String])] = [
        ([(5, "a1"), (5, "a2"), (5, "a3")], [(5, "b1"), (5, "b2")], ["a1", "a2", "a3"]),
        ([(5, "a1"), (5, "a2")], [(5, "b1"), (5, "b2"), (5, "b3")], ["a1", "a2", "b3"]),
        (
          [(1, "a0"), (5, "a1"), (5, "a2"), (9, "a9")],
          [(5, "b1"), (5, "b2"), (5, "b3"), (7, "b7")],
          ["a0", "a1", "a2", "b3", "b7", "a9"]
        ),
      ]
      for (lhs, rhs, expected) in cases {
        XCTAssertEqual(tagged(lhs).union(tagged(rhs)).map(\.tag), expected)
        var formed = tagged(lhs)
        formed.formUnion(tagged(rhs))
        XCTAssertEqual(formed.map(\.tag), expected)
      }
    }
  #endif

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
    var cases: [(name: String, operation: (inout RedBlackTreeMultiSet<Int>, RedBlackTreeMultiSet<Int>) -> Void, expected: [Int])] = [
      ("formIntersection", { $0.formIntersection($1) }, [2, 3]),
      ("formDifference", { $0.formDifference($1) }, [1, 2]),
      ("formSymmetricDifference", { $0.formSymmetricDifference($1) }, [1, 2, 3, 4]),
    ]
    #if !COMPATIBLE_ATCODER_2025
      cases.append(("formUnion", { $0.formUnion($1) }, [1, 2, 2, 3, 3, 4]))
    #endif

    for (name, operation, expected) in cases {
      var receiver = original
      operation(&receiver, other)
      XCTAssertEqual(Array(receiver), expected, name)
      XCTAssertEqual(Array(original), [1, 2, 2, 3], name)
      XCTAssertEqual(Array(other), [2, 3, 3, 4], name)
    }
  }
}
