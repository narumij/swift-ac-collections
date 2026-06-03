//
//  Test.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/30.
//

#if DEBUG && DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Foundation
  @testable import RedBlackTreeCollections
  import Testing

  struct BoundExpressionCoverage {

    @Test func `.index on RedBlackTreeSet`() async throws {
      let a = RedBlackTreeSet<Int>(0..<10)
      #expect(a.isValid(.index(a.startIndex)))
      #expect(!a.isValid(.index(a.endIndex)))
      #expect(!a.isValid(.index(.failure(.null))))
    }

    @Test func `.index on RedBlackTreeMultiSet`() async throws {
      let a = RedBlackTreeMultiSet<Int>(0..<10)
      #expect(a.isValid(.index(a.startIndex)))
      #expect(!a.isValid(.index(a.endIndex)))
      #expect(!a.isValid(.index(.failure(.null))))
    }
    
    @Test func `.index on RedBlackTreeMultiMap`() async throws {
      let a = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (0..<10).map { ($0, $0 + 3) })
      #expect(a.isValid(.index(a.startIndex)))
      #expect(!a.isValid(.index(a.endIndex)))
      #expect(!a.isValid(.index(.failure(.null))))
    }
    
    @Test func `.index on RedBlackTreeDictionary`() async throws {
      let a = RedBlackTreeDictionary<Int, Int>(
        uniqueKeysWithValues: (0..<10).map { ($0, $0 + 3) })
      #expect(a.isValid(.index(a.startIndex)))
      #expect(!a.isValid(.index(a.endIndex)))
      #expect(!a.isValid(.index(.failure(.null))))
    }
  }
#endif
