// RedBlackTreeMultisetSubSequenceTests.swift
// swift-tools-version:5.10
//
// SubSequence (読み取り専用) の振る舞いを検証
//   - 重複要素を正しく保持するか
//   - BidirectionalCollection の規約を満たすか
//   - 基 multiset 変化時に index が無効化されるか

import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultisetSubSequenceTests: RedBlackTreeTestCase {

  // MARK: 基本プロパティ -------------------------------------------------

  #if !COMPATIBLE_ATCODER_2025
  func testSliceCountFirstLast() {
    // 0 1 1 2 3 3 3 4
    let base: RedBlackTreeMultiSet = [0, 1, 1, 2, 3, 3, 3, 4]
    let slice = base.elements(in: 1...3)  // 1,1,2,3,3,3

    XCTAssertEqual(slice.count, 6)
    XCTAssertEqual(slice.first, 1)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(slice.last, 3)
      XCTAssertEqual(
        slice.distance(
          from: slice.startIndex,
          to: slice.endIndex), 6)
    #endif
  }
  #endif

  // MARK: forward / backward イテレーション ------------------------------

  func testBidirectionalIterationWithDuplicates() {
    let base: RedBlackTreeMultiSet = [1, 1, 2, 3, 3]
    let slice = base.elements(in: 1..<3)  // 1,1,2

    // forward
    XCTAssertEqual(Array(slice), [1, 1, 2])

    // backward
    XCTAssertEqual(Array(slice.reversed()), [2, 1, 1])
  }

  // MARK: offsetBy / limitedBy ------------------------------------------

}
