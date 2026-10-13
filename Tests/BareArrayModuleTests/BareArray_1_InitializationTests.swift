import BareArrayModule
import XCTest

/// 公開initializer: `init(repeating:...)`は全要素を同じ値で埋め、closure版は返り値をstorageへ順に格納する。
/// zero次元は許され、そのときclosureは呼ばれない。
final class BareArray_1_InitializationTests: XCTestCase {

  // MARK: - init(repeating:)

  func testBareArrayRepeatingFillsEveryElement() {
    let array = ElementBuffer<Int>(repeating: 42, count: 5)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3, 4])

    for i in array.indices {
      XCTAssertEqual(array.element(at: i), 42)
    }
  }

  func testBareArray2DRepeatingFillsEveryElement() {
    let array = ElementBuffer2D<Int>(
      repeating: 7,
      width: 3,
      height: 2)

    for y in array.indices {
      for x in 0..<3 {
        XCTAssertEqual(array.element(at: x, y), 7)
      }
    }
  }

  func testBareArray3DRepeatingFillsEveryElement() {
    let array = ElementBuffer3D<Int>(repeating: 7, width: 2, height: 3, depth: 4)

    for z in array.indices {
      for y in 0..<3 {
        for x in 0..<2 {
          XCTAssertEqual(array.element(at: x, y, z), 7)
        }
      }
    }
  }

  func testBareArray4DRepeatingFillsEveryElement() {
    let array = ElementBuffer4D<Int>(repeating: 7, size0: 2, size1: 3, size2: 2, size3: 2)

    for w in array.indices {
      for z in 0..<2 {
        for y in 0..<3 {
          for x in 0..<2 {
            XCTAssertEqual(array.element(at: x, y, z, w), 7)
          }
        }
      }
    }
  }

  // MARK: - init(_:) closure
  //
  // closureの返り値はstorageへ順に格納され、座標accessでは最も内側の軸が最速で進む。
  // 非対称寸法で全位置を照合するtestは`BareArray_2_ElementAccessTests`にある。

  func testBareArrayClosureFillsStorageInOrder() {
    var value = 0

    let array = ElementBuffer<Int>(count: 5) {
      defer { value += 1 }
      return value
    }

    XCTAssertEqual(array.element(at: 0), 0)
    XCTAssertEqual(array.element(at: 1), 1)
    XCTAssertEqual(array.element(at: 2), 2)
    XCTAssertEqual(array.element(at: 3), 3)
    XCTAssertEqual(array.element(at: 4), 4)
  }

  func testBareArray2DClosureFillsStorageInOrder() {
    var value = 0

    let array = ElementBuffer2D<Int>(
      width: 2,
      height: 2
    ) {
      defer { value += 1 }
      return value
    }

    XCTAssertEqual(array.element(at: 0, 0), 0)
    XCTAssertEqual(array.element(at: 1, 0), 1)
    XCTAssertEqual(array.element(at: 0, 1), 2)
    XCTAssertEqual(array.element(at: 1, 1), 3)
  }

  func testBareArray3DClosureFillsStorageInOrder() {
    var value = 0

    let array = ElementBuffer3D<Int>(
      width: 2,
      height: 2,
      depth: 2
    ) {
      defer { value += 1 }
      return value
    }

    XCTAssertEqual(array.element(at: 0, 0, 0), 0)
    XCTAssertEqual(array.element(at: 1, 0, 0), 1)
    XCTAssertEqual(array.element(at: 0, 1, 0), 2)
    XCTAssertEqual(array.element(at: 1, 1, 0), 3)
    XCTAssertEqual(array.element(at: 0, 0, 1), 4)
    XCTAssertEqual(array.element(at: 1, 0, 1), 5)
    XCTAssertEqual(array.element(at: 0, 1, 1), 6)
    XCTAssertEqual(array.element(at: 1, 1, 1), 7)
  }

  func testBareArray4DClosureFillsStorageInOrder() {
    var value = 0

    let array = ElementBuffer4D<Int>(
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2
    ) {
      defer { value += 1 }
      return value
    }

    XCTAssertEqual(array.element(at: 0, 0, 0, 0), 0)
    XCTAssertEqual(array.element(at: 1, 0, 0, 0), 1)
    XCTAssertEqual(array.element(at: 1, 1, 1, 1), 15)
  }

  // MARK: - Zero dimensions

  func testZeroDimensionsCreateEmptyStorageWithoutCallingInitializerClosure() {
    var calls = 0

    let one = ElementBuffer<Int>(count: 0) {
      calls += 1
      return 0
    }
    let two = ElementBuffer2D<Int>(width: 0, height: 3) {
      calls += 1
      return 0
    }
    // 途中積はoverflowしても、数学的な積がzeroなら許される
    let three = ElementBuffer3D<Int>(width: .max, height: .max, depth: 0) {
      calls += 1
      return 0
    }
    let four = ElementBuffer4D<Int>(size0: .max, size1: .max, size2: .max, size3: 0) {
      calls += 1
      return 0
    }

    XCTAssertTrue(one.indices.isEmpty)
    XCTAssertEqual(Array(two.indices), [0, 1, 2])
    XCTAssertTrue(three.indices.isEmpty)
    XCTAssertTrue(four.indices.isEmpty)
    XCTAssertEqual(calls, 0)
  }
}
