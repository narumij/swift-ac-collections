//
//  BoundsExpressionInvalidIndexMultiSetTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
import Foundation
import RedBlackTreeModule
import Testing

struct BoundsExpressionInvalidIndexMultiSetTests {

  @Test
  func `MultiSetでBoundRangeが不正な場合、eraesがSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
      set.eraes(lowerBound(3)..<lowerBound(1))
    }
  }

  @Test
  func `MultiSetでBoundRangeが不正な場合、erase whereがSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
      set.erase(lowerBound(3)..<lowerBound(1)) { _ in false }
    }
  }
}
#endif
