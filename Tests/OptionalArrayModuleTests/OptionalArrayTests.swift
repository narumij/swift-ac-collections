import XCTest

#if DEBUG
@testable import OptionalArrayModule

final class OptionalArrayTests: XCTestCase {

  func testOptionalArray1D_InitiallyContainsNil() {
    let array = OptionalArray1D<Int>(capacity: 3)

    XCTAssertNil(array[0])
    XCTAssertNil(array[1])
    XCTAssertNil(array[2])
  }

  func testOptionalArray1D_CanStoreValue() {
    var array = OptionalArray1D<Int>(capacity: 3)

    array[1] = 42

    XCTAssertNil(array[0])
    XCTAssertEqual(array[1], 42)
    XCTAssertNil(array[2])
  }

  func testOptionalArray1D_RemoveAllClearsValues() {
    var array = OptionalArray1D<Int>(capacity: 3)

    array[0] = 10
    array[2] = 20

    array.removeAll()

    XCTAssertNil(array[0])
    XCTAssertNil(array[1])
    XCTAssertNil(array[2])
  }

  func testOptionalArray1D_Indices() {
    let array = OptionalArray1D<Int>(capacity: 3)

    XCTAssertEqual(Array(array.indices), [0, 1, 2])
  }

  func testOptionalArray2D_CanStoreValue() {
    var array = OptionalArray2D<Int>(
      width: 3,
      height: 2)

    array[1][2] = 99

    XCTAssertNil(array[0][0])
    XCTAssertNil(array[0][1])
    XCTAssertNil(array[0][2])

    XCTAssertNil(array[1][0])
    XCTAssertNil(array[1][1])
    XCTAssertEqual(array[1][2], 99)
  }

  func testOptionalArray2D_SliceMutationUpdatesParent() {
    var array = OptionalArray2D<Int>(
      width: 3,
      height: 2)

    var row = array[1]
    row[2] = 77

    XCTAssertEqual(array[1][2], 77)
  }

  func testOptionalArray2D_RemoveAllClearsValues() {
    var array = OptionalArray2D<Int>(
      width: 3,
      height: 2)

    array[0][1] = 10
    array[1][2] = 20

    array.removeAll()

    for y in 0..<2 {
      for x in 0..<3 {
        XCTAssertNil(array[y][x])
      }
    }
  }

  func testOptionalArray2D_Indices() {
    let array = OptionalArray2D<Int>(
      width: 3,
      height: 2)

    XCTAssertEqual(Array(array.indices), [0, 1])
  }

  func testOptionalArray3D_PlanesAreIndependent() {
    var array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    array[1][1][1] = 123

    XCTAssertNil(array[0][1][1])
    XCTAssertEqual(array[1][1][1], 123)
  }

  func testOptionalArray3D_StrideCalculationIsCorrect() {
    var array = OptionalArray3D<Int>(
      width: 3,
      height: 4,
      depth: 2)

    array[0][0][0] = 10
    array[1][0][0] = 20

    XCTAssertEqual(array[0][0][0], 10)
    XCTAssertEqual(array[1][0][0], 20)
  }

  func testOptionalArray3D_RemoveAllClearsValues() {
    var array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    array[0][0][0] = 10
    array[1][1][1] = 20

    array.removeAll()

    for z in 0..<2 {
      for y in 0..<2 {
        for x in 0..<2 {
          XCTAssertNil(array[z][y][x])
        }
      }
    }
  }

  func testOptionalArray3D_Indices() {
    let array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 4)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3])
  }
}
#endif
