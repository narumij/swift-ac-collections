//
//  RangeExpressionInvalidIndexMultiMapTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
import Foundation
import RedBlackTreeModule
import Testing

struct RangeExpressionInvalidIndexMultiMapTests {

  @Test
  func `MultiMapでlowerがupperより大きい場合、SIGSEGV以外の方法で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      let map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      let lower = map.index(map.startIndex, offsetBy: 3)
      let upper = map.index(map.startIndex, offsetBy: 1)
      _ = map[lower..<upper]
    }
  }

  @Test
  func `MultiMapで削除済みインデックスを使った場合、SIGSEGV以外の方法で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      let lower = map.index(map.startIndex, offsetBy: 2)
      map.remove(at: lower)
      _ = map[lower...]
    }
  }

  @Test
  func `MultiMapでlowerがupperより大きい場合、subscript erase(where:)がSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      let lower = map.index(map.startIndex, offsetBy: 3)
      let upper = map.index(map.startIndex, offsetBy: 1)
      map[lower..<upper].erase(where: { _ in false })
    }
  }

  @Test
  func `MultiMapでlowerがupperより大きい場合、map.erase(where:)がSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      let lower = map.index(map.startIndex, offsetBy: 3)
      let upper = map.index(map.startIndex, offsetBy: 1)
      map.erase(lower..<upper) { _ in false }
    }
  }

  @Test
  func `MultiMapでlowerがupperより大きい場合、map.eraseがSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      let lower = map.index(map.startIndex, offsetBy: 3)
      let upper = map.index(map.startIndex, offsetBy: 1)
      map.erase(lower..<upper)
    }
  }
}
#endif
