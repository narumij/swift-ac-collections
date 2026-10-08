//
//  NextPermutationsSequence_1_EnumerationTests.swift
//  swift-ac-collections
//

// 列挙の規則のTest as Specification。
// `nextPermutations()`はC++の`next_permutation`と同じく、現在の並びを最初に返し、
// 辞書順で後続する並びだけを返す。全順列の列挙ではない。

import PermutationModule
import XCTest

final class NextPermutationsSequence_1_EnumerationTests: XCTestCase {

  func testTwoElements() throws {
    XCTAssertEqual(
      [1, 2].nextPermutations().map { Array($0) },
      [[1, 2], [2, 1]])
  }

  func testFromAscendingOrderEnumeratesAll() throws {
    XCTAssertEqual(
      [1, 2, 3].nextPermutations().map { Array($0) },
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
  }

  func testStartsFromCurrentOrder() throws {
    // 辞書順で先頭(昇順)ではない開始位置から、「現在位置以降」だけを辿る
    XCTAssertEqual(
      [2, 1, 3].nextPermutations().map { Array($0) },
      [[2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
  }

  func testDescendingYieldsOnce() throws {
    // 辞書順で最後なので、最初の一回で終了となる
    XCTAssertEqual([4, 3, 2, 1].nextPermutations().map { Array($0) }, [[4, 3, 2, 1]])
  }

  func testAllEqualYieldsOnce() throws {
    // 辞書順では変化しようがないので、最初の一回で終了となる
    XCTAssertEqual([0, 0].nextPermutations().map { Array($0) }, [[0, 0]])
  }

  func testEmptyYieldsOnce() throws {
    // 要素が無いので並べ替え不可能だが、他の境界(1回で終了)と同様に
    // 最初の1件のみ(空配列)を返して終了する
    XCTAssertEqual([Int]().nextPermutations().map { Array($0) }, [[]])
  }

  func testSingleElementYieldsOnce() throws {
    XCTAssertEqual([5].nextPermutations().map { Array($0) }, [[5]])
  }

  func testEqualElementsAreNotDuplicated() throws {
    // 比較上等しい要素は位置の違いだけで重複列挙しない(next_permutationと同じ)。
    // 参考: swift-algorithmsのpermutations()は[0, 0, 1]で、位置違いの重複を含む6件を返す。
    XCTAssertEqual(
      [0, 0, 1].nextPermutations().map { Array($0) },
      [[0, 0, 1], [0, 1, 0], [1, 0, 0]])
    XCTAssertEqual(
      [1, 1, 2, 2].nextPermutations().map { Array($0) },
      [
        [1, 1, 2, 2], [1, 2, 1, 2], [1, 2, 2, 1],
        [2, 1, 1, 2], [2, 1, 2, 1], [2, 2, 1, 1],
      ])
  }

  func testAcceptsNonArrayIntIndexedSources() throws {
    // Array以外のCollectionも入力にでき、元の並びから列挙する。
    XCTAssertEqual(
      (1..<4).nextPermutations().map { Array($0) },
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    // startIndexが0でないスライスでも、要素値の並びは同じ規則で列挙される。
    // (結果の添字の起点は`_3_PermutationCollectionTests`で固定する)
    let slice = [9, 3, 1, 2, 9][1..<4]
    XCTAssertEqual(
      slice.nextPermutations().map { Array($0) },
      [[3, 1, 2], [3, 2, 1]])
  }

  func testAcceptsNonIntIndexedSources() throws {
    // 要素はbufferへコピーしてから並べ替えるので、入力の添字型は問わない(2026-10-07から)。
    XCTAssertEqual(
      "bac".nextPermutations().map { String($0) },
      ["bac", "bca", "cab", "cba"])
  }

  func testSourceIsNotModified() throws {
    // 列挙は入力のコピーに対して行い、元のコレクションは変わらない
    let a = [1, 2, 3]
    _ = Array(a.nextPermutations())
    XCTAssertEqual(a, [1, 2, 3])
  }
}
