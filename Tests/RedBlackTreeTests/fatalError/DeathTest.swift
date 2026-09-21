//
//  Test.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/30.
//

#if DEATH_TEST
  import RedBlackTreeCollections
  import Testing

  struct DeathTest {

    @Test func `endIndex cannot be subscripted`() async {
      await #expect(processExitsWith: .failure) {
        let set: RedBlackTreeSet<Int> = [1, 2, 3]
        _ = set[set.endIndex]
      }
    }

    @Test func `removed index cannot be subscripted`() async {
      await #expect(processExitsWith: .failure) {
        var set: RedBlackTreeSet<Int> = [1, 2, 3]
        let index = set.firstIndex(of: 2)!
        set.remove(at: index)
        _ = set[index]
      }
    }

    #if !COMPATIBLE_ATCODER_2025
      @Test func `index from another tree cannot be subscripted`() async {
        await #expect(processExitsWith: .failure) {
          let set: RedBlackTreeSet<Int> = [1, 2, 3]
          let other: RedBlackTreeSet<Int> = [4, 5, 6]
          _ = set[other.startIndex]
        }
      }
    #endif
  }
#endif
