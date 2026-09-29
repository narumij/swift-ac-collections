#if DEATH_TEST
  import Foundation
  import RedBlackTreeCollections
  import Testing

  struct RedBlackTreeDictionaryDeathTests {

    @Test
    func duplicateKeysInUniqueKeysInitializer_terminateProcess() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        _ = RedBlackTreeDictionary<Int, Int>(uniqueKeysWithValues: [(1, 1), (1, 2)])
      }
    }

    @Test
    func removingFirstFromEmptyDictionary_terminatesProcess() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var dictionary = RedBlackTreeDictionary<Int, Int>()
        dictionary.removeFirst()
      }
    }

    @Test
    func removingLastFromEmptyDictionary_terminatesProcess() async {
      await #expect(processExitsWith: .signal(SIGTRAP)) {
        var dictionary = RedBlackTreeDictionary<Int, Int>()
        dictionary.removeLast()
      }
    }

    #if !COMPATIBLE_ATCODER_2025
      @Test
      func emptyStartIndexSubscript_terminatesProcess() async {
        await #expect(processExitsWith: .signal(SIGTRAP)) {
          let dictionary = RedBlackTreeDictionary<Int, Int>()
          _ = dictionary[dictionary.startIndex]
        }
      }

      @Test
      func removingEmptyStartIndex_terminatesProcess() async {
        await #expect(processExitsWith: .signal(SIGTRAP)) {
          var dictionary = RedBlackTreeDictionary<Int, Int>()
          dictionary.remove(at: dictionary.startIndex)
        }
      }

      @Test
      func removingEndIndex_terminatesProcess() async {
        await #expect(processExitsWith: .signal(SIGTRAP)) {
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
        await #expect(processExitsWith: .signal(SIGTRAP)) {
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
