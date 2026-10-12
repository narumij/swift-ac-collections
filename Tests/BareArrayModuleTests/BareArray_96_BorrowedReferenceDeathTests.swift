#if DEATH_TEST
  import BareArrayModule
  import Testing

  /// Swift 6.4以降の借用参照生成は、各軸の範囲外座標をSwift precondition trapで拒否する。
  struct BareArray_96_BorrowedReferenceDeathTests {

    @Test func referenceRejectsInvalidCoordinates1D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray<Int>(repeating: 0, count: 3).reference(at: -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray<Int>(repeating: 0, count: 3).reference(at: 3)
      }
    }

    @Test func referenceRejectsInvalidCoordinates2D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray2D<Int>(repeating: 0, width: 2, height: 3).reference(at: -1, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray2D<Int>(repeating: 0, width: 2, height: 3).reference(at: 2, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray2D<Int>(repeating: 0, width: 2, height: 3).reference(at: 0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray2D<Int>(repeating: 0, width: 2, height: 3).reference(at: 0, 3)
      }
    }

    @Test func referenceRejectsInvalidCoordinates3D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).reference(at: -1, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).reference(at: 2, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).reference(at: 0, -1, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).reference(at: 0, 3, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).reference(at: 0, 0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray3D<Int>(repeating: 0, width: 2, height: 3, depth: 4).reference(at: 0, 0, 4)
      }
    }

    @Test func referenceRejectsInvalidCoordinates4D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).reference(at: -1, 0, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).reference(at: 2, 0, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).reference(at: 0, -1, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).reference(at: 0, 3, 0, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).reference(at: 0, 0, -1, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).reference(at: 0, 0, 4, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).reference(at: 0, 0, 0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = BareArray4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5).reference(at: 0, 0, 0, 5)
      }
    }
  }
#endif
