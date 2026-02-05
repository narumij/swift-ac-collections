// RedBlackTreeMultisetSubSequenceTests.swift
// swift-tools-version:5.10
//
// SubSequence (読み取り専用) の振る舞いを検証
//   - 重複要素を正しく保持するか
//   - BidirectionalCollection の規約を満たすか
//   - 基 multiset 変化時に index が無効化されるか

import RedBlackTreeModule
import XCTest

final class RedBlackTreeMultisetSubSequenceTests: RedBlackTreeTestCase {

  // MARK: 基本プロパティ -------------------------------------------------

  func testSliceCountFirstLast() {
    // 0 1 1 2 3 3 3 4
    let base: RedBlackTreeMultiSet = [0, 1, 1, 2, 3, 3, 3, 4]
    let slice = base.elements(in: 1...3)  // 1,1,2,3,3,3

    XCTAssertEqual(slice.count, 6)
    XCTAssertEqual(slice.first, 1)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(slice.last, 3)
    #endif
    XCTAssertEqual(
      slice.distance(
        from: slice.startIndex,
        to: slice.endIndex), 6)
  }

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

  func testSliceIndexOffsetting() {
    let m: RedBlackTreeMultiSet = [5, 5, 6, 7, 7, 8]
    let slice = m.elements(in: 5...7)  // 5,5,6,7,7

    let idx = slice.index(slice.startIndex, offsetBy: 3)
    XCTAssertEqual(slice[idx], 7)

    // limitedBy: 成功
    let ok = slice.index(
      slice.startIndex, offsetBy: 4,
      limitedBy: slice.endIndex)
    XCTAssertNotNil(ok)
    XCTAssertEqual(slice[ok!], 7)

    // limitedBy: 失敗 → nil
    let fail = slice.index(
      slice.startIndex, offsetBy: 10,
      limitedBy: slice.endIndex)
    XCTAssertNil(fail)
  }

  // MARK: 距離の対称性 ---------------------------------------------------

  func testDistanceSymmetry() {
    let ms: RedBlackTreeMultiSet = [0, 1, 1, 2, 3, 3, 4, 4, 4]
    let slice = ms.elements(in: 1...3)  // 1,1,2,3,3
    let i = slice.index(slice.startIndex, offsetBy: 1)  // 2番目 (1)
    let j = slice.index(slice.startIndex, offsetBy: 4)  // 5番目 (3)
    XCTAssertEqual(slice.distance(from: i, to: j), 3)
    XCTAssertEqual(slice.distance(from: j, to: i), -3)
  }

  // MARK: index invalidation after base mutation ------------------------

  func testIndexInvalidationAfterBaseMutation() throws {
    #if !USE_OLD_FIND
      throw XCTSkip("挙動が変わるためスキップ")
    #endif

    var base: RedBlackTreeMultiSet = [1, 1, 2, 2, 3]
    let slice = base.elements(in: 1...2)  // 1,1,2,2

    let idx = slice.firstIndex(of: 1)!  // 指すノードは 1
    _ = base.remove(1)  // 重複 1 個削除 (木再構成)

    XCTAssertFalse(base.isValid(index: idx))

    throw XCTSkip("setと統一の動作ならばFalseだが、multiset特有の事情でCoWが発生するため、未対応")

    //    XCTAssertFalse(slice.isValid(index: idx))
  }
}
