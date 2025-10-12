// RedBlackTreeSetBidirectionalTests.swift
// swift-tools-version:5.10
//
// Tests target に追加して `swift test` / Xcode ⌘-U で実行

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeSetBidirectionalTests: XCTestCase {

  // MARK: ── empty / single element ───────────────────────────────

  func testEmptySetIndices() {
    let s = RedBlackTreeSet<Int>()
    XCTAssertEqual(s.startIndex, s.endIndex)
    XCTAssertEqual(s.distance(from: s.startIndex, to: s.endIndex), 0)
  }

  func testSingleElementIndexing() {
    let s: RedBlackTreeSet = [42]
    XCTAssertNotEqual(s.startIndex, s.endIndex)
    XCTAssertEqual(s.distance(from: s.startIndex, to: s.endIndex), 1)
    XCTAssertEqual(s[s.startIndex], 42)

    let beforeEnd = s.index(before: s.endIndex)
    XCTAssertEqual(s[beforeEnd], 42)
    XCTAssertEqual(s.index(after: s.startIndex), s.endIndex)
  }

  // MARK: ── forward / backward iteration consistency ─────────────

  func testForwardAndBackwardIteration() {
    let s: RedBlackTreeSet = [1, 3, 5, 7, 9]
    // forward
    var fwd: [Int] = []
    for idx in s.indices { fwd.append(s[idx]) }
    // backward
    var bwd: [Int] = []
    var i = s.index(before: s.endIndex)
    while true {
      bwd.append(s[i])
      if i == s.startIndex { break }
      i = s.index(before: i)
    }
    XCTAssertEqual(fwd, [1, 3, 5, 7, 9])
    XCTAssertEqual(bwd, [9, 7, 5, 3, 1])
  }

  // MARK: ── offsetBy / limitedBy ─────────────────────────────────

  func testIndexOffsetBy() {
    let s: RedBlackTreeSet = [0, 1, 2, 3, 4]
    let idx2 = s.index(s.startIndex, offsetBy: 2)
    XCTAssertEqual(s[idx2], 2)

    let idxNeg1 = s.index(s.endIndex, offsetBy: -1)
    XCTAssertEqual(s[idxNeg1], 4)

    // limitedBy success
    let limited = s.index(s.startIndex, offsetBy: 3, limitedBy: s.endIndex)
    XCTAssertNotNil(limited)
    XCTAssertEqual(s[limited!], 3)

    // limitedBy failure → nil
    let nilIdx = s.index(s.startIndex, offsetBy: 6, limitedBy: s.endIndex)
    XCTAssertNil(nilIdx)
  }

  // MARK: ── formIndex(inout) 常時更新されるか ────────────────────

  func testFormIndexMutating() {
    let s: RedBlackTreeSet = [10, 20, 30]
    var i = s.startIndex
    s.formIndex(after: &i)
    XCTAssertEqual(s[i], 20)
    s.formIndex(before: &i)
    XCTAssertEqual(s[i], 10)

    var j = s.startIndex
    let ok = s.formIndex(&j, offsetBy: 2, limitedBy: s.endIndex)
    XCTAssertTrue(ok)
    XCTAssertEqual(s[j], 30)
  }

  // MARK: ── distance symmetry ───────────────────────────────────

  func testDistanceSymmetry() {
    let s: RedBlackTreeSet = .init(0..<50)
    let i = s.index(s.startIndex, offsetBy: 7)
    let j = s.index(s.startIndex, offsetBy: 42)
    XCTAssertEqual(s.distance(from: i, to: j), 35)
    XCTAssertEqual(s.distance(from: j, to: i), -35)
  }

  // MARK: ── slicing subscript verifies range behaviour ───────────

  func testSubscriptRange() {
    let s: RedBlackTreeSet = [0, 1, 2, 3, 4, 5]
    let low = s.index(s.startIndex, offsetBy: 2)  // → 2
    let high = s.index(s.startIndex, offsetBy: 5)  // → 5 (exclusive)
    let slice = s[low..<high]
    XCTAssertEqual(Array(slice), [2, 3, 4])
  }
}
