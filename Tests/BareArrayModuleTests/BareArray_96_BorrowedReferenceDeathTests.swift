#if DEATH_TEST
  import BareArrayModule
  import Testing

  /// Swift 6.4以降の借用参照生成は、各軸の範囲外座標をSwift precondition trapで拒否する。
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
