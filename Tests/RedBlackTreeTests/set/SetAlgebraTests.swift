import RedBlackTreeModule
import XCTest

final class SetAlgebraTests: RedBlackTreeTestCase {

  func testUnion0() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    lhs.formUnion(rhs)
    assertEquiv(lhs, [1, 2, 3, 4, 5, 6])
  }

  func testUnion1() throws {
    var lhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    let rhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    lhs.formUnion(rhs)
    assertEquiv(lhs, [1, 2, 3, 4, 5, 6])
  }

  func testUnion2() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    let rhs: RedBlackTreeSet<Int> = [4, 5, 6]
    lhs.formUnion(rhs)
    assertEquiv(lhs, [1, 2, 3, 4, 5, 6])
  }

  func testUnion3() throws {
    let lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    assertEquiv(lhs.union(rhs), [1, 2, 3, 4, 5, 6])
  }

  func testSymm0() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    lhs.formSymmetricDifference(rhs)
    assertEquiv(lhs, [1, 2, 5, 6])
  }

  func testSymm1() throws {
    var lhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    let rhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    lhs.formSymmetricDifference(rhs)
    assertEquiv(lhs, [1, 2, 5, 6])
  }

  func testSymm2() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [2, 4]
    lhs.formSymmetricDifference(rhs)
    assertEquiv(lhs, [1, 3])
  }

  func testSymm3() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 3]
    let rhs: RedBlackTreeSet<Int> = [2, 4]
    lhs.formSymmetricDifference(rhs)
    assertEquiv(lhs, [1, 2, 3, 4])
  }

  func testSymm4() throws {
    let lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    assertEquiv(lhs.symmetricDifference(rhs), [1, 2, 5, 6])
  }

  func testSymm5() throws {
    var lhs: RedBlackTreeSet<Int> = []
    let rhs: RedBlackTreeSet<Int> = [1, 2, 3]
    lhs.formSymmetricDifference(rhs)
    assertEquiv(lhs, [1, 2, 3])
  }

  func testSymm6() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    let rhs: RedBlackTreeSet<Int> = []
    lhs.formSymmetricDifference(rhs)
    assertEquiv(lhs, [1, 2, 3])
  }

  func testSymm7() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    let rhs: RedBlackTreeSet<Int> = [1, 2, 3]
    lhs.formSymmetricDifference(rhs)
    assertEquiv(lhs, [])
  }

  func testInter0() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    lhs.formIntersection(rhs)
    assertEquiv(lhs, [3, 4])
  }

  func testInter1() throws {
    let lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    assertEquiv(lhs.intersection(rhs), [3, 4])
  }

  func testDiff0() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4, 7, 8]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    lhs.formDifference(rhs)
    assertEquiv(lhs, [1, 2, 7, 8])
  }

  func testDiff1() throws {
    let lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4, 7, 8]
    let rhs: RedBlackTreeSet<Int> = [3, 4, 5, 6]
    assertEquiv(lhs.difference(rhs), [1, 2, 7, 8])
  }

  func testDiff2() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    let rhs: RedBlackTreeSet<Int> = []
    lhs.formDifference(rhs)
    assertEquiv(lhs, [1, 2, 3])
  }

  func testDiff3() throws {
    var lhs: RedBlackTreeSet<Int> = []
    let rhs: RedBlackTreeSet<Int> = [1, 2, 3]
    lhs.formDifference(rhs)
    assertEquiv(lhs, [])
  }

  func testDiff4() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    let rhs: RedBlackTreeSet<Int> = [1, 2, 3]
    lhs.formDifference(rhs)
    assertEquiv(lhs, [])
  }

  func testDiff5() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3]
    let rhs: RedBlackTreeSet<Int> = [4, 5, 6]
    lhs.formDifference(rhs)
    assertEquiv(lhs, [1, 2, 3])
  }

  func testDiff6() throws {
    var lhs: RedBlackTreeSet<Int> = [4, 5, 6]
    let rhs: RedBlackTreeSet<Int> = [1, 2, 3]
    lhs.formDifference(rhs)
    assertEquiv(lhs, [4, 5, 6])
  }

  func testDiff7() throws {
    var lhs: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    let rhs: RedBlackTreeSet<Int> = [2, 4, 6]
    lhs.formDifference(rhs)
    assertEquiv(lhs, [1, 3, 5])
  }

  func testDiff8() throws {
    var lhs: RedBlackTreeSet<Int> = [2, 4, 6]
    let rhs: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    lhs.formDifference(rhs)
    assertEquiv(lhs, [])
  }
}
