import XCTest
import OptionalArrayModule

final class OptionalArray_4_IndicesTests: XCTestCase {

  // MARK: - OptionalElementBuffer

  func testOptionalArray1DIndices() {
    let array = OptionalElementBuffer<Int>(capacity: 4)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3])
  }

  // MARK: - OptionalElementBuffer2D

  func testOptionalArray2DIndices() {
    let array = OptionalElementBuffer2D<Int>(
      width: 2,
      height: 4)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3])
  }

  // MARK: - OptionalElementBuffer3D

  func testOptionalArray3DIndices() {
    let array = OptionalElementBuffer3D<Int>(
      width: 2,
      height: 2,
      depth: 3)

    XCTAssertEqual(Array(array.indices), [0, 1, 2])
  }

  // MARK: - OptionalElementBuffer4D

  func testOptionalArray4DIndices() {
    let array = OptionalElementBuffer4D<Int>(
      size0: 1,
      size1: 1,
      size2: 1,
      size3: 4)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3])
  }

}
