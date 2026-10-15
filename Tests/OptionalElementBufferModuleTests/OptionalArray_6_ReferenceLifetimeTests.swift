import XCTest
import OptionalElementBufferModule

final class OptionalArray_6_ReferenceLifetimeTests: XCTestCase {

  // MARK: - Reference element lifetime

  func testOptionalArray1DOverwriteDeinitializesPreviousReferenceElement() {
    final class Box {
      let onDeinit: () -> Void
      init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
      deinit { onDeinit() }
    }

    var deinitCount = 0
    let array = OptionalElementBuffer<Box>(capacity: 1)

    array.setElement(Box({ deinitCount += 1 }), at: 0)
    XCTAssertEqual(deinitCount, 0)

    array.setElement(Box({ deinitCount += 1 }), at: 0)
    XCTAssertEqual(deinitCount, 1, "nilを経由せず上書きしても古い要素がdeinitされること")

    array.setElement(nil, at: 0)
    XCTAssertEqual(deinitCount, 2, "nil代入でも要素がdeinitされること")

    array.setElement(Box({ deinitCount += 1 }), at: 0)
    array.removeAll()
    XCTAssertEqual(deinitCount, 3, "removeAllで保持中の要素がdeinitされること")
  }

  /// The `removeAll()` and `deinit` implementations of `OptionalElementBuffer2D`, `3D`, and `4D` use code separate from 1D
  /// (although each loops `capacity` times), so test them separately with reference-type elements.
  func testOptionalArray2DRemoveAllDeinitializesReferenceElements() {
    final class Box {
      let onDeinit: () -> Void
      init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
      deinit { onDeinit() }
    }

    var deinitCount = 0
    do {
      let array = OptionalElementBuffer2D<Box>(width: 2, height: 2)
      array.setElement(Box({ deinitCount += 1 }), at: 0, 0)
      array.setElement(Box({ deinitCount += 1 }), at: 1, 1)
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
      let array = OptionalElementBuffer3D<Box>(width: 2, height: 2, depth: 2)
      array.setElement(Box({ deinitCount += 1 }), at: 0, 0, 0)
      array.setElement(Box({ deinitCount += 1 }), at: 1, 1, 1)
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
      let array = OptionalElementBuffer2D<Box>(width: 2, height: 2)
      array.setElement(Box({ deinitCount += 1 }), at: 0, 0)
      array.setElement(Box({ deinitCount += 1 }), at: 1, 1)
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
      let array = OptionalElementBuffer4D<Box>(size0: 2, size1: 2, size2: 2, size3: 2)
      array.setElement(Box({ deinitCount += 1 }), at: 0, 0, 0, 0)
      array.setElement(Box({ deinitCount += 1 }), at: 1, 1, 1, 1)
      XCTAssertEqual(deinitCount, 0)
    }
    XCTAssertEqual(deinitCount, 2, "スコープを抜けてarrayがdeinitされると、未removeAllの要素も解放されること")
  }

  /// Verifies that slots can be reused after `removeAll()` and that a newly set element is released exactly once by the owning array's deinitializer,
  /// without double-releasing elements already released by `removeAll()`.
  func testOptionalArray3DRemoveAllReleasesReferenceElementsAndSlotsAreReusable() {
    final class Box {
      let onDeinit: () -> Void
      init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
      deinit { onDeinit() }
    }

    var deinitCount = 0
    do {
      let array = OptionalElementBuffer3D<Box>(width: 2, height: 2, depth: 2)
      array.setElement(Box({ deinitCount += 1 }), at: 0, 0, 0)
      array.setElement(Box({ deinitCount += 1 }), at: 1, 1, 1)
      array.removeAll()
      XCTAssertEqual(deinitCount, 2, "removeAllで設定済みの全要素がdeinitされること")
      XCTAssertNil(array.element(at: 0, 0, 0))
      XCTAssertNil(array.element(at: 1, 1, 1))

      let reused = Box({ deinitCount += 1 })
      array.setElement(reused, at: 1, 1, 1)
      XCTAssertTrue(array.element(at: 1, 1, 1) === reused, "removeAll後のスロットへ再設定できること")
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
      let array = OptionalElementBuffer4D<Box>(size0: 2, size1: 2, size2: 2, size3: 2)
      array.setElement(Box({ deinitCount += 1 }), at: 0, 0, 0, 0)
      array.setElement(Box({ deinitCount += 1 }), at: 1, 1, 1, 1)
      array.removeAll()
      XCTAssertEqual(deinitCount, 2, "removeAllで設定済みの全要素がdeinitされること")
      XCTAssertNil(array.element(at: 0, 0, 0, 0))
      XCTAssertNil(array.element(at: 1, 1, 1, 1))

      let reused = Box({ deinitCount += 1 })
      array.setElement(reused, at: 1, 1, 1, 1)
      XCTAssertTrue(array.element(at: 1, 1, 1, 1) === reused, "removeAll後のスロットへ再設定できること")
      XCTAssertEqual(deinitCount, 2)
    }
    XCTAssertEqual(deinitCount, 3, "deinitでは再設定した要素だけが1回解放されること")
  }
}
