import BareArrayModule
import XCTest

/// 要素subscript: 所有型は外側の軸から順に選び、連鎖subscriptで要素を読み書きする。
/// 連鎖書き込みは外側subscriptのwriteback（同一Viewの書き戻し）を通って成立する。
final class BareArray_2_ElementAccessTests: XCTestCase {

  // MARK: - Mutation

  func testBareArrayMutation() {
    var array = BareArray<Int>(repeating: 0, count: 3)

    array[0] = 10
    array[1] = 20
    array[2] = 30

    XCTAssertEqual(array[0], 10)
    XCTAssertEqual(array[1], 20)
    XCTAssertEqual(array[2], 30)
  }

  func testBareArray2DChainedMutation() {
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

  func testBareArray3DChainedMutation() {
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

  func testBareArray4DChainedMutation() {
    var array = BareArray4D<Int>(
      repeating: 0,
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2)

    array[1][0][1][0] = 1234

    XCTAssertEqual(array[1][0][1][0], 1234)
  }

  // MARK: - Storage position with asymmetric dimensions
  //
  // 正方形・立方体ではstrideの取り違えが隠れるため、各軸の長さを変えて全位置を確かめる。
  // 初期化closureの返り値はstorageへ順に格納されるので、各位置の値はそのまま線形位置になる。

  func testBareArray2DChainedSubscriptReachesEveryPositionWithAsymmetricDimensions() {
    let (width, height) = (3, 2)
    var next = 0
    let array = BareArray2D<Int>(width: width, height: height) {
      defer { next += 1 }
      return next
    }

    for y in 0..<height {
      for x in 0..<width {
        XCTAssertEqual(array[y][x], y * width + x, "[\(y)][\(x)]")
      }
    }
  }

  func testBareArray3DChainedSubscriptReachesEveryPositionWithAsymmetricDimensions() {
    let (width, height, depth) = (2, 3, 4)
    var next = 0
    let array = BareArray3D<Int>(width: width, height: height, depth: depth) {
      defer { next += 1 }
      return next
    }

    for z in 0..<depth {
      for y in 0..<height {
        for x in 0..<width {
          XCTAssertEqual(array[z][y][x], (z * height + y) * width + x, "[\(z)][\(y)][\(x)]")
        }
      }
    }
  }

  /// 4Dの軸は`size0`が最内（最後のsubscript）、`size3`が最外（最初のsubscript）。
  func testBareArray4DChainedSubscriptReachesEveryPositionWithAsymmetricDimensions() {
    let (size0, size1, size2, size3) = (2, 3, 4, 5)
    var next = 0
    let array = BareArray4D<Int>(size0: size0, size1: size1, size2: size2, size3: size3) {
      defer { next += 1 }
      return next
    }

    for w in 0..<size3 {
      for z in 0..<size2 {
        for y in 0..<size1 {
          for x in 0..<size0 {
            XCTAssertEqual(
              array[w][z][y][x], ((w * size2 + z) * size1 + y) * size0 + x,
              "[\(w)][\(z)][\(y)][\(x)]")
          }
        }
      }
    }
  }
}
