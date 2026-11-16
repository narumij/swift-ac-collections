import XCTest
import OptionalElementBufferModule

final class OptionalArray_1_InitializationTests: XCTestCase {

  // MARK: - OptionalElementBuffer

  func testOptionalArray1DInitialValuesAreNil() {
    let array = OptionalElementBuffer<Int>(capacity: 3)

    XCTAssertNil(array.element(at: 0))
    XCTAssertNil(array.element(at: 1))
    XCTAssertNil(array.element(at: 2))
  }

  // MARK: - Dimension contract

  // 次元契約(2026-10-08、OPT-032): 各次元は0以上、全次元の積は`Int`で表現可能であること。
  // zero dimensionは要素を1つも持たない有効な配列として受け入れる。
  // 負値と積のoverflowの停止は`OptionalArrayDeathTests`で固定する。

  func testOptionalArray1DZeroCapacityIsEmpty() {
    let array = OptionalElementBuffer<Int>(capacity: 0)
    XCTAssertTrue(array.indices.isEmpty)
  }

  func testOptionalArray2DZeroDimensionHasNoElements() {
    let zeroWidth = OptionalElementBuffer2D<Int>(width: 0, height: 3)
    XCTAssertEqual(zeroWidth.indices.count, 3)

    let zeroHeight = OptionalElementBuffer2D<Int>(width: 3, height: 0)
    XCTAssertTrue(zeroHeight.indices.isEmpty)
  }

  func testOptionalArray3DZeroDimensionHasNoElements() {
    let zeroWidth = OptionalElementBuffer3D<Int>(width: 0, height: 2, depth: 2)
    XCTAssertEqual(zeroWidth.indices.count, 2)

    let zeroHeight = OptionalElementBuffer3D<Int>(width: 2, height: 0, depth: 2)
    XCTAssertEqual(zeroHeight.indices.count, 2)

    let zeroDepth = OptionalElementBuffer3D<Int>(width: 2, height: 2, depth: 0)
    XCTAssertTrue(zeroDepth.indices.isEmpty)
  }

  func testOptionalArray4DZeroDimensionHasNoElements() {
    let zeroSize0 = OptionalElementBuffer4D<Int>(size0: 0, size1: 2, size2: 2, size3: 2)
    XCTAssertEqual(zeroSize0.indices.count, 2)

    let zeroSize3 = OptionalElementBuffer4D<Int>(size0: 2, size1: 2, size2: 2, size3: 0)
    XCTAssertTrue(zeroSize3.indices.isEmpty)
  }

  func testZeroDimensionMakesProductRepresentableEvenWithLargeDimensions() {
    // 1つでも0の次元があれば全次元の積は0で、`Int`で表現できる。
    // 他の次元同士の積がoverflowする大きさでも、有効な空配列として受け入れる。
    let array2D = OptionalElementBuffer2D<Int>(width: Int.max, height: 0)
    XCTAssertTrue(array2D.indices.isEmpty)

    let array3D = OptionalElementBuffer3D<Int>(width: Int.max, height: 2, depth: 0)
    XCTAssertTrue(array3D.indices.isEmpty)

    let array4D = OptionalElementBuffer4D<Int>(size0: Int.max, size1: 2, size2: 0, size3: 1)
    XCTAssertEqual(array4D.indices.count, 1)
  }

  func testOptionalArray4DZeroVolumeConstructionPreservesOuterShape() {
    // `size3 > 0`で内側のいずれかの軸が0でも、有効な空配列として構築できる。
    let zeroSize0 = OptionalElementBuffer4D<Int>(size0: 0, size1: 2, size2: 2, size3: 1)
    XCTAssertEqual(zeroSize0.indices.count, 1)

    let zeroSize1 = OptionalElementBuffer4D<Int>(size0: 2, size1: 0, size2: 2, size3: 1)
    XCTAssertEqual(zeroSize1.indices.count, 1)

    let zeroSize2 = OptionalElementBuffer4D<Int>(size0: 2, size1: 2, size2: 0, size3: 1)
    XCTAssertEqual(zeroSize2.indices.count, 1)

    // 内側の途中の積(`size0 * size1`)だけがoverflowする形でも、構築は停止しない。
    let largeZeroVolume = OptionalElementBuffer4D<Int>(size0: Int.max, size1: 2, size2: 0, size3: 1)
    XCTAssertEqual(largeZeroVolume.indices.count, 1)
  }
}
