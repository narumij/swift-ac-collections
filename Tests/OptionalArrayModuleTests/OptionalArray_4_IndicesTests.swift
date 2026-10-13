import XCTest
import OptionalArrayModule

final class OptionalArray_4_IndicesTests: XCTestCase {

  // MARK: - OptionalArray1D

  func testOptionalArray1DIndices() {
    let array = OptionalArray1D<Int>(capacity: 4)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3])
  }

  // MARK: - OptionalArray2D

  func testOptionalArray2DIndices() {
    let array = OptionalArray2D<Int>(
      width: 2,
      height: 4)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3])
  }

  // MARK: - OptionalArray3D

  func testOptionalArray3DIndices() {
    let array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 3)

    XCTAssertEqual(Array(array.indices), [0, 1, 2])
  }

  // MARK: - OptionalArray4D

  func testOptionalArray4DIndices() {
    let array = OptionalArray4D<Int>(
      size0: 1,
      size1: 1,
      size2: 1,
      size3: 4)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3])
  }

}
