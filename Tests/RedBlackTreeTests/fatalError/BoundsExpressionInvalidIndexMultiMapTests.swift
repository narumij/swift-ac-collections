//
//  BoundsExpressionInvalidIndexMultiMapTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
import Foundation
import RedBlackTreeModule
import Testing

struct BoundsExpressionInvalidIndexMultiMapTests {

  @Test
  func `MultiMapでBoundRangeが不正な場合、eraseがSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d"]
      map.erase(lowerBound(3)..<lowerBound(1))
    }
  }

  @Test
  func `MultiMapでBoundRangeが不正な場合、erase whereがSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d"]
      map.erase(lowerBound(3)..<lowerBound(1)) { _ in false }
    }
  }
}
#endif
