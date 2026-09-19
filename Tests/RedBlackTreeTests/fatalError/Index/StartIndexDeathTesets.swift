//
//  EmptySetIndexV3DeathTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Foundation
  import RedBlackTreeCollections
  import Testing

  struct StartIndexDeathTesets {

    @Test
    func `空のSetでstartIndexをsubscriptするとSIGSEGV以外で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        let set = RedBlackTreeSet<Int>()
        _ = set[set.startIndex]
      }
    }

    @Test
    func `空のSetでremove(at:)を呼ぶとSIGSEGV以外で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var set = RedBlackTreeSet<Int>()
        _ = set.remove(at: set.startIndex)
      }
    }

    @Test
    func `空のMultiSetでstartIndexをsubscriptするとSIGSEGV以外で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        let set = RedBlackTreeMultiSet<Int>()
        _ = set[set.startIndex]
      }
    }

    @Test
    func `空のMultiSetでremove(at:)を呼ぶとSIGSEGV以外で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var set = RedBlackTreeMultiSet<Int>()
        _ = set.remove(at: set.startIndex)
      }
    }

    @Test
    func `空のMultiMapでstartIndexをsubscriptするとSIGSEGV以外で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        let set = RedBlackTreeMultiMap<Int, Int>()
        _ = set[set.startIndex]
      }
    }

    @Test
    func `空のMultiMapでremove(at:)を呼ぶとSIGSEGV以外で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var set = RedBlackTreeMultiMap<Int, Int>()
        _ = set.remove(at: set.startIndex)
      }
    }

    @Test
    func `空のDictionaryでstartIndexをsubscriptするとSIGSEGV以外で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        let set = RedBlackTreeDictionary<Int, Int>()
        _ = set[set.startIndex]
      }
    }

    @Test
    func `空のDictionaryでremove(at:)を呼ぶとSIGSEGV以外で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var set = RedBlackTreeDictionary<Int, Int>()
        _ = set.remove(at: set.startIndex)
      }
    }
  }
#endif
