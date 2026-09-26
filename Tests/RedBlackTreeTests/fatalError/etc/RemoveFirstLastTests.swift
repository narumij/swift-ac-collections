//
//  Test.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/30.
//

#if DEATH_TEST
  import Foundation
  import RedBlackTreeCollections
  import Testing

  struct RemoveFirstLastTests {

    @Test func `RemoveFirst makes crash with empty RedBlackTreeSet`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeSet<Int>()
        a.removeFirst()
      }
    }

    @Test func `RemoveLast makes crash with empty RedBlackTreeSet`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeSet<Int>()
        a.removeLast()
      }
    }

    @Test func `RemoveFirst makes crash with empty RedBlackTreeMultiSet`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeMultiSet<Int>()
        a.removeFirst()
      }
    }

    @Test func `RemoveLast makes crash with empty RedBlackTreeMultiSet`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeMultiSet<Int>()
        a.removeLast()
      }
    }

    @Test func `RemoveFirst makes crash with empty RedBlackTreeMultiMap`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeMultiMap<Int, Int>()
        a.removeFirst()
      }
    }

    @Test func `RemoveLast makes crash with empty RedBlackTreeMultiMap`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeMultiMap<Int, Int>()
        a.removeLast()
      }
    }

    @Test func `RemoveFirst makes crash with empty RedBlackTreeDictionary`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeDictionary<Int, Int>()
        a.removeFirst()
      }
    }

    @Test func `RemoveLast makes crash with empty RedBlackTreeDictionary`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeDictionary<Int, Int>()
        a.removeLast()
      }
    }

  }
#endif
