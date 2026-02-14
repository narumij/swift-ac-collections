//
//  Test 2.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/02.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Testing
  import Foundation
  import RedBlackTreeModule

  struct Test_2 {

    @Test func `イテレータの不変条件違反の件0`() async throws {
      // Write your test here and use APIs like `#expect(...)` to check expected conditions.
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeSet((0..<5).map { $0 * 5 })
        var it = a[a.firstIndex(of: 5)!..<a.firstIndex(of: 20)!].makeIterator()
        #expect(a + [] == [0, 5, 10, 15, 20])
        #expect(a.firstIndex(of: 20)?.value == 4)
        a.remove(5)
        #expect(a.firstIndex(of: 1)?.value == nil)
        #expect(a + [] == [0, 10, 15, 20])
        #expect(it.next() == nil) // ここで落ちる
//        #expect(it.next() == nil)
      }
    }

    @Test func `イテレータの不変条件違反の件1`() async throws {
      // Write your test here and use APIs like `#expect(...)` to check expected conditions.
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeSet((0..<5).map { $0 * 5 })
        var it = a[a.firstIndex(of: 5)!..<a.firstIndex(of: 20)!].makeIterator()
        #expect(a + [] == [0, 5, 10, 15, 20])
        #expect(a.firstIndex(of: 20)?.value == 4)
        a.remove(20)
        a.insert(1)
        #expect(a.firstIndex(of: 1)?.value == 4)
        #expect(a + [] == [0, 1, 5, 10, 15])
        #expect(it.next() == 5) // ここで落ちてほしい
//        #expect(it.next() == 10)
//        #expect(it.next() == 15)
      }
    }

    @Test func `イテレータの不変条件違反の件2`() async throws {
      // Write your test here and use APIs like `#expect(...)` to check expected conditions.
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeSet((0..<5).map { $0 * 5 })
        var it = a[a.firstIndex(of: 5)!..<a.firstIndex(of: 20)!].makeIterator()
        #expect(a + [] == [0, 5, 10, 15, 20])
        #expect(a.firstIndex(of: 20)?.value == 4)
        a.remove(20)
        a.insert(30)
        a.insert(25)
        #expect(a.firstIndex(of: 30)?.value == 4)
        #expect(a + [] == [0, 5, 10, 15, 25, 30])
        #expect(it.next() == 5) // ここで落ちてほしい
//        #expect(it.next() == 10)
//        #expect(it.next() == 15)
//        #expect(it.next() == 25)// おちない
        // なおってしまった。
        // だが、ちゃんと把握できていない
      }
    }

    @Test func `イテレータの不変条件違反の件3`() async throws {
      await #expect(processExitsWith: .success) {
        var a = RedBlackTreeSet((0..<10).map { $0 * 5 })
        var it = a[a.lowerBound(5)..<a.lowerBound(50)].makeIterator()
//        #expect(a + [] == [0, 5, 10, 15, 20, 25, 30, 35, 40, 45])
//        #expect(a.firstIndex(of: 20)?.rawValue.raw == 4)
        a.remove(15) // 二つ先以降を消しても影響がない
        a.remove(35) // 二つ先以降を消しても影響がない
//        #expect(a + [] == [0, 5, 10, 20, 25, 30, 40, 45])
        #expect(it.next() == 5)
        #expect(it.next() == 10)
        #expect(it.next() == 20)
        #expect(it.next() == 25)
        #expect(it.next() == 30)
        #expect(it.next() == 40)
        #expect(it.next() == 45)
      }
    }

    @Test func `イテレータの不変条件違反の件4`() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var a = RedBlackTreeSet((0..<5).map { $0 * 5 })
        var it = a[a.firstIndex(of: 5)!..<a.lowerBound(20)].makeIterator()
        #expect(a + [] == [0, 5, 10, 15, 20])
        #expect(a.firstIndex(of: 20)?.value == 4)
        a.remove(10) // remove awareが1個先まですすんでるので、先頭の次を消すと落ちる
        // xこの挙動をどうするかは悩み
        // oそもそもイテレータ作成後に元の配列を編集した場合の挙動は未定義ということでいいのだとおもう
        #expect(a + [] == [0, 5, 15, 20])
        #expect(it.next() == 5)
      }
    }
  }
#endif
