//
//  Test 5.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/19.
//

import Foundation
import RedBlackTreeModule
import Testing

#if DEATH_TEST
  struct DictionaryInitTests {

    @Test func `標準辞書の重複キー初期化で落ちるかどうか？調査`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        _ = [Int: Int](uniqueKeysWithValues: [(1, 1), (1, 2)])
      }
    }

    @Test func `辞書の重複キー初期化で落ちるかどうか？`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        _ = RedBlackTreeDictionary<Int, Int>(uniqueKeysWithValues: [(1, 1), (1, 2)])
      }
    }
  }
#endif
