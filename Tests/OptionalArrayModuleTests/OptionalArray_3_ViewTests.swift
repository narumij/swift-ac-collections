import XCTest
import OptionalArrayModule

final class OptionalArray_3_ViewTests: XCTestCase {

  // MARK: - OptionalArray2D

  func testOptionalArray2DViewSharesStorage() {
    let array = OptionalArray2D<Int>(
      width: 2,
      height: 2)

    var row = array[1]
    row[0] = 123

    XCTAssertEqual(array[1][0], 123)
  }

  // MARK: - OptionalArray3D

  func testOptionalArray3DViewSharesStorage() {
    let array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    var plane = array[1]
    plane[0][1] = 555

    XCTAssertEqual(array[1][0][1], 555)
  }

  // MARK: - OptionalArray4D

  func testOptionalArray4DViewSharesStorage() {
    let array = OptionalArray4D<Int>(
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2)

    var cube = array[1]
    cube[1][1][1] = 777

    XCTAssertEqual(array[1][1][1][1], 777)
  }

  func testOptionalArray4DViewUsesDepthAsItsOuterBound() {
    var array = OptionalArray4D<Int>(
      size0: 1,
      size1: 1,
      size2: 3,
      size3: 1)

    array[0][2][0][0] = 42

    XCTAssertEqual(array[0][2][0][0], 42)
    XCTAssertEqual(Array(array[0].indices), [0, 1, 2])
  }

  func testOptionalArray4DViewUsesFullPlaneStride() {
    var array = OptionalArray4D<Int>(
      size0: 2,
      size1: 3,
      size2: 2,
      size3: 1)

    array[0][1][0][0] = 42

    XCTAssertEqual(array[0][1][0][0], 42)
    XCTAssertNil(array[0][0][1][0])
  }
}
