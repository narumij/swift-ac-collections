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

  // MARK: - View Indices

  func testViewIndices() {
    let array2d = OptionalArray2D<Int>(
      width: 3,
      height: 2)

    XCTAssertEqual(
      Array(array2d[0].indices),
      [0, 1, 2])

    let array3d = OptionalArray3D<Int>(
      width: 2,
      height: 3,
      depth: 4)

    XCTAssertEqual(
      Array(array3d[0].indices),
      [0, 1, 2])

    XCTAssertEqual(
      Array(array3d[0][0].indices),
      [0, 1])

    let array4d = OptionalArray4D<Int>(
      size0: 2,
      size1: 3,
      size2: 4,
      size3: 5)

    XCTAssertEqual(
      Array(array4d[0].indices),
      [0, 1, 2, 3])

    XCTAssertEqual(
      Array(array4d[0][0].indices),
      [0, 1, 2])

    XCTAssertEqual(
      Array(array4d[0][0][0].indices),
      [0, 1])
  }
}
