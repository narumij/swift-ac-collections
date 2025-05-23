// swift-tools-version:5.10
// RedBlackTreeDictionarySubSequenceTests.swift
//
// Dictionary の SubSequence (読み取り専用ビュー) を検証する
//
// * elements(in:) で取得した部分ビューのプロパティ
// * BidirectionalCollection 規約 (前後イテレーション・距離計算)
// * index(_:offsetBy:) / limitedBy: の境界判定
// * CoW 後の index 無効化 (base・slice とも false になる)

import XCTest

@testable import RedBlackTreeModule  // ←モジュール名を書き換えてください

final class RedBlackTreeDictionarySubSequenceTests: XCTestCase {

  // MARK: 基本プロパティ -------------------------------------------------

  func testSliceCountFirstLast() {
    let base: RedBlackTreeDictionary = [
      "a": 1, "b": 2, "c": 3, "d": 4, "e": 5,
    ]
    let slice = base.elements(in: "b"..<"e")  // b,c,d

    XCTAssertEqual(slice.count, 3)
    XCTAssertEqual(slice.first?.key, "b")
    XCTAssertEqual(slice.last?.key, "d")
  }

  // MARK: forward / backward イテレーション ------------------------------

  func testBidirectionalIteration() {
    let dict: RedBlackTreeDictionary = [
      1: "one", 2: "two", 3: "three", 4: "four",
    ]
    let slice = dict.elements(in: 2...3)  // 2,3

    let forwardKeys = slice.map { $0.key }
    let backwardKeys = slice.reversed().map { $0.key }

    XCTAssertEqual(forwardKeys, [2, 3])
    XCTAssertEqual(backwardKeys, [3, 2])
  }

  // MARK: offsetBy / limitedBy ------------------------------------------

  func testSliceIndexOffsetting() {
    let dict: RedBlackTreeDictionary = [
      10: 0, 11: 1, 12: 2, 13: 3, 14: 4,
    ]
    let slice = dict.elements(in: 11...13)  // 11,12,13

    let idx = slice.index(slice.startIndex, offsetBy: 2)
    XCTAssertEqual(slice[idx].key, 13)

    let nilIdx = slice.index(
      slice.startIndex,
      offsetBy: 10,
      limitedBy: slice.endIndex)
    XCTAssertNil(nilIdx)
  }

  // MARK: 距離の対称性 ---------------------------------------------------

  func testDistanceSymmetry() {
    let dict: RedBlackTreeDictionary = [
      0: "zero", 1: "one", 2: "two",
      3: "three", 4: "four", 5: "five",
    ]
    let slice = dict.elements(in: 1...4)  // 1,2,3,4

    let i = slice.index(slice.startIndex, offsetBy: 1)  // 2
    let j = slice.index(slice.startIndex, offsetBy: 3)  // 4

    XCTAssertEqual(slice.distance(from: i, to: j), 2)
    XCTAssertEqual(slice.distance(from: j, to: i), -2)
  }

  // MARK: CoW 後の index 無効化 -----------------------------------------

  func testIndexInvalidationAfterCoWMutation() {
    var base: RedBlackTreeDictionary = [
      "x": 1, "y": 2, "z": 3,
    ]
    let slice = base.elements(in: "x"..."y")  // x,y

    let idx = slice.firstIndex(where: { $0.key == "x" })!

    // CoW 発動 (base がユニークストレージへ)
    _ = base.removeValue(forKey: "x")

    // 共有ストレージの木が差し替わるため BOTH invalid
    XCTAssertFalse(base.isValid(index: idx))
    XCTAssertFalse(slice.isValid(index: idx))
  }
}
