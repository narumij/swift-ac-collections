import XCTest

#if DEBUG
  @testable import BareArrayModule

  final class BareArrayTests: XCTestCase {

    // MARK: - BareArray

    func testBareArrayRepeating() {
      let array = BareArray<Int>(repeating: 42, count: 5)

      XCTAssertEqual(Array(array.indices), [0, 1, 2, 3, 4])

      for i in array.indices {
        XCTAssertEqual(array[i], 42)
      }
    }

    func testBareArrayInitializerClosure() {
      var value = 0

      let array = BareArray<Int>(count: 5) {
        defer { value += 1 }
        return value
      }

      XCTAssertEqual(array[0], 0)
      XCTAssertEqual(array[1], 1)
      XCTAssertEqual(array[2], 2)
      XCTAssertEqual(array[3], 3)
      XCTAssertEqual(array[4], 4)
    }

    func testBareArrayMutation() {
      var array = BareArray<Int>(repeating: 0, count: 3)

      array[0] = 10
      array[1] = 20
      array[2] = 30

      XCTAssertEqual(array[0], 10)
      XCTAssertEqual(array[1], 20)
      XCTAssertEqual(array[2], 30)
    }

    // MARK: - BareArray2D

    func testBareArray2DRepeating() {
      let array = BareArray2D<Int>(
        repeating: 7,
        width: 3,
        height: 2)

      for y in array.indices {
        for x in array[y].indices {
          XCTAssertEqual(array[y][x], 7)
        }
      }
    }

    func testBareArray2DMutation() {
      var array = BareArray2D<Int>(
        repeating: 0,
        width: 3,
        height: 2)

      array[0][0] = 1
      array[0][1] = 2
      array[1][2] = 3

      XCTAssertEqual(array[0][0], 1)
      XCTAssertEqual(array[0][1], 2)
      XCTAssertEqual(array[1][2], 3)
    }

    func testBareArray2DSliceReflectsOriginalStorage() {
      let array = BareArray2D<Int>(
        repeating: 0,
        width: 2,
        height: 2)

      var row = array[1]
      row[0] = 123

      // 標準ではこの挙動は許容できないのだとおもう。
      XCTAssertEqual(array[1][0], 123)
    }

    func testBareArray2DInitializerClosure() {
      var value = 0

      let array = BareArray2D<Int>(
        width: 2,
        height: 2
      ) {
        defer { value += 1 }
        return value
      }

      XCTAssertEqual(array[0][0], 0)
      XCTAssertEqual(array[0][1], 1)
      XCTAssertEqual(array[1][0], 2)
      XCTAssertEqual(array[1][1], 3)
    }

    // MARK: - BareArray3D

    func testBareArray3DMutation() {
      var array = BareArray3D<Int>(
        repeating: 0,
        width: 2,
        height: 2,
        depth: 2)

      array[0][0][0] = 10
      array[0][1][1] = 20
      array[1][0][1] = 30

      XCTAssertEqual(array[0][0][0], 10)
      XCTAssertEqual(array[0][1][1], 20)
      XCTAssertEqual(array[1][0][1], 30)
    }

    func testBareArray3DInitializerClosure() {
      var value = 0

      let array = BareArray3D<Int>(
        width: 2,
        height: 2,
        depth: 2
      ) {
        defer { value += 1 }
        return value
      }

      XCTAssertEqual(array[0][0][0], 0)
      XCTAssertEqual(array[0][0][1], 1)
      XCTAssertEqual(array[0][1][0], 2)
      XCTAssertEqual(array[0][1][1], 3)
      XCTAssertEqual(array[1][0][0], 4)
      XCTAssertEqual(array[1][0][1], 5)
      XCTAssertEqual(array[1][1][0], 6)
      XCTAssertEqual(array[1][1][1], 7)
    }

    func testBareArray3DSliceReflectsOriginalStorage() {
      let array = BareArray3D<Int>(
        repeating: 0,
        width: 2,
        height: 2,
        depth: 2)

      var plane = array[1]
      plane[0][1] = 999

      XCTAssertEqual(array[1][0][1], 999)
    }

    // MARK: - BareArray4D

    func testBareArray4DMutation() {
      var array = BareArray4D<Int>(
        repeating: 0,
        size0: 2,
        size1: 2,
        size2: 2,
        size3: 2)

      array[1][0][1][0] = 1234

      XCTAssertEqual(array[1][0][1][0], 1234)
    }

    func testBareArray4DInitializerClosure() {
      var value = 0

      let array = BareArray4D<Int>(
        size0: 2,
        size1: 2,
        size2: 2,
        size3: 2
      ) {
        defer { value += 1 }
        return value
      }

      XCTAssertEqual(array[0][0][0][0], 0)
      XCTAssertEqual(array[0][0][0][1], 1)
      XCTAssertEqual(array[1][1][1][1], 15)
    }

    func testBareArray4DSliceReflectsOriginalStorage() {
      let array = BareArray4D<Int>(
        repeating: 0,
        size0: 2,
        size1: 2,
        size2: 2,
        size3: 2)

      var cube = array[1]
      cube[1][1][1] = 555

      XCTAssertEqual(array[1][1][1][1], 555)
    }

    // MARK: - Indices

    func testIndices() {
      XCTAssertEqual(
        Array(BareArray<Int>(repeating: 0, count: 3).indices),
        [0, 1, 2])

      XCTAssertEqual(
        Array(BareArray2D<Int>(repeating: 0, width: 2, height: 4).indices),
        [0, 1, 2, 3])

      XCTAssertEqual(
        Array(BareArray3D<Int>(repeating: 0, width: 2, height: 2, depth: 3).indices),
        [0, 1, 2])

      XCTAssertEqual(
        Array(
          BareArray4D<Int>(
            repeating: 0,
            size0: 2,
            size1: 2,
            size2: 2,
            size3: 4
          ).indices),
        [0, 1, 2, 3])
    }

    func testSliceIndices() {
      let array2d = BareArray2D<Int>(
        repeating: 0,
        width: 3,
        height: 2)

      XCTAssertEqual(
        Array(array2d[0].indices),
        [0, 1, 2])

      let array3d = BareArray3D<Int>(
        repeating: 0,
        width: 2,
        height: 3,
        depth: 4)

      XCTAssertEqual(
        Array(array3d[0].indices),
        [0, 1, 2])

      XCTAssertEqual(
        Array(array3d[0][0].indices),
        [0, 1])

      let array4d = BareArray4D<Int>(
        repeating: 0,
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
