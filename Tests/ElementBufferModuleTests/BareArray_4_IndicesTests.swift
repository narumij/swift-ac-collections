import ElementBufferModule
import XCTest

/// `indices`: for each owned type, `indices` is `0..<length` along the outermost axis.
final class BareArray_4_IndicesTests: XCTestCase {

  // MARK: - Owned arrays

  func testOwnedArrayIndicesCoverOutermostAxis() {
    XCTAssertEqual(
      Array(ElementBuffer<Int>(repeating: 0, count: 3).indices),
      [0, 1, 2])

    XCTAssertEqual(
      Array(ElementBuffer2D<Int>(repeating: 0, width: 2, height: 4).indices),
      [0, 1, 2, 3])

    XCTAssertEqual(
      Array(ElementBuffer3D<Int>(repeating: 0, width: 2, height: 2, depth: 3).indices),
      [0, 1, 2])

    XCTAssertEqual(
      Array(
        ElementBuffer4D<Int>(
          repeating: 0,
          size0: 2,
          size1: 2,
          size2: 2,
          size3: 4
        ).indices),
      [0, 1, 2, 3])
  }

  // BARE-046 D: an inner zero axis empties the storage but does not shrink `indices`,
  // which always covers the outermost axis.
  func testInnerZeroAxisKeepsOutermostIndices() {
    XCTAssertEqual(Array(ElementBuffer2D<Int>(repeating: 0, width: 0, height: 3).indices), [0, 1, 2])
    XCTAssertEqual(
      Array(ElementBuffer3D<Int>(repeating: 0, width: 2, height: 0, depth: 3).indices), [0, 1, 2])
    XCTAssertEqual(
      Array(ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 0, size3: 3).indices),
      [0, 1, 2])
  }

  func testBareArrayEmptyHasNoIndices() {
    let array = ElementBuffer<Int>(repeating: 0, count: 0)
    XCTAssertEqual(Array(array.indices), [])
  }
}
