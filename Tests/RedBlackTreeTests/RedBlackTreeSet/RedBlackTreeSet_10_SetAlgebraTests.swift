import RedBlackTreeModule
import XCTest

final class RedBlackTreeSetSetAlgebraTests: RedBlackTreeTestCase {

  /// unionが正しく動作すること
  func test_union() {
    // 事前条件: set1, set2
    let set1 = RedBlackTreeSet([1, 2, 3])
    let set2 = RedBlackTreeSet([3, 4, 5])

    // 実行: union
    let result = set1.union(set2)

    // 事後条件: 重複なしの和集合
    XCTAssertEqual(result.sorted(), [1, 2, 3, 4, 5])
  }

  /// formUnionが正しく動作すること
  func test_formUnion() {
    var set1 = RedBlackTreeSet([1, 2, 3])
    let set2 = RedBlackTreeSet([3, 4, 5])

    set1.formUnion(set2)

    XCTAssertEqual(set1.sorted(), [1, 2, 3, 4, 5])
  }

  /// intersectionが正しく動作すること
  func test_intersection() {
    let set1 = RedBlackTreeSet([1, 2, 3])
    let set2 = RedBlackTreeSet([3, 4, 5])

    let result = set1.intersection(set2)

    XCTAssertEqual(result.sorted(), [3])
  }

  /// formIntersectionが正しく動作すること
  func test_formIntersection() {
    var set1 = RedBlackTreeSet([1, 2, 3])
    let set2 = RedBlackTreeSet([3, 4, 5])

    set1.formIntersection(set2)

    XCTAssertEqual(set1.sorted(), [3])
  }

  /// symmetricDifferenceが正しく動作すること
  func test_symmetricDifference() {
    let set1 = RedBlackTreeSet([1, 2, 3])
    let set2 = RedBlackTreeSet([3, 4, 5])

    let result = set1.symmetricDifference(set2)

    XCTAssertEqual(result.sorted(), [1, 2, 4, 5])
  }

  /// formSymmetricDifferenceが正しく動作すること
  func test_formSymmetricDifference() {
    var set1 = RedBlackTreeSet([1, 2, 3])
    let set2 = RedBlackTreeSet([3, 4, 5])

    set1.formSymmetricDifference(set2)

    XCTAssertEqual(set1.sorted(), [1, 2, 4, 5])
  }
}

extension RedBlackTreeSetSetAlgebraTests {

  /// formUnionで一方の集合が空のとき、もう一方がそのまま残ること
  func test_formUnion_withEmptySet() {
    var set1 = RedBlackTreeSet([1, 2, 3])
    let set2 = RedBlackTreeSet<Int>()

    set1.formUnion(set2)

    XCTAssertEqual(set1.sorted(), [1, 2, 3])
  }

  /// formUnionで両方空集合のとき、結果も空であること
  func test_formUnion_bothEmpty() {
    var set1 = RedBlackTreeSet<Int>()
    let set2 = RedBlackTreeSet<Int>()

    set1.formUnion(set2)

    XCTAssertTrue(set1.isEmpty)
  }
}

extension RedBlackTreeSetSetAlgebraTests {

  /// formUnionでotherの先頭要素がselfより小さい場合、正しくマージされること
  func test_formUnion_otherElementsBeforeSelf() {
    var set1 = RedBlackTreeSet([2, 3])
    let set2 = RedBlackTreeSet([1])

    set1.formUnion(set2)

    XCTAssertEqual(set1.sorted(), [1, 2, 3])
  }
}

extension RedBlackTreeSetSetAlgebraTests {

  /// formSymmetricDifferenceで一部要素が異なる場合、正しく計算されること
  func test_formSymmetricDifference_partialOverlap() {
    var set1 = RedBlackTreeSet([1, 3])
    let set2 = RedBlackTreeSet([2, 3])

    set1.formSymmetricDifference(set2)

    XCTAssertEqual(set1.sorted(), [1, 2])
  }
}

extension RedBlackTreeSetSetAlgebraTests {

  /// formSymmetricDifferenceでotherが空の場合、全要素が保持されること
  func test_formSymmetricDifference_otherIsEmpty() {
    var set1 = RedBlackTreeSet([1, 2, 3])
    let set2 = RedBlackTreeSet<Int>()  // 空のセット

    set1.formSymmetricDifference(set2)

    XCTAssertEqual(set1.sorted(), [1, 2, 3])
  }
}

extension RedBlackTreeSetSetAlgebraTests {

  /// union操作のスモークテスト
  func test_smoke_union() {
    let a = RedBlackTreeSet([1, 3, 5])
    let b = RedBlackTreeSet([2, 4, 6])
    let result = a.union(b)
    XCTAssertFalse(result.isEmpty)
  }

  /// intersection操作のスモークテスト
  func test_smoke_intersection() {
    let a = RedBlackTreeSet([1, 2, 3])
    let b = RedBlackTreeSet([3, 4, 5])
    let result = a.intersection(b)
    XCTAssertFalse(result.isEmpty || result.isEmpty)
  }

  /// symmetricDifference操作のスモークテスト
  func test_smoke_symmetricDifference() {
    let a = RedBlackTreeSet([1, 2, 3])
    let b = RedBlackTreeSet([3, 4, 5])
    let result = a.symmetricDifference(b)
    XCTAssertFalse(result.isEmpty || result.isEmpty)
  }

  /// formUnion操作のスモークテスト
  func test_smoke_formUnion() {
    var a = RedBlackTreeSet([1, 3, 5])
    let b = RedBlackTreeSet([2, 4, 6])
    a.formUnion(b)
    XCTAssertFalse(a.isEmpty)
  }

  /// formIntersection操作のスモークテスト
  func test_smoke_formIntersection() {
    var a = RedBlackTreeSet([1, 2, 3])
    let b = RedBlackTreeSet([3, 4, 5])
    a.formIntersection(b)
    XCTAssertFalse(a.isEmpty || a.isEmpty)
  }

  /// formSymmetricDifference操作のスモークテスト
  func test_smoke_formSymmetricDifference() {
    var a = RedBlackTreeSet([1, 2, 3])
    let b = RedBlackTreeSet([3, 4, 5])
    a.formSymmetricDifference(b)
    XCTAssertFalse(a.isEmpty || a.isEmpty)
  }

  /// union操作で空集合を使ったスモークテスト
  func test_smoke_union_withEmpty() {
    let a = RedBlackTreeSet<Int>()
    let b = RedBlackTreeSet([1, 2, 3])
    let result = a.union(b)
    XCTAssertFalse(result.isEmpty)
  }

  /// intersection操作で空集合を使ったスモークテスト
  func test_smoke_intersection_withEmpty() {
    let a = RedBlackTreeSet<Int>()
    let b = RedBlackTreeSet([1, 2, 3])
    let result = a.intersection(b)
    XCTAssertTrue(result.isEmpty)
  }

  /// symmetricDifference操作で空集合を使ったスモークテスト
  func test_smoke_symmetricDifference_withEmpty() {
    let a = RedBlackTreeSet<Int>()
    let b = RedBlackTreeSet([1, 2, 3])
    let result = a.symmetricDifference(b)
    XCTAssertFalse(result.isEmpty)
  }

  /// subtract(_:) が正しく動作すること（勝手に生えるメソッド）
  func test_smoke_subtract() {
    let a = RedBlackTreeSet([1, 2, 3, 4, 5])
    let b = RedBlackTreeSet([3, 4, 5, 6, 7])
    let result = a.subtracting(b)
    XCTAssertEqual(result.sorted(), [1, 2])
  }

  /// formSubtract(_:) が正しく動作すること（勝手に生えるメソッド）
  func test_smoke_formSubtract() {
    var a = RedBlackTreeSet([1, 2, 3, 4, 5])
    let b = RedBlackTreeSet([3, 4, 5, 6, 7])
    a.subtract(b)
    XCTAssertEqual(a.sorted(), [1, 2])
  }
}
