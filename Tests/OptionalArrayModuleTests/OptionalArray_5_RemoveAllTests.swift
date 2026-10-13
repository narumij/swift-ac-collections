import XCTest
import OptionalArrayModule

final class OptionalArray_5_RemoveAllTests: XCTestCase {

  // MARK: - OptionalArray1D

  func testOptionalArray1DRemoveAll() {
    var array = OptionalArray1D<Int>(capacity: 3)

    array.setElement(1, at: 0)
    array.setElement(2, at: 1)
    array.setElement(3, at: 2)

    array.removeAll()

    XCTAssertNil(array.element(at: 0))
    XCTAssertNil(array.element(at: 1))
    XCTAssertNil(array.element(at: 2))
  }

  // MARK: - OptionalArray2D

  func testOptionalArray2DRemoveAll() {
    var array = OptionalArray2D<Int>(
      width: 2,
      height: 2)

    array.setElement(1, at: 0, 0)
    array.setElement(2, at: 1, 1)

    array.removeAll()

    XCTAssertNil(array.element(at: 0, 0))
    XCTAssertNil(array.element(at: 1, 1))
  }

  // MARK: - OptionalArray3D

  func testOptionalArray3DRemoveAll() {
    var array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    array.setElement(999, at: 1, 0, 1)

    array.removeAll()

    XCTAssertNil(array.element(at: 1, 0, 1))
  }

  // MARK: - OptionalArray4D

  func testOptionalArray4DRemoveAll() {
    var array = OptionalArray4D<Int>(
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2)

    array.setElement(1234, at: 0, 1, 0, 1)

    array.removeAll()

    XCTAssertNil(array.element(at: 0, 1, 0, 1))
  }
}
