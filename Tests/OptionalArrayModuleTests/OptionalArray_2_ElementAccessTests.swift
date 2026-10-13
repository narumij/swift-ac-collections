import XCTest
import OptionalArrayModule

final class OptionalArray_2_ElementAccessTests: XCTestCase {

  // MARK: - OptionalElementBuffer

  func testOptionalArray1DSetAndGet() {
    var array = OptionalElementBuffer<Int>(capacity: 3)

    array.setElement(10, at: 0)
    array.setElement(30, at: 2)

    XCTAssertEqual(array.element(at: 0), 10)
    XCTAssertNil(array.element(at: 1))
    XCTAssertEqual(array.element(at: 2), 30)
  }

  func testOptionalArray1DAssignNil() {
    var array = OptionalElementBuffer<Int>(capacity: 3)

    array.setElement(123, at: 1)
    XCTAssertEqual(array.element(at: 1), 123)

    array.setElement(nil, at: 1)
    XCTAssertNil(array.element(at: 1))
  }

  func testOptionalArray1DDirectMethods() {
    let array = OptionalElementBuffer<Int>(capacity: 2)
    XCTAssertNil(array.element(at: 1))
    array.setElement(10, at: 1)
    XCTAssertEqual(array.element(at: 1), 10)
    array.setElement(nil, at: 1)
    XCTAssertNil(array.element(at: 1))
  }

  // MARK: - OptionalElementBuffer2D

  func testOptionalArray2DSetAndGet() {
    var array = OptionalElementBuffer2D<Int>(
      width: 2,
      height: 2)

    array.setElement(10, at: 0, 0)
    array.setElement(20, at: 1, 1)

    XCTAssertEqual(array.element(at: 0, 0), 10)
    XCTAssertEqual(array.element(at: 1, 1), 20)
    XCTAssertNil(array.element(at: 1, 0))
  }

  func testOptionalArray2DDirectMethods() {
    let array = OptionalElementBuffer2D<Int>(width: 2, height: 3)
    XCTAssertNil(array.element(at: 1, 2))
    array.setElement(20, at: 1, 2)
    XCTAssertEqual(array.element(at: 1, 2), 20)
    XCTAssertNil(array.element(at: 0, 2))
    array.setElement(nil, at: 1, 2)
    XCTAssertNil(array.element(at: 1, 2))
  }

  // MARK: - OptionalElementBuffer3D

  func testOptionalArray3DSetAndGet() {
    var array = OptionalElementBuffer3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    array.setElement(999, at: 1, 0, 1)

    XCTAssertEqual(array.element(at: 1, 0, 1), 999)
    XCTAssertNil(array.element(at: 0, 0, 0))
  }

  func testOptionalArray3DDirectMethods() {
    let array = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4)
    XCTAssertNil(array.element(at: 1, 2, 3))
    array.setElement(30, at: 1, 2, 3)
    XCTAssertEqual(array.element(at: 1, 2, 3), 30)
    XCTAssertNil(array.element(at: 0, 2, 3))
    array.setElement(nil, at: 1, 2, 3)
    XCTAssertNil(array.element(at: 1, 2, 3))
  }

  // MARK: - OptionalElementBuffer4D

  func testOptionalArray4DSetAndGet() {
    var array = OptionalElementBuffer4D<Int>(
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2)

    array.setElement(1234, at: 0, 1, 0, 1)

    XCTAssertEqual(array.element(at: 0, 1, 0, 1), 1234)
    XCTAssertNil(array.element(at: 0, 0, 0, 0))
  }

  func testOptionalArray4DDirectMethods() {
    let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5)
    XCTAssertNil(array.element(at: 1, 2, 3, 4))
    array.setElement(40, at: 1, 2, 3, 4)
    XCTAssertEqual(array.element(at: 1, 2, 3, 4), 40)
    XCTAssertNil(array.element(at: 0, 2, 3, 4))
    array.setElement(nil, at: 1, 2, 3, 4)
    XCTAssertNil(array.element(at: 1, 2, 3, 4))
  }
}
