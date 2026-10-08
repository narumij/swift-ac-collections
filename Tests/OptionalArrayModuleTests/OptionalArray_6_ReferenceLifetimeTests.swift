import XCTest
import OptionalArrayModule

final class OptionalArray_6_ReferenceLifetimeTests: XCTestCase {

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
}
