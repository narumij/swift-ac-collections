//
//  ABC385DTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/01.
//

import RedBlackTreeModule
import XCTest

final class ABC358DTests: RedBlackTreeTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }

  #if !COMPATIBLE_ATCODER_2025
  func testABC358D(N: Int, M: Int, _A: [Int], B: [Int]) throws {
    #if true
    var A = RedBlackTreeMultiSet(_A)
    var ans = 0
    for b in B {
      // ぜんぜんうれしさがない
      let result: Int? = A._withUnsafeMutableTree { A in
        let i = A.lowerBound(b)
        guard i != A.end() else { return nil }
        let result = A[i]
        _ = A.erase(i)
        return result
      }
      guard let result else {
        ans = -1
        break
      }
      ans += result
    }
    print(ans)
    #else
    var A = RedBlackTreeMultiSet(_A)
    var ans = 0
    for b in B {
      guard let i = A.remove(lowerBound(b)) else {
        ans = -1
        break
      }
      ans += i
    }
    print(ans)
    #endif
  }
  #else
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

  func testPerformanceExample2() throws {
    // This is an example of a performance test case.
    _ = 3

    self.measure {
      // Put the code you want to measure the time of here.
      try! testExample2()
    }
  }
}
