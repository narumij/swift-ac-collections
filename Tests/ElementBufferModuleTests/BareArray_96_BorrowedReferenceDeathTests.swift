#if DEATH_TEST
  import ElementBufferModule
  import Testing

  /// On Swift 6.4 and later, creating a borrowed reference rejects out-of-bounds coordinates on every axis with a Swift precondition trap.
  struct BareArray_96_BorrowedReferenceDeathTests {

    @Test func referenceRejectsInvalidCoordinates1D() async {
      guard #available(macOS 27.0, *) else { return }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference1D(-1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference1D(3)
      }
    }

    @Test func referenceRejectsInvalidCoordinates2D() async {
      guard #available(macOS 27.0, *) else { return }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference2D(-1, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference2D(2, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference2D(0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference2D(0, 3)
      }
    }

    @Test func referenceRejectsInvalidCoordinates3D() async {
      guard #available(macOS 27.0, *) else { return }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference3D(-1, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference3D(2, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference3D(0, -1, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference3D(0, 3, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference3D(0, 0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference3D(0, 0, 4)
      }
    }

    @Test func referenceRejectsInvalidCoordinates4D() async {
      guard #available(macOS 27.0, *) else { return }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference4D(-1, 0, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference4D(2, 0, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference4D(0, -1, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference4D(0, 3, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference4D(0, 0, -1, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference4D(0, 0, 4, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference4D(0, 0, 0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.reference4D(0, 0, 0, 5)
      }
    }

    // BARE-046 D: empty storage has no valid coordinate, even when `indices` is not empty.
    @Test func referenceRejectsCoordinateZeroInEmptyStorage() async {
      guard #available(macOS 27.0, *) else { return }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.referenceInEmpty1D()
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.referenceInEmpty2D()
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.referenceInEmpty3D()
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.referenceInEmpty4D()
      }
    }

    @available(macOS 27.0, *)
    private static func referenceInEmpty1D() {
      var array = ElementBuffer<Int>(repeating: 0, count: 0)
      _ = array.reference(at: 0)
    }

    @available(macOS 27.0, *)
    private static func referenceInEmpty2D() {
      var array = ElementBuffer2D<Int>(repeating: 0, width: 0, height: 3)
      _ = array.reference(at: 0, 0)
    }

    @available(macOS 27.0, *)
    private static func referenceInEmpty3D() {
      var array = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 0, depth: 3)
      _ = array.reference(at: 0, 0, 0)
    }

    @available(macOS 27.0, *)
    private static func referenceInEmpty4D() {
      var array = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 0, size3: 3)
      _ = array.reference(at: 0, 0, 0, 0)
    }

    @available(macOS 27.0, *)
    private static func reference1D(_ position: Int) {
      var array = ElementBuffer<Int>(repeating: 0, count: 3)
      _ = array.reference(at: position)
    }

    @available(macOS 27.0, *)
    private static func reference2D(_ x: Int, _ y: Int) {
      var array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 3)
      _ = array.reference(at: x, y)
    }

    @available(macOS 27.0, *)
    private static func reference3D(_ x: Int, _ y: Int, _ z: Int) {
      var array = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4)
      _ = array.reference(at: x, y, z)
    }

    @available(macOS 27.0, *)
    private static func reference4D(_ x: Int, _ y: Int, _ z: Int, _ w: Int) {
      var array = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5)
      _ = array.reference(at: x, y, z, w)
    }
  }
#endif
