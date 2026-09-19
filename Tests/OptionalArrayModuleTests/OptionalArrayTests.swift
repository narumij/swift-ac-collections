import XCTest

#if DEBUG
@testable import OptionalArrayModule

final class OptionalArrayTests: XCTestCase {

  // MARK: - OptionalArray1D

  func testOptionalArray1DInitialValuesAreNil() {
    let array = OptionalArray1D<Int>(capacity: 3)

    XCTAssertNil(array[0])
    XCTAssertNil(array[1])
    XCTAssertNil(array[2])
  }

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

  func testOptionalArray1DIndices() {
    let array = OptionalArray1D<Int>(capacity: 4)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3])
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

  func testOptionalArray2DViewSharesStorage() {
    let array = OptionalArray2D<Int>(
      width: 2,
      height: 2)

    var row = array[1]
    row[0] = 123

    XCTAssertEqual(array[1][0], 123)
  }

  func testOptionalArray2DIndices() {
    let array = OptionalArray2D<Int>(
      width: 2,
      height: 4)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3])
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

  func testOptionalArray3DRemoveAll() {
    var array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    array[1][0][1] = 999

    array.removeAll()

    XCTAssertNil(array[1][0][1])
  }

  func testOptionalArray3DViewSharesStorage() {
    let array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    var plane = array[1]
    plane[0][1] = 555

    XCTAssertEqual(array[1][0][1], 555)
  }

  func testOptionalArray3DIndices() {
    let array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 3)

    XCTAssertEqual(Array(array.indices), [0, 1, 2])
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
#endif
