// RedBlackTreeSetSubSequenceTests.swift
// swift-tools-version:5.10
//
// Tests target に追加して `swift test` で実行
// モジュール名を合わせて下さい → YourPackageName

import XCTest

@testable import RedBlackTreeModule

final class RedBlackTreeSetSubSequenceTests: XCTestCase {

  // MARK: 基本プロパティ -------------------------------------------------

  func testSliceStartEndCount() {
    let base = RedBlackTreeSet(0..<10)  // [0‥9]
    let slice = base.elements(in: 2..<6)  // [2,3,4,5]

    XCTAssertEqual(slice.count, 4)
    XCTAssertEqual(slice.first, 2)
    XCTAssertEqual(slice.last, 5)
    XCTAssertEqual(
      slice.distance(
        from: slice.startIndex,
        to: slice.endIndex), 4)
  }

  // MARK: forward / backward イテレーション ------------------------------

  func testBidirectionalIteration() {
    let base: RedBlackTreeSet = [1, 2, 3, 4, 5, 6, 7]
    let slice = base.elements(in: 2..<6)  // [2,3,4,5]

    XCTAssertEqual(Array(slice), [2, 3, 4, 5])  // forward
    XCTAssertEqual(Array(slice.reversed()), [5, 4, 3, 2])  // backward
  }

  // MARK: offsetBy / limitedBy ------------------------------------------

  func testSliceIndexOffsetting() {
    let set: RedBlackTreeSet = [0, 1, 2, 3, 4, 5, 6]
    let slice = set.elements(in: 1...4)  // [1,2,3,4]

    let idx2 = slice.index(slice.startIndex, offsetBy: 2)
    XCTAssertEqual(slice[idx2], 3)

    let nilIdx = slice.index(
      slice.startIndex,
      offsetBy: 10,
      limitedBy: slice.endIndex)
    XCTAssertNil(nilIdx)
  }

  // MARK: index invalidation after base mutation ------------------------

  func testIndexInvalidationAfterBaseMutation() {
    var base: RedBlackTreeSet = [0, 1, 2, 3]
    let slice = base.elements(in: 1..<3)  // [1,2]

    let idx = slice.firstIndex(of: 1)!
    base.remove(1)  // 基集合を変化させる

    XCTAssertFalse(base.isValid(index: idx))
    XCTAssertFalse(slice.isValid(index: idx))
  }
}
