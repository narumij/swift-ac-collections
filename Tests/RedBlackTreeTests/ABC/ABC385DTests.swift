//
//  ABC385DTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/01.
//

import RedBlackTreeModule
import XCTest

final class ABC385DTests: RedBlackTreeTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }

  #if true
    func testABC385D(N: Int, M: Int, x: Int, y: Int, _xy: [(Int, Int)], _dc: [(String, Int)]) throws
    {
      //    var (N, M, x, y) = (Int.stdin, Int.stdin, Int.stdin, Int.stdin)
      var (x, y) = (x, y)
      var xy: [Int: RedBlackTreeSet<Int>] = [:]
      var yx: [Int: RedBlackTreeSet<Int>] = [:]
      for (xx, yy) in _xy {
        xy[xx, default: []].insert(yy)
        yx[yy, default: []].insert(xx)
      }
      var ans = 0
      for (c, d) in _dc {
        switch c {
        case "U":
          let new_y = y + d
          xy[x]?.sequence(from: y, through: new_y).forEach { i, v in
            ans += 1
            yx[v]?.remove(x)
            xy[x]?.remove(at: i)
          }
          y = new_y
        case "D":
          let new_y = y - d
          xy[x]?.sequence(from: new_y, through: y).forEach { i, v in
            ans += 1
            yx[v]?.remove(x)
            xy[x]?.remove(at: i)
          }
          y = new_y
        case "L":
          let new_x = x - d
          yx[y]?.sequence(from: new_x, through: x).forEach { i, v in
            ans += 1
            xy[v]?.remove(y)
            yx[y]?.remove(at: i)
          }
          x = new_x
        case "R":
          let new_x = x + d
          yx[y]?.sequence(from: x, through: new_x).forEach { i, v in
            ans += 1
            xy[v]?.remove(y)
            yx[y]?.remove(at: i)
          }
          x = new_x
        default:
          break
        }
      }
      print(x, y, ans)
    }
  #endif

  #if true
    func testABC358D(N: Int, M: Int, _A: [Int], B: [Int]) throws {
      var A = RedBlackTreeMultiSet(_A)
      var ans = 0
      for b in B {
        let i = A.lowerBound(b)
        guard i != A.endIndex else {
          ans = -1
          break
        }
        ans += A.remove(at: i)
      }
      print(ans)
    }
  #endif

  #if true
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

  func ABC411F(N: Int, M: Int, UV: [(Int, Int)], Q: Int, X: [Int]) throws {
    var m = M
    var p_rev = (0..<N) + []
    var p = (0..<N).map { [$0] }
    var e: [RedBlackTreeSet<Int>] = .init(repeating: .init(), count: N)
    var u: [Int] = []
    var v: [Int] = []
    for (_u, _v) in UV.map({ ($0 - 1, $1 - 1) }) {
      u.append(_u)
      v.append(_v)
      e[_u].insert(_v)
      e[_v].insert(_u)
    }
    for x in X {
      var vx = p_rev[u[x]]
      var vy = p_rev[v[x]]
      if vx != vy {
        let valx = (e[vx].count) + (p[vx].count)
        let valy = (e[vy].count) + (p[vy].count)
        if valx > valy { swap(&vx, &vy) }
        let sz = p[vx].count
        for j in 0..<sz {
          p[vy].append(p[vx][j])
          p_rev[p[vx][j]] = vy
        }
        p[vx].removeAll()
        for vz in e[vx] {
          if vz == vy {
            m -= 1
            e[vy].remove(vx)
          } else {
            if e[vy].contains(vz) {
              m -= 1
            } else {
              e[vy].insert(vz)
              e[vz].insert(vy)
            }
            e[vz].remove(vx)
          }
        }
        e[vx].removeAll()
      }
      print(m)
    }
  }

  func testExample() throws {
    try testABC385D(
      N: 3, M: 4, x: 3, y: 2,
      _xy: [
        (2, 2),
        (3, 3),
        (2, 1),
      ],
      _dc: [
        ("L", 2),
        ("D", 1),
        ("R", 2),
      ])
    try testABC385D(
      N: 1, M: 3, x: 0, y: 0,
      _xy: [
        (1, 1)
      ],
      _dc: [
        ("R", 1_000_000_000),
        ("R", 1_000_000_000),
        ("R", 1_000_000_000),
      ])
  }

  func testExample2() throws {
    try testABC358D(
      N: 4, M: 2,
      _A: [3, 4, 5, 4],
      B: [1, 4])
    try testABC358D(
      N: 3, M: 3,
      _A: [1, 1, 1],
      B: [1_000_000_000, 1_000_000_000, 1_000_000_000])
    try testABC358D(
      N: 7, M: 3,
      _A: [2, 6, 8, 9, 5, 1, 11],
      B: [3, 5, 7])
  }

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

  func testExample4() throws {
    try ABC411F(
      N: 7, M: 7,
      UV: [
        (1, 2),
        (1, 3),
        (2, 3),
        (1, 4),
        (1, 5),
        (2, 5),
        (6, 7)],
      Q: 5,
      X: [1, 2, 3, 1, 5])
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    _ = 3

    self.measure {
      // Put the code you want to measure the time of here.
      try! testExample()
    }
  }

  func testPerformanceExample2() throws {
    // This is an example of a performance test case.
    _ = 3

    self.measure {
      // Put the code you want to measure the time of here.
      try! testExample2()
    }
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
