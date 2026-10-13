import XCTest
import OptionalElementBufferModule

final class OptionalArray_5_RemoveAllTests: XCTestCase {

  // MARK: - OptionalElementBuffer

  func testOptionalArray1DRemoveAll() {
    let array = OptionalElementBuffer<Int>(capacity: 3)

    array.setElement(1, at: 0)
    array.setElement(2, at: 1)
    array.setElement(3, at: 2)

    array.removeAll()

    XCTAssertNil(array.element(at: 0))
    XCTAssertNil(array.element(at: 1))
    XCTAssertNil(array.element(at: 2))
  }

  // MARK: - OptionalElementBuffer2D

  func testOptionalArray2DRemoveAll() {
    let array = OptionalElementBuffer2D<Int>(
      width: 2,
      height: 2)

    array.setElement(1, at: 0, 0)
    array.setElement(2, at: 1, 1)

    array.removeAll()

    XCTAssertNil(array.element(at: 0, 0))
    XCTAssertNil(array.element(at: 1, 1))
  }

  // MARK: - OptionalElementBuffer3D

  func testOptionalArray3DRemoveAll() {
    let array = OptionalElementBuffer3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    array.setElement(999, at: 1, 0, 1)

    array.removeAll()

    XCTAssertNil(array.element(at: 1, 0, 1))
  }

  // MARK: - OptionalElementBuffer4D

  func testOptionalArray4DRemoveAll() {
    let array = OptionalElementBuffer4D<Int>(
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2)

    array.setElement(1234, at: 0, 1, 0, 1)

    array.removeAll()

    XCTAssertNil(array.element(at: 0, 1, 0, 1))
  }
}
