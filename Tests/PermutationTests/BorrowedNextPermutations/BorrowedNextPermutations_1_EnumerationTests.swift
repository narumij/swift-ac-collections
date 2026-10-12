//
//  BorrowedNextPermutations_1_EnumerationTests.swift
//  swift-ac-collections
//

// 列挙順と境界のTest as Specification（Swift 6.4以降の借用版）。
// - 最初の`next()`は元の並びそのものを返す
// - 以後は辞書順の後続だけを返し、元の並びより前の並びは返さない
// - 比較上等しい要素は、位置の違いだけで重複列挙しない
// - 空、単一要素、全要素が等しい並び、後続のない並びは、現在の並びを1回だけ返す
// - 最後の並びの後は`nil`を返し、以後も`nil`を返し続ける
// - 元のCollectionは変更しない

#if compiler(>=6.4)
import PermutationModule
import XCTest

/// `Span`は`~Escapable`なので`XCTAssertNil`等へ直接渡せない。次の並びがあったかだけを返す。
private func advance<Element: Comparable>(_ iterator: inout BorrowedNextPermutations<Element>) -> Bool {
  iterator.next() != nil
}

/// 各`Span`を次の`next()`より前に配列へ写して、列挙結果を集める。
private func collect<Element: Comparable>(
  _ iterator: inout BorrowedNextPermutations<Element>
) -> [[Element]] {
  var result: [[Element]] = []
  while let span = iterator.next() {
    var order: [Element] = []
    for i in 0..<span.count {
      order.append(span[i])
    }
    result.append(order)
  }
  return result
}

private func orders<C: Collection>(_ source: C) -> [[C.Element]] where C.Element: Comparable {
  var iterator = source.borrowedNextPermutations()
  return collect(&iterator)
}

final class BorrowedNextPermutations_1_EnumerationTests: XCTestCase {

  func testFromAscendingOrderEnumeratesAll() throws {
    XCTAssertEqual(
      orders([1, 2, 3]),
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
  }

  func testStartsFromCurrentOrderAndYieldsOnlySuccessors() throws {
    XCTAssertEqual(
      orders([2, 1, 3]),
      [[2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
  }

  func testTwoElements() throws {
    XCTAssertEqual(orders([1, 2]), [[1, 2], [2, 1]])
  }

  func testEmptyYieldsOnce() throws {
    XCTAssertEqual(orders([Int]()), [[]])
  }

  func testSingleElementYieldsOnce() throws {
    XCTAssertEqual(orders([7]), [[7]])
  }

  func testAllEqualYieldsOnce() throws {
    XCTAssertEqual(orders([5, 5, 5]), [[5, 5, 5]])
  }

  func testDescendingYieldsOnce() throws {
    XCTAssertEqual(orders([3, 2, 1]), [[3, 2, 1]])
  }

  func testEqualElementsAreNotDuplicated() throws {
    XCTAssertEqual(
      orders([0, 0, 1]),
      [[0, 0, 1], [0, 1, 0], [1, 0, 0]])
    XCTAssertEqual(
      orders([1, 1, 2, 2]),
      [
        [1, 1, 2, 2], [1, 2, 1, 2], [1, 2, 2, 1],
        [2, 1, 1, 2], [2, 1, 2, 1], [2, 2, 1, 1],
      ])
  }

  func testReturnsNilRepeatedlyAfterTheLastOrder() throws {
    var iterator = [1, 2].borrowedNextPermutations()
    XCTAssertTrue(advance(&iterator))
    XCTAssertTrue(advance(&iterator))
    XCTAssertFalse(advance(&iterator))
    XCTAssertFalse(advance(&iterator))
    XCTAssertFalse(advance(&iterator))
  }

  func testReturnsNilRepeatedlyAfterASingleOrder() throws {
    var iterator = [Int]().borrowedNextPermutations()
    XCTAssertTrue(advance(&iterator))
    XCTAssertFalse(advance(&iterator))
    XCTAssertFalse(advance(&iterator))
  }

  func testAcceptsNonArraySources() throws {
    XCTAssertEqual(
      orders(1..<4),
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    // startIndexが0でないスライスでも、要素値の並びから列挙する
    let slice = [9, 3, 1, 2, 9][1..<4]
    XCTAssertEqual(orders(slice), [[3, 1, 2], [3, 2, 1]])
    // Int以外のIndexを持つCollection
    XCTAssertEqual(orders("ba"), [["b", "a"]])
    XCTAssertEqual(orders("ab"), [["a", "b"], ["b", "a"]])
  }

  func testSourceIsNotModified() throws {
    let source = [2, 1, 3]
    var iterator = source.borrowedNextPermutations()
    _ = collect(&iterator)
    XCTAssertEqual(source, [2, 1, 3])
  }
}

#endif
