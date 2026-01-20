//
//  Test.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

import Testing
import RedBlackTreeModule

struct TestRedBlackTreeSetFatalError {

  @Test
  func `削除済みインデックスを再度利用するとfatalErrorとなること`() async {
    await #expect(processExitsWith: .failure) {
      var a = RedBlackTreeSet<Int>(0..<100)
      let it = a.startIndex
      a.remove(at: it)
      a.remove(at: it)
    }
  }
  
  @Test
  func `末尾インデックスで削除するとfatalErrorとなること`() async {
    await #expect(processExitsWith: .failure) {
      var a = RedBlackTreeSet<Int>(0..<100)
      a.remove(at: a.endIndex)
    }
  }
}
