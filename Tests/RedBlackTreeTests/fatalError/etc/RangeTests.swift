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

  struct RangeTest {

    @Test func `invalid range with RedBlackTreeSet`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeSet(0..<8)
        let range = a.equalRange(3)
        a.remove(3)
        #expect(a.isValid(range) == false)
        _ = Array(a[range])
      }
    }

    @Test func `invalid range with RedBlackTreeMultiSet`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeMultiSet(0..<8)
        let range = a.equalRange(3)
        _ = a.erase(.find(3))
        #expect(a.isValid(range) == false)
        _ = Array(a[range])
      }
    }
    
    @Test func `invalid range with RedBlackTreeMultiMap`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (0..<8).map { ($0, $0 + 3) })
        let range = a.equalRange(3)
        _ = a.erase(.find(3))
        #expect(a.isValid(range) == false)
        _ = Array(a[range])
      }
    }
    
    @Test func `invalid range with RedBlackTreeDictionary`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeDictionary<Int, Int>(uniqueKeysWithValues: (0..<8).map { ($0, $0 + 3) })
        let range = a.equalRange(3)
        _ = a.erase(.find(3))
        #expect(a.isValid(range) == false)
        _ = Array(a[range])
      }
    }
  }
#endif
