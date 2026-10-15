#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
#if false
  import Testing

  #if canImport(Darwin)
    import Darwin
  #elseif canImport(Glibc)
    import Glibc
  #endif

  import PermutationModule

  /// Public `NextPermutationsSequence.Permutation[position]` (formerly `Permutations.SubSequenceN`) had no bounds check and, for an out-of-bounds index,
  /// returned an indeterminate value or raised SIGSEGV (investigated 2026-10-03).
  /// This file verifies that reads at `endIndex`, `-1`, `endIndex + 1`, `Int.min`, and `Int.max` stop with a normal
  /// precondition failure (SIGTRAP).
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
#endif
