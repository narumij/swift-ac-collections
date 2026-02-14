//
//  EmptySetIndexV3DeathTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
import Foundation
import RedBlackTreeModule
import Testing

struct EmptySetIndexV3DeathTests {

    @Test
    func `空のSetでstartIndexをsubscriptするとSIGSEGV以外で停止すること`() async {
        await #expect(processExitsWith: .signal(SIGTRAP)) {
            let set = RedBlackTreeSet<Int>()
            _ = set[set.startIndex]
        }
    }

    @Test
    func `空のSetでremove(at:)を呼ぶとSIGSEGV以外で停止すること`() async {
        await #expect(processExitsWith: .signal(SIGTRAP)) {
            var set = RedBlackTreeSet<Int>()
            _ = set.remove(at: set.startIndex)
        }
    }
}
#endif
