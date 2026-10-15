//
//  BorrowedNextPermutations_2_SpanAccessTests.swift
//  swift-ac-collections
//

// `next()`が返す`Span`の読み方のTest as Specification（Swift 6.4以降の借用版）。
// - `Span`は0始まりの添字を持ち、元のCollectionの添字型や開始位置に依存しない
// - `count`は元の要素数と等しい
// - 各`Span`は、次の`next()`を呼ぶまでの間、現在の並びを読める
//
// 返された`Span`を次の`next()`の後まで使えないこと、iteratorの寿命を越えて持ち出せないことは
// compilerが拒否する性質で、実行時testでは表せない。PERM-051の返却記録にcompile結果を残す。

#if compiler(>=6.4)
import NextPermutationModule
import XCTest

final class BorrowedNextPermutations_2_SpanAccessTests: XCTestCase {

  func testSpanIsZeroBasedForSliceSource() throws {
    let slice = [9, 3, 1, 2, 9][1..<4]
    XCTAssertEqual(slice.startIndex, 1)
    var iterator = slice.borrowedNextPermutations()
    guard let span = iterator.next() else { return XCTFail("no first order") }
    XCTAssertEqual(span.indices, 0..<3)
    XCTAssertEqual(span[0], 3)
    XCTAssertEqual(span[1], 1)
    XCTAssertEqual(span[2], 2)
  }

  func testSpanIsZeroBasedForNonIntIndexedSource() throws {
    var iterator = "ab".borrowedNextPermutations()
    guard let span = iterator.next() else { return XCTFail("no first order") }
    XCTAssertEqual(span.indices, 0..<2)
    XCTAssertEqual(span[0], "a")
    XCTAssertEqual(span[1], "b")
  }

  func testSpanCountMatchesSourceCount() throws {
    var iterator = [4, 2, 7, 1].borrowedNextPermutations()
    var steps = 0
    while let span = iterator.next() {
      XCTAssertEqual(span.count, 4)
      XCTAssertFalse(span.isEmpty)
      steps += 1
      if steps == 3 { break }
    }
    XCTAssertEqual(steps, 3)
  }

  func testEmptySourceYieldsEmptySpan() throws {
    var iterator = [Int]().borrowedNextPermutations()
    guard let span = iterator.next() else { return XCTFail("no first order") }
    XCTAssertEqual(span.count, 0)
    XCTAssertTrue(span.isEmpty)
  }

  func testEachSpanReadsTheCurrentOrderBeforeAdvancing() throws {
    var iterator = [1, 2, 3].borrowedNextPermutations()
    var sums: [Int] = []
    var firstElements: [Int] = []
    while let span = iterator.next() {
      var sum = 0
      for i in span.indices {
        sum += span[i]
      }
      sums.append(sum)
      firstElements.append(span[0])
    }
    XCTAssertEqual(sums, [6, 6, 6, 6, 6, 6])
    XCTAssertEqual(firstElements, [1, 1, 2, 2, 3, 3])
  }
}

#endif
