import BareArrayModule
import XCTest

/// 座標access: 所有型の要素を`element`と`setElement`で読み書きする。
final class BareArray_2_ElementAccessTests: XCTestCase {

  // MARK: - Mutation

  func testBareArrayMutation() {
    let array = ElementBuffer<Int>(repeating: 0, count: 3)

    array.setElement(10, at: 0)
    array.setElement(20, at: 1)
    array.setElement(30, at: 2)

    XCTAssertEqual(array.element(at: 0), 10)
    XCTAssertEqual(array.element(at: 1), 20)
    XCTAssertEqual(array.element(at: 2), 30)
  }

  func testBareArray2DCoordinateMutation() {
    let array = ElementBuffer2D<Int>(
      repeating: 0,
      width: 3,
      height: 2)

    array.setElement(1, at: 0, 0)
    array.setElement(2, at: 1, 0)
    array.setElement(3, at: 2, 1)

    XCTAssertEqual(array.element(at: 0, 0), 1)
    XCTAssertEqual(array.element(at: 1, 0), 2)
    XCTAssertEqual(array.element(at: 2, 1), 3)
  }

  func testBareArray3DCoordinateMutation() {
    let array = ElementBuffer3D<Int>(
      repeating: 0,
      width: 2,
      height: 2,
      depth: 2)

    array.setElement(10, at: 0, 0, 0)
    array.setElement(20, at: 1, 1, 0)
    array.setElement(30, at: 1, 0, 1)

    XCTAssertEqual(array.element(at: 0, 0, 0), 10)
    XCTAssertEqual(array.element(at: 1, 1, 0), 20)
    XCTAssertEqual(array.element(at: 1, 0, 1), 30)
  }

  func testBareArray4DCoordinateMutation() {
    let array = ElementBuffer4D<Int>(
      repeating: 0,
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2)

    array.setElement(1234, at: 0, 1, 0, 1)

    XCTAssertEqual(array.element(at: 0, 1, 0, 1), 1234)
  }

  // MARK: - Storage position with asymmetric dimensions
  //
  // 正方形・立方体ではstrideの取り違えが隠れるため、各軸の長さを変えて全位置を確かめる。
  // 初期化closureの返り値はstorageへ順に格納されるので、各位置の値はそのまま線形位置になる。

  func testBareArray2DCoordinateAccessReachesEveryPositionWithAsymmetricDimensions() {
    let (width, height) = (3, 2)
    var next = 0
    let array = ElementBuffer2D<Int>(width: width, height: height) {
      defer { next += 1 }
      return next
    }

    for y in 0..<height {
      for x in 0..<width {
        XCTAssertEqual(array.element(at: x, y), y * width + x, "(\(x), \(y))")
      }
    }
  }

  func testBareArray3DCoordinateAccessReachesEveryPositionWithAsymmetricDimensions() {
    let (width, height, depth) = (2, 3, 4)
    var next = 0
    let array = ElementBuffer3D<Int>(width: width, height: height, depth: depth) {
      defer { next += 1 }
      return next
    }

    for z in 0..<depth {
      for y in 0..<height {
        for x in 0..<width {
          XCTAssertEqual(array.element(at: x, y, z), (z * height + y) * width + x, "(\(x), \(y), \(z))")
        }
      }
    }
  }

  /// 4Dの軸は`size0`が最内、`size3`が最外。
  func testBareArray4DCoordinateAccessReachesEveryPositionWithAsymmetricDimensions() {
    let (size0, size1, size2, size3) = (2, 3, 4, 5)
    var next = 0
    let array = ElementBuffer4D<Int>(size0: size0, size1: size1, size2: size2, size3: size3) {
      defer { next += 1 }
      return next
    }

    for w in 0..<size3 {
      for z in 0..<size2 {
        for y in 0..<size1 {
          for x in 0..<size0 {
            XCTAssertEqual(
              array.element(at: x, y, z, w), ((w * size2 + z) * size1 + y) * size0 + x,
              "(\(x), \(y), \(z), \(w))")
          }
        }
      }
    }
  }
}
