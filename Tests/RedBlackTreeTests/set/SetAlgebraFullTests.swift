// RedBlackTreeSetAlgebraFullTests.swift
// swift-tools-version:5.10
//
// すべての SetAlgebra API を網羅するテスト。
// 既存の CornerCaseTests と併用して OK。

import XCTest
import RedBlackTreeModule

final class RedBlackTreeSetAlgebraFullTests: XCTestCase {

  // MARK: ── 汎用比較ヘルパ ───────────────────────────────────────────────

  /// 2 つの `RedBlackTreeSet` と対応する `Set` を生成
  private func makeRandomPair(seed: inout SplitMix64) -> (
    rbt1: RedBlackTreeSet<Int>, rbt2: RedBlackTreeSet<Int>,
    set1: Set<Int>, set2: Set<Int>
  ) {
    let size1 = Int(seed.next() & 0x3F)  // 0‥63
    let size2 = Int(seed.next() & 0x3F)
    let a = (0..<size1).map { _ in Int(seed.next() & 0xFF) - 128 }
    let b = (0..<size2).map { _ in Int(seed.next() & 0xFF) - 128 }
    return (
      RedBlackTreeSet(a), RedBlackTreeSet(b),
      Set(a), Set(b)
    )
  }

  // MARK: ── API 9 個の機能比較 ─────────────────────────────────────────

  func testAllSetAlgebraOperationsEquivalence() {
    var rng = SplitMix64(seed: 0xFACE_FEED)

    for _ in 0..<250 {  // 250 ランダムケース
      let (rbt1, rbt2, set1, set2) = makeRandomPair(seed: &rng)

      assertEquiv(
        rbt1.union(rbt2),
        set1.union(set2))

      assertEquiv(
        rbt1.intersection(rbt2),
        set1.intersection(set2))

      assertEquiv(
        rbt1.symmetricDifference(rbt2),
        set1.symmetricDifference(set2))

      assertEquiv(
        rbt1.subtracting(rbt2),
        set1.subtracting(set2))
    }
  }

  // MARK: ── in-place 変異系 4 メソッド ───────────────────────────────

  func testFormOperationsMutateReceiverOnly() {
    var rng = SplitMix64(seed: 0xCAFE_BABE)

    for _ in 0..<80 {
      let (lhs, rhs, sL, sR) = makeRandomPair(seed: &rng)

      // formUnion
      var lhsU = lhs
      lhsU.formUnion(rhs)
      var sLU = sL
      sLU.formUnion(sR)
      assertEquiv(lhsU, RedBlackTreeSet(sLU))

      // formIntersection
      var lhsI = lhs
      lhsI.formIntersection(rhs)
      var sLI = sL
      sLI.formIntersection(sR)
      assertEquiv(lhsI, RedBlackTreeSet(sLI))

      // formSymmetricDifference
      var lhsS = lhs
      lhsS.formSymmetricDifference(rhs)
      var sLS = sL
      sLS.formSymmetricDifference(sR)
      assertEquiv(lhsS, RedBlackTreeSet(sLS))

      // subtract (mutating)
      var lhsSub = lhs
      lhsSub.subtract(rhs)
      var sLSub = sL
      sLSub.subtract(sR)
      assertEquiv(lhsSub, RedBlackTreeSet(sLSub))

      // “rhs は無変化” を保証
      assertEquiv(rhs, rhs)  // 型安全のためダミーチェック
      XCTAssertEqual(rhs.sorted(), RedBlackTreeSet(sR).sorted())
    }
  }

  // MARK: ── 関係演算 3 種 ─────────────────────────────────────────────

  func testRelationOperationsMatchSwiftSet() {
    var rng = SplitMix64(seed: 0x0DDC_0FFE)

    for _ in 0..<120 {
      let (a, b, sa, sb) = makeRandomPair(seed: &rng)

      XCTAssertEqual(a.isSubset(of: b), sa.isSubset(of: sb))
      XCTAssertEqual(a.isSuperset(of: b), sa.isSuperset(of: sb))
      XCTAssertEqual(a.isDisjoint(with: b), sa.isDisjoint(with: sb))
      // strict 版はプロトコル拡張提供なので念のため
      XCTAssertEqual(a.isStrictSubset(of: b), sa.isStrictSubset(of: sb))
      XCTAssertEqual(a.isStrictSuperset(of: b), sa.isStrictSuperset(of: sb))
    }
  }

  // MARK: ── 恒等律・吸収律・交換律など ────────────────────────────────

  func testAlgebraicLaws() {
    let a: RedBlackTreeSet = [1, 2, 3]
    let b: RedBlackTreeSet = [3, 4]

    // 交換律（commutative）
    XCTAssertEqual(a.union(b), b.union(a))
    XCTAssertEqual(a.intersection(b), b.intersection(a))

    // 結合律（associative）
    let c: RedBlackTreeSet = [3, 5]
    XCTAssertEqual(a.union(b).union(c), a.union(b.union(c)))
    XCTAssertEqual(
      a.intersection(b).intersection(c),
      a.intersection(b.intersection(c)))

    // 吸収律
    XCTAssertEqual(a.union(a.intersection(b)), a)
    XCTAssertEqual(a.intersection(a.union(b)), a)

    // 空集合との恒等
    let empty = RedBlackTreeSet<Int>()
    XCTAssertEqual(a.union(empty), a)
    XCTAssertEqual(a.intersection(empty), empty)
    XCTAssertEqual(a.subtracting(a), empty)
  }
}
