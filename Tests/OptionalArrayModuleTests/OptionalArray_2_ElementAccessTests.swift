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

  func testOptionalArray1DDirectMethods() {
    let array = OptionalArray1D<Int>(capacity: 2)
    XCTAssertNil(array.element(at: 1))
    array.setElement(10, at: 1)
    XCTAssertEqual(array.element(at: 1), 10)
    array.setElement(nil, at: 1)
    XCTAssertNil(array.element(at: 1))
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

  func testOptionalArray2DDirectMethods() {
    let array = OptionalArray2D<Int>(width: 2, height: 3)
    XCTAssertNil(array.element(at: 1, 2))
    array.setElement(20, at: 1, 2)
    XCTAssertEqual(array.element(at: 1, 2), 20)
    XCTAssertNil(array.element(at: 0, 2))
    array.setElement(nil, at: 1, 2)
    XCTAssertNil(array.element(at: 1, 2))
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

  func testOptionalArray3DDirectMethods() {
    let array = OptionalArray3D<Int>(width: 2, height: 3, depth: 4)
    XCTAssertNil(array.element(at: 1, 2, 3))
    array.setElement(30, at: 1, 2, 3)
    XCTAssertEqual(array.element(at: 1, 2, 3), 30)
    XCTAssertNil(array.element(at: 0, 2, 3))
    array.setElement(nil, at: 1, 2, 3)
    XCTAssertNil(array.element(at: 1, 2, 3))
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

  func testOptionalArray4DDirectMethods() {
    let array = OptionalArray4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5)
    XCTAssertNil(array.element(at: 1, 2, 3, 4))
    array.setElement(40, at: 1, 2, 3, 4)
    XCTAssertEqual(array.element(at: 1, 2, 3, 4), 40)
    XCTAssertNil(array.element(at: 0, 2, 3, 4))
    array.setElement(nil, at: 1, 2, 3, 4)
    XCTAssertNil(array.element(at: 1, 2, 3, 4))
  }
}
