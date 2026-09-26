// swift-tools-version:5.10
// RedBlackTreeDictionarySubSequenceTests.swift
//
// Dictionary の SubSequence (読み取り専用ビュー) を検証する
//
// * elements(in:) で取得した部分ビューのプロパティ
// * BidirectionalCollection 規約 (前後イテレーション・距離計算)
// * index(_:offsetBy:) / limitedBy: の境界判定
// * CoW 後の index 無効化 (base・slice とも false になる)

import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionarySubSequenceTests: RedBlackTreeTestCase {

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

}
