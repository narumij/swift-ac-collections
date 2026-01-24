// RedBlackTreeSetCornerCaseTests.swift
// swift-tools-version:5.10

import RedBlackTreeModule
import XCTest

final class RedBlackTreeSetCornerCaseTests: RedBlackTreeTestCase {

  // MARK: ── 基本プロパティ ────────────────────────────────────────────────

  func testEmptySetCharacteristics() {
    var set = RedBlackTreeSet<Int>()
    XCTAssertTrue(set.isEmpty)
    XCTAssertEqual(set.count, 0)
    XCTAssertNil(set.min())
    XCTAssertNil(set.max())
    XCTAssertNil(set.remove(123))
  }

  func testSingleElementFirstAndLastAreSame() {
    var set: RedBlackTreeSet = [42]
    XCTAssertEqual(set.first, 42)
    XCTAssertEqual(set.last, 42)
    XCTAssertEqual(set.removeFirst(), 42)
    XCTAssertTrue(set.isEmpty)
  }

  func testDuplicateInsertion() {
    var set = RedBlackTreeSet<Int>()
    let r1 = set.insert(10)
    let r2 = set.insert(10)
    XCTAssertTrue(r1.inserted)
    XCTAssertFalse(r2.inserted)
    XCTAssertEqual(set.count, 1)
  }

  func testUpdateReturnsOldValue() {
    var set: RedBlackTreeSet = [1, 3, 5]
    let old = set.update(with: 3)  // 3 は既存
    XCTAssertEqual(old, 3)
    let none = set.update(with: 4)  // 4 は新規
    XCTAssertNil(none)
    XCTAssertTrue(set.contains(4))
  }

  // MARK: ── Index 無効化・Copy-on-Write ───────────────────────────────────

  func testIndexInvalidationAfterMutation() {
    var set: RedBlackTreeSet = [0, 1, 2]
    let idx = set.firstIndex(of: 1)!
    set.remove(1)
    XCTAssertFalse(set.isValid(index: idx))  // 無効になっていること
  }

  func testCopyOnWrite() {
    let original: RedBlackTreeSet = [1, 2, 3]
    var copy = original
    _ = copy.insert(99)
    XCTAssertTrue(copy.contains(99))
    XCTAssertFalse(original.contains(99))  // 元は変わらない
  }

  // MARK: ── lowerBound / upperBound & 部分削除 ───────────────────────────

  func testLowerAndUpperBound() {
    let set: RedBlackTreeSet = [1, 3, 5, 7, 9]
    XCTAssertEqual(set.lowerBound(0), set.startIndex)
    XCTAssertEqual(set.lowerBound(4), set.firstIndex(of: 5))
    XCTAssertEqual(set.upperBound(5), set.firstIndex(of: 7))
    XCTAssertEqual(set.upperBound(9), set.endIndex)
  }

  func testRemoveSubrangeHalfOpen() {
    var set: RedBlackTreeSet = [0, 1, 2, 3, 4, 5]
    let lhs = set.lowerBound(2)
    let rhs = set.lowerBound(5)
    set.removeSubrange(lhs..<rhs)  // 2,3,4 を削除
    XCTAssertEqual(set.sorted(), [0, 1, 5])
  }

  // MARK: ── ランダムファズ (Swift.Set と同期待) ──────────────────────────

  /// 1 回当たり最大 1 000 操作でランダムに insert/remove を行い、
  /// 標準 Set<Int> と結果を突き合わせる。
  func testFuzzAgainstSwiftSet() {
    let iterations = 100
    let operations = 1_000
    var rng = SplitMix64(seed: 0xDEAD_BEEF)

    for _ in 0..<iterations {
      var rbTree = RedBlackTreeSet<Int>()
      var stdSet = Set<Int>()

      for _ in 0..<operations {
        let value = Int(rng.next() & 0xFF) - 128  // −128…127
        let action = rng.next() & 3

        switch action {
        case 0:  // insert
          let rb = rbTree.insert(value)
          let st = stdSet.insert(value).inserted
          XCTAssertEqual(
            rb.inserted, st,
            "insert mismatch on value \(value)")
        case 1:  // remove
          let rb = rbTree.remove(value)
          let st = stdSet.remove(value)
          XCTAssertEqual(
            rb, st,
            "remove mismatch on value \(value)")
        case 2 where !rbTree.isEmpty:  // removeFirst
          XCTAssertEqual(rbTree.removeFirst(), stdSet.min()!)
          stdSet.remove(stdSet.min()!)
        case 3 where !rbTree.isEmpty:  // removeLast
          XCTAssertEqual(rbTree.removeLast(), stdSet.max()!)
          stdSet.remove(stdSet.max()!)
        default:
          continue
        }
        XCTAssertEqual(
          rbTree.sorted(), stdSet.sorted(),
          "state diverged after operation")
      }
    }
  }

  func testPopFirstAndSubtracting() {
    var s: RedBlackTreeSet = [3, 1, 2]
    XCTAssertEqual(s.popFirst(), 1)
    XCTAssertEqual(s.sorted(), [2, 3])

    let sub = s.subtracting([2])
    XCTAssertEqual(sub.sorted(), [3])

    s.subtract([2, 3])
    XCTAssertTrue(s.isEmpty)
  }

  func testSequenceUnionEquivalence() {
    let base: RedBlackTreeSet = [1, 4]
    let rbs = base.union([2, 4, 6])
    let swift = Set([1, 4]).union([2, 4, 6])
    XCTAssertEqual(rbs.sorted(), swift.sorted())
  }
}
