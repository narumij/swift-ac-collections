import ElementBufferModule
import XCTest

/// 所有1D〜4D型の座標value accessは、Viewを生成せずに同じ連続storageを読み書きする。
/// 非対称shapeで全座標を確認し、軸順とstrideの取り違えを検出する。
final class BareArray_6_CoordinateValueAccessTests: XCTestCase {

  func testElementAtReachesEveryPosition() {
    let one = ElementBuffer<Int>(count: 5) { 10 }
    for x in 0..<5 {
      XCTAssertEqual(one.element(at: x), 10)
    }

    var next = 0
    let two = ElementBuffer2D<Int>(width: 2, height: 3) {
      defer { next += 1 }
      return next
    }
    for y in 0..<3 {
      for x in 0..<2 {
        XCTAssertEqual(two.element(at: x, y), y * 2 + x, "(\(x), \(y))")
      }
    }

    next = 0
    let three = ElementBuffer3D<Int>(width: 2, height: 3, depth: 4) {
      defer { next += 1 }
      return next
    }
    for z in 0..<4 {
      for y in 0..<3 {
        for x in 0..<2 {
          XCTAssertEqual(
            three.element(at: x, y, z), (z * 3 + y) * 2 + x,
            "(\(x), \(y), \(z))")
        }
      }
    }

    next = 0
    let four = ElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5) {
      defer { next += 1 }
      return next
    }
    for w in 0..<5 {
      for z in 0..<4 {
        for y in 0..<3 {
          for x in 0..<2 {
            XCTAssertEqual(
              four.element(at: x, y, z, w), ((w * 4 + z) * 3 + y) * 2 + x,
              "(\(x), \(y), \(z), \(w))")
          }
        }
      }
    }
  }

  func testSetElementChangesSelectedPositionOnly() {
    let one = ElementBuffer<Int>(repeating: 0, count: 3)
    one.setElement(11, at: 1)
    XCTAssertEqual((0..<3).map { one.element(at: $0) }, [0, 11, 0])

    let two = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 3)
    two.setElement(22, at: 1, 2)
    XCTAssertEqual(two.element(at: 1, 2), 22)
    XCTAssertEqual(two.element(at: 0, 2), 0)
    XCTAssertEqual(two.element(at: 1, 1), 0)

    let three = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4)
    three.setElement(33, at: 1, 2, 3)
    XCTAssertEqual(three.element(at: 1, 2, 3), 33)
    XCTAssertEqual(three.element(at: 0, 2, 3), 0)
    XCTAssertEqual(three.element(at: 1, 1, 3), 0)
    XCTAssertEqual(three.element(at: 1, 2, 2), 0)

    let four = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5)
    four.setElement(44, at: 1, 2, 3, 4)
    XCTAssertEqual(four.element(at: 1, 2, 3, 4), 44)
    XCTAssertEqual(four.element(at: 0, 2, 3, 4), 0)
    XCTAssertEqual(four.element(at: 1, 1, 3, 4), 0)
    XCTAssertEqual(four.element(at: 1, 2, 2, 4), 0)
    XCTAssertEqual(four.element(at: 1, 2, 3, 3), 0)
  }

  func testSetElementDestroysReplacedReferenceExactlyOnce() {
    final class Box {
      let id: Int
      let onDeinit: (Int) -> Void

      init(id: Int, onDeinit: @escaping (Int) -> Void) {
        self.id = id
        self.onDeinit = onDeinit
      }

      deinit { onDeinit(id) }
    }

    var destroyed: [Int] = []
    do {
      let array = ElementBuffer<Box>(count: 1) { Box(id: 0) { destroyed.append($0) } }
      array.setElement(Box(id: 1) { destroyed.append($0) }, at: 0)

      XCTAssertEqual(destroyed, [0])
      XCTAssertEqual(array.element(at: 0).id, 1)
      withExtendedLifetime(array) {}
    }
    XCTAssertEqual(destroyed, [0, 1])
  }
}
