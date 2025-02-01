//
//  PermutationTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/01/01.
//

import PermutationModule
import XCTest

#if USING_ALGORITHMS
  import Algorithms
#endif

final class PermutationTests: XCTestCase {

  #if USING_ALGORITHMS
  // 挙動比較用
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

  func testUnsafePermutations() throws {
    do {
      let a = [1, 2]
      XCTAssertEqual(
        a.unsafePermutations().map { $0.map { $0 } },
        [[1, 2], [2, 1]])
    }
    do {
      let a = [1, 2, 3]
      XCTAssertEqual(
        a.unsafePermutations().map { $0.map { $0 } },
        [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    }
    do {
      let a = [0, 0, 1]
      XCTAssertEqual(
        a.unsafePermutations().map { $0.map { $0 } },
        [[0, 0, 1], [0, 1, 0], [0, 0, 1], [0, 1, 0], [1, 0, 0], [1, 0, 0]])
    }
    do {
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        for p in (0..<4).unsafePermutations() {
          XCTAssertEqual(p._copyCount, 0)
        }
      #endif
    }
  }

  func testNextPermutations() throws {
    do {
      let a = [1, 2]
      XCTAssertEqual(
        a.nextPermutations().map { $0.map { $0 } },
        [[1, 2], [2, 1]])
    }
    do {
      let a = [1, 2, 3]
      XCTAssertEqual(
        a.nextPermutations().map { $0.map { $0 } },
        [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    }
    do {
      let a = [0, 0]
      // 辞書順では変化しようがないので、最初の一回で終了となる
      XCTAssertEqual(
        a.nextPermutations().map { $0.map { $0 } },
        [[0, 0]])
    }
    do {
      let a = [4, 3, 2, 1]
      // 辞書順で最後なので、最初の一回で終了となる
      XCTAssertEqual(
        a.nextPermutations().map { $0.map { $0 } },
        [[4, 3, 2, 1]])
    }
    do {
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        for p in (0..<4).nextPermutations() {
          XCTAssertEqual(p._copyCount, 0)
        }
      #endif
    }
  }

#if ENABLE_PERFORMANCE_TESTING
  func testPerformance00() throws {
    #if DEBUG
    let s = (0..<9) + []
    #else
    let s = (0..<10) + []
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

  #if USING_ALGORITHMS
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
#endif
}
