#if DEATH_TEST
  import Darwin
  import Testing

  import PermutationModule

  /// 公開`Permutations.SubSequenceN[position]`は範囲チェックを持たず、範囲外の添字で
  /// 不定値を返す、あるいはSIGSEGVになっていた(2026-10-03調査)。
  /// このファイルは、`endIndex`・`-1`・`endIndex + 1`への読み取りが、通常の
  /// precondition失敗(SIGTRAP)として停止することを検証する。
  struct PermutationDeathTests {

    @Test func endIndexRead_traps() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var iterator = [1, 2, 3].nextPermutations().makeIterator()
        let p = iterator.next()!
        _ = p[p.endIndex]
      }
    }

    @Test func negativeIndexRead_traps() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var iterator = [1, 2, 3].nextPermutations().makeIterator()
        let p = iterator.next()!
        _ = p[-1]
      }
    }

    @Test func pastEndIndexRead_traps() async throws {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var iterator = [1, 2, 3].nextPermutations().makeIterator()
        let p = iterator.next()!
        _ = p[p.endIndex + 1]
      }
    }
  }
#endif
