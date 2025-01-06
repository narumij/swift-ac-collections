//
//  SetAlgebraTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/01/05.
//

import RedBlackTreeModule
import XCTest

final class SetAlgebraTests: XCTestCase {

  func testUnion0() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    lhs.formUnion(rhs)
    XCTAssertEqual(lhs, [1, 2, 3, 4, 5, 6])
  }
  
  func testUnion1() throws {
    var lhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    let rhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    lhs.formUnion(rhs)
    XCTAssertEqual(lhs, [1, 2, 3, 4, 5, 6])
  }

  func testUnion2() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    let rhs: RedBlackTreeSet<Int> = [4, 5, 6]
    lhs.formUnion(rhs)
    XCTAssertEqual(lhs, [1, 2, 3, 4, 5, 6])
  }
  
  func testUnion3() throws {
    let lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    XCTAssertEqual(lhs.union(rhs), [1, 2, 3, 4, 5, 6])
  }
  
  func testSymm0() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    lhs.formSymmetricDifference(rhs)
    XCTAssertEqual(lhs, [1, 2, 5, 6])
  }

  func testSymm1() throws {
    var lhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    let rhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    lhs.formSymmetricDifference(rhs)
    XCTAssertEqual(lhs, [1, 2, 5, 6])
  }

  func testSymm2() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [2, 4]
    lhs.formSymmetricDifference(rhs)
    XCTAssertEqual(lhs, [1, 3])
  }
  
  func testSymm3() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 3]
    let rhs: RedBlackTreeSet<Int> = [2, 4]
    lhs.formSymmetricDifference(rhs)
    XCTAssertEqual(lhs, [1, 2, 3, 4])
  }
  
  func testSymm4() throws {
    let lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    XCTAssertEqual(lhs.symmetricDifference(rhs), [1, 2, 5, 6])
  }
  
  func testInter0() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    lhs.formIntersection(rhs)
    XCTAssertEqual(lhs, [3, 4])
  }
  
  func testInter1() throws {
    let lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    XCTAssertEqual(lhs.intersection(rhs), [3, 4])
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
