#if DEATH_TEST
  import Foundation
  import RedBlackTreeCollections
  import Testing

  struct RedBlackTreeDictionaryDeathTests {

    #if !COMPATIBLE_ATCODER_2025
      /// 空のDictionaryでも、他の木の要素を指すIndex範囲のeraseは検査で停止すること
      /// (空のときにCoWを省いても、範囲の検査は省かない)。
      @Test
      func erasingForeignRangeFromEmptyDictionary_terminatesProcess() async {
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let source = RedBlackTreeDictionary<Int, String>(
            uniqueKeysWithValues: (0..<8).map { ($0, "\($0)") })
          var target = RedBlackTreeDictionary<Int, String>()
          let lower = source.index(source.startIndex, offsetBy: 2)
          let upper = source.index(source.startIndex, offsetBy: 6)
          target.erase(lower..<upper)
        }
      }
    #endif

    @Test
    func duplicateKeysInUniqueKeysInitializer_terminateProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = RedBlackTreeDictionary<Int, Int>(uniqueKeysWithValues: [(1, 1), (1, 2)])
      }
    }

    @Test
    func removingFirstFromEmptyDictionary_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var dictionary = RedBlackTreeDictionary<Int, Int>()
        dictionary.removeFirst()
      }
    }

    @Test
    func removingLastFromEmptyDictionary_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var dictionary = RedBlackTreeDictionary<Int, Int>()
        dictionary.removeLast()
      }
    }

    #if !COMPATIBLE_ATCODER_2025
      @Test
      func emptyStartIndexSubscript_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let dictionary = RedBlackTreeDictionary<Int, Int>()
          _ = dictionary[dictionary.startIndex]
        }
      }

      @Test
      func removingEmptyStartIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          var dictionary = RedBlackTreeDictionary<Int, Int>()
          dictionary.remove(at: dictionary.startIndex)
        }
      }

      @Test
      func removingEndIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          var dictionary = RedBlackTreeDictionary<Int, Int>(
            uniqueKeysWithValues: (0..<100).map { ($0, $0) }
          )
          dictionary.remove(at: dictionary.endIndex)
        }
      }

      @Test
      func reversedIndexRange_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d"]
          let lower = dictionary.index(dictionary.startIndex, offsetBy: 3)
          let upper = dictionary.index(dictionary.startIndex, offsetBy: 1)
          _ = dictionary[lower..<upper]
        }

        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func removedIndexRange_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          var dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]
          let removed = dictionary.firstIndex(of: 1)!
          dictionary.remove(at: removed)
          _ = dictionary[removed...]
        }

        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func erasingReversedIndexRange_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          var dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d"]
          let lower = dictionary.index(dictionary.startIndex, offsetBy: 3)
          let upper = dictionary.index(dictionary.startIndex, offsetBy: 1)
          _ = dictionary.erase(lower..<upper)
        }

        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func erasingThroughReversedRangeView_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          var dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d"]
          let lower = dictionary.index(dictionary.startIndex, offsetBy: 3)
          let upper = dictionary.index(dictionary.startIndex, offsetBy: 1)
          dictionary[lower..<upper].erase(where: { _ in false })
        }

        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func conditionallyErasingReversedRange_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          var dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d"]
          let lower = dictionary.index(dictionary.startIndex, offsetBy: 3)
          let upper = dictionary.index(dictionary.startIndex, offsetBy: 1)
          dictionary.erase(lower..<upper) { _ in false }
        }

        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func endIndexSubscript_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]
          _ = dictionary[dictionary.endIndex]
        }
      }

      @Test
      func closedRangeEndIndexThenStartIndex_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]
          _ = dictionary[dictionary.endIndex...dictionary.startIndex]
        }

        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func closedRangeStartIndexThenEndIndex_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]
          _ = dictionary[dictionary.startIndex...dictionary.endIndex]
        }

        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func indexBeforeStartIndex_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let dictionary: RedBlackTreeDictionary = (0..<10).reduce(into: RedBlackTreeDictionary<Int, Int>()) { $0[$1] = $1 }
          var i = dictionary.startIndex
          i = dictionary.index(before: i)
        }

        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func indexAfterEndIndex_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let dictionary: RedBlackTreeDictionary = (0..<10).reduce(into: RedBlackTreeDictionary<Int, Int>()) { $0[$1] = $1 }
          var i = dictionary.endIndex
          i = dictionary.index(after: i)
        }

        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func indexOffsetByBeyondBounds_terminatesWithoutInvalidMemoryAccess() async {
        let result1 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let dictionary: RedBlackTreeDictionary = (0..<10).reduce(into: RedBlackTreeDictionary<Int, Int>()) { $0[$1] = $1 }
          var i = dictionary.startIndex
          i = dictionary.index(i, offsetBy: -1)
        }
        expectNoInvalidMemoryAccess(result1)

        let result2 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let dictionary: RedBlackTreeDictionary = (0..<10).reduce(into: RedBlackTreeDictionary<Int, Int>()) { $0[$1] = $1 }
          var i = dictionary.endIndex
          i = dictionary.index(i, offsetBy: 1)
        }
        expectNoInvalidMemoryAccess(result2)
      }

      @Test
      func indexOffsetByLimitedByBeyondBounds_terminatesWithoutInvalidMemoryAccess() async {
        let result1 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let dictionary: RedBlackTreeDictionary = (0..<10).reduce(into: RedBlackTreeDictionary<Int, Int>()) { $0[$1] = $1 }
          let i = dictionary.startIndex
          _ = dictionary.index(i, offsetBy: -1, limitedBy: dictionary.endIndex)
        }
        expectNoInvalidMemoryAccess(result1)

        let result2 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let dictionary: RedBlackTreeDictionary = (0..<10).reduce(into: RedBlackTreeDictionary<Int, Int>()) { $0[$1] = $1 }
          let i = dictionary.endIndex
          _ = dictionary.index(i, offsetBy: 1, limitedBy: dictionary.startIndex)
        }
        expectNoInvalidMemoryAccess(result2)
      }

      @Test
      func formIndexOffsetByLimitedByBeyondBounds_terminatesWithoutInvalidMemoryAccess() async {
        let result1 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let dictionary: RedBlackTreeDictionary = (0..<10).reduce(into: RedBlackTreeDictionary<Int, Int>()) { $0[$1] = $1 }
          var i = dictionary.startIndex
          _ = dictionary.formIndex(&i, offsetBy: -1, limitedBy: dictionary.endIndex)
        }
        expectNoInvalidMemoryAccess(result1)

        let result2 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let dictionary: RedBlackTreeDictionary = (0..<10).reduce(into: RedBlackTreeDictionary<Int, Int>()) { $0[$1] = $1 }
          var i = dictionary.endIndex
          _ = dictionary.formIndex(&i, offsetBy: 1, limitedBy: dictionary.startIndex)
        }
        expectNoInvalidMemoryAccess(result2)
      }

      @Test
      func indexOffsetByLimitedByStaleLimit_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          var dictionary: RedBlackTreeDictionary = [0: 0, 1: 1, 2: 2]
          let start = dictionary.startIndex
          let staleLimit = dictionary.index(after: start)
          dictionary.remove(at: staleLimit)
          _ = dictionary.index(start, offsetBy: 1, limitedBy: staleLimit)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func formIndexOffsetByLimitedByStaleLimit_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          var dictionary: RedBlackTreeDictionary = [0: 0, 1: 1, 2: 2]
          var start = dictionary.endIndex
          let staleLimit = dictionary.index(before: start)
          dictionary.remove(at: staleLimit)
          _ = dictionary.formIndex(&start, offsetBy: -1, limitedBy: staleLimit)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func mappedValuesSubscriptWithErasedIndex_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          var dictionary: RedBlackTreeDictionary = [0: "a", 1: "b"]
          let stale = dictionary.startIndex
          dictionary.remove(at: stale)
          _ = dictionary.values[stale]
        }

        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func mappedValuesAssignmentWithErasedIndex_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          var dictionary: RedBlackTreeDictionary = [0: "a", 1: "b"]
          let stale = dictionary.startIndex
          dictionary.remove(at: stale)
          dictionary.values[stale] = "stale"
        }

        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func mappedValuesSwapWithErasedIndex_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          var dictionary: RedBlackTreeDictionary = [0: "a", 1: "b"]
          let stale = dictionary.startIndex
          dictionary.remove(at: stale)
          dictionary.values.swapAt(stale, dictionary.startIndex)
        }

        expectNoInvalidMemoryAccess(result)
      }

      @Test
      func mappedValuesSubscriptAtTreeEnd_terminatesWithoutInvalidMemoryAccess() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let dictionary: RedBlackTreeDictionary = [0: "a", 1: "b"]
          _ = dictionary.values[dictionary.endIndex]
        }

        expectNoInvalidMemoryAccess(result)
      }

      private func expectNoInvalidMemoryAccess(_ result: ExitTest.Result?) {
        guard let result else { return }

        #if canImport(Darwin) || canImport(Glibc)
          #expect(result.exitStatus != .signal(SIGSEGV))
          #expect(result.exitStatus != .signal(SIGBUS))
        #endif

        let standardError = String(decoding: result.standardErrorContent, as: UTF8.self)
        #expect(!standardError.contains("AddressSanitizer"))
      }
    #endif
  }
#endif
