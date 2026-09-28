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

    #if !COMPATIBLE_ATCODER_2025
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
