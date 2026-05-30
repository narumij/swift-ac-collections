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
      var a = RedBlackTreeSet<Int>(0..<3)
      a.erase { _ in
        return true
      }
      #expect(a.isEmpty)
    }
  }
#endif
