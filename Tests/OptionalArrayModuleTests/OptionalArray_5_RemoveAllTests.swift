import XCTest
import OptionalArrayModule

final class OptionalArray_5_RemoveAllTests: XCTestCase {

  // MARK: - OptionalArray1D

  func testOptionalArray1DRemoveAll() {
    var array = OptionalArray1D<Int>(capacity: 3)

    array[0] = 1
    array[1] = 2
    array[2] = 3

    array.removeAll()

    XCTAssertNil(array[0])
    XCTAssertNil(array[1])
    XCTAssertNil(array[2])
  }

  // MARK: - OptionalArray2D

  func testOptionalArray2DRemoveAll() {
    var array = OptionalArray2D<Int>(
      width: 2,
      height: 2)

    array[0][0] = 1
    array[1][1] = 2

    array.removeAll()

    XCTAssertNil(array[0][0])
    XCTAssertNil(array[1][1])
  }

  // MARK: - OptionalArray3D

  func testOptionalArray3DRemoveAll() {
    var array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    array[1][0][1] = 999

    array.removeAll()

    XCTAssertNil(array[1][0][1])
  }

  // MARK: - OptionalArray4D

  func testOptionalArray4DRemoveAll() {
    var array = OptionalArray4D<Int>(
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2)

    array[1][0][1][0] = 1234

    array.removeAll()

    XCTAssertNil(array[1][0][1][0])
  }
}
