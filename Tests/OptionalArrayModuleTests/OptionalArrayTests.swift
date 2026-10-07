import XCTest
import OptionalArrayModule

final class OptionalArrayTests: XCTestCase {

  // MARK: - OptionalArray1D

  func testOptionalArray1DInitialValuesAreNil() {
    let array = OptionalArray1D<Int>(capacity: 3)

    XCTAssertNil(array[0])
    XCTAssertNil(array[1])
    XCTAssertNil(array[2])
  }

  func testOptionalArray1DSetAndGet() {
    var array = OptionalArray1D<Int>(capacity: 3)

    array[0] = 10
    array[2] = 30

    XCTAssertEqual(array[0], 10)
    XCTAssertNil(array[1])
    XCTAssertEqual(array[2], 30)
  }

  func testOptionalArray1DAssignNil() {
    var array = OptionalArray1D<Int>(capacity: 3)

    array[1] = 123
    XCTAssertEqual(array[1], 123)

    array[1] = nil
    XCTAssertNil(array[1])
  }

  func testOptionalArray1DRemoveAll() {
    var array = OptionalArray1D<Int>(capacity: 3)

    array[0] = 1
    array[1] = 2
    array[2] = 3

    array.removeAll()

    XCTAssertNil(array[0])
    XCTAssertNil(array[1])
    XCTAssertNil(array[2])
  }

  func testOptionalArray1DIndices() {
    let array = OptionalArray1D<Int>(capacity: 4)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3])
  }

  // MARK: - OptionalArray2D

  func testOptionalArray2DSetAndGet() {
    var array = OptionalArray2D<Int>(
      width: 2,
      height: 2)

    array[0][0] = 10
    array[1][1] = 20

    XCTAssertEqual(array[0][0], 10)
    XCTAssertEqual(array[1][1], 20)
    XCTAssertNil(array[0][1])
  }

  func testOptionalArray2DRemoveAll() {
    var array = OptionalArray2D<Int>(
      width: 2,
      height: 2)

    array[0][0] = 1
    array[1][1] = 2

    array.removeAll()

    XCTAssertNil(array[0][0])
    XCTAssertNil(array[1][1])
  }

  func testOptionalArray2DViewSharesStorage() {
    let array = OptionalArray2D<Int>(
      width: 2,
      height: 2)

    var row = array[1]
    row[0] = 123

    XCTAssertEqual(array[1][0], 123)
  }

  func testOptionalArray2DIndices() {
    let array = OptionalArray2D<Int>(
      width: 2,
      height: 4)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3])
  }

  // MARK: - OptionalArray3D

  func testOptionalArray3DSetAndGet() {
    var array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    array[1][0][1] = 999

    XCTAssertEqual(array[1][0][1], 999)
    XCTAssertNil(array[0][0][0])
  }

  func testOptionalArray3DRemoveAll() {
    var array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    array[1][0][1] = 999

    array.removeAll()

    XCTAssertNil(array[1][0][1])
  }

  func testOptionalArray3DViewSharesStorage() {
    let array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    var plane = array[1]
    plane[0][1] = 555

    XCTAssertEqual(array[1][0][1], 555)
  }

  func testOptionalArray3DIndices() {
    let array = OptionalArray3D<Int>(
      width: 2,
      height: 2,
      depth: 3)

    XCTAssertEqual(Array(array.indices), [0, 1, 2])
  }

  // MARK: - OptionalArray4D

  func testOptionalArray4DSetAndGet() {
    var array = OptionalArray4D<Int>(
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2)

    array[1][0][1][0] = 1234

    XCTAssertEqual(array[1][0][1][0], 1234)
    XCTAssertNil(array[0][0][0][0])
  }

  func testOptionalArray4DRemoveAll() {
    var array = OptionalArray4D<Int>(
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2)

    array[1][0][1][0] = 1234

    array.removeAll()

    XCTAssertNil(array[1][0][1][0])
  }

  func testOptionalArray4DViewSharesStorage() {
    let array = OptionalArray4D<Int>(
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2)

    var cube = array[1]
    cube[1][1][1] = 777

    XCTAssertEqual(array[1][1][1][1], 777)
  }

  func testOptionalArray4DViewUsesDepthAsItsOuterBound() {
    var array = OptionalArray4D<Int>(
      size0: 1,
      size1: 1,
      size2: 3,
      size3: 1)

    array[0][2][0][0] = 42

    XCTAssertEqual(array[0][2][0][0], 42)
    XCTAssertEqual(Array(array[0].indices), [0, 1, 2])
  }

  func testOptionalArray4DViewUsesFullPlaneStride() {
    var array = OptionalArray4D<Int>(
      size0: 2,
      size1: 3,
      size2: 2,
      size3: 1)

    array[0][1][0][0] = 42

    XCTAssertEqual(array[0][1][0][0], 42)
    XCTAssertNil(array[0][0][1][0])
  }

  func testOptionalArray4DIndices() {
    let array = OptionalArray4D<Int>(
      size0: 1,
      size1: 1,
      size2: 1,
      size3: 4)

    XCTAssertEqual(Array(array.indices), [0, 1, 2, 3])
  }

  // MARK: - View Indices

  func testViewIndices() {
    let array2d = OptionalArray2D<Int>(
      width: 3,
      height: 2)

    XCTAssertEqual(
      Array(array2d[0].indices),
      [0, 1, 2])

    let array3d = OptionalArray3D<Int>(
      width: 2,
      height: 3,
      depth: 4)

    XCTAssertEqual(
      Array(array3d[0].indices),
      [0, 1, 2])

    XCTAssertEqual(
      Array(array3d[0][0].indices),
      [0, 1])

    let array4d = OptionalArray4D<Int>(
      size0: 2,
      size1: 3,
      size2: 4,
      size3: 5)

    XCTAssertEqual(
      Array(array4d[0].indices),
      [0, 1, 2, 3])

    XCTAssertEqual(
      Array(array4d[0][0].indices),
      [0, 1, 2])

    XCTAssertEqual(
      Array(array4d[0][0][0].indices),
      [0, 1])
  }

  // MARK: - Sendable

  #if swift(>=5.5)
    func testSendable_compiles() {
      func requiresSendable<T: Sendable & ~Copyable>(_ value: borrowing T) {}
      let array = OptionalArray1D<Int>(capacity: 1)
      requiresSendable(array)
    }
  #endif

  // MARK: - Reference element lifetime

  func testOptionalArray1DOverwriteDeinitializesPreviousReferenceElement() {
    final class Box {
      let onDeinit: () -> Void
      init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
      deinit { onDeinit() }
    }

    var deinitCount = 0
    var array = OptionalArray1D<Box>(capacity: 1)

    array[0] = Box({ deinitCount += 1 })
    XCTAssertEqual(deinitCount, 0)

    array[0] = Box({ deinitCount += 1 })
    XCTAssertEqual(deinitCount, 1, "nilを経由せず上書きしても古い要素がdeinitされること")

    array[0] = nil
    XCTAssertEqual(deinitCount, 2, "nil代入でも要素がdeinitされること")

    array[0] = Box({ deinitCount += 1 })
    array.removeAll()
    XCTAssertEqual(deinitCount, 3, "removeAllで保持中の要素がdeinitされること")
  }

  /// `OptionalArray1DView`の`subscript`は`OptionalArray1D`と別実装(同じ`.move()`パターン)
  /// のため、View経由でも同じライフタイム契約が成り立つことを個別に検証する。
  func testOptionalArray1DViewOverwriteDeinitializesPreviousReferenceElement() {
    final class Box {
      let onDeinit: () -> Void
      init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
      deinit { onDeinit() }
    }

    var deinitCount = 0
    var array = OptionalArray2D<Box>(width: 1, height: 1)
    var row = array[0]

    row[0] = Box({ deinitCount += 1 })
    XCTAssertEqual(deinitCount, 0)

    row[0] = Box({ deinitCount += 1 })
    XCTAssertEqual(deinitCount, 1, "View経由の上書きでも古い要素がdeinitされること")

    row[0] = nil
    XCTAssertEqual(deinitCount, 2, "View経由のnil代入でも要素がdeinitされること")

    row[0] = Box({ deinitCount += 1 })
    array.removeAll()
    XCTAssertEqual(deinitCount, 3, "親配列のremoveAllで、View経由で設定した要素もdeinitされること")
  }

  /// `OptionalArray2D`/`3D`/`4D`自身の`removeAll()`/`deinit`は、1Dとは別のコード
  /// (同じ`capacity`回ループする構築)のため、参照型要素での検証を個別に行う。
  func testOptionalArray2DRemoveAllDeinitializesReferenceElements() {
    final class Box {
      let onDeinit: () -> Void
      init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
      deinit { onDeinit() }
    }

    var deinitCount = 0
    do {
      var array = OptionalArray2D<Box>(width: 2, height: 2)
      array[0][0] = Box({ deinitCount += 1 })
      array[1][1] = Box({ deinitCount += 1 })
      array.removeAll()
      XCTAssertEqual(deinitCount, 2, "removeAllで設定済みの全要素がdeinitされること")
    }
    XCTAssertEqual(deinitCount, 2, "removeAll後は空なので、deinit自体で追加解放は発生しないこと")
  }

  func testOptionalArray3DDeinitReleasesRemainingReferenceElementsExactlyOnce() {
    final class Box {
      let onDeinit: () -> Void
      init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
      deinit { onDeinit() }
    }

    var deinitCount = 0
    do {
      var array = OptionalArray3D<Box>(width: 2, height: 2, depth: 2)
      array[0][0][0] = Box({ deinitCount += 1 })
      array[1][1][1] = Box({ deinitCount += 1 })
      XCTAssertEqual(deinitCount, 0)
    }
    XCTAssertEqual(deinitCount, 2, "スコープを抜けてarrayがdeinitされると、未removeAllの要素も解放されること")
  }

  func testOptionalArray2DDeinitReleasesRemainingReferenceElementsExactlyOnce() {
    final class Box {
      let onDeinit: () -> Void
      init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
      deinit { onDeinit() }
    }

    var deinitCount = 0
    do {
      var array = OptionalArray2D<Box>(width: 2, height: 2)
      array[0][0] = Box({ deinitCount += 1 })
      array[1][1] = Box({ deinitCount += 1 })
      XCTAssertEqual(deinitCount, 0)
    }
    XCTAssertEqual(deinitCount, 2, "スコープを抜けてarrayがdeinitされると、未removeAllの要素も解放されること")
  }

  func testOptionalArray4DDeinitReleasesRemainingReferenceElementsExactlyOnce() {
    final class Box {
      let onDeinit: () -> Void
      init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
      deinit { onDeinit() }
    }

    var deinitCount = 0
    do {
      var array = OptionalArray4D<Box>(size0: 2, size1: 2, size2: 2, size3: 2)
      array[0][0][0][0] = Box({ deinitCount += 1 })
      array[1][1][1][1] = Box({ deinitCount += 1 })
      XCTAssertEqual(deinitCount, 0)
    }
    XCTAssertEqual(deinitCount, 2, "スコープを抜けてarrayがdeinitされると、未removeAllの要素も解放されること")
  }

  /// `removeAll()`後のスロットが再利用でき、再設定した要素は所有配列のdeinitで
  /// 1回だけ解放されること(`removeAll`で解放済みの要素は二重解放されないこと)を検証する。
  func testOptionalArray3DRemoveAllReleasesReferenceElementsAndSlotsAreReusable() {
    final class Box {
      let onDeinit: () -> Void
      init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
      deinit { onDeinit() }
    }

    var deinitCount = 0
    do {
      var array = OptionalArray3D<Box>(width: 2, height: 2, depth: 2)
      array[0][0][0] = Box({ deinitCount += 1 })
      array[1][1][1] = Box({ deinitCount += 1 })
      array.removeAll()
      XCTAssertEqual(deinitCount, 2, "removeAllで設定済みの全要素がdeinitされること")
      XCTAssertNil(array[0][0][0])
      XCTAssertNil(array[1][1][1])

      let reused = Box({ deinitCount += 1 })
      array[1][1][1] = reused
      XCTAssertTrue(array[1][1][1] === reused, "removeAll後のスロットへ再設定できること")
      XCTAssertEqual(deinitCount, 2)
    }
    XCTAssertEqual(deinitCount, 3, "deinitでは再設定した要素だけが1回解放されること")
  }

  func testOptionalArray4DRemoveAllReleasesReferenceElementsAndSlotsAreReusable() {
    final class Box {
      let onDeinit: () -> Void
      init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
      deinit { onDeinit() }
    }

    var deinitCount = 0
    do {
      var array = OptionalArray4D<Box>(size0: 2, size1: 2, size2: 2, size3: 2)
      array[0][0][0][0] = Box({ deinitCount += 1 })
      array[1][1][1][1] = Box({ deinitCount += 1 })
      array.removeAll()
      XCTAssertEqual(deinitCount, 2, "removeAllで設定済みの全要素がdeinitされること")
      XCTAssertNil(array[0][0][0][0])
      XCTAssertNil(array[1][1][1][1])

      let reused = Box({ deinitCount += 1 })
      array[1][1][1][1] = reused
      XCTAssertTrue(array[1][1][1][1] === reused, "removeAll後のスロットへ再設定できること")
      XCTAssertEqual(deinitCount, 2)
    }
    XCTAssertEqual(deinitCount, 3, "deinitでは再設定した要素だけが1回解放されること")
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
