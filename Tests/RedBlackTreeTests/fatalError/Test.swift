//
//  Test.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

import Foundation
import RedBlackTreeModule
import Testing

struct TestRedBlackTreeSetFatalError {

  #if DEATH_TEST
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
  #endif
}
