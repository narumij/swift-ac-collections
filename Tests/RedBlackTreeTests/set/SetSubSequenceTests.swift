// RedBlackTreeSetSubSequenceTests.swift
// swift-tools-version:5.10
//
// Tests target に追加して `swift test` で実行
// モジュール名を合わせて下さい → YourPackageName

import RedBlackTreeModule
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

  #if COMPATIBLE_ATCODER_2025
    func testSliceStartEndCount() {
      let base = RedBlackTreeSet(0..<10)  // [0‥9]
      let slice = base.elements(in: 2..<6)  // [2,3,4,5]

      XCTAssertEqual(slice.count, 4)
      XCTAssertEqual(slice.first, 2)
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(slice.last, 5)
      #endif
      XCTAssertEqual(
        slice.distance(
          from: slice.startIndex,
          to: slice.endIndex), 4)
    }
  #endif

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

  #if COMPATIBLE_ATCODER_2025
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
  #endif

  // MARK: index invalidation after base mutation ------------------------

  #if COMPATIBLE_ATCODER_2025
    func testIndexInvalidationAfterBaseMutation() throws {
      // TODO: 再度確認
      var base: RedBlackTreeSet = [0, 1, 2, 3]
      let slice = base.elements(in: 1..<3)  // [1,2]

      let b_idx = base.firstIndex(of: 1)!
      let idx = slice.firstIndex(of: 1)!
      XCTAssertTrue(base.isValid(index: b_idx)) // これは従来と同じ挙動
      XCTAssertTrue(base.isValid(index: idx)) // これは従来と同じ挙動
      XCTAssertTrue(slice.isValid(index: idx)) // これは従来と同じ挙動
      
      base.remove(1)  // 基集合を変化させる

      XCTAssertFalse(base.isValid(index: b_idx)) // これは従来と同じ挙動
      XCTAssertFalse(base.isValid(index: idx)) // これは従来と同じ挙動
//      XCTAssertFalse(slice.isValid(index: idx)) // なぜ連動してfalseになる想定だったのか思い出せない
      XCTAssertTrue(slice.isValid(index: idx), " 内部挙動の変更でCoW後のslideに強く紐付いている")

      base.insert(1)
      #if DEBUG
        // 内部的には再利用で同一ノードとなる
        XCTAssertEqual(base.firstIndex(of: 1)?._rawTag, idx._rawTag, "これは固定された仕様では無く、あくまで確認")
      #endif

      XCTAssertFalse(base.isValid(index: b_idx), "内部挙動変更でfalseとなった")
      XCTAssertFalse(base.isValid(index: idx)) // これは従来と同じ挙動
//      XCTAssertFalse(slice.isValid(index: idx)) // なぜ連動してfalseになる想定だったのか思い出せない
      XCTAssertTrue(slice.isValid(index: idx), " 内部挙動の変更でCoW後のslideに強く紐付いている")
    }
  #endif
}
