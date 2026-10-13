import BareArrayModule
import XCTest

/// `indices`: 各所有型の`indices`は、最外軸の`0..<長さ`である。
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
}
