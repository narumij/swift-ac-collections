//
//  MultiSetAlgebraTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/08/02.
//

import RedBlackTreeModule
import XCTest

#if COMPATIBLE_ATCODER_2025 || USE_SET_ALGEBRA
final class MultiSetAlgebraTests: RedBlackTreeTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }

  func testUnion0() throws {
    var lhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeMultiSet<Int> = [3, 4, 5, 6]
    lhs.formUnion(rhs)
    assertEquiv(lhs, [1, 2, 3, 3, 4, 4, 5, 6])
  }

  func testUnion1() throws {
    let lhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeMultiSet<Int> = [3, 4, 5, 6]
    assertEquiv(lhs.union(rhs), [1, 2, 3, 3, 4, 4, 5, 6])
  }

  func testSymm0() throws {
    var lhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeMultiSet<Int> = [3, 4, 5, 6]
    lhs.formSymmetricDifference(rhs)
    assertEquiv(lhs, [1, 2, 5, 6])
  }

  func testSymm1() throws {
    let lhs: RedBlackTreeMultiSet<Int> = [3, 4, 5, 6]
    let rhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4]
    assertEquiv(lhs.symmetricDifference(rhs), [1, 2, 5, 6])
  }

  func testSymm2() throws {
    let lhs: RedBlackTreeMultiSet<Int> = [3, 4, 4, 5, 6]
    let rhs: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 4]
    assertEquiv(lhs.symmetricDifference(rhs), [1, 2, 2, 4, 5, 6])
  }

  func testSymm3() throws {
    let lhs: RedBlackTreeMultiSet<Int> = [1, 1, 1]
    let rhs: RedBlackTreeMultiSet<Int> = [1]
    assertEquiv(lhs.symmetricDifference(rhs), [1, 1])
  }

  func testSymm4() throws {
    let lhs: RedBlackTreeMultiSet<Int> = [1, 1]
    let rhs: RedBlackTreeMultiSet<Int> = [1, 1]
    assertEquiv(lhs.symmetricDifference(rhs), [])
  }

  func testInter0() throws {
    var lhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeMultiSet<Int> = [3, 4, 5, 6]
    lhs.formIntersection(rhs)
    assertEquiv(lhs, [3, 4])
  }

  func testInter1() throws {
    let lhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeMultiSet<Int> = [3, 4, 5, 6]
    assertEquiv(lhs.intersection(rhs), [3, 4])
  }

  func testInter2() throws {
    let lhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 3, 4]
    let rhs: RedBlackTreeMultiSet<Int> = [3, 4, 4, 5, 6]
    assertEquiv(lhs.intersection(rhs), [3, 4])
  }

  func testInter3() throws {
    let lhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 3, 4, 4]
    let rhs: RedBlackTreeMultiSet<Int> = [3, 4, 4, 5, 6]
    assertEquiv(lhs.intersection(rhs), [3, 4, 4])
  }

  func testInter4() throws {
    let lhs: RedBlackTreeMultiSet<Int> = [1, 1, 1, 2]
    let rhs: RedBlackTreeMultiSet<Int> = [1, 1, 1, 1, 3]
    assertEquiv(lhs.intersection(rhs), [1, 1, 1])
  }

  func testInter5() throws {
    let lhs: RedBlackTreeMultiSet<Int> = [1, 1, 1, 1]
    let rhs: RedBlackTreeMultiSet<Int> = [1, 1]
    assertEquiv(lhs.intersection(rhs), [1, 1])
  }

  func testDiff0() throws {
    var lhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 3, 4]
    let rhs: RedBlackTreeMultiSet<Int> = [3, 4, 5, 6]
    lhs.formDifference(rhs)
    assertEquiv(lhs, [1, 2, 3])
  }

  func testDiff1() throws {
    let lhs: RedBlackTreeMultiSet<Int> = [1, 2, 3, 3, 4]
    let rhs: RedBlackTreeMultiSet<Int> = [3, 4, 5, 6]
    assertEquiv(lhs.difference(rhs), [1, 2, 3])
  }

  func testDiff2() throws {
    var lhs: RedBlackTreeMultiSet<Int> = [1, 1, 1, 2]
    let rhs: RedBlackTreeMultiSet<Int> = [1]
    lhs.formDifference(rhs)
    assertEquiv(lhs, [1, 1, 2])
  }

  func testDiff3() throws {
    var lhs: RedBlackTreeMultiSet<Int> = [1]
    let rhs: RedBlackTreeMultiSet<Int> = [1, 1, 1]
    lhs.formDifference(rhs)
    assertEquiv(lhs, [])
  }

  func testDiff4() throws {
    var lhs: RedBlackTreeMultiSet<Int> = [1, 1, 1]
    let rhs: RedBlackTreeMultiSet<Int> = [1, 1]
    lhs.formDifference(rhs)
    assertEquiv(lhs, [1])
  }
}
#endif
