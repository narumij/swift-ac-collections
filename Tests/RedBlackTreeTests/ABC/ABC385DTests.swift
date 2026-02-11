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

  #if COMPATIBLE_ATCODER_2025
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
  #else
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
          xy[x]?[lowerBound(y)..<upperBound(new_y)].erase { v in
            ans += 1
            yx[v]?.remove(x)
            return true
          }
          y = new_y
        case "D":
          let new_y = y - d
          xy[x]?[lowerBound(new_y)..<upperBound(y)].erase { v in
            ans += 1
            yx[v]?.remove(x)
            return true
          }
          y = new_y
        case "L":
          let new_x = x - d
          yx[y]?.removeAll(in: lowerBound(new_x)..<upperBound(x)) { v in
            ans += 1
            xy[v]?.remove(y)
            return true
          }
          x = new_x
        case "R":
          let new_x = x + d
          yx[y]?.removeAll(in: lowerBound(x)..<upperBound(new_x)) { v in
            ans += 1
            xy[v]?.remove(y)
            return true
          }
          x = new_x
        default:
          break
        }
      }
      print(x, y, ans)
    }
  #endif

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

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    _ = 3

    self.measure {
      // Put the code you want to measure the time of here.
      try! testExample()
    }
  }
}
