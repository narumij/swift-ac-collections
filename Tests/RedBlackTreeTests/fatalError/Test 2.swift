//
//  Test 2.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/02.
//

#if DEATH_TEST
  import Testing
  import Foundation
  import RedBlackTreeModule

  struct Test_2 {

    @Test func `イテレータの不変条件違反の件0`() async throws {
      // Write your test here and use APIs like `#expect(...)` to check expected conditions.
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeSet((0..<5).map { $0 * 5 })
        var it = a[a.firstIndex(of: 5)..<a.firstIndex(of: 20)].makeIterator()
        #expect(a + [] == [0, 5, 10, 15, 20])
        #expect(a.firstIndex(of: 20)?.trackingTag?.rawValue == 4)
        a.remove(20)
        #expect(a.firstIndex(of: 1)?.trackingTag?.rawValue == nil)
        #expect(a + [] == [0, 5, 10, 15])
        #expect(it.next() == nil) // ここで落ちる
        #expect(it.next() == nil)
      }
    }

    @Test func `イテレータの不変条件違反の件1`() async throws {
      // Write your test here and use APIs like `#expect(...)` to check expected conditions.
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeSet((0..<5).map { $0 * 5 })
        var it = a[a.firstIndex(of: 5)..<a.firstIndex(of: 20)].makeIterator()
        #expect(a + [] == [0, 5, 10, 15, 20])
        #expect(a.firstIndex(of: 20)?.trackingTag?.rawValue == 4)
        a.remove(20)
        a.insert(1)
        #expect(a.firstIndex(of: 1)?.trackingTag?.rawValue == 4)
        #expect(a + [] == [0, 1, 5, 10, 15])
        #expect(it.next() == 5) // ここで落ちてほしい
        #expect(it.next() == 10)
        #expect(it.next() == 15)
      }
    }

    @Test func `イテレータの不変条件違反の件2`() async throws {
      // Write your test here and use APIs like `#expect(...)` to check expected conditions.
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeSet((0..<5).map { $0 * 5 })
        var it = a[a.firstIndex(of: 5)..<a.firstIndex(of: 20)].makeIterator()
        #expect(a + [] == [0, 5, 10, 15, 20])
        #expect(a.firstIndex(of: 20)?.trackingTag?.rawValue == 4)
        a.remove(20)
        a.insert(30)
        a.insert(25)
        #expect(a.firstIndex(of: 30)?.trackingTag?.rawValue == 4)
        #expect(a + [] == [0, 5, 10, 15, 25, 30])
        #expect(it.next() == 5) // ここで落ちてほしい
        #expect(it.next() == 10)
        #expect(it.next() == 15)
        #expect(it.next() == 25)// おちない
      }
    }

  }
#endif
