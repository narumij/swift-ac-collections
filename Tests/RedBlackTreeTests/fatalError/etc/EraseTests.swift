//
//  Test.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/30.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Foundation
  @testable import RedBlackTreeModule
  import Testing

  struct EraseTests {

    @Test func `erase() on RedBlackTreeSet`() async throws {
      var a = RedBlackTreeSet<Int>(0..<10)
      var it = a.startIndex
      while it != a.endIndex {
        it = a.erase(it)
      }
      #expect(a.isEmpty)
    }

    @Test func `erase evens on RedBlackTreeSet`() async throws {
      var a = RedBlackTreeSet<Int>(0..<10)
      var it = a.startIndex
      while it != a.endIndex {
        if a[it] % 2 == 0 {
          it = a.erase(it)
        } else {
          it = a.index(after: it)
        }
      }
      #expect(a.allSatisfy { $0 % 2 == 1 })
      #expect(a.count == 5)
    }

    @Test func `erase() on RedBlackTreeMultiSet`() async throws {
      var a = RedBlackTreeMultiSet<Int>(0..<10)
      var it = a.startIndex
      while it != a.endIndex {
        it = a.erase(it)
      }
      #expect(a.isEmpty)
    }

    @Test func `erase evens on RedBlackTreeMultiSet`() async throws {
      var a = RedBlackTreeMultiSet<Int>(0..<10)
      var it = a.startIndex
      while it != a.endIndex {
        if a[it] % 2 == 0 {
          it = a.erase(it)
        } else {
          it = a.index(after: it)
        }
      }
      #expect(a.allSatisfy { $0 % 2 == 1 })
      #expect(a.count == 5)
    }

    @Test func `erase() on RedBlackTreeMultiMap`() async throws {
      var a = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (0..<10).map { ($0, $0 + 3) })
      var it = a.startIndex
      while it != a.endIndex {
        it = a.erase(it)
      }
      #expect(a.isEmpty)
    }

    @Test func `erase evens on RedBlackTreeMultiMap`() async throws {
      var a = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (0..<10).map { ($0, $0 + 3) })
      var it = a.startIndex
      while it != a.endIndex {
        if a[it].key % 2 == 0 {
          it = a.erase(it)
        } else {
          it = a.index(after: it)
        }
      }
      #expect(a.allSatisfy { $0.key % 2 == 1 })
      #expect(a.count == 5)
    }

    @Test func `erase() on RedBlackTreeDictionary`() async throws {
      var a = RedBlackTreeDictionary<Int, Int>(
        uniqueKeysWithValues: (0..<10).map { ($0, $0 + 3) })
      var it = a.startIndex
      while it != a.endIndex {
        it = a.erase(it)
      }
      #expect(a.isEmpty)
    }

    @Test func `erase evens on RedBlackTreeDictionary`() async throws {
      var a = RedBlackTreeDictionary<Int, Int>(
        uniqueKeysWithValues: (0..<10).map { ($0, $0 + 3) })
      var it = a.startIndex
      while it != a.endIndex {
        if a[it].key % 2 == 0 {
          it = a.erase(it)
        } else {
          it = a.index(after: it)
        }
      }
      #expect(a.allSatisfy { $0.key % 2 == 1 })
      #expect(a.count == 5)
    }

  }
#endif
