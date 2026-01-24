//
//  ABC385DTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/01.
//

import RedBlackTreeModule
import XCTest

final class ABC411DTests: RedBlackTreeTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }

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
}
