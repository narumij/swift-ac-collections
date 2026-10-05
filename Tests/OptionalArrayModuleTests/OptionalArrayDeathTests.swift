// このファイル自体は整理整頓時に消さないこと

#if DEATH_TEST
  import Testing
  import OptionalArrayModule

  /// `OptionalArray`系の`subscript`が、範囲外indexで読み書きともにトラップすることを検証する。
  struct OptionalArrayDeathTests {

    @Test func negativeIndexRead_traps() async throws {
      await #expect(processExitsWith: .failure) {
        let array = OptionalArray1D<Int>(capacity: 3)
        _ = array[-1]
      }
    }

    @Test func negativeIndexWrite_traps() async throws {
      await #expect(processExitsWith: .failure) {
        var array = OptionalArray1D<Int>(capacity: 3)
        array[-1] = 1
      }
    }

    @Test func outOfUpperBoundRead_traps() async throws {
      await #expect(processExitsWith: .failure) {
        let array = OptionalArray1D<Int>(capacity: 3)
        _ = array[3]
      }
    }

    @Test func negativeIndexRead_traps_view1D() async throws {
      await #expect(processExitsWith: .failure) {
        let array = OptionalArray2D<Int>(width: 3, height: 2)
        _ = array[0][-1]
      }
    }

    @Test func negativeIndexWrite_traps_view1D() async throws {
      await #expect(processExitsWith: .failure) {
        var array = OptionalArray2D<Int>(width: 3, height: 2)
        array[0][-1] = 1
      }
    }

    @Test func negativeIndexGet_traps_view2D() async throws {
      await #expect(processExitsWith: .failure) {
        var array = OptionalArray3D<Int>(width: 2, height: 2, depth: 2)
        array[0][-1][0] = 1
      }
    }

    @Test func negativeIndexGet_traps_view3D() async throws {
      await #expect(processExitsWith: .failure) {
        var array = OptionalArray4D<Int>(size0: 2, size1: 2, size2: 2, size3: 2)
        array[0][-1][0][0] = 1
      }
    }

    @Test func upperBoundIndexGet_traps_view3D() async throws {
      await #expect(processExitsWith: .failure) {
        var array = OptionalArray4D<Int>(size0: 1, size1: 3, size2: 2, size3: 1)
        array[0][2][0][0] = 1
      }
    }
  }
#endif
