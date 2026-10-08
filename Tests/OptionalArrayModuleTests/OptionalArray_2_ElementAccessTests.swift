import XCTest
import OptionalArrayModule

final class OptionalArray_2_ElementAccessTests: XCTestCase {

  // MARK: - OptionalArray1D

  func testOptionalArray1DSetAndGet() {
    var array = OptionalArray1D<Int>(capacity: 3)

    array[0] = 10
    array[2] = 30

    XCTAssertEqual(array[0], 10)
    XCTAssertNil(array[1])
    XCTAssertEqual(array[2], 30)
  }

  func testOptionalArray1DAssignNil() {
    var array = OptionalArray1D<Int>(capacity: 3)

    array[1] = 123
    XCTAssertEqual(array[1], 123)

    array[1] = nil
    XCTAssertNil(array[1])
  }

  // MARK: - OptionalArray2D

  func testOptionalArray2DSetAndGet() {
    var array = OptionalArray2D<Int>(
      width: 2,
      height: 2)

    array[0][0] = 10
    array[1][1] = 20

    XCTAssertEqual(array[0][0], 10)
    XCTAssertEqual(array[1][1], 20)
    XCTAssertNil(array[0][1])
  }

  // MARK: - OptionalArray3D

  func testOptionalArray3DSetAndGet() {
    var array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    array[1][0][1] = 999

    XCTAssertEqual(array[1][0][1], 999)
    XCTAssertNil(array[0][0][0])
  }

  // MARK: - OptionalArray4D

  func testOptionalArray4DSetAndGet() {
    var array = OptionalArray4D<Int>(
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2)

    array[1][0][1][0] = 1234

    XCTAssertEqual(array[1][0][1][0], 1234)
    XCTAssertNil(array[0][0][0][0])
  }
}
