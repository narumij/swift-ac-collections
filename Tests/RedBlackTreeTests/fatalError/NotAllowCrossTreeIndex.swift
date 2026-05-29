//
//  Test 3.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/29.
//

import Testing
import Foundation
import RedBlackTreeModule

#if !ALLOW_CROSS_TREE_INDEX

  struct NotAllowCrossTreeIndex {

    @Test
    func `ことなる木由来のインデックスを用いて範囲削除しようとした場合、停止すること`() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        let source = RedBlackTreeSet(0..<8)
        var target = RedBlackTreeSet(100..<108)
        let lower = source.index(source.startIndex, offsetBy: 2)
        let upper = source.index(source.startIndex, offsetBy: 6)
        target.erase(lower..<upper)
      }
    }

  }
#endif
