#if DEATH_TEST
  import OptionalElementBufferModule
  import Testing

  /// Coordinate value access rejects negative and upper-bound coordinates on every axis with a normal Swift precondition trap.
  struct OptionalArray_97_CoordinateValueAccessDeathTests {

    // OPT-074 D: a buffer with a zero dimension has no valid coordinate, even when `indices` is not
    // empty. Coordinate zero is rejected for reads, writes, and writes of `nil`, so an
    // implementation cannot return "unset" for an out-of-range read or skip the check for `nil`.

    @Test func emptyBufferRejectsCoordinateZero1D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer<Int>(capacity: 0).element(at: 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer<Int>(capacity: 0); array.setElement(1, at: 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer<Int>(capacity: 0); array.setElement(nil, at: 0) }
    }

    @Test func emptyBufferRejectsCoordinateZero2D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer2D<Int>(width: 0, height: 3).element(at: 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer2D<Int>(width: 0, height: 3); array.setElement(1, at: 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer2D<Int>(width: 0, height: 3); array.setElement(nil, at: 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer2D<Int>(width: 2, height: 0).element(at: 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer2D<Int>(width: 2, height: 0); array.setElement(1, at: 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer2D<Int>(width: 2, height: 0); array.setElement(nil, at: 0, 0) }
    }

    @Test func emptyBufferRejectsCoordinateZero3D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer3D<Int>(width: 0, height: 2, depth: 3).element(at: 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer3D<Int>(width: 0, height: 2, depth: 3); array.setElement(1, at: 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer3D<Int>(width: 0, height: 2, depth: 3); array.setElement(nil, at: 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer3D<Int>(width: 2, height: 0, depth: 3).element(at: 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer3D<Int>(width: 2, height: 0, depth: 3); array.setElement(1, at: 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer3D<Int>(width: 2, height: 0, depth: 3); array.setElement(nil, at: 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer3D<Int>(width: 2, height: 2, depth: 0).element(at: 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer3D<Int>(width: 2, height: 2, depth: 0); array.setElement(1, at: 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer3D<Int>(width: 2, height: 2, depth: 0); array.setElement(nil, at: 0, 0, 0) }
    }

    @Test func emptyBufferRejectsCoordinateZero4D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer4D<Int>(size0: 0, size1: 2, size2: 2, size3: 3).element(at: 0, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 0, size1: 2, size2: 2, size3: 3); array.setElement(1, at: 0, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 0, size1: 2, size2: 2, size3: 3); array.setElement(nil, at: 0, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer4D<Int>(size0: 2, size1: 0, size2: 2, size3: 3).element(at: 0, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 0, size2: 2, size3: 3); array.setElement(1, at: 0, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 0, size2: 2, size3: 3); array.setElement(nil, at: 0, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer4D<Int>(size0: 2, size1: 2, size2: 0, size3: 3).element(at: 0, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 2, size2: 0, size3: 3); array.setElement(1, at: 0, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 2, size2: 0, size3: 3); array.setElement(nil, at: 0, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer4D<Int>(size0: 2, size1: 2, size2: 2, size3: 0).element(at: 0, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 2, size2: 2, size3: 0); array.setElement(1, at: 0, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 2, size2: 2, size3: 0); array.setElement(nil, at: 0, 0, 0, 0) }
    }

    @Test func elementAtRejectsInvalidCoordinates1D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer<Int>(capacity: 3).element(at: -1) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer<Int>(capacity: 3).element(at: 3) }
    }

    @Test func setElementRejectsInvalidCoordinates1D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer<Int>(capacity: 3); array.setElement(1, at: -1) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer<Int>(capacity: 3); array.setElement(1, at: 3) }
    }

    @Test func elementAtRejectsInvalidCoordinates2D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer2D<Int>(width: 2, height: 3).element(at: -1, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer2D<Int>(width: 2, height: 3).element(at: 2, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer2D<Int>(width: 2, height: 3).element(at: 0, -1) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer2D<Int>(width: 2, height: 3).element(at: 0, 3) }
    }

    @Test func setElementRejectsInvalidCoordinates2D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer2D<Int>(width: 2, height: 3); array.setElement(1, at: -1, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer2D<Int>(width: 2, height: 3); array.setElement(1, at: 2, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer2D<Int>(width: 2, height: 3); array.setElement(1, at: 0, -1) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer2D<Int>(width: 2, height: 3); array.setElement(1, at: 0, 3) }
    }

    @Test func elementAtRejectsInvalidCoordinates3D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4).element(at: -1, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4).element(at: 2, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4).element(at: 0, -1, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4).element(at: 0, 3, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4).element(at: 0, 0, -1) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4).element(at: 0, 0, 4) }
    }

    @Test func setElementRejectsInvalidCoordinates3D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4); array.setElement(1, at: -1, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4); array.setElement(1, at: 2, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4); array.setElement(1, at: 0, -1, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4); array.setElement(1, at: 0, 3, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4); array.setElement(1, at: 0, 0, -1) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4); array.setElement(1, at: 0, 0, 4) }
    }

    @Test func elementAtRejectsInvalidCoordinates4D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5).element(at: -1, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5).element(at: 2, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5).element(at: 0, -1, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5).element(at: 0, 3, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5).element(at: 0, 0, -1, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5).element(at: 0, 0, 4, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5).element(at: 0, 0, 0, -1) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { _ = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5).element(at: 0, 0, 0, 5) }
    }

    @Test func setElementRejectsInvalidCoordinates4D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5); array.setElement(1, at: -1, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5); array.setElement(1, at: 2, 0, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5); array.setElement(1, at: 0, -1, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5); array.setElement(1, at: 0, 3, 0, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5); array.setElement(1, at: 0, 0, -1, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5); array.setElement(1, at: 0, 0, 4, 0) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5); array.setElement(1, at: 0, 0, 0, -1) }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) { let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5); array.setElement(1, at: 0, 0, 0, 5) }
    }
  }
#endif
