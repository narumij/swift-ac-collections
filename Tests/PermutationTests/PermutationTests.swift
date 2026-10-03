//
//  PermutationTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/01/01.
//

import PermutationModule
import XCTest

#if USING_ALGORITHMS
  import Algorithms
#endif

final class PermutationTests: XCTestCase {

  private func requireSendable<T: Sendable>(_: T) {}
  private func requireSendableType<T: Sendable>(_: T.Type) {}

  func testSendableSequenceSurface() {
    requireSendableType(Permutations<[Int]>.self)
    requireSendable([1, 2, 3].nextPermutations())
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

  #if USING_ALGORITHMS
  // 挙動比較用
    func testExample0() throws {
      do {
        let a = [1, 2]
        XCTAssertEqual(
          a.permutations().map { $0 },
          [[1, 2], [2, 1]])
      }
      do {
        let a = [1, 2, 3]
        XCTAssertEqual(
          a.permutations().map { $0 },
          [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
      }
      do {
        let a = [0, 0, 1]
        XCTAssertEqual(
          a.permutations().map { $0 },
          [[0, 0, 1], [0, 1, 0], [0, 0, 1], [0, 1, 0], [1, 0, 0], [1, 0, 0]])
      }
    }
  #endif

  func testNextPermutations() throws {
    do {
      let a = [1, 2]
      XCTAssertEqual(
        a.nextPermutations().map { $0.map { $0 } },
        [[1, 2], [2, 1]])
      XCTAssertEqual(
        a.nextPermutations().map { $0 }.map { $0.map { $0 } },
        [[1, 2], [2, 1]])
    }
    do {
      let a = [1, 2, 3]
      let aa = a.nextPermutations().map { $0 }
      XCTAssertEqual(
        aa.map { $0.map { $0 } },
        [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    }
    do {
      let a = [0, 0]
      let aa = a.nextPermutations().map { $0 }
      // 辞書順では変化しようがないので、最初の一回で終了となる
      XCTAssertEqual(
        aa.map { $0.map { $0 } },
        [[0, 0]])
    }
    do {
      let a = [4, 3, 2, 1]
      let aa = a.nextPermutations().map { $0 }
      // 辞書順で最後なので、最初の一回で終了となる
      XCTAssertEqual(
        aa.map { $0.map { $0 } },
        [[4, 3, 2, 1]])
    }
    do {
      // 空コレクション: 要素が無いので並べ替え不可能だが、他の境界(1回で終了)と
      // 同様に最初の1件のみ(空配列)を返して終了する
      let a = [Int]()
      let aa = a.nextPermutations().map { $0 }
      XCTAssertEqual(aa.map { $0.map { $0 } }, [[]])
    }
    do {
      // 単一要素: 並べ替えの余地が無いので最初の1件のみで終了する
      let a = [5]
      let aa = a.nextPermutations().map { $0 }
      XCTAssertEqual(aa.map { $0.map { $0 } }, [[5]])
    }
    do {
      // 辞書順で先頭(昇順)ではない開始位置から辞書順の「現在位置以降」だけを
      // 辿ることを確認する(先頭からの全列挙ではないことの確認)
      let a = [2, 1, 3]
      let aa = a.nextPermutations().map { $0 }
      XCTAssertEqual(
        aa.map { $0.map { $0 } },
        [[2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    }
    do {
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        for p in (0..<4).nextPermutations() {
          XCTAssertEqual(p._copyCount, 0)
        }
      #endif
    }
  }

  func testNextPermutationsRetainedResultsRemainStable() throws {
    // CoWにより、以前にyieldされた結果(SubSequenceN)はイテレータがさらに進んでも
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

#if ENABLE_PERFORMANCE_TESTING
  #if USING_ALGORITHMS
    func testPerformance0() throws {
      #if DEBUG
        let s = (0..<9) + []
      #else
        let s = (0..<10) + []
      #endif
      var ans = 0
      self.measure {
        for p in s.permutations() {
          ans += p.count
        }
      }
      print(ans)
    }
  #endif
#endif
}
