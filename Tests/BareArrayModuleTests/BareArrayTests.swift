import XCTest

#if DEBUG
  @testable import BareArrayModule

  final class BareArrayTests: XCTestCase {

    func testBareArray_ReadInitialValue() {
      // 条件
      let array = BareArray(repeating: 123, count: 3)

      // 操作・期待結果
      XCTAssertEqual(array[0], 123)
      XCTAssertEqual(array[1], 123)
      XCTAssertEqual(array[2], 123)
    }

    func testBareArray_WriteValue() {
      // 条件
      var array = BareArray(repeating: 0, count: 3)

      // 操作
      array[1] = 99

      // 期待結果
      XCTAssertEqual(array[0], 0)
      XCTAssertEqual(array[1], 99)
      XCTAssertEqual(array[2], 0)
    }

    func testBareArray2D_WriteValue() {
      // 条件
      var array = BareArray2D(repeating: 0, width: 3, height: 2)

      // 操作
      array[1][2] = 42

      // 期待結果
      XCTAssertEqual(array[0][0], 0)
      XCTAssertEqual(array[1][2], 42)
    }

    func testBareArray3D_StrideCalculation() {
      // 条件
      var array = BareArray3D(repeating: 0, width: 3, height: 4, depth: 2)

      // 操作
      array[0][0][0] = 10
      array[1][0][0] = 20

      // 期待結果
      XCTAssertEqual(array[0][0][0], 10)
      XCTAssertEqual(array[1][0][0], 20)
    }

    func testBareArray3D_PlanesAreIndependent() {
      // 条件
      var array = BareArray3D(repeating: 0, width: 2, height: 2, depth: 2)

      // 操作
      array[1][1][1] = 99

      // 期待結果
      XCTAssertEqual(array[0][1][1], 0)
      XCTAssertEqual(array[1][1][1], 99)
    }
  }
#endif
