// RedBlackTreeMultisetCornerCaseTests.swift
// swift-tools-version:5.10

import XCTest
@testable import RedBlackTreeModule   // ←モジュール名を合わせてください

/// シンプル Count ディクショナリを Swift 標準 Multiset 代わりに利用
private struct ReferenceMultiset {
    private var dict: [Int:Int] = [:]
    mutating func insert(_ x: Int) { dict[x, default: 0] += 1 }
    mutating func removeOne(_ x: Int) { if let c = dict[x], c > 1 { dict[x] = c-1 } else { dict.removeValue(forKey: x) } }
    mutating func removeAll(_ x: Int) { dict.removeValue(forKey: x) }
    func count(of x: Int) -> Int { dict[x] ?? 0 }
    var sorted: [Int] { dict.flatMap { Array(repeating: $0.key, count: $0.value) } .sorted() }
}

final class RedBlackTreeMultisetCornerCaseTests: XCTestCase {

    // MARK: ── 基本動作 ──────────────────────────────────────────────

    func testDuplicateInsertAndCount() {
        var ms = RedBlackTreeMultiset<Int>()
        ms.insert(7); ms.insert(7); ms.insert(3)
        XCTAssertEqual(ms.count(of: 7), 2)
        XCTAssertEqual(ms.count(of: 3), 1)
        XCTAssertEqual(ms.count(of: 42), 0)
    }

    func testRemoveOneVersusRemoveAll() {
        var ms: RedBlackTreeMultiset = [5, 5, 5]
        XCTAssertNotNil(ms.remove(5))        // 1 個だけ
        XCTAssertEqual(ms.count(of: 5), 2)

        XCTAssertNotNil(ms.removeAll(5))     // 全消し
        XCTAssertFalse(ms.contains(5))
        XCTAssertNil(ms.removeAll(5))        // もう無いので nil
    }

    func testLowerUpperBoundsWithDuplicates() {
        let ms: RedBlackTreeMultiset = [1, 2, 2, 2, 3]
        let lb = ms.lowerBound(2)
        let ub = ms.upperBound(2)
        XCTAssertEqual(ms.distance(from: ms.startIndex, to: lb), 1)   // 2 より前は 1 つ
        XCTAssertEqual(ms.distance(from: lb, to: ub), 3)              // 2 が 3 個
    }

    // MARK: ── インデックス無効化・CoW ──────────────────────────────────

    func testIndexInvalidationAfterErase() {
        var ms: RedBlackTreeMultiset = [9, 9, 9]
        let idx = ms.firstIndex(of: 9)!
        ms.remove(at: idx)
        XCTAssertFalse(ms.isValid(index: idx))
    }

    func testCopyOnWriteBehavior() {
        var original: RedBlackTreeMultiset = [1, 1]
        var copy = original
        copy.insert(2)
        XCTAssertTrue(copy.contains(2))
        XCTAssertFalse(original.contains(2))
    }

    // MARK: ── Subrange Removal ──────────────────────────────────────

    func testRemoveSubrange() {
        var ms: RedBlackTreeMultiset = [0, 1, 2, 2, 3, 4]
        let l = ms.lowerBound(2)
        let r = ms.upperBound(2)   // 半開なので 2 のみ消す
        ms.removeSubrange(l..<r)
        XCTAssertEqual(ms.sorted(), [0,1,3,4])
    }

    // MARK: ── ファズテスト (辞書カウントと突き合わせ) ────────────────

    func testRandomizedAgainstReferenceMultiset() {
        var rng = SplitMix64(seed: 0xBADC0DE)
        let rounds = 150
        let opsPerRound = 400

        for _ in 0..<rounds {
            var ms = RedBlackTreeMultiset<Int>()
            var ref = ReferenceMultiset()

            for _ in 0..<opsPerRound {
                let v = Int(rng.next() & 0x3F)    // 0…63
                switch rng.next() & 3 {
                case 0:  // insert
                    ms.insert(v); ref.insert(v)
                case 1:  // remove one
                    _ = ms.remove(v); ref.removeOne(v)
                case 2:  // removeAll
                    _ = ms.removeAll(v); ref.removeAll(v)
                default: // count check only
                    break
                }
                // 同期検証
                XCTAssertEqual(ms.count(of: v), ref.count(of: v))
            }
            XCTAssertEqual(ms.sorted(), ref.sorted)
        }
    }
  
  func testPopFirstDuplicates() {
      var ms: RedBlackTreeMultiset = [1, 1, 2]
      XCTAssertEqual(ms.popFirst(), 1)
      XCTAssertEqual(ms.count(of: 1), 1)
      XCTAssertEqual(ms.popFirst(), 1)
      XCTAssertEqual(ms.popFirst(), 2)
      XCTAssertTrue(ms.isEmpty)
  }

}

