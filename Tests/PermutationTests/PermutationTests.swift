//
//  PermutationTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/01/01.
//

import Algorithms
import PermutationModule
import XCTest

final class PermutationTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

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
  }

  func testExample() throws {
    do {
      let a = [1, 2]
      XCTAssertEqual(
        // アルゴリズムとの衝突をさけた使い方にする
        PermutationSequence(a).map { $0.map { $0 } },
        [[1, 2], [2, 1]])
    }
    do {
      let a = [1, 2, 3]
      XCTAssertEqual(
        // アルゴリズムとの衝突をさけた使い方にする
        PermutationSequence(a).map { $0.map { $0 } },
        [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
    }
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
