//
//  ABC385DTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/01.
//

import RedBlackTreeCollections
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

    func ABC370D(H: Int, W: Int, Q: [(Int, Int)]) throws {
      
      let _g1 = RedBlackTreeSet<Int>(0..<W)
      let _g2 = RedBlackTreeSet<Int>(0..<H)
      
      nonisolated(unsafe) var g1: [RedBlackTreeSet<Int>] = .init(repeating: _g1, count: H)
      nonisolated(unsafe) var g2: [RedBlackTreeSet<Int>] = .init(repeating: _g2, count: W)

      for (R, C) in Q {
        
        // 合ってるかどうかわからない。雰囲気で書いて動いている程度
        
        g2[C][.lessThan(R) ... .greaterThan(R)].erase {
          g1[$0].remove(C)
          return true
        }

        g1[R][.lessThan(C) ... .greaterThan(C)].erase {
          g2[$0].remove(R)
          return true
        }
        
      }

      print(g1.map(\.count).reduce(0, +))
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

  #if ENABLE_PERFORMANCE_TESTING
  func testPerformanceExample3() throws {
    // This is an example of a performance test case.
    _ = 3

    self.measure {
      // Put the code you want to measure the time of here.
      try! testExample3()
    }
  }
  #endif
}
