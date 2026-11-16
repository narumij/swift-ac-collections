//
//  BorrowedNextPermutations_98_InternalTests.swift
//  swift-ac-collections
//

// 所有と破棄の検査（Swift 6.4以降の借用版）。公開契約そのものではなく、実装の寿命管理を確かめる。
// - iteratorは元の要素を自分のbufferへコピーして保持し、元のCollectionが無くなっても要素を生かす
// - iteratorの破棄で、保持していた要素をそれぞれちょうど1回解放する
// - 一度も列挙せずに破棄しても、列挙の途中や列挙を終えてから破棄しても同じ

#if compiler(>=6.4)
import NextPermutationModule
import XCTest

/// Because `Span` is `~Escapable`, it cannot be passed directly to `XCTAssertNil` or similar APIs. Returns only whether a next permutation existed.
private func advance<Element: Comparable>(_ iterator: inout BorrowedNextPermutations<Element>) -> Bool {
  iterator.next() != nil
}

/// A box that counts releases. Create one per test function to avoid global state.
private final class ReleaseCounter {
  var count = 0
}

private final class Tracked: Comparable {
  let value: Int
  let counter: ReleaseCounter

  init(_ value: Int, _ counter: ReleaseCounter) {
    self.value = value
    self.counter = counter
  }

  deinit { counter.count += 1 }

  static func == (lhs: Tracked, rhs: Tracked) -> Bool { lhs.value == rhs.value }
  static func < (lhs: Tracked, rhs: Tracked) -> Bool { lhs.value < rhs.value }
}

final class BorrowedNextPermutations_98_InternalTests: XCTestCase {

  func testIteratorKeepsCopiedElementsAliveAfterSourceIsGone() throws {
    let counter = ReleaseCounter()
    var iterator: BorrowedNextPermutations<Tracked>
    do {
      let source = [Tracked(1, counter), Tracked(2, counter)]
      iterator = source.borrowedNextPermutations()
    }
    XCTAssertEqual(counter.count, 0)
    // `Span`が生きている間は`consume iterator`がcompile errorになるので、読み終えてから破棄する
    do {
      guard let span = iterator.next() else { return XCTFail("no first order") }
      XCTAssertEqual(span[0].value, 1)
      XCTAssertEqual(span[1].value, 2)
    }
    _ = consume iterator
    XCTAssertEqual(counter.count, 2)
  }

  func testDestroyingNeverStartedIteratorReleasesEachElementOnce() throws {
    let counter = ReleaseCounter()
    do {
      // 元配列は式の中だけの一時値で、iteratorの外に要素への参照を残さない
      let iterator = [Tracked(1, counter), Tracked(2, counter), Tracked(3, counter)]
        .borrowedNextPermutations()
      XCTAssertEqual(counter.count, 0)
      _ = consume iterator
    }
    XCTAssertEqual(counter.count, 3)
  }

  func testDestroyingMidwayReleasesEachElementOnce() throws {
    let counter = ReleaseCounter()
    do {
      var iterator = [Tracked(1, counter), Tracked(2, counter), Tracked(3, counter)]
        .borrowedNextPermutations()
      _ = iterator.next()
      _ = iterator.next()
    }
    XCTAssertEqual(counter.count, 3)
  }

  func testDestroyingAfterExhaustionReleasesEachElementOnce() throws {
    let counter = ReleaseCounter()
    do {
      var iterator = [Tracked(1, counter), Tracked(2, counter), Tracked(3, counter)]
        .borrowedNextPermutations()
      var steps = 0
      while iterator.next() != nil {
        steps += 1
      }
      XCTAssertEqual(steps, 6)
      XCTAssertFalse(advance(&iterator))
    }
    XCTAssertEqual(counter.count, 3)
  }

  func testDestroyingEmptyIteratorIsSafe() throws {
    do {
      var iterator = [Int]().borrowedNextPermutations()
      _ = iterator.next()
    }
    do {
      _ = [Int]().borrowedNextPermutations()
    }
  }
}

#endif
