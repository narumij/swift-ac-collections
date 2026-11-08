// このファイル自体は整理整頓時に消さないこと

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Testing
  import RedBlackTreeCollections

  /// 棚卸し用の雑多な検証置き場。
  struct Test {
    #if ENABLE_OFFSET_OVERFLOW_GUARD
      // RBT-076: 確保サイズが桁あふれする容量は、確保前に停止する。
      @Test func extremeMinimumCapacity_terminatesProcess() async {
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          _ = RedBlackTreeDictionary<Int, Int>(minimumCapacity: Int.max)
        }
      }
    #endif

    @Test func `このメソッドはひな形なので整理整頓時に消さないこと`() async throws {
      await #expect(processExitsWith: .failure, ) {
        fatalError()
      }
    }
  }
#endif
