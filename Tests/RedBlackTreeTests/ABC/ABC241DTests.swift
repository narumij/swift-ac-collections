//
//  ABC241DTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/15.
//

import RedBlackTreeModule
import XCTest

final class ABC241DTests: RedBlackTreeTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }

  enum Query {
    case insert(Int)
    case under(Int, Int)
    case over(Int, Int)
  }

  #if !COMPATIBLE_ATCODER_2025
    func testABC241D(queries: [Query]) throws {
      var multiset = RedBlackTreeMultiSet<Int>()
      for q in queries {
        switch q {
        case .insert(let x):
          multiset.insert(x)
        case .under(let x, let k):
          print(multiset[upperBound(x).advanced(by: -k)] ?? -1)
        case .over(let x, let k):
          print(multiset[lowerBound(x).advanced(by: k - 1)] ?? -1)
        }
      }
    }
  #else
    func testABC241D(queries: [Query]) throws {
      var multiset = RedBlackTreeMultiSet<Int>()
      for q in queries {
        switch q {
        case .insert(let x):
          multiset.insert(x)
        case .under(let x, let k):
          print(multiset.upperBound(x).advanced(by: -k).pointee ?? -1)
        case .over(let x, let k):
          print(multiset.lowerBound(x).advanced(by: k - 1).pointee ?? -1)
        }
      }
    }
  #endif

  func testExample() throws {
    try testABC241D(
      queries: [
        // 11
        // 1 20
        // [20]
        .insert(20),
        // 1 10
        // [10,20]
        .insert(10),
        // 1 30
        // [10,20,30]
        .insert(30),
        // 1 20
        // [10,20,20,30]
        .insert(20),
        // 3 15 1
        // [10,20,20,30]
        //     ^->^
        .under(15, 1),
        // 3 15 2
        // [10,20,20,30]
        //     ^---->^
        .under(15, 2),
        // 3 15 3
        // [10,20,20,30]
        //     ^------->^
        .under(15, 3),
        // 3 15 4
        // [10,20,20,30]
        //     ^------->^
        .under(15, 4),
        // 2 100 5
        //  [10,20,20,30]
        // ^<------------^
        .over(100, 5),
        // 1 1
        //  [ 1,10,20,20,30]
        .insert(1),
        // 2 100 5
        //  [ 1,10,20,20,30]
        //    ^<------------^
        .over(100, 5),
      ])
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
