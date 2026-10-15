//
//  NextPermutations_1_EnumerationTests.swift
//  swift-ac-collections
//

// 列挙順と境界のTest as Specification（runtime-check版`NextPermutations`、PERM-053 G1）。
// - 最初の`next()`は元の並びそのものを返す
// - 以後は辞書順の後続だけを返し、元の並びより前の並びは返さない
// - 比較上等しい要素は、位置の違いだけで重複列挙しない
// - 空、単一要素、全要素が等しい並び、後続のない並びは、現在の並びを1回だけ返す
// - 入力のCollectionの種類（Array、Range、Slice、Int以外のIndex）によらず同じ規則で列挙する
// - 元のCollectionは変更しない
// - 終了後の`next()`は`nil`を返し続ける
//
// `Permutation`は次の`next()`で無効になるViewなので、各Viewを次の`next()`より前に配列へ写す。
// View自体を保持して後で比べることはしない。

#if !COMPATIBLE_ATCODER_2025
import NextPermutationModule
import XCTest

/// Copies each view into an owning array before the next call to `next()` and collects the results.
private func orders<C: Collection>(_ source: C) -> [[C.Element]] where C.Element: Comparable {
  var permutations = source.nextPermutations()
  var result: [[C.Element]] = []
  while let permutation = permutations.next() {
    result.append(Array(permutation))
  }
  return result
}

final class NextPermutations_1_EnumerationTests: XCTestCase {

  func testTwoElements() throws {
    XCTAssertEqual(orders([1, 2]), [[1, 2], [2, 1]])
  }

  func testFromAscendingOrderEnumeratesAll() throws {
    XCTAssertEqual(
      orders([1, 2, 3]),
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
  }

  func testStartsFromCurrentOrder() throws {
    XCTAssertEqual(
      orders([2, 1, 3]),
      [[2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
  }

  func testDescendingYieldsOnce() throws {
    XCTAssertEqual(orders([3, 2, 1]), [[3, 2, 1]])
  }

  func testAllEqualYieldsOnce() throws {
    XCTAssertEqual(orders([5, 5, 5]), [[5, 5, 5]])
  }

  func testEmptyYieldsOnce() throws {
    XCTAssertEqual(orders([Int]()), [[]])
  }

  func testSingleElementYieldsOnce() throws {
    XCTAssertEqual(orders([7]), [[7]])
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

  func testAcceptsNonArrayIntIndexedSources() throws {
    XCTAssertEqual(
      orders(1..<4),
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    // startIndexが0でないスライスでも、要素値の並びから列挙する
    let slice = [9, 3, 1, 2, 9][1..<4]
    XCTAssertEqual(slice.startIndex, 1)
    XCTAssertEqual(orders(slice), [[3, 1, 2], [3, 2, 1]])
  }

  func testAcceptsNonIntIndexedSources() throws {
    XCTAssertEqual(orders("ab"), [["a", "b"], ["b", "a"]])
    XCTAssertEqual(orders("ba"), [["b", "a"]])
  }

  func testSourceIsNotModified() throws {
    let source = [2, 1, 3]
    _ = orders(source)
    XCTAssertEqual(source, [2, 1, 3])
  }

  func testReturnsNilRepeatedlyAfterCompletion() throws {
    var permutations = [1, 2].nextPermutations()
    XCTAssertNotNil(permutations.next())
    XCTAssertNotNil(permutations.next())
    XCTAssertNil(permutations.next())
    XCTAssertNil(permutations.next())
    XCTAssertNil(permutations.next())
  }
}

#endif
