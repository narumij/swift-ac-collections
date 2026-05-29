//
//  RangeExpressionInvalidIndexTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Foundation
  import RedBlackTreeModule
  import Testing

  struct RangeExpressionInvalidIndexTests {

    @Test
    func `RangeExpressionでlowerがupperより大きい場合、SIGSEGV以外の方法で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        let set = RedBlackTreeSet<Int>(0..<10)
        let lower = set.index(set.startIndex, offsetBy: 6)
        let upper = set.index(set.startIndex, offsetBy: 2)
        _ = set[lower..<upper]
      }
    }

    @Test
    func `RangeExpressionで削除済みインデックスを使った場合、SIGSEGV以外の方法で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var set = RedBlackTreeSet<Int>(0..<10)
        let lower = set.index(set.startIndex, offsetBy: 3)
        set.remove(at: lower)
        _ = set[lower...]
      }
    }

    @Test
    func `RangeExpressionでlowerがupperより大きい場合、subscript erase(where:)がSIGSEGV以外で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var set = RedBlackTreeSet<Int>(0..<10)
        let lower = set.index(set.startIndex, offsetBy: 6)
        let upper = set.index(set.startIndex, offsetBy: 2)
        set[lower..<upper].erase(where: { _ in false })
      }
    }

    @Test
    func `RangeExpressionでlowerがupperより大きい場合、set.erase(where:)がSIGSEGV以外で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var set = RedBlackTreeSet<Int>(0..<10)
        let lower = set.index(set.startIndex, offsetBy: 6)
        let upper = set.index(set.startIndex, offsetBy: 2)
        set.erase(lower..<upper) { _ in false }
      }
    }

    @Test
    func `RangeExpressionでlowerがupperより大きい場合、set.eraseがSIGSEGV以外で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var set = RedBlackTreeSet<Int>(0..<10)
        let lower = set.index(set.startIndex, offsetBy: 6)
        let upper = set.index(set.startIndex, offsetBy: 2)
        set.erase(lower..<upper)
      }
    }

    #if !ALLOW_CROSS_TREE_INDEX
      @Test
      func `ことなる木由来のインデックスを用いて範囲削除しようとした場合、停止すること`() async {
        await #expect(processExitsWith: .signal(SIGTRAP)) {
          let source = RedBlackTreeSet(0..<8)
          var target = RedBlackTreeSet(100..<108)
          let lower = source.index(source.startIndex, offsetBy: 2)
          let upper = source.index(source.startIndex, offsetBy: 6)
          target.erase(lower..<upper)
        }
      }
    #endif
  }
#endif
