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

  // RBT-104：中身を破棄したノードを指すIndexを渡しても、破棄済みの中身や古いリンクを読む前に停止すること。

  private func expectNoInvalidMemoryAccess(_ result: ExitTest.Result?) {
    guard let result else {
      return
    }

    #if canImport(Darwin) || canImport(Glibc)
      #expect(
        result.exitStatus != .signal(SIGSEGV),
        "SIGSEGV による停止は不正メモリアクセスの可能性がある"
      )

      #expect(
        result.exitStatus != .signal(SIGBUS),
        "SIGBUS による停止は不正メモリアクセスの可能性がある"
      )
    #endif

    let stderr = String(
      decoding: result.standardErrorContent,
      as: UTF8.self
    )

    #expect(
      !stderr.contains("AddressSanitizer"),
      "Address Sanitizer が不正メモリアクセスを検出した"
    )
  }

  /// 消したときに文字列の領域が解放されるよう、毎回新しく作る要素。
  private func rbt104Element(_ c: Character) -> String {
    String(repeating: c, count: 40)
  }

  #if !USE_LAZY_DETACH
    /// 容量を保ったまま全削除したあとに残る、削除前のIndex。
    private func indexBeforeRemoveAllKeepingCapacity()
      -> (set: RedBlackTreeSet<String>, stale: RedBlackTreeSet<String>.Index)
    {
      var set = RedBlackTreeSet<String>()
      for c in "abc" { set.insert(rbt104Element(c)) }
      let stale = set.firstIndex(of: rbt104Element("b"))!
      set.removeAll(keepingCapacity: true)
      set.insert(rbt104Element("x"))
      return (set, stale)
    }

    struct RBT104RemoveAllKeepingCapacityDeathTests {

      @Test
      func isElement_returnsFalse() {
        let (set, stale) = indexBeforeRemoveAllKeepingCapacity()
        #expect(!set.isElement(at: stale))
      }

      @Test
      func containsSubrange_returnsFalse() {
        let (set, stale) = indexBeforeRemoveAllKeepingCapacity()
        #expect(!set.containsSubrange(stale..<set.endIndex))
      }

      @Test
      func subscript_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          let (set, stale) = indexBeforeRemoveAllKeepingCapacity()
          _ = set[stale]
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func distance_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          let (set, stale) = indexBeforeRemoveAllKeepingCapacity()
          _ = set.distance(from: set.startIndex, to: stale)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func indexAfter_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          let (set, stale) = indexBeforeRemoveAllKeepingCapacity()
          _ = set.index(after: stale)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func indexBefore_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          let (set, stale) = indexBeforeRemoveAllKeepingCapacity()
          _ = set.index(before: stale)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func insertWithHint_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          var (set, stale) = indexBeforeRemoveAllKeepingCapacity()
          _ = set.insert(rbt104Element("y"), hint: stale)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func updateWithHint_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          var (set, stale) = indexBeforeRemoveAllKeepingCapacity()
          _ = set.update(rbt104Element("y"), hint: stale)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func viewFirst_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          let (set, stale) = indexBeforeRemoveAllKeepingCapacity()
          _ = set[stale..<set.endIndex].first
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func eraseRange_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          var (set, stale) = indexBeforeRemoveAllKeepingCapacity()
          _ = set.erase(stale..<set.endIndex)
        }
        expectNoInvalidMemoryAccess(result)
      }
    }
  #endif

  #if USE_COMPACT_NODE_METADATA
    /// compact構成で世代が一周し、回収済みになった枠を指すIndex。
    private func indexAfterSealWraparound()
      -> (set: RedBlackTreeSet<String>, stale: RedBlackTreeSet<String>.Index)
    {
      var set = RedBlackTreeSet<String>()
      set.insert(rbt104Element("a"))
      set.insert(rbt104Element("c"))
      set.insert(rbt104Element("b"))
      let stale = set.firstIndex(of: rbt104Element("b"))!
      set.remove(rbt104Element("b"))
      for _ in 0..<65535 {
        set.insert(rbt104Element("b"))
        set.remove(rbt104Element("b"))
      }
      return (set, stale)
    }

    struct RBT104SealWraparoundDeathTests {

      @Test
      func isElement_returnsFalse() {
        let (set, stale) = indexAfterSealWraparound()
        #expect(!set.isElement(at: stale))
      }

      @Test
      func containsSubrange_returnsFalse() {
        let (set, stale) = indexAfterSealWraparound()
        #expect(!set.containsSubrange(stale..<set.endIndex))
      }

      @Test
      func subscript_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          let (set, stale) = indexAfterSealWraparound()
          _ = set[stale]
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func distance_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          let (set, stale) = indexAfterSealWraparound()
          _ = set.distance(from: set.startIndex, to: stale)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func indexAfter_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          let (set, stale) = indexAfterSealWraparound()
          _ = set.index(after: stale)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func indexBefore_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          let (set, stale) = indexAfterSealWraparound()
          _ = set.index(before: stale)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func insertWithHint_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          var (set, stale) = indexAfterSealWraparound()
          _ = set.insert(rbt104Element("y"), hint: stale)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func updateWithHint_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          var (set, stale) = indexAfterSealWraparound()
          _ = set.update(rbt104Element("y"), hint: stale)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func viewFirst_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          let (set, stale) = indexAfterSealWraparound()
          _ = set[stale..<set.endIndex].first
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func eraseRange_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
          var (set, stale) = indexAfterSealWraparound()
          _ = set.erase(stale..<set.endIndex)
        }
        expectNoInvalidMemoryAccess(result)
      }
    }
  #endif
#endif
