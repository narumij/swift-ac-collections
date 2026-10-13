//
//  NextPermutations_99_DeathTests.swift
//  swift-ac-collections
//

// `NextPermutations<Value>.Permutation`の範囲外の添字が、通常のprecondition失敗として停止することの
// Test as Specification（PERM-053 G3）。`-1`、`endIndex`、`endIndex + 1`、`Int.min`、`Int.max`の読み取りを扱う。
// 停止signalはtarget共通の`expectedSwiftTrapSignal`（DarwinはSIGTRAP、LinuxはSIGILL）に完全一致させる。
// Viewの失効による停止（G2）はこのfileでは扱わない。

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Testing
  import PermutationModule

  struct NextPermutations_99_DeathTests {

    @Test func negativeIndexRead_traps() async throws {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var permutations = [1, 2, 3].nextPermutations()
        let p = permutations.next()!
        _ = p[-1]
      }
    }

    @Test func endIndexRead_traps() async throws {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var permutations = [1, 2, 3].nextPermutations()
        let p = permutations.next()!
        _ = p[p.endIndex]
      }
    }

    @Test func pastEndIndexRead_traps() async throws {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var permutations = [1, 2, 3].nextPermutations()
        let p = permutations.next()!
        _ = p[p.endIndex + 1]
      }
    }

    @Test func intMinIndexRead_traps() async throws {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var permutations = [1, 2, 3].nextPermutations()
        let p = permutations.next()!
        _ = p[Int.min]
      }
    }

    @Test func intMaxIndexRead_traps() async throws {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var permutations = [1, 2, 3].nextPermutations()
        let p = permutations.next()!
        _ = p[Int.max]
      }
    }
  }
#endif
