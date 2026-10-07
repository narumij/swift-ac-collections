//
//  NextPermutationsSequence_2_ValueSemanticsTests.swift
//  swift-ac-collections
//

// 値セマンティクスのTest as Specification。
// - 取得済みの`Permutation`は、イテレータを先へ進めても書き換わらない
// - イテレータのコピーは、それぞれ独立に進む
// - 上の2点は、別のTaskへ渡した場合も成り立つ

import PermutationModule
import XCTest

final class NextPermutationsSequence_2_ValueSemanticsTests: XCTestCase {

  func testRetainedResultsRemainStable() throws {
    var iterator = [1, 2, 3].nextPermutations().makeIterator()
    let first = iterator.next()
    let second = iterator.next()
    let third = iterator.next()
    XCTAssertEqual(first.map { Array($0) }, [1, 2, 3])
    XCTAssertEqual(second.map { Array($0) }, [1, 3, 2])
    XCTAssertEqual(third.map { Array($0) }, [2, 1, 3])
  }

  func testCollectedResultsCanBeReadLater() throws {
    // 先に全件を集めてから読んでも、各結果は列挙時の並びのまま
    let collected = Array([1, 2, 3].nextPermutations())
    XCTAssertEqual(
      collected.map { Array($0) },
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
  }

  func testIteratorCopiesAdvanceIndependently() throws {
    var original = [1, 2, 3].nextPermutations().makeIterator()
    _ = original.next()
    var copy = original
    // `next()`はassertionの外で呼ぶ。Swift 6.4の`-O`では、コピー後の変数をクロージャ
    // (XCTAssertEqualの@autoclosureを含む)の中で変更すると、`isKnownUniquelyReferenced`が
    // コピーを見落として共有bufferを直接書き換える(2026-10-07確認、ライブラリ非依存で再現)。
    let originalSecond = original.next().map { Array($0) }
    let originalThird = original.next().map { Array($0) }
    let copySecond = copy.next().map { Array($0) }
    XCTAssertEqual(originalSecond, [1, 3, 2])
    XCTAssertEqual(originalThird, [2, 1, 3])
    XCTAssertEqual(copySecond, [1, 3, 2])
  }

  func testYieldedValueRemainsStableAcrossTask() async throws {
    var iterator = [1, 2, 3].nextPermutations().makeIterator()
    let first = try XCTUnwrap(iterator.next())

    let reader = Task.detached { Array(first) }
    let second = try XCTUnwrap(iterator.next())
    let firstElements = await reader.value

    XCTAssertEqual(firstElements, [1, 2, 3])
    XCTAssertEqual(Array(second), [1, 3, 2])
  }

  func testIteratorCopiesAdvanceIndependentlyAcrossTasks() async {
    let iterator = [1, 2, 3].nextPermutations().makeIterator()

    let firstTask = Task.detached { () -> [[Int]] in
      var copy = iterator
      var results: [[Int]] = []
      while let value = copy.next() {
        results.append(Array(value))
      }
      return results
    }
    let secondTask = Task.detached { () -> [[Int]] in
      var copy = iterator
      var results: [[Int]] = []
      while let value = copy.next() {
        results.append(Array(value))
      }
      return results
    }

    let firstResults = await firstTask.value
    let secondResults = await secondTask.value
    let expected = [
      [1, 2, 3], [1, 3, 2], [2, 1, 3],
      [2, 3, 1], [3, 1, 2], [3, 2, 1],
    ]

    XCTAssertEqual(firstResults, expected)
    XCTAssertEqual(secondResults, expected)
  }
}
