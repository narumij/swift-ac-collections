//
//  BorrowedNextPermutations_0_PublicSurfaceTests.swift
//  swift-ac-collections
//

// 公開表面のTest as Specification（Swift 6.4以降の借用版）。
// - 入口は`Collection.borrowedNextPermutations()`で、要素が`Comparable`のCollectionから呼べる
// - 返り値の型は`BorrowedNextPermutations<Element>`で、元のCollection型に依存しない
// - `next()`は`Span<Element>?`を返す
//
// この公開面は`#if compiler(>=6.4)`の中にだけ存在する。Swift 6.4未満で存在しないことは、
// このfileも同じ条件で囲まれているため、ここでは確認しない（PERM-051の返却記録を参照）。
// 型が`~Copyable`で`Sequence`に適合しないことは、compile結果として返却記録に残す。

#if compiler(>=6.4)
import NextPermutationModule
import XCTest

/// Because `Span` is `~Escapable`, it cannot be passed directly to `XCTAssertNil` or similar APIs. Returns only whether a next permutation existed.
private func advance<Element: Comparable>(_ iterator: inout BorrowedNextPermutations<Element>) -> Bool {
  iterator.next() != nil
}

final class BorrowedNextPermutations_0_PublicSurfaceTests: XCTestCase {

  func testEntryPointReturnsElementGenericIterator() throws {
    var fromArray: BorrowedNextPermutations<Int> = [1, 2].borrowedNextPermutations()
    var fromRange: BorrowedNextPermutations<Int> = (1..<3).borrowedNextPermutations()
    var fromSlice: BorrowedNextPermutations<Int> = [0, 1, 2][1...].borrowedNextPermutations()
    var fromString: BorrowedNextPermutations<Character> = "ab".borrowedNextPermutations()
    XCTAssertTrue(advance(&fromArray))
    XCTAssertTrue(advance(&fromRange))
    XCTAssertTrue(advance(&fromSlice))
    XCTAssertTrue(advance(&fromString))
  }

  func testNextReturnsOptionalSpan() throws {
    var iterator = [1, 2].borrowedNextPermutations()
    let first: Span<Int>? = iterator.next()
    XCTAssertEqual(first?.count, 2)
  }
}

#endif
