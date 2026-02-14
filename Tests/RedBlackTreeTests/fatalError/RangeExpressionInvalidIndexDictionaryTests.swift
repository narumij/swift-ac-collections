//
//  RangeExpressionInvalidIndexDictionaryTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
import Foundation
import RedBlackTreeModule
import Testing

struct RangeExpressionInvalidIndexDictionaryTests {

  @Test
  func `Dictionaryでlowerがupperより大きい場合、SIGSEGV以外の方法で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      let dict: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      let lower = dict.index(dict.startIndex, offsetBy: 3)
      let upper = dict.index(dict.startIndex, offsetBy: 1)
      _ = dict[lower..<upper]
    }
  }

  @Test
  func `Dictionaryで削除済みインデックスを使った場合、SIGSEGV以外の方法で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var dict: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      let lower = dict.index(dict.startIndex, offsetBy: 2)
      dict.remove(at: lower)
      _ = dict[lower...]
    }
  }

  @Test
  func `Dictionaryでlowerがupperより大きい場合、subscript erase(where:)がSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var dict: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      let lower = dict.index(dict.startIndex, offsetBy: 3)
      let upper = dict.index(dict.startIndex, offsetBy: 1)
      dict[lower..<upper].erase(where: { _ in false })
    }
  }

  @Test
  func `Dictionaryでlowerがupperより大きい場合、dict.erase(where:)がSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var dict: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      let lower = dict.index(dict.startIndex, offsetBy: 3)
      let upper = dict.index(dict.startIndex, offsetBy: 1)
      dict.erase(lower..<upper) { _ in false }
    }
  }

  @Test
  func `Dictionaryでlowerがupperより大きい場合、dict.eraseがSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var dict: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      let lower = dict.index(dict.startIndex, offsetBy: 3)
      let upper = dict.index(dict.startIndex, offsetBy: 1)
      dict.erase(lower..<upper)
    }
  }
}
#endif
