#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Testing

  #if canImport(Darwin)
    import Darwin
  #elseif canImport(Glibc)
    import Glibc
  #endif

  import PermutationModule

  /// 公開`NextPermutationsSequence.Permutation[position]`(旧`Permutations.SubSequenceN`)は範囲チェックを持たず、範囲外の添字で
  /// 不定値を返す、あるいはSIGSEGVになっていた(2026-10-03調査)。
  /// このファイルは、`endIndex`・`-1`・`endIndex + 1`・`Int.min`・`Int.max`への読み取りが、通常の
  /// precondition失敗(SIGTRAP)として停止することを検証する。
  struct NextPermutationsSequence_99_DeathTests {

    @Test func endIndexRead_traps() async throws {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var iterator = [1, 2, 3].nextPermutations().makeIterator()
        let p = iterator.next()!
        _ = p[p.endIndex]
      }
    }

    @Test func negativeIndexRead_traps() async throws {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var iterator = [1, 2, 3].nextPermutations().makeIterator()
        let p = iterator.next()!
        _ = p[-1]
      }
    }

    @Test func pastEndIndexRead_traps() async throws {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var iterator = [1, 2, 3].nextPermutations().makeIterator()
        let p = iterator.next()!
        _ = p[p.endIndex + 1]
      }
    }

    @Test func intMinIndexRead_traps() async throws {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var iterator = [1, 2, 3].nextPermutations().makeIterator()
        let p = iterator.next()!
        _ = p[Int.min]
      }
    }

    @Test func intMaxIndexRead_traps() async throws {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var iterator = [1, 2, 3].nextPermutations().makeIterator()
        let p = iterator.next()!
        _ = p[Int.max]
      }
    }
  }
#endif
