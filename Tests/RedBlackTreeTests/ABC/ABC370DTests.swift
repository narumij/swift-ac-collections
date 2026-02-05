//
//  ABC385DTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/01.
//

import RedBlackTreeModule
import XCTest

final class ABC370DTests: RedBlackTreeTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }

  #if !COMPATIBLE_ATCODER_2025
  func ABC370D(H: Int, W: Int, Q: [(Int, Int)]) throws {
    let _g1 = RedBlackTreeSet<Int>(0..<W)
    let _g2 = RedBlackTreeSet<Int>(0..<H)
    nonisolated(unsafe) var g1: [RedBlackTreeSet<Int>] = .init(repeating: _g1, count: H)
    nonisolated(unsafe) var g2: [RedBlackTreeSet<Int>] = .init(repeating: _g2, count: W)

    func erase(_ i: Int, _ j: Int) {
      _ = g1[i].remove(j)
      _ = g2[j].remove(i)
    }

    for (R, C) in Q {

      if g1[R].contains(C) {
        erase(R, C)
        continue
      }

      if let r = g2[C][lowerBound(R).before] {
        erase(r, C)
      }

      if let r = g2[C][lowerBound(R)] {
        erase(r, C)
      }

      if let c = g1[R][lowerBound(C).before] {
        erase(R, c)
      }

      if let c = g1[R][lowerBound(C)] {
        erase(R, c)
      }
    }

    var ans = 0
    for i in 0..<H {
      ans += g1[i].count
    }

    print(ans)
  }
  #elseif true
    func ABC370D(H: Int, W: Int, Q: [(Int, Int)]) throws {
      let _g1 = RedBlackTreeSet<Int>(0..<W)
      let _g2 = RedBlackTreeSet<Int>(0..<H)
      nonisolated(unsafe) var g1: [RedBlackTreeSet<Int>] = .init(repeating: _g1, count: H)
      nonisolated(unsafe) var g2: [RedBlackTreeSet<Int>] = .init(repeating: _g2, count: W)

      func erase(_ i: Int, _ j: Int) {
        _ = g1[i].remove(j)
        _ = g2[j].remove(i)
      }

      for (R, C) in Q {

        if g1[R].contains(C) {
          erase(R, C)
          continue
        }

        if let r = g2[C].lowerBound(R).previous?.pointee {
          erase(r, C)
        }

        if let r = g2[C].lowerBound(R).pointee {
          erase(r, C)
        }

        if let c = g1[R].lowerBound(C).previous?.pointee {
          erase(R, c)
        }

        if let c = g1[R].lowerBound(C).pointee {
          erase(R, c)
        }
      }

      var ans = 0
      for i in 0..<H {
        ans += g1[i].count
      }

      print(ans)
    }
  #else
    func ABC370D(H: Int, W: Int, Q: [(Int, Int)]) throws {
      let _g1 = RedBlackTreeSet<Int>(0..<W)
      let _g2 = RedBlackTreeSet<Int>(0..<H)
      nonisolated(unsafe) var g1: [RedBlackTreeSet<Int>] = .init(repeating: _g1, count: H)
      nonisolated(unsafe) var g2: [RedBlackTreeSet<Int>] = .init(repeating: _g2, count: W)

      func erase(_ i: Int, _ j: Int) {
        _ = g1[i].remove(j)
        _ = g2[j].remove(i)
      }

      for (R, C) in Q {

        if g1[R].contains(C) {
          erase(R, C)
          continue
        }

        if let r = g2[C].___element(at: g2[C].___prev(g2[C].___lower_bound(R))) {
          erase(r, C)
        }

        if let r = g2[C].___element(at: g2[C].___lower_bound(R)) {
          erase(r, C)
        }

        if let c = g1[R].___element(at: g1[R].___prev(g1[R].___lower_bound(C))) {
          erase(R, c)
        }

        if let c = g1[R].___element(at: g1[R].___lower_bound(C)) {
          erase(R, c)
        }
      }

      var ans = 0
      for i in 0..<H {
        ans += g1[i].count
      }

      print(ans)
    }
  #endif

  func testExample3() throws {
    try ABC370D(H: 2, W: 4, Q: [(1, 2), (1, 2), (1, 3)].map { ($0 - 1, $1 - 1) })
    try ABC370D(H: 5, W: 5, Q: [(3, 3), (3, 3), (3, 2), (2, 2), (1, 2)].map { ($0 - 1, $1 - 1) })
    try ABC370D(
      H: 4, W: 3,
      Q: [
        (2, 2),
        (4, 1),
        (1, 1),
        (4, 2),
        (2, 1),
        (3, 1),
        (1, 3),
        (1, 2),
        (4, 3),
        (4, 2),
      ].map { ($0 - 1, $1 - 1) })
  }

  func testPerformanceExample3() throws {
    // This is an example of a performance test case.
    _ = 3

    self.measure {
      // Put the code you want to measure the time of here.
      try! testExample3()
    }
  }
}
