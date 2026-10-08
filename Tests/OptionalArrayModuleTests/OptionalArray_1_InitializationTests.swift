import XCTest
import OptionalArrayModule

final class OptionalArray_1_InitializationTests: XCTestCase {

  // MARK: - OptionalArray1D

  func testOptionalArray1DInitialValuesAreNil() {
    let array = OptionalArray1D<Int>(capacity: 3)

    XCTAssertNil(array[0])
    XCTAssertNil(array[1])
    XCTAssertNil(array[2])
  }

  // MARK: - Dimension contract

  // 次元契約(2026-10-08、OPT-032): 各次元は0以上、全次元の積は`Int`で表現可能であること。
  // zero dimensionは要素を1つも持たない有効な配列として受け入れる。
  // 負値と積のoverflowの停止は`OptionalArrayDeathTests`で固定する。

  func testOptionalArray1DZeroCapacityIsEmpty() {
    let array = OptionalArray1D<Int>(capacity: 0)
    XCTAssertTrue(array.indices.isEmpty)
  }

  func testOptionalArray2DZeroDimensionHasNoElements() {
    let zeroWidth = OptionalArray2D<Int>(width: 0, height: 3)
    XCTAssertEqual(zeroWidth.indices.count, 3)
    for y in zeroWidth.indices {
      XCTAssertTrue(zeroWidth[y].indices.isEmpty)
    }

    let zeroHeight = OptionalArray2D<Int>(width: 3, height: 0)
    XCTAssertTrue(zeroHeight.indices.isEmpty)
  }

  func testOptionalArray3DZeroDimensionHasNoElements() {
    let zeroWidth = OptionalArray3D<Int>(width: 0, height: 2, depth: 2)
    for z in zeroWidth.indices {
      for y in zeroWidth[z].indices {
        XCTAssertTrue(zeroWidth[z][y].indices.isEmpty)
      }
    }

    let zeroHeight = OptionalArray3D<Int>(width: 2, height: 0, depth: 2)
    for z in zeroHeight.indices {
      XCTAssertTrue(zeroHeight[z].indices.isEmpty)
    }

    let zeroDepth = OptionalArray3D<Int>(width: 2, height: 2, depth: 0)
    XCTAssertTrue(zeroDepth.indices.isEmpty)
  }

  func testOptionalArray4DZeroDimensionHasNoElements() {
    let zeroSize0 = OptionalArray4D<Int>(size0: 0, size1: 2, size2: 2, size3: 2)
    for p in zeroSize0.indices {
      for z in zeroSize0[p].indices {
        for y in zeroSize0[p][z].indices {
          XCTAssertTrue(zeroSize0[p][z][y].indices.isEmpty)
        }
      }
    }

    let zeroSize3 = OptionalArray4D<Int>(size0: 2, size1: 2, size2: 2, size3: 0)
    XCTAssertTrue(zeroSize3.indices.isEmpty)
  }

  func testZeroDimensionMakesProductRepresentableEvenWithLargeDimensions() {
    // 1つでも0の次元があれば全次元の積は0で、`Int`で表現できる。
    // 他の次元同士の積がoverflowする大きさでも、有効な空配列として受け入れる。
    let array2D = OptionalArray2D<Int>(width: Int.max, height: 0)
    XCTAssertTrue(array2D.indices.isEmpty)

    let array3D = OptionalArray3D<Int>(width: Int.max, height: 2, depth: 0)
    XCTAssertTrue(array3D.indices.isEmpty)

    let array4D = OptionalArray4D<Int>(size0: Int.max, size1: 2, size2: 0, size3: 1)
    XCTAssertEqual(array4D.indices.count, 1)
  }

  func testOptionalArray4DZeroVolumeOuterSubscriptReachesEmptyViews() {
    // `size3 > 0`で内側のいずれかの軸が0のとき、外側subscriptは有効で、
    // 0の軸に当たるViewまで辿るとindicesが空になる。
    let zeroSize0 = OptionalArray4D<Int>(size0: 0, size1: 2, size2: 2, size3: 1)
    for z in zeroSize0[0].indices {
      for y in zeroSize0[0][z].indices {
        XCTAssertTrue(zeroSize0[0][z][y].indices.isEmpty)
      }
    }

    let zeroSize1 = OptionalArray4D<Int>(size0: 2, size1: 0, size2: 2, size3: 1)
    for z in zeroSize1[0].indices {
      XCTAssertTrue(zeroSize1[0][z].indices.isEmpty)
    }

    let zeroSize2 = OptionalArray4D<Int>(size0: 2, size1: 2, size2: 0, size3: 1)
    XCTAssertTrue(zeroSize2[0].indices.isEmpty)

    // 内側の途中の積(`size0 * size1`)だけがoverflowする形でも、外側subscriptは停止しない。
    let largeZeroVolume = OptionalArray4D<Int>(size0: Int.max, size1: 2, size2: 0, size3: 1)
    XCTAssertTrue(largeZeroVolume[0].indices.isEmpty)
  }
}
