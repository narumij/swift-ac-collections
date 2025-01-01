//
//  PermutationTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/01/01.
//

//import Algorithms
import PermutationModule
import XCTest

final class PermutationTests: XCTestCase {

#if false
  func testExample0() throws {
    do {
      let a = [1, 2]
      XCTAssertEqual(
        a.permutations().map { $0 },
        [[1, 2], [2, 1]])
    }
    do {
      let a = [1, 2, 3]
      XCTAssertEqual(
        a.permutations().map { $0 },
        [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    }
    do {
      let a = [0, 0, 1]
      XCTAssertEqual(
        a.permutations().map { $0 },
        [[0, 0, 1], [0, 1, 0], [0, 0, 1], [0, 1, 0], [1, 0, 0], [1, 0, 0]])
    }
  }
#endif

  func testExample() throws {
    do {
      let a = [1, 2]
      XCTAssertEqual(
        // アルゴリズムとの衝突をさけた使い方にする
        a.unsafePermutations().map { $0.map { $0 } },
        [[1, 2], [2, 1]])
    }
    do {
      let a = [1, 2, 3]
      XCTAssertEqual(
        // アルゴリズムとの衝突をさけた使い方にする
        a.unsafePermutations().map { $0.map { $0 } },
        [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    }
    do {
      let a = [0, 0, 1]
      // 挙動が異なるので一致しない
      XCTAssertNotEqual(
        a.unsafePermutations().map { $0.map { $0 } },
        [[0, 0, 1], [0, 1, 0], [0, 0, 1], [0, 1, 0], [1, 0, 0], [1, 0, 0]])
    }
    do {
#if AC_COLLECTIONS_INTERNAL_CHECKS
      for p in (0 ..< 4).unsafePermutations() {
        XCTAssertEqual(p._copyCount, 0)
      }
#endif
    }
  }

  func testPerformance00() throws {
    #if DEBUG
      var s = (0..<9) + []
    #else
      var s = (0..<10) + []
    #endif
    var ans = 0
    self.measure {
      var p = s
      repeat {
        ans += p.count
      } while p.nextPermutation()
    }
    print(ans)
  }

#if false
  func testPerformance0() throws {
    #if DEBUG
      let s = (0..<9) + []
    #else
      let s = (0..<10) + []
    #endif
    var ans = 0
    self.measure {
      for p in s.permutations() {
        ans += p.count
      }
    }
    print(ans)
  }
#endif

  func testPerformance1() throws {
    #if DEBUG
      let s = (0..<9) + []
    #else
      let s = (0..<10) + []
    #endif
    var ans = 0
    self.measure {
      for p in s.unsafePermutations() {
        ans += p.count
      }
    }
    print(ans)
  }
}
