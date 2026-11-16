// このファイル自体は整理整頓時に消さないこと

#if DEATH_TEST
  import Testing
  import OptionalElementBufferModule

  /// Verifies that inputs violating the initializer dimension contract (2026-10-08, OPT-032) trap.
  /// Every dimension must be nonnegative, and the product of all dimensions must be representable as an `Int`.
  ///
  /// Checks negative values one axis at a time. Sets one other axis to zero so that the product is zero,
  /// ensuring that the trap comes from checking that axis rather than an invalid allocation size.
  struct OptionalArrayDimensionDeathTests {

    @Test func negativeCapacity_traps_1D() async throws {
      await #expect(processExitsWith: .failure) {
        _ = OptionalElementBuffer<Int>(capacity: -1)
      }
    }

    @Test func negativeWidth_traps_2D() async throws {
      await #expect(processExitsWith: .failure) {
        _ = OptionalElementBuffer2D<Int>(width: -1, height: 0)
      }
    }

    @Test func negativeHeight_traps_2D() async throws {
      await #expect(processExitsWith: .failure) {
        _ = OptionalElementBuffer2D<Int>(width: 0, height: -1)
      }
    }

    @Test func negativeWidth_traps_3D() async throws {
      await #expect(processExitsWith: .failure) {
        _ = OptionalElementBuffer3D<Int>(width: -1, height: 0, depth: 1)
      }
    }

    @Test func negativeHeight_traps_3D() async throws {
      await #expect(processExitsWith: .failure) {
        _ = OptionalElementBuffer3D<Int>(width: 1, height: -1, depth: 0)
      }
    }

    @Test func negativeDepth_traps_3D() async throws {
      await #expect(processExitsWith: .failure) {
        _ = OptionalElementBuffer3D<Int>(width: 0, height: 1, depth: -1)
      }
    }

    @Test func negativeSize0_traps_4D() async throws {
      await #expect(processExitsWith: .failure) {
        _ = OptionalElementBuffer4D<Int>(size0: -1, size1: 0, size2: 1, size3: 1)
      }
    }

    @Test func negativeSize1_traps_4D() async throws {
      await #expect(processExitsWith: .failure) {
        _ = OptionalElementBuffer4D<Int>(size0: 1, size1: -1, size2: 0, size3: 1)
      }
    }

    @Test func negativeSize2_traps_4D() async throws {
      await #expect(processExitsWith: .failure) {
        _ = OptionalElementBuffer4D<Int>(size0: 1, size1: 1, size2: -1, size3: 0)
      }
    }

    @Test func negativeSize3_traps_4D() async throws {
      await #expect(processExitsWith: .failure) {
        _ = OptionalElementBuffer4D<Int>(size0: 0, size1: 1, size2: 1, size3: -1)
      }
    }

    @Test func productOverflow_traps_2D() async throws {
      await #expect(processExitsWith: .failure) {
        _ = OptionalElementBuffer2D<Int>(width: Int.max, height: 2)
      }
    }

    @Test func productOverflow_traps_3D() async throws {
      await #expect(processExitsWith: .failure) {
        _ = OptionalElementBuffer3D<Int>(width: 1 << 32, height: 1 << 32, depth: 1)
      }
    }

    @Test func productOverflow_traps_4D() async throws {
      await #expect(processExitsWith: .failure) {
        _ = OptionalElementBuffer4D<Int>(size0: 1 << 16, size1: 1 << 16, size2: 1 << 16, size3: 1 << 16)
      }
    }
  }
#endif
