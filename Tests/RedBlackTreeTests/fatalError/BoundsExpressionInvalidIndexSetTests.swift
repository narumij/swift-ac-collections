//
//  BoundsExpressionInvalidIndexSetTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
import Foundation
import RedBlackTreeModule
import Testing

struct BoundsExpressionInvalidIndexSetTests {

  @Test
  func `SetでBoundRangeが不正な場合、eraseがSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var set = RedBlackTreeSet<Int>(0..<5)
      set.erase(lowerBound(3)..<lowerBound(1))
    }
  }

  @Test
  func `SetでBoundRangeが不正な場合、erase whereがSIGSEGV以外で停止すること`() async {
    await #expect(processExitsWith: .signal(SIGTRAP)) {
      var set = RedBlackTreeSet<Int>(0..<5)
      set.erase(lowerBound(3)..<lowerBound(1)) { _ in false }
    }
  }
}
#endif
