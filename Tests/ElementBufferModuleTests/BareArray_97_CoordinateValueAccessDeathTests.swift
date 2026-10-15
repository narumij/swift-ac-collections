#if DEATH_TEST
  import ElementBufferModule
  import Testing

  /// Coordinate value access rejects negative and upper-bound coordinates on every axis with a normal Swift precondition trap.
  struct BareArray_97_CoordinateValueAccessDeathTests {

    @Test func elementAtRejectsInvalidCoordinates1D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer<Int>(repeating: 0, count: 3).element(at: -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer<Int>(repeating: 0, count: 3).element(at: 3)
      }
    }

    @Test func setElementRejectsInvalidCoordinates1D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer<Int>(repeating: 0, count: 3).setElement(1, at: -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer<Int>(repeating: 0, count: 3).setElement(1, at: 3)
      }
    }

    @Test func elementAtRejectsInvalidCoordinates2D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 3).element(at: -1, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 3).element(at: 2, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 3).element(at: 0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 3).element(at: 0, 3)
      }
    }

    @Test func setElementRejectsInvalidCoordinates2D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer2D<Int>(repeating: 0, width: 2, height: 3).setElement(1, at: -1, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer2D<Int>(repeating: 0, width: 2, height: 3).setElement(1, at: 2, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer2D<Int>(repeating: 0, width: 2, height: 3).setElement(1, at: 0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer2D<Int>(repeating: 0, width: 2, height: 3).setElement(1, at: 0, 3)
      }
    }

    @Test func elementAtRejectsInvalidCoordinates3D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).element(at: -1, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).element(at: 2, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).element(at: 0, -1, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).element(at: 0, 3, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).element(at: 0, 0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).element(at: 0, 0, 4)
      }
    }

    @Test func setElementRejectsInvalidCoordinates3D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).setElement(1, at: -1, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).setElement(1, at: 2, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).setElement(1, at: 0, -1, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).setElement(1, at: 0, 3, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).setElement(1, at: 0, 0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).setElement(1, at: 0, 0, 4)
      }
    }

    @Test func elementAtRejectsInvalidCoordinates4D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).element(at: -1, 0, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).element(at: 2, 0, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).element(at: 0, -1, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).element(at: 0, 3, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).element(at: 0, 0, -1, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).element(at: 0, 0, 4, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).element(at: 0, 0, 0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).element(at: 0, 0, 0, 5)
      }
    }

    @Test func setElementRejectsInvalidCoordinates4D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).setElement(1, at: -1, 0, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).setElement(1, at: 2, 0, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).setElement(1, at: 0, -1, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).setElement(1, at: 0, 3, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).setElement(1, at: 0, 0, -1, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).setElement(1, at: 0, 0, 4, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).setElement(1, at: 0, 0, 0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).setElement(1, at: 0, 0, 0, 5)
      }
    }
  }
#endif
