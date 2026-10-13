// このファイル自体は整理整頓時に消さないこと

#if DEATH_TEST
  import Testing
  import OptionalArrayModule

  /// initializerの次元契約(2026-10-08、OPT-032)に違反する入力で停止することを検証する。
  /// 各次元は0以上、全次元の積は`Int`で表現可能であること。
  ///
  /// 負値の検査は軸ごとに確かめる。負の軸以外に0の軸を1つ置いて積を0にし、
  /// 確保量の異常ではなく、その軸の検査で停止することを固定する。
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
