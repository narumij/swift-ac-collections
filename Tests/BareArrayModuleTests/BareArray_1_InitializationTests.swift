import BareArrayModule
import XCTest

/// 公開initializer: `init(repeating:...)`は全要素を同じ値で埋め、closure版は返り値をstorageへ順に格納する。
/// zero次元は許され、そのときclosureは呼ばれない。
final class BareArray_1_InitializationTests: XCTestCase {

  // MARK: - init(repeating:)

  func testBareArrayRepeatingFillsEveryElement() {
    let array = BareArray<Int>(repeating: 42, count: 5)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3, 4])

    for i in array.indices {
      XCTAssertEqual(array[i], 42)
    }
  }

  func testBareArray2DRepeatingFillsEveryElement() {
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

  func testBareArray3DRepeatingFillsEveryElement() {
    let array = BareArray3D<Int>(repeating: 7, width: 2, height: 3, depth: 4)

    for z in array.indices {
      for y in array[z].indices {
        for x in array[z][y].indices {
          XCTAssertEqual(array[z][y][x], 7)
        }
      }
    }
  }

  func testBareArray4DRepeatingFillsEveryElement() {
    let array = BareArray4D<Int>(repeating: 7, size0: 2, size1: 3, size2: 2, size3: 2)

    for w in array.indices {
      for z in array[w].indices {
        for y in array[w][z].indices {
          for x in array[w][z][y].indices {
            XCTAssertEqual(array[w][z][y][x], 7)
          }
        }
      }
    }
  }

  // MARK: - init(_:) closure
  //
  // closureの返り値はstorageへ順に格納され、連鎖subscriptでは最も内側の軸が最速で進む。
  // 非対称寸法で全位置を照合するtestは`BareArray_2_ElementAccessTests`にある。

  func testBareArrayClosureFillsStorageInOrder() {
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

  func testBareArray2DClosureFillsStorageInOrder() {
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

  func testBareArray3DClosureFillsStorageInOrder() {
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

  func testBareArray4DClosureFillsStorageInOrder() {
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

  // MARK: - Zero dimensions

  func testZeroDimensionsCreateEmptyStorageWithoutCallingInitializerClosure() {
    var calls = 0

    let one = BareArray<Int>(count: 0) {
      calls += 1
      return 0
    }
    let two = BareArray2D<Int>(width: 0, height: 3) {
      calls += 1
      return 0
    }
    // 途中積はoverflowしても、数学的な積がzeroなら許される
    let three = BareArray3D<Int>(width: .max, height: .max, depth: 0) {
      calls += 1
      return 0
    }
    let four = BareArray4D<Int>(size0: .max, size1: .max, size2: .max, size3: 0) {
      calls += 1
      return 0
    }

    XCTAssertTrue(one.indices.isEmpty)
    XCTAssertEqual(Array(two.indices), [0, 1, 2])
    XCTAssertTrue(two[0].indices.isEmpty)
    XCTAssertTrue(three.indices.isEmpty)
    XCTAssertTrue(four.indices.isEmpty)
    XCTAssertEqual(calls, 0)
  }
}
