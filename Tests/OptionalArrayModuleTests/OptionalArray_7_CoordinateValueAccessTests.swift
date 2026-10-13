import OptionalArrayModule
import XCTest

/// 所有1D〜4D型の座標value accessは、Viewを生成せずに同じ連続storageを読み書きする。
/// 非対称shapeで全座標を確認し、軸順とstrideの取り違えを検出する。
final class OptionalArray_7_CoordinateValueAccessTests: XCTestCase {

  func testSetAndElementReachEveryPosition() {
    var one = OptionalElementBuffer<Int>(capacity: 5)
    for x in 0..<5 { one.setElement(x, at: x) }
    for x in 0..<5 { XCTAssertEqual(one.element(at: x), x) }

    var two = OptionalElementBuffer2D<Int>(width: 2, height: 3)
    for y in 0..<3 {
      for x in 0..<2 { two.setElement(y * 2 + x, at: x, y) }
    }
    for y in 0..<3 {
      for x in 0..<2 {
        XCTAssertEqual(two.element(at: x, y), y * 2 + x, "(\(x), \(y))")
      }
    }

    var three = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4)
    for z in 0..<4 {
      for y in 0..<3 {
        for x in 0..<2 { three.setElement((z * 3 + y) * 2 + x, at: x, y, z) }
      }
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

    var four = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5)
    for w in 0..<5 {
      for z in 0..<4 {
        for y in 0..<3 {
          for x in 0..<2 {
            four.setElement(((w * 4 + z) * 3 + y) * 2 + x, at: x, y, z, w)
          }
        }
      }
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
    var one = OptionalElementBuffer<Int>(capacity: 3)
    one.setElement(11, at: 1)
    XCTAssertNil(one.element(at: 0))
    XCTAssertEqual(one.element(at: 1), 11)
    XCTAssertNil(one.element(at: 2))

    var two = OptionalElementBuffer2D<Int>(width: 2, height: 3)
    two.setElement(22, at: 1, 2)
    XCTAssertEqual(two.element(at: 1, 2), 22)
    XCTAssertNil(two.element(at: 0, 2))
    XCTAssertNil(two.element(at: 1, 1))

    var three = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4)
    three.setElement(33, at: 1, 2, 3)
    XCTAssertEqual(three.element(at: 1, 2, 3), 33)
    XCTAssertNil(three.element(at: 0, 2, 3))
    XCTAssertNil(three.element(at: 1, 1, 3))
    XCTAssertNil(three.element(at: 1, 2, 2))

    var four = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5)
    four.setElement(44, at: 1, 2, 3, 4)
    XCTAssertEqual(four.element(at: 1, 2, 3, 4), 44)
    XCTAssertNil(four.element(at: 0, 2, 3, 4))
    XCTAssertNil(four.element(at: 1, 1, 3, 4))
    XCTAssertNil(four.element(at: 1, 2, 2, 4))
    XCTAssertNil(four.element(at: 1, 2, 3, 3))
  }

  func testSetElementDestroysReplacedReferencesExactlyOnce() {
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
      var array = OptionalElementBuffer<Box>(capacity: 1)
      array.setElement(Box(id: 10) { destroyed.append($0) }, at: 0)
      array.setElement(Box(id: 11) { destroyed.append($0) }, at: 0)
      XCTAssertEqual(destroyed, [10])
      array.setElement(nil, at: 0)
      XCTAssertEqual(destroyed, [10, 11])
      withExtendedLifetime(array) {}
    }

    do {
      var array = OptionalElementBuffer2D<Box>(width: 1, height: 1)
      array.setElement(Box(id: 20) { destroyed.append($0) }, at: 0, 0)
      array.setElement(Box(id: 21) { destroyed.append($0) }, at: 0, 0)
      XCTAssertEqual(destroyed, [10, 11, 20])
      array.setElement(nil, at: 0, 0)
      XCTAssertEqual(destroyed, [10, 11, 20, 21])
      withExtendedLifetime(array) {}
    }

    do {
      var array = OptionalElementBuffer3D<Box>(width: 1, height: 1, depth: 1)
      array.setElement(Box(id: 30) { destroyed.append($0) }, at: 0, 0, 0)
      array.setElement(Box(id: 31) { destroyed.append($0) }, at: 0, 0, 0)
      XCTAssertEqual(destroyed, [10, 11, 20, 21, 30])
      array.setElement(nil, at: 0, 0, 0)
      XCTAssertEqual(destroyed, [10, 11, 20, 21, 30, 31])
      withExtendedLifetime(array) {}
    }

    do {
      var array = OptionalElementBuffer4D<Box>(size0: 1, size1: 1, size2: 1, size3: 1)
      array.setElement(Box(id: 40) { destroyed.append($0) }, at: 0, 0, 0, 0)
      array.setElement(Box(id: 41) { destroyed.append($0) }, at: 0, 0, 0, 0)
      XCTAssertEqual(destroyed, [10, 11, 20, 21, 30, 31, 40])
      array.setElement(nil, at: 0, 0, 0, 0)
      XCTAssertEqual(destroyed, [10, 11, 20, 21, 30, 31, 40, 41])
      withExtendedLifetime(array) {}
    }
    XCTAssertEqual(destroyed, [10, 11, 20, 21, 30, 31, 40, 41])
  }
}
