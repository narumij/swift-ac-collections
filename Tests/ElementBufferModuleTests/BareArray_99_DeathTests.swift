// このファイル自体は整理整頓時に消さないこと

#if DEATH_TEST
  import Testing

  import ElementBufferModule

  /// 公開initializerの次元が非負で、その積を`Int`で表現できるというtrap契約を検証する。
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

