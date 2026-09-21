// RedBlackTreeSetSubSequenceTests.swift
// swift-tools-version:5.10
//
// Tests target に追加して `swift test` で実行
// モジュール名を合わせて下さい → YourPackageName

import RedBlackTreeCollections
import XCTest

final class SetSubSequenceTests: RedBlackTreeTestCase {

  func testEmptySlice() {

    // 軽く心配になったが、release/AtCoder/2025でも同じ動作結果が得られた

    let base = RedBlackTreeSet(0..<10)  // [0‥9]

    #if COMPATIBLE_ATCODER_2025
      do {
        let slice = base[base.startIndex..<base.startIndex]  // []

        XCTAssertEqual(slice.count, 0)
        XCTAssertEqual(slice.first, nil)
        XCTAssertEqual(slice.last, nil)
        XCTAssertEqual(
          slice.distance(
            from: slice.startIndex,
            to: slice.endIndex), 0)
      }

      do {
        let mid = base.startIndex.advanced(by: 5)
        let slice = base[mid..<mid]  // []

        XCTAssertEqual(slice.count, 0)
        XCTAssertEqual(slice.first, nil)
        XCTAssertEqual(slice.last, nil)
        XCTAssertEqual(
          slice.distance(
            from: slice.startIndex,
            to: slice.endIndex), 0)
      }

      do {
        let slice = base[base.endIndex..<base.endIndex]  // []

        XCTAssertEqual(slice.count, 0)
        XCTAssertEqual(slice.first, nil)
        XCTAssertEqual(slice.last, nil)
        XCTAssertEqual(
          slice.distance(
            from: slice.startIndex,
            to: slice.endIndex), 0)
      }
    #endif
  }

  // MARK: 基本プロパティ -------------------------------------------------


  func testSliceSorted() {
    let base = RedBlackTreeSet(0..<10)  // [0‥9]
    let slice = base.elements(in: 2..<6)  // [2,3,4,5]

    XCTAssertEqual(slice.sorted().count, 4)
    XCTAssertEqual(slice.sorted().first, 2)
    XCTAssertEqual(slice.sorted().last, 5)
  }

  // MARK: forward / backward イテレーション ------------------------------

  func testBidirectionalIteration() {
    let base: RedBlackTreeSet = [1, 2, 3, 4, 5, 6, 7]
    let slice = base.elements(in: 2..<6)  // [2,3,4,5]

    XCTAssertEqual(Array(slice), [2, 3, 4, 5])  // forward
    XCTAssertEqual(Array(slice.reversed()), [5, 4, 3, 2])  // backward
  }

  // MARK: offsetBy / limitedBy ------------------------------------------


  // MARK: index invalidation after base mutation ------------------------

}
