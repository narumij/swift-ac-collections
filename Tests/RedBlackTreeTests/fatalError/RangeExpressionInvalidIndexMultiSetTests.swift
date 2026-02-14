//
//  RangeExpressionInvalidIndexMultiSetTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
import Foundation
import RedBlackTreeModule
import Testing

struct RangeExpressionInvalidIndexMultiSetTests {

  @Test
  func `MultiSetでlowerがupperより大きい場合、SIGSEGV以外の方法で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      let set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
      let lower = set.index(set.startIndex, offsetBy: 6)
      let upper = set.index(set.startIndex, offsetBy: 2)
      _ = set[lower..<upper]
    }
  }

  @Test
  func `MultiSetで削除済みインデックスを使った場合、SIGSEGV以外の方法で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
      let lower = set.index(set.startIndex, offsetBy: 3)
      set.remove(at: lower)
      _ = set[lower...]
    }
  }

  @Test
  func `MultiSetでlowerがupperより大きい場合、subscript erase(where:)がSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
      let lower = set.index(set.startIndex, offsetBy: 6)
      let upper = set.index(set.startIndex, offsetBy: 2)
      set[lower..<upper].erase(where: { _ in false })
    }
  }

  @Test
  func `MultiSetでlowerがupperより大きい場合、set.erase(where:)がSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
      let lower = set.index(set.startIndex, offsetBy: 6)
      let upper = set.index(set.startIndex, offsetBy: 2)
      set.erase(lower..<upper) { _ in false }
    }
  }

  @Test
  func `MultiSetでlowerがupperより大きい場合、set.eraseがSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
      let lower = set.index(set.startIndex, offsetBy: 6)
      let upper = set.index(set.startIndex, offsetBy: 2)
      set.erase(lower..<upper)
    }
  }
}
#endif
