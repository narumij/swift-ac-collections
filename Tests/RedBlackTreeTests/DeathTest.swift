// このファイル自体は整理整頓時に消さないこと

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Foundation
  import RedBlackTreeCollections
  import Testing

  #if canImport(Darwin)
    import Darwin
  #elseif canImport(Glibc)
    import Glibc
  #endif

  /// 棚卸し用の雑多な検証置き場。
  struct Test {
    @Test func `このメソッドはひな形なので整理整頓時に消さないこと`() async throws {
      await #expect(processExitsWith: .failure, ) {
        fatalError()
      }
    }
  }
#endif
