// このファイル自体は整理整頓時に消さないこと

#if DEATH_TEST
  import Testing

  import BareArrayModule

  /// `BareArray`系の`subscript`は、読み取り(`unsafeAddress`)では下限チェックを行うが、
  /// 書き込み(`unsafeMutableAddress`)では下限チェックが抜けていたことがある(2026-10-03発見)。
  /// このファイルは、負インデックスへの書き込みが読み取りと同じようにトラップすることを検証する。
  struct BareArray_99_DeathTests {

    @Test func negativeIndexWrite_traps() async throws {
      await #expect(processExitsWith: .failure) {
        var array = BareArray<Int>(repeating: 0, count: 3)
        array[-1] = 1
      }
    }

    @Test func negativeIndexRead_traps() async throws {
      await #expect(processExitsWith: .failure) {
        let array = BareArray<Int>(repeating: 0, count: 3)
        _ = array[-1]
      }
    }

    @Test func upperBoundIndexRead_traps() async throws {
      await #expect(processExitsWith: .failure) {
        let array = BareArray<Int>(repeating: 0, count: 3)
        _ = array[3]
      }
    }

    @Test func upperBoundIndexWrite_traps() async throws {
      await #expect(processExitsWith: .failure) {
        var array = BareArray<Int>(repeating: 0, count: 3)
        array[3] = 1
      }
    }

    @Test func negativeIndexRead_traps_view1D() async throws {
      await #expect(processExitsWith: .failure) {
        let array = BareArray2D<Int>(repeating: 0, width: 3, height: 2)
        _ = array[0][-1]
      }
    }

    @Test func negativeIndexWrite_traps_view1D() async throws {
      await #expect(processExitsWith: .failure) {
        var array = BareArray2D<Int>(repeating: 0, width: 3, height: 2)
        array[0][-1] = 1
      }
    }

    @Test func upperBoundIndexWrite_traps_view1D() async throws {
      await #expect(processExitsWith: .failure) {
        var array = BareArray2D<Int>(repeating: 0, width: 3, height: 2)
        array[0][3] = 1
      }
    }

    @Test func negativeIndexGet_traps_view2D() async throws {
      await #expect(processExitsWith: .failure) {
        var array = BareArray3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
        array[0][-1][0] = 1
      }
    }

    @Test func upperBoundIndexGet_traps_view2D() async throws {
      await #expect(processExitsWith: .failure) {
        var array = BareArray3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
        array[0][2][0] = 1
      }
    }

    @Test func negativeIndexGet_traps_view3D() async throws {
      await #expect(processExitsWith: .failure) {
        var array = BareArray4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
        array[0][-1][0][0] = 1
      }
    }

    @Test func upperBoundIndexGet_traps_view3D() async throws {
      await #expect(processExitsWith: .failure) {
        var array = BareArray4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
        array[0][2][0][0] = 1
      }
    }

    // 所有2D〜4Dの外側subscript（View を返す側）の上下限（BARE-009）

    @Test func negativeOuterIndex_traps_owned2D() async throws {
      await #expect(processExitsWith: .failure) {
        let array = BareArray2D<Int>(repeating: 0, width: 3, height: 2)
        _ = array[-1]
      }
    }

    @Test func upperBoundOuterIndex_traps_owned2D() async throws {
      await #expect(processExitsWith: .failure) {
        let array = BareArray2D<Int>(repeating: 0, width: 3, height: 2)
        _ = array[2]
      }
    }

    @Test func negativeOuterIndex_traps_owned3D() async throws {
      await #expect(processExitsWith: .failure) {
        let array = BareArray3D<Int>(repeating: 0, width: 2, height: 3, depth: 4)
        _ = array[-1]
      }
    }

    @Test func upperBoundOuterIndex_traps_owned3D() async throws {
      await #expect(processExitsWith: .failure) {
        let array = BareArray3D<Int>(repeating: 0, width: 2, height: 3, depth: 4)
        _ = array[4]
      }
    }

    @Test func negativeOuterIndex_traps_owned4D() async throws {
      await #expect(processExitsWith: .failure) {
        let array = BareArray4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5)
        _ = array[-1]
      }
    }

    @Test func upperBoundOuterIndex_traps_owned4D() async throws {
      await #expect(processExitsWith: .failure) {
        let array = BareArray4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5)
        _ = array[5]
      }
    }

    // 外側subscriptのsetterは、連鎖writebackと異なるView全体代入を拒否する（BARE-014）

    @Test func foreignViewAssignment_traps_owned2D() async throws {
      await #expect(processExitsWith: .failure) {
        var lhs = BareArray2D<Int>(repeating: 0, width: 2, height: 2)
        let rhs = BareArray2D<Int>(repeating: 1, width: 2, height: 2)
        lhs[0] = rhs[0]
      }
    }

    @Test func foreignViewAssignment_traps_owned3D() async throws {
      await #expect(processExitsWith: .failure) {
        var lhs = BareArray3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
        let rhs = BareArray3D<Int>(repeating: 1, width: 2, height: 2, depth: 2)
        lhs[0] = rhs[0]
      }
    }

    @Test func foreignViewAssignment_traps_owned4D() async throws {
      await #expect(processExitsWith: .failure) {
        var lhs = BareArray4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
        let rhs = BareArray4D<Int>(repeating: 1, size0: 2, size1: 2, size2: 2, size3: 2)
        lhs[0] = rhs[0]
      }
    }

    @Test func foreignViewAssignment_traps_view2D() async throws {
      await #expect(processExitsWith: .failure) {
        let lhsArray = BareArray3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
        let rhsArray = BareArray3D<Int>(repeating: 1, width: 2, height: 2, depth: 2)
        var lhs = lhsArray[0]
        lhs[0] = rhsArray[0][0]
      }
    }

    @Test func foreignViewAssignment_traps_view3D() async throws {
      await #expect(processExitsWith: .failure) {
        let lhsArray = BareArray4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
        let rhsArray = BareArray4D<Int>(repeating: 1, size0: 2, size1: 2, size2: 2, size3: 2)
        var lhs = lhsArray[0]
        lhs[0] = rhsArray[0][0]
      }
    }

    // 公開initializerの次元は非負で、積がIntで表現可能でなければならない（BARE-015）

    @Test func negativeDimension_traps_1DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray<Int>(repeating: 0, count: -1)
      }
    }

    @Test func negativeDimension_traps_1DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray<Int>(count: -1) { 0 }
      }
    }

    @Test func negativeDimension_traps_2DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray2D<Int>(repeating: 0, width: -1, height: -1)
      }
    }

    @Test func negativeDimension_traps_2DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray2D<Int>(width: -1, height: -1) { 0 }
      }
    }

    @Test func negativeDimension_traps_3DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray3D<Int>(repeating: 0, width: -1, height: -1, depth: 1)
      }
    }

    @Test func negativeDimension_traps_3DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray3D<Int>(width: -1, height: -1, depth: 1) { 0 }
      }
    }

    @Test func negativeDimension_traps_4DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray4D<Int>(repeating: 0, size0: -1, size1: -1, size2: 1, size3: 1)
      }
    }

    @Test func negativeDimension_traps_4DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray4D<Int>(size0: -1, size1: -1, size2: 1, size3: 1) { 0 }
      }
    }

    @Test func dimensionProductOverflow_traps_2DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray2D<Int>(repeating: 0, width: .max, height: 2)
      }
    }

    @Test func dimensionProductOverflow_traps_2DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray2D<Int>(width: .max, height: 2) { 0 }
      }
    }

    @Test func dimensionProductOverflow_traps_3DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray3D<Int>(repeating: 0, width: .max, height: 2, depth: 1)
      }
    }

    @Test func dimensionProductOverflow_traps_3DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray3D<Int>(width: .max, height: 2, depth: 1) { 0 }
      }
    }

    @Test func dimensionProductOverflow_traps_4DRepeating() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray4D<Int>(repeating: 0, size0: .max, size1: 2, size2: 1, size3: 1)
      }
    }

    @Test func dimensionProductOverflow_traps_4DClosure() async throws {
      await #expect(processExitsWith: .failure) {
        _ = BareArray4D<Int>(size0: .max, size1: 2, size2: 1, size3: 1) { 0 }
      }
    }
  }
#endif
