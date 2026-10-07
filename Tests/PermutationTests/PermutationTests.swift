//
//  PermutationTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/01/01.
//

import PermutationModule
import XCTest

final class PermutationTests: XCTestCase {

  private func requireSendable<T: Sendable>(_: T) {}
  private func requireSendableType<T: Sendable>(_: T.Type) {}

  func testSendableSequenceSurface() {
    requireSendableType(NextPermutationsSequence<[Int]>.self)
    requireSendable([1, 2, 3].nextPermutations())
  }

  func testPublicTypeNames() throws {
    // 公開型の名前と入れ子の形を固定する(2026-10-07改名)。
    let sequence: NextPermutationsSequence<[Int]> = [1, 2].nextPermutations()
    var iterator: NextPermutationsSequence<[Int]>.Iterator = sequence.makeIterator()
    let first: NextPermutationsSequence<[Int]>.Permutation? = iterator.next()
    XCTAssertEqual(first.map { Array($0) }, [1, 2])
  }

  func testSendableIteratorAndYieldedValueRemainIndependentAcrossTask() async throws {
    var iterator = [1, 2, 3].nextPermutations().makeIterator()
    let first = try XCTUnwrap(iterator.next())

    requireSendable(iterator)
    requireSendable(first)

    let reader = Task.detached { Array(first) }
    let second = try XCTUnwrap(iterator.next())
    let firstElements = await reader.value

    XCTAssertEqual(firstElements, [1, 2, 3])
    XCTAssertEqual(Array(second), [1, 3, 2])
  }

  func testSendableIteratorCopiesAdvanceIndependentlyAcrossTasks() async {
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

  func testNextPermutationsTwoElements() throws {
    XCTAssertEqual(
      [1, 2].nextPermutations().map { Array($0) },
      [[1, 2], [2, 1]])
    // 先に全件を集めてから読んでも、各結果は列挙時の並びのまま
    let collected = Array([1, 2].nextPermutations())
    XCTAssertEqual(collected.map { Array($0) }, [[1, 2], [2, 1]])
  }

  func testNextPermutationsFromAscendingOrderEnumeratesAll() throws {
    XCTAssertEqual(
      [1, 2, 3].nextPermutations().map { Array($0) },
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
  }

  func testNextPermutationsAllEqualYieldsOnce() throws {
    // 辞書順では変化しようがないので、最初の一回で終了となる
    XCTAssertEqual([0, 0].nextPermutations().map { Array($0) }, [[0, 0]])
  }

  func testNextPermutationsDescendingYieldsOnce() throws {
    // 辞書順で最後なので、最初の一回で終了となる
    XCTAssertEqual([4, 3, 2, 1].nextPermutations().map { Array($0) }, [[4, 3, 2, 1]])
  }

  func testNextPermutationsEmptyYieldsOnce() throws {
    // 空コレクション: 要素が無いので並べ替え不可能だが、他の境界(1回で終了)と
    // 同様に最初の1件のみ(空配列)を返して終了する
    XCTAssertEqual([Int]().nextPermutations().map { Array($0) }, [[]])
  }

  func testNextPermutationsSingleElementYieldsOnce() throws {
    // 単一要素: 並べ替えの余地が無いので最初の1件のみで終了する
    XCTAssertEqual([5].nextPermutations().map { Array($0) }, [[5]])
  }

  func testNextPermutationsStartFromCurrentOrder() throws {
    // 辞書順で先頭(昇順)ではない開始位置から辞書順の「現在位置以降」だけを
    // 辿ることを確認する(先頭からの全列挙ではないことの確認)
    XCTAssertEqual(
      [2, 1, 3].nextPermutations().map { Array($0) },
      [[2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
  }

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    func testNextPermutationsDoNotCopyWhenResultsAreNotRetained() throws {
      // 結果を保持せずに進めるなら、bufferのコピーは起きない
      for p in (0..<4).nextPermutations() {
        XCTAssertEqual(p._copyCount, 0)
      }
    }
  #endif

  func testNextPermutationsDoNotDuplicateEqualElements() throws {
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

  func testNextPermutationsAcceptNonArrayIntIndexedSources() throws {
    // Index == Int の任意のCollectionを入力にでき、元の並びから列挙する。
    XCTAssertEqual(
      (1..<4).nextPermutations().map { Array($0) },
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    // startIndexが0でないスライスでも、要素値の並びは同じ規則で列挙される。
    // (yieldされるPermutationの添字の起点は契約として固定しない)
    let slice = [9, 3, 1, 2, 9][1..<4]
    XCTAssertEqual(
      slice.nextPermutations().map { Array($0) },
      [[3, 1, 2], [3, 2, 1]])
  }

  func testNextPermutationsRetainedResultsRemainStable() throws {
    // CoWにより、以前にyieldされた結果(Permutation)はイテレータがさらに進んでも
    // 書き換わらずに安定していることを直接確認する。
    let a = [1, 2, 3]
    var iterator = a.nextPermutations().makeIterator()
    let first = iterator.next()
    let second = iterator.next()
    let third = iterator.next()
    XCTAssertEqual(first.map { Array($0) }, [1, 2, 3])
    XCTAssertEqual(second.map { Array($0) }, [1, 3, 2])
    XCTAssertEqual(third.map { Array($0) }, [2, 1, 3])
  }

  func testSubSequenceSubscriptValidBoundaries() throws {
    // 有効範囲の両端(startIndex と endIndex - 1)は添字でアクセスできる。
    // 範囲外の添字は PermutationDeathTests で precondition 失敗を確認する。
    var iterator = [1, 2, 3].nextPermutations().makeIterator()
    _ = iterator.next()
    let p = try XCTUnwrap(iterator.next())
    XCTAssertEqual(p.startIndex, 0)
    XCTAssertEqual(p.endIndex, 3)
    XCTAssertEqual(p[p.startIndex], 1)
    XCTAssertEqual(p[p.endIndex - 1], 2)
  }
}
