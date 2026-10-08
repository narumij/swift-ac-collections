#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Foundation
  import RedBlackTreeCollections
  import Testing

  /// 共有Viewの空での`removeFirst()` / `removeLast()`が、通常構成で停止することを確かめる。
  ///
  /// 契約検査(`preconditionFailure`)なので、`_O_UNCHECKED`では停止せずに終わる。
  /// これは仕様どおりである(`Design-RuntimeChecks.md`)。
  struct RedBlackTreeViewDeathTests {

    // MARK: - KeyOnly Range View

    @Test
    func removingFirstFromEmptyKeyOnlyRangeView_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeSet<Int>()
        set[...].removeFirst()
      }
    }

    @Test
    func removingLastFromEmptyKeyOnlyRangeView_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeSet<Int>()
        set[...].removeLast()
      }
    }

    @Test
    func removingFirstFromEmptyKeyOnlyRangeViewOfNonEmptySet_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set: RedBlackTreeSet = [1, 2, 3]
        let start = set.startIndex
        set[start..<start].removeFirst()
      }
    }

    // MARK: - KeyValue Range View

    @Test
    func removingFirstFromEmptyKeyValueRangeView_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var dictionary = RedBlackTreeDictionary<Int, Int>()
        dictionary[...].removeFirst()
      }
    }

    @Test
    func removingLastFromEmptyKeyValueRangeView_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var dictionary = RedBlackTreeDictionary<Int, Int>()
        dictionary[...].removeLast()
      }
    }

    @Test
    func removingLastFromEmptyKeyValueRangeViewOfNonEmptyDictionary_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var dictionary: RedBlackTreeDictionary = [1: 1, 2: 2, 3: 3]
        let start = dictionary.startIndex
        dictionary[start..<start].removeLast()
      }
    }

    // MARK: - Mapped Values View

    @Test
    func removingFirstFromEmptyMappedValuesView_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var dictionary = RedBlackTreeDictionary<Int, Int>()
        dictionary.values.removeFirst()
      }
    }

    @Test
    func removingLastFromEmptyMappedValuesView_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var dictionary = RedBlackTreeDictionary<Int, Int>()
        dictionary.values.removeLast()
      }
    }
  }
#endif
