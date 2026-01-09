// RedBlackTreeMapExtendedTests.swift
// swift-tools-version:5.10
//
// YourPackageNameTests target に追加して `swift test` で実行

import XCTest
import RedBlackTreeModule

final class MultiSetExtendedTests: RedBlackTreeTestCase {

  // MARK: ── merge / merging ─────────────────────────────────────

  func testMergeAndMergingAPIs() {
    var d1: RedBlackTreeMultiSet = [1, 2]
    let seq: RedBlackTreeMultiSet = [100, 3]

    // 破壊的 merge (Sequence)
    d1.insert(contentsOf: seq)
    XCTAssertEqual(d1, [1,2,3,100])

    // 非破壊的 merging (Dictionary)
    let other: RedBlackTreeMultiSet = [9, 4]
    let merged = d1.inserting(contentsOf: other)
    XCTAssertEqual(merged, [1,2,3,4,9,100])
    XCTAssertEqual(d1, [1,2,3,100])  // 元は無変化
  }
  
  func testMergeAndMergingAPIs_2() {
    var d1: RedBlackTreeMultiSet = [1, 2]
    let seq: RedBlackTreeSet = [100, 3]

    // 破壊的 merge (Sequence)
    d1.insert(contentsOf: seq)
    XCTAssertEqual(d1, [1,2,3,100])

    // 非破壊的 merging (Dictionary)
    let other: RedBlackTreeSet = [9, 4]
    let merged = d1.inserting(contentsOf: other)
    XCTAssertEqual(merged, [1,2,3,4,9,100])
    XCTAssertEqual(d1, [1,2,3,100])  // 元は無変化
  }
  
  func testMergeAndMergingAPIs_3() {
    var d1: RedBlackTreeMultiSet = [1, 2]
    let seq = [100, 3]

    // 破壊的 merge (Sequence)
    d1.insert(contentsOf: seq)
    XCTAssertEqual(d1, [1,2,3,100])

    // 非破壊的 merging (Dictionary)
    let other = [9, 4]
    let merged = d1.inserting(contentsOf: other)
    XCTAssertEqual(merged, [1,2,3,4,9,100])
    XCTAssertEqual(d1, [1,2,3,100])  // 元は無変化
  }
}
