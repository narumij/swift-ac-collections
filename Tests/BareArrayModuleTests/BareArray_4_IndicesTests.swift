import BareArrayModule
import XCTest

/// `indices`: 各型の`indices`は、その型の外側subscriptが受け付ける軸の`0..<長さ`である。
/// 所有型とViewとも、外側から順に`height` / `depth` / `size3`、内側へ進むほど短い次元の軸になる。
final class BareArray_4_IndicesTests: XCTestCase {

  // MARK: - Owned arrays

  func testOwnedArrayIndicesCoverOutermostAxis() {
    XCTAssertEqual(
      Array(BareArray<Int>(repeating: 0, count: 3).indices),
      [0, 1, 2])

    XCTAssertEqual(
      Array(BareArray2D<Int>(repeating: 0, width: 2, height: 4).indices),
      [0, 1, 2, 3])

    XCTAssertEqual(
      Array(BareArray3D<Int>(repeating: 0, width: 2, height: 2, depth: 3).indices),
      [0, 1, 2])

    XCTAssertEqual(
      Array(
        BareArray4D<Int>(
          repeating: 0,
          size0: 2,
          size1: 2,
          size2: 2,
          size3: 4
        ).indices),
      [0, 1, 2, 3])
  }

  func testBareArrayEmptyHasNoIndices() {
    let array = BareArray<Int>(repeating: 0, count: 0)
    XCTAssertEqual(Array(array.indices), [])
  }

  // MARK: - Views

  func testViewIndicesCoverNextInnerAxis() {
    let array2d = BareArray2D<Int>(
      repeating: 0,
      width: 3,
      height: 2)

    XCTAssertEqual(
      Array(array2d[0].indices),
      [0, 1, 2])

    let array3d = BareArray3D<Int>(
      repeating: 0,
      width: 2,
      height: 3,
      depth: 4)

    XCTAssertEqual(
      Array(array3d[0].indices),
      [0, 1, 2])

    XCTAssertEqual(
      Array(array3d[0][0].indices),
      [0, 1])

    let array4d = BareArray4D<Int>(
      repeating: 0,
      size0: 2,
      size1: 3,
      size2: 4,
      size3: 5)

    XCTAssertEqual(
      Array(array4d[0].indices),
      [0, 1, 2, 3])

    XCTAssertEqual(
      Array(array4d[0][0].indices),
      [0, 1, 2])

    XCTAssertEqual(
      Array(array4d[0][0][0].indices),
      [0, 1])
  }
}
