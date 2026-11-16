#if DEATH_TEST && COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import Testing

  // RBT-064: maxCountが0以下のLRUは作れないこと
  struct MemoizeCacheLRUDeathTests {

    @Test func zeroMaxCount_traps() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ___LRUMemoizeStorage<Int, Int>(maxCount: 0)
      }
    }

    @Test func negativeMaxCount_traps() async throws {
      await #expect(processExitsWith: .failure) {
        _ = ___LRUMemoizeStorage<Int, Int>(maxCount: -1)
      }
    }
  }
#endif
