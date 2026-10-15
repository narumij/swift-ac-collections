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

  // MARK: - Shared references and returned values (OPT-074 B)

  // A slot owns one strong reference, not the object. The same object stored in two slots, and a
  // reference returned by `element(at:)`, must survive unsetting a slot, `removeAll()`, and the
  // buffer's destruction, and the object is destroyed only when its last reference goes away.
  // A weak reference observes liveness; the buffer's end is fixed with `consume`.

  private func checkSharedReferenceLifetime<B: OptionalBufferProbe<TrackedBox> & ~Copyable>(
    _ makeBuffer: () -> B, shape: [Int], file: StaticString = #filePath, line: UInt = #line
  ) {
    let positions = allCoordinates(shape)
    let p = positions[0]
    let q = positions[positions.count - 1]
    var destroyed: [Int] = []
    weak var weakShared: TrackedBox?
    var fetched: TrackedBox?

    let array = makeBuffer()
    var shared: TrackedBox? = TrackedBox(1) { destroyed.append($0) }
    weakShared = shared
    array.probeSetElement(shared, at: p)
    array.probeSetElement(shared, at: q)
    shared = nil
    XCTAssertNotNil(weakShared, "both slots keep the shared object alive", file: file, line: line)

    array.probeSetElement(nil, at: p)
    XCTAssertTrue(
      array.probeElement(at: q) === weakShared,
      "unsetting one slot leaves the other slot's reference intact", file: file, line: line)
    XCTAssertEqual(destroyed, [], file: file, line: line)

    fetched = array.probeElement(at: q)
    array.removeAll()
    XCTAssertNotNil(weakShared, "a returned reference outlives removeAll()", file: file, line: line)
    XCTAssertEqual(destroyed, [], file: file, line: line)

    array.probeSetElement(fetched, at: p)
    _ = consume array
    XCTAssertEqual(destroyed, [], "a returned reference outlives the buffer", file: file, line: line)
    XCTAssertTrue(fetched === weakShared, file: file, line: line)

    fetched = nil
    XCTAssertEqual(destroyed, [1], "the last reference destroys the object once", file: file, line: line)
    XCTAssertNil(weakShared, file: file, line: line)
  }

  private func checkReturnedValueIsIndependent<B: OptionalBufferProbe<[Int]> & ~Copyable>(
    _ array: borrowing B, shape: [Int], file: StaticString = #filePath, line: UInt = #line
  ) {
    let p = allCoordinates(shape)[0]
    array.probeSetElement([1, 2], at: p)
    let fetched = array.probeElement(at: p)

    array.probeSetElement([9], at: p)
    XCTAssertEqual(fetched, [1, 2], "a later update does not change a returned value", file: file, line: line)
    XCTAssertEqual(array.probeElement(at: p), [9], file: file, line: line)

    array.removeAll()
    XCTAssertEqual(fetched, [1, 2], file: file, line: line)
    XCTAssertNil(array.probeElement(at: p), file: file, line: line)
  }

  func testSharedReferenceLifetime1D() {
    checkSharedReferenceLifetime({ OptionalElementBuffer<TrackedBox>(capacity: 3) }, shape: [3])
  }

  func testSharedReferenceLifetime2D() {
    checkSharedReferenceLifetime(
      { OptionalElementBuffer2D<TrackedBox>(width: 2, height: 3) }, shape: [2, 3])
  }

  func testSharedReferenceLifetime3D() {
    checkSharedReferenceLifetime(
      { OptionalElementBuffer3D<TrackedBox>(width: 2, height: 3, depth: 2) }, shape: [2, 3, 2])
  }

  func testSharedReferenceLifetime4D() {
    checkSharedReferenceLifetime(
      { OptionalElementBuffer4D<TrackedBox>(size0: 2, size1: 1, size2: 3, size3: 2) },
      shape: [2, 1, 3, 2])
  }

  func testReturnedValueIsIndependentOfLaterUpdates() {
    checkReturnedValueIsIndependent(OptionalElementBuffer<[Int]>(capacity: 3), shape: [3])
    checkReturnedValueIsIndependent(
      OptionalElementBuffer2D<[Int]>(width: 2, height: 3), shape: [2, 3])
    checkReturnedValueIsIndependent(
      OptionalElementBuffer3D<[Int]>(width: 2, height: 3, depth: 2), shape: [2, 3, 2])
    checkReturnedValueIsIndependent(
      OptionalElementBuffer4D<[Int]>(size0: 2, size1: 1, size2: 3, size3: 2), shape: [2, 1, 3, 2])
  }
}
