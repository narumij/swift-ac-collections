import BareArrayModule
import XCTest

/// View: 所有型の外側subscriptが返すViewは要素を所有せず、所有者のstorageの一部を直接読み書きする。
/// Viewのoffsetとstrideは、外側subscriptの位置と所有者の寸法から決まる。
final class BareArray_3_ViewTests: XCTestCase {

  // MARK: - Shared storage

  func testBareArray1DViewWritesReflectInOwnerStorage() {
    let array = BareArray2D<Int>(
      repeating: 0,
      width: 2,
      height: 2)

    var row = array[1]
    row[0] = 123

    // 標準ではこの挙動は許容できないのだとおもう。
    XCTAssertEqual(array[1][0], 123)
  }

  func testBareArray2DViewWritesReflectInOwnerStorage() {
    let array = BareArray3D<Int>(
      repeating: 0,
      width: 2,
      height: 2,
      depth: 2)

    var plane = array[1]
    plane[0][1] = 999

    XCTAssertEqual(array[1][0][1], 999)
  }

  func testBareArray3DViewWritesReflectInOwnerStorage() {
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

  // MARK: - Offset and stride with asymmetric dimensions

  func testBareArray2DViewOffsetAndSharingWithAsymmetricDimensions() {
    let (width, height, depth) = (2, 3, 4)
    var next = 0
    let array = BareArray3D<Int>(width: width, height: height, depth: depth) {
      defer { next += 1 }
      return next
    }

    for z in 0..<depth {
      var plane = array[z]
      for y in 0..<height {
        for x in 0..<width {
          let linear = (z * height + y) * width + x
          XCTAssertEqual(plane[y][x], linear, "plane \(z) [\(y)][\(x)]")
          plane[y][x] = -linear - 1
        }
      }
    }

    // View経由の書き込みが、各面の外へはみ出さず元のstorageへ反映されていること
    for z in 0..<depth {
      for y in 0..<height {
        for x in 0..<width {
          XCTAssertEqual(array[z][y][x], -((z * height + y) * width + x) - 1, "[\(z)][\(y)][\(x)]")
        }
      }
    }
  }

  func testBareArray3DViewOffsetAndSharingWithAsymmetricDimensions() {
    let (size0, size1, size2, size3) = (2, 3, 4, 5)
    var next = 0
    let array = BareArray4D<Int>(size0: size0, size1: size1, size2: size2, size3: size3) {
      defer { next += 1 }
      return next
    }

    for w in 0..<size3 {
      var cube = array[w]
      for z in 0..<size2 {
        for y in 0..<size1 {
          for x in 0..<size0 {
            let linear = ((w * size2 + z) * size1 + y) * size0 + x
            XCTAssertEqual(cube[z][y][x], linear, "cube \(w) [\(z)][\(y)][\(x)]")
            cube[z][y][x] = -linear - 1
          }
        }
      }
    }

    // View経由の書き込みが、各立方体の外へはみ出さず元のstorageへ反映されていること
    for w in 0..<size3 {
      for z in 0..<size2 {
        for y in 0..<size1 {
          for x in 0..<size0 {
            XCTAssertEqual(
              array[w][z][y][x], -(((w * size2 + z) * size1 + y) * size0 + x) - 1,
              "[\(w)][\(z)][\(y)][\(x)]")
          }
        }
      }
    }
  }
}
