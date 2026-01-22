//
//  Test.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

#if DEATH_TEST
  import Foundation
  import RedBlackTreeModule
  import Testing

  struct TestFatalError {

    @Test
    func `削除済みインデックスを再度利用した場合、SIGSEGV以外の方法で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeSet<Int>(0..<100)
        let it = a.startIndex
        a.remove(at: it)
        a.remove(at: it)
      }
    }

    @Test
    func `末尾インデックスで削除した場合、SIGSEGV以外の方法で停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeSet<Int>(0..<100)
        a.remove(at: a.endIndex)
      }
    }

    #if !COMPATIBLE_ATCODER_2025
      @Test
      func
        `MMultiSetRemoveTests testSmokeRemove0 removeAllで不正化したインデックスを使用した場合、SIGSEGV以外の方法で停止すること`()
        async
      {
        await #expect(processExitsWith: .signal(SIGTRAP)) {
          var s: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })
          //          XCTAssertEqual(s + [], (0..<2_000).flatMap { [$0, $0] })
          #expect(s + [] == (0..<2_000).flatMap { [$0, $0] })
          for i in s {
            s.removeAll(i)
          }
        }
      }

      @Test
      func `MultiSetRemoveTests testSmokeRemove1 removeAllで不正化したインデックスを使用した場合、SIGSEGV以外の方法で停止すること`()
        async
      {
        await #expect(processExitsWith: .signal(SIGTRAP)) {
          var s: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })
          let b = s.lowerBound(0)
          let e = s.lowerBound(10_000)
          //          XCTAssertEqual(s[b..<e] + [], (0..<2_000).flatMap { [$0, $0] })
          #expect(s[b..<e] + [] == (0..<2_000).flatMap { [$0, $0] })
          //          XCTAssertEqual(s.elements(in: 0..<10_000) + [], (0..<2_000).flatMap { [$0, $0] })
          #expect(s.elements(in: 0..<10_000) + [] == (0..<2_000).flatMap { [$0, $0] })
          for i in s.elements(in: 0..<10_000) {
            s.removeAll(i)
          }
        }
      }

      @Test
      func `MultisetTests testRandom() removeAllで不正化したインデックスを使用した場合、SIGSEGV以外の方法で停止すること`() async {
        await #expect(processExitsWith: .signal(SIGTRAP)) {
          var set = RedBlackTreeMultiSet<Int>()
          for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
            set.insert(i)
            #expect(set.___tree_invariant() == true)
          }
          for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
            set.removeAll(i)
            #expect(set.___tree_invariant() == true)
          }
          for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
            set.insert(i)
            #expect(set.___tree_invariant() == true)
          }
          for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
            set.removeAll(i)
            #expect(set.___tree_invariant() == true)
          }
          for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
            set.insert(i)
            #expect(set.___tree_invariant() == true)
          }
          for i in set {
            set.removeAll(i)
            #expect(set.___tree_invariant() == true)
          }
        }
      }

      @Test
      func `MultisetTests testRandom2() removeAllで不正化したインデックスを使用した場合、SIGSEGV以外の方法で停止すること`() async {
        await #expect(processExitsWith: .signal(SIGTRAP)) {
          //    func testRandom2() throws {
          var set = RedBlackTreeMultiSet<Int>()
          for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
            set.insert(i)
            #expect(set.___tree_invariant() == true)
          }
          //      XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
          for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
            set.removeAll(i)
            #expect(set.___tree_invariant() == true)
          }
          //      XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
          for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
            set.insert(i)
            #expect(set.___tree_invariant() == true)
          }
          //      XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
          for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
            set.removeAll(i)
            #expect(set.___tree_invariant() == true)
          }
          //      XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
          for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
            set.insert(i)
            #expect(set.___tree_invariant() == true)
          }
          //      XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
          print("set.count", set.count)
          #if AC_COLLECTIONS_INTERNAL_CHECKS
            print("set._copyCount", set._copyCount)
          #endif
          for i in set[set.startIndex..<set.endIndex] {
            // erase multiなので、CoWなしだと、ポインタが破壊される
            set.removeAll(i)
            //        XCTAssertTrue(set.___tree_invariant())
          }
        }
      }
    #endif

  }
#endif
