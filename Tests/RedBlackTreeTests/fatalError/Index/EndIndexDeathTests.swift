//
//  Test.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/29.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Foundation
  import RedBlackTreeCollections
  import Testing

  struct EndIndexDeathTests {

    @Test
    func `Setを末尾インデックスで削除した場合、SIGSEGV以外の方法で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeSet<Int>(0..<100)
        a.remove(at: a.endIndex)
      }
    }

    @Test
    func `MultiSetを末尾インデックスで削除した場合、SIGSEGV以外の方法で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeMultiSet<Int>(0..<100)
        a.remove(at: a.endIndex)
      }
    }

    @Test
    func `MultiMapを末尾インデックスで削除した場合、SIGSEGV以外の方法で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (0..<100).map { ($0, $0) })
        a.remove(at: a.endIndex)
      }
    }

    @Test
    func `Dictionaryを末尾インデックスで削除した場合、SIGSEGV以外の方法で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeDictionary<Int, Int>(uniqueKeysWithValues: (0..<100).map { ($0, $0) })
        a.remove(at: a.endIndex)
      }
    }
  }
#endif
