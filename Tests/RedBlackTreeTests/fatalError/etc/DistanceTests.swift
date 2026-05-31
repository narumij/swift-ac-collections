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

  struct DistanceTests {

    @Test func `distance on RedBlackTreeSet`() async throws {
      let a = RedBlackTreeSet<Int>(0..<10)
      #expect(a.distance(from: .start, to: .end) == a.count)
      #expect(a.distance(from: .end, to: .start) == -a.count)
    }

    @Test func `distance on RedBlackTreeMultiSet`() async throws {
      let a = RedBlackTreeMultiSet<Int>(0..<10)
      #expect(a.distance(from: .start, to: .end) == a.count)
      #expect(a.distance(from: .end, to: .start) == -a.count)
    }

    @Test func `distance on RedBlackTreeMultiMap`() async throws {
      let a = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (0..<10).map { ($0, $0 + 3) })
      #expect(a.distance(from: .start, to: .end) == a.count)
      #expect(a.distance(from: .end, to: .start) == -a.count)
    }

    @Test func `distance on RedBlackTreeDictionary`() async throws {
      let a = RedBlackTreeDictionary<Int, Int>(
        uniqueKeysWithValues: (0..<10).map { ($0, $0 + 3) })
      #expect(a.distance(from: .start, to: .end) == a.count)
      #expect(a.distance(from: .end, to: .start) == -a.count)
    }
  }
#endif
