// RedBlackTreeDictionaryExtendedTests.swift
// swift-tools-version:5.10
//
// YourPackageNameTests target に追加して `swift test` で実行

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeDictionaryExtendedTests: XCTestCase {

  // MARK: ── ヘルパ ────────────────────────────────────────────────

  private func assertEqual<K: Comparable, V: Equatable>(
    _ rb: RedBlackTreeDictionary<K, V>,
    _ swift: [K: V],
    file: StaticString = #file, line: UInt = #line
  ) {
    XCTAssertEqual(rb.count, swift.count, file: (file), line: line)
    for (k, v) in swift {
      XCTAssertEqual(
        rb[k], v, "Mismatch at key: \(k)",
        file: (file), line: line)
    }
  }

  // MARK: ── ArrayLiteral / DictionaryLiteral 初期化 ──────────────

  func testLiteralInitializers() {
    let fromDictLit: RedBlackTreeDictionary = ["a": 1, "b": 2]
    XCTAssertEqual(fromDictLit["b"], 2)

    let fromArrLit: RedBlackTreeDictionary = [("x", 10), ("y", 20)]
    XCTAssertEqual(fromArrLit["x"], 10)
  }

  // MARK: ── merge / merging ─────────────────────────────────────

  func testMergeAndMergingAPIs() {
    var d1: RedBlackTreeDictionary = [("k", 1), ("v", 2)]
    let seq = [("v", 100), ("z", 3)]

    // 破壊的 merge (Sequence)
    d1.merge(seq) { old, new in old + new }
    XCTAssertEqual(d1["v"], 102)
    XCTAssertEqual(d1["z"], 3)

    // 非破壊的 merging (Dictionary)
    let other: RedBlackTreeDictionary = [("k", 9), ("n", 4)]
    let merged = d1.merging(other) { _, new in new }
    XCTAssertEqual(merged["k"], 9)  // new 優先
    XCTAssertEqual(d1["k"], 1)  // 元は無変化
  }

  func testMergeAndMergingAPIs_2() {
    var d1: RedBlackTreeDictionary = [("k", 1), ("v", 2)]
    let seq = [("v", 100), ("z", 3)]

    // 破壊的 merge (Sequence)
    d1.merge(seq) { old, new in old + new }
    XCTAssertEqual(d1["v"], 102)
    XCTAssertEqual(d1["z"], 3)

    // 非破壊的 merging (Dictionary)
    let other = [("k", 9), ("n", 4)]
    let merged = d1.merging(other) { _, new in new }
    XCTAssertEqual(merged["k"], 9)  // new 優先
    XCTAssertEqual(d1["k"], 1)  // 元は無変化
  }
  
  func testMergeAndMergingAPIs_3() {
    var d1: RedBlackTreeDictionary = [("k", 1), ("v", 2)]
    let seq = [("v", 100), ("z", 3)].map { Pair($0) }

    // 破壊的 merge (Sequence)
    d1.merge(seq) { old, new in old + new }
    XCTAssertEqual(d1["v"], 102)
    XCTAssertEqual(d1["z"], 3)

    // 非破壊的 merging (Dictionary)
    let other = [("k", 9), ("n", 4)].map { Pair($0) }
    let merged = d1.merging(other) { _, new in new }
    XCTAssertEqual(merged["k"], 9)  // new 優先
    XCTAssertEqual(d1["k"], 1)  // 元は無変化
  }

  // MARK: ── popFirst ────────────────────────────────────────────

  func testPopFirstReturnsMinKey() {
    var d: RedBlackTreeDictionary = [("b", 2), ("a", 1), ("c", 3)]
    let first = d.popFirst()
    XCTAssertEqual(first?.key, "a")
    XCTAssertEqual(Set(d.keys()), ["b", "c"])
    XCTAssertEqual(d.popFirst()?.key, "b")
    _ = d.popFirst()
    XCTAssertTrue(d.isEmpty)
    XCTAssertNil(d.popFirst())
  }

  // MARK: ── mapValues / compactMapValues / filter ───────────────

  func testMapAndCompactMapValues() {
    let src: RedBlackTreeDictionary = ["one": 1, "two": 2]
    let strDict = src.mapValues { "\($0)" }
    XCTAssertEqual(strDict["one"], "1")

    let evenOnly = src.compactMapValues { $0.isMultiple(of: 2) ? $0 : nil }
    XCTAssertNil(evenOnly["one"])
    XCTAssertEqual(evenOnly["two"], 2)
  }

  func testFilterReturnsDictionary() {
    let d: RedBlackTreeDictionary = [1: "x", 2: "y", 3: "z"]
    let filtered = d.filter { $0.key.isMultiple(of: 2) }
    XCTAssertEqual(filtered.count, 1)
    XCTAssertEqual(filtered[2], "y")
  }

  // MARK: ── 基本 CRUD & CoW・インデックス無効化 ─────────────────

  func testBasicCrudAndIndexInvalidation() {
    var dict: RedBlackTreeDictionary = ["p": 9, "q": 8]
    let idx = dict.firstIndex(of: "p")!
    dict.remove(at: idx)
    XCTAssertFalse(dict.isValid(index: idx))

    var copy = dict
    copy["q"] = 100
    XCTAssertEqual(dict["q"], 8)
    XCTAssertEqual(copy["q"], 100)
  }

  // MARK: ── ランダムファズ (Swift.Dictionary 同値性) ─────────────

  func testFuzzEquivalence() {
    var rng = SplitMix64(seed: 0x1337_C0DE)
    for _ in 0..<120 {
      var rb = RedBlackTreeDictionary<Int, Int>()
      var std = [Int: Int]()

      for _ in 0..<300 {
        let k = Int(rng.next() & 0x3F)
        switch rng.next() & 7 {
        case 0:  // 代入
          let v = Int(rng.next() & 0xFFFF)
          rb[k] = v
          std[k] = v
        case 1:  // popFirst
          _ = rb.popFirst()
          _ = std.sorted { $0.key < $1.key }.first
            .map { std.removeValue(forKey: $0.key) }
        case 2:  // merge 1 要素
          rb.merge([(k, 1)]) { $0 + $1 }
          std.merge([k: 1]) { $0 + $1 }
        case 3:  // mapValues chain
          rb = rb.mapValues { $0 + 1 }
          std = std.mapValues { $0 + 1 }
        default: break
        }
        assertEqual(rb, std)
      }
    }
  }
}
