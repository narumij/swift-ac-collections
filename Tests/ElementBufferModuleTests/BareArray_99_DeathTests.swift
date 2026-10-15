// このファイル自体は整理整頓時に消さないこと

#if DEATH_TEST
  import Testing

  import ElementBufferModule

  /// Verifies the trapping contract that public initializer dimensions are nonnegative and their product is representable as an `Int`.
  struct BareArray_99_DeathTests {

    // MARK: - Initializer dimensions (BARE-015)

    @Test func negativeDimension_traps_1DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer<Int>(repeating: 0, count: -1)
      }
    }

    @Test func negativeDimension_traps_1DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer<Int>(count: -1) { 0 }
      }
    }

    @Test func negativeDimension_traps_2DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer2D<Int>(repeating: 0, width: -1, height: -1)
      }
    }

    @Test func negativeDimension_traps_2DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer2D<Int>(width: -1, height: -1) { 0 }
      }
    }

    @Test func negativeDimension_traps_3DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer3D<Int>(repeating: 0, width: -1, height: -1, depth: 1)
      }
    }

    @Test func negativeDimension_traps_3DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer3D<Int>(width: -1, height: -1, depth: 1) { 0 }
      }
    }

    @Test func negativeDimension_traps_4DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer4D<Int>(repeating: 0, size0: -1, size1: -1, size2: 1, size3: 1)
      }
    }

    @Test func negativeDimension_traps_4DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer4D<Int>(size0: -1, size1: -1, size2: 1, size3: 1) { 0 }
      }
    }

    // MARK: - Per-axis nonnegative dimensions (BARE-046 C)
    //
    // Each axis is negative on its own while the other axes are positive, so a missing check on any
    // single axis is detected. The cases expect the Swift precondition trap signal, not just any failure.
    // Exit test bodies cannot capture values, so each case calls a helper with literal dimensions.

    @Test func negativeSingleAxis_traps_2DRepeating() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating2D(-1, 2)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating2D(2, -1)
      }
    }

    @Test func negativeSingleAxis_traps_2DClosure() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure2D(-1, 2)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure2D(2, -1)
      }
    }

    @Test func negativeSingleAxis_traps_3DRepeating() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating3D(-1, 2, 2)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating3D(2, -1, 2)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating3D(2, 2, -1)
      }
    }

    @Test func negativeSingleAxis_traps_3DClosure() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure3D(-1, 2, 2)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure3D(2, -1, 2)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure3D(2, 2, -1)
      }
    }

    @Test func negativeSingleAxis_traps_4DRepeating() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating4D(-1, 2, 2, 2)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating4D(2, -1, 2, 2)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating4D(2, 2, -1, 2)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating4D(2, 2, 2, -1)
      }
    }

    @Test func negativeSingleAxis_traps_4DClosure() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure4D(-1, 2, 2, 2)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure4D(2, -1, 2, 2)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure4D(2, 2, -1, 2)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure4D(2, 2, 2, -1)
      }
    }

    // A zero axis must not let the empty-storage path skip the check on a negative axis.

    @Test func zeroAndNegativeAxes_traps_2D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating2D(0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure2D(0, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating2D(-1, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure2D(-1, 0)
      }
    }

    @Test func zeroAndNegativeAxes_traps_3D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating3D(0, 2, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure3D(0, 2, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating3D(-1, 2, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure3D(-1, 2, 0)
      }
    }

    @Test func zeroAndNegativeAxes_traps_4D() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating4D(0, 2, 2, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure4D(0, 2, 2, -1)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.repeating4D(-1, 2, 2, 0)
      }
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        Self.closure4D(-1, 2, 2, 0)
      }
    }

    private static func repeating2D(_ width: Int, _ height: Int) {
      _ = ElementBuffer2D<Int>(repeating: 0, width: width, height: height)
    }

    private static func closure2D(_ width: Int, _ height: Int) {
      _ = ElementBuffer2D<Int>(width: width, height: height) { 0 }
    }

    private static func repeating3D(_ width: Int, _ height: Int, _ depth: Int) {
      _ = ElementBuffer3D<Int>(repeating: 0, width: width, height: height, depth: depth)
    }

    private static func closure3D(_ width: Int, _ height: Int, _ depth: Int) {
      _ = ElementBuffer3D<Int>(width: width, height: height, depth: depth) { 0 }
    }

    private static func repeating4D(_ size0: Int, _ size1: Int, _ size2: Int, _ size3: Int) {
      _ = ElementBuffer4D<Int>(repeating: 0, size0: size0, size1: size1, size2: size2, size3: size3)
    }

    private static func closure4D(_ size0: Int, _ size1: Int, _ size2: Int, _ size3: Int) {
      _ = ElementBuffer4D<Int>(size0: size0, size1: size1, size2: size2, size3: size3) { 0 }
    }

    @Test func dimensionProductOverflow_traps_2DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer2D<Int>(repeating: 0, width: .max, height: 2)
      }
    }

    @Test func dimensionProductOverflow_traps_2DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer2D<Int>(width: .max, height: 2) { 0 }
      }
    }

    @Test func dimensionProductOverflow_traps_3DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer3D<Int>(repeating: 0, width: .max, height: 2, depth: 1)
      }
    }

    @Test func dimensionProductOverflow_traps_3DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer3D<Int>(width: .max, height: 2, depth: 1) { 0 }
      }
    }

    @Test func dimensionProductOverflow_traps_4DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer4D<Int>(repeating: 0, size0: .max, size1: 2, size2: 1, size3: 1)
      }
    }

    @Test func dimensionProductOverflow_traps_4DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ElementBuffer4D<Int>(size0: .max, size1: 2, size2: 1, size3: 1) { 0 }
      }
    }
  }
#endif

