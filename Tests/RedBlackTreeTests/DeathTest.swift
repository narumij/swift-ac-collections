// このファイル自体は整理整頓時に消さないこと

#if DEATH_TEST
  import Testing

  /// 棚卸し用の雑多な検証置き場。
  struct Test {
    @Test func `このメソッドはひな形なので整理整頓時に消さないこと`() async throws {
      await #expect(processExitsWith: .failure, ) {
        fatalError()
      }
    }
  }
#endif
