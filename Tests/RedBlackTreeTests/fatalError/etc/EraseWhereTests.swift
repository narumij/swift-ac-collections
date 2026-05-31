//
//  Test.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/30.
//

#if DEATH_TEST
  import Foundation
  @testable import RedBlackTreeModule
  import Testing

  struct EraseWhereTests {

    @Test func `erase(where:) on RedBlackTreeSet`() async throws {
      var a = RedBlackTreeSet<Int>(0..<10)
      a.erase { _ in
        return true
      }
      #expect(a.isEmpty)
    }

    @Test func `erase evens on RedBlackTreeSet`() async throws {
      var a = RedBlackTreeSet<Int>(0..<10)
      a.erase { $0 % 2 == 0 }
      #expect(a.allSatisfy { $0 % 2 == 1 })
      #expect(a.count == 5)
    }

    @Test func `erase(where:) on RedBlackTreeMultiSet`() async throws {
      var a = RedBlackTreeMultiSet<Int>(0..<10)
      a.erase { _ in
        return true
      }
      #expect(a.isEmpty)
    }

    @Test func `erase evens on RedBlackTreeMultiSet`() async throws {
      var a = RedBlackTreeMultiSet<Int>(0..<10)
      a.erase { $0 % 2 == 0 }
      #expect(a.allSatisfy { $0 % 2 == 1 })
      #expect(a.count == 5)
    }

    @Test func `erase(where:) on RedBlackTreeMultiMap`() async throws {
      var a = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (0..<10).map { ($0, $0 + 3) })
      a.erase { _ in
        return true
      }
      #expect(a.isEmpty)
    }

    @Test func `erase evens on RedBlackTreeMultiMap`() async throws {
      var a = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (0..<10).map { ($0, $0 + 3) })
      a.erase { $0.key % 2 == 0 }
      #expect(a.allSatisfy { $0.key % 2 == 1 })
      #expect(a.count == 5)
    }

    @Test func `erase(where:) on RedBlackTreeDictionary`() async throws {
      var a = RedBlackTreeDictionary<Int, Int>(
        uniqueKeysWithValues: (0..<10).map { ($0, $0 + 3) })
      a.erase { _ in
        return true
      }
      #expect(a.isEmpty)
    }

    @Test func `erase evens on RedBlackTreeDictionary`() async throws {
      var a = RedBlackTreeDictionary<Int, Int>(
        uniqueKeysWithValues: (0..<10).map { ($0, $0 + 3) })
      a.erase { $0.key % 2 == 0 }
      #expect(a.allSatisfy { $0.key % 2 == 1 })
      #expect(a.count == 5)
    }

  }
#endif
