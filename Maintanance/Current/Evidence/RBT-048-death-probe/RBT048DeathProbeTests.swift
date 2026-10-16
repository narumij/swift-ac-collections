// RBT-048 additional check (death tests). Run only in a temporary copy; not part of the repository suite.
// Each probe runs in a child process. `.success` means: no trap, and the returned value matched.
#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Foundation
  import RedBlackTreeCollections
  import Testing

  private func check(_ ok: Bool) { if !ok { exit(3) } }  // 3 = ran without trap but result differed

  struct RBT048DeathProbeTests {

    // MARK: MultiSet.update(_:at:)

    @Test func ms_P1_sharedEndIndex() async {
      await #expect(processExitsWith: .success) {
        var a: RedBlackTreeMultiSet<Int> = [1, 2, 3]; let b = a
        check(a.update(1, at: a.endIndex) == nil); check(Array(b) == [1, 2, 3])
      }
    }
    @Test func ms_P2_sharedRemovedIndex() async {
      await #expect(processExitsWith: .success) {
        var a: RedBlackTreeMultiSet<Int> = [1, 1, 1]
        let r = a.index(after: a.startIndex); a.remove(at: r); let b = a
        check(a.update(1, at: r) == nil); check(Array(b) == [1, 1])
      }
    }
    @Test func ms_P3_sharedMismatch() async {
      await #expect(processExitsWith: .success) {
        var a: RedBlackTreeMultiSet<Int> = [1, 2, 3]; let b = a
        check(a.update(99, at: a.startIndex) == nil); check(Array(b) == [1, 2, 3])
      }
    }
    @Test func ms_P4_sharedIndexTakenFromCopy() async {
      await #expect(processExitsWith: .success) {
        var a: RedBlackTreeMultiSet<Int> = [1, 2, 3]; let b = a
        check(a.update(2, at: b.index(after: b.startIndex)) == 2)
        check(Array(a) == [1, 2, 3]); check(Array(b) == [1, 2, 3])
      }
    }
    @Test func ms_P5_staleIndexAcrossEarlierCopy() async {
      await #expect(processExitsWith: .success) {
        var a: RedBlackTreeMultiSet<Int> = [1, 2, 3]
        let i = a.index(after: a.startIndex)
        let keep = a; a.insert(4)          // a is copied here; i was made before the copy
        let b = a                          // share again
        check(a.update(2, at: i) == 2); check(Array(keep) == [1, 2, 3]); check(Array(b) == [1, 2, 3, 4])
      }
    }
    @Test func ms_P6_sharedRemovedThenSlotReused() async {
      await #expect(processExitsWith: .success) {
        var a: RedBlackTreeMultiSet<Int> = [1, 2, 3]
        let r = a.index(after: a.startIndex); a.remove(at: r); a.insert(2)  // slot may be reused
        let b = a
        check(a.update(2, at: r) == nil); check(Array(b) == [1, 2, 3])
      }
    }
    @Test func ms_P7_sharedForeignIndex_unspecified() async {
      // Unrelated tree's index: behavior is not a contract. Recorded only to see whether the draft adds a trap.
      await #expect(processExitsWith: .success) {
        let c: RedBlackTreeMultiSet<Int> = [7, 8, 9]
        var a: RedBlackTreeMultiSet<Int> = [1, 2, 3]; let b = a
        _ = a.update(1, at: c.startIndex); check(Array(b) == [1, 2, 3])
      }
    }

    // MARK: MultiMap.updateValue(_:at:)

    @Test func mm_P1_sharedEndIndex() async {
      await #expect(processExitsWith: .success) {
        var a: RedBlackTreeMultiMap<Int, Int> = [(1, 10)]; let b = a
        check(a.updateValue(0, at: a.endIndex) == nil); check(b.map(\.value) == [10])
      }
    }
    @Test func mm_P2_sharedRemovedIndex() async {
      await #expect(processExitsWith: .success) {
        var a: RedBlackTreeMultiMap<Int, Int> = [(1, 10), (1, 20)]
        let r = a.startIndex; a.remove(at: r); let b = a
        check(a.updateValue(0, at: r) == nil); check(b.map(\.value) == [20])
      }
    }
    @Test func mm_P4_sharedIndexTakenFromCopy() async {
      await #expect(processExitsWith: .success) {
        var a: RedBlackTreeMultiMap<Int, Int> = [(1, 10), (1, 20)]; let b = a
        check(a.updateValue(0, at: b.startIndex) == 10)
        check(a.map(\.value) == [0, 20]); check(b.map(\.value) == [10, 20])
      }
    }
    @Test func mm_P5_staleIndexAcrossEarlierCopy() async {
      await #expect(processExitsWith: .success) {
        var a: RedBlackTreeMultiMap<Int, Int> = [(1, 10), (2, 20)]
        let i = a.startIndex
        let keep = a; a.insert((3, 30)); let b = a
        check(a.updateValue(0, at: i) == 10); check(keep.map(\.value) == [10, 20]); check(b.map(\.value) == [10, 20, 30])
      }
    }
    @Test func mm_P6_sharedRemovedThenSlotReused() async {
      await #expect(processExitsWith: .success) {
        var a: RedBlackTreeMultiMap<Int, Int> = [(1, 10), (2, 20)]
        let r = a.startIndex; a.remove(at: r); a.insert((1, 11)); let b = a
        check(a.updateValue(0, at: r) == nil); check(b.map(\.value) == [11, 20])
      }
    }
    @Test func mm_P7_sharedForeignIndex_unspecified() async {
      await #expect(processExitsWith: .success) {
        let c: RedBlackTreeMultiMap<Int, Int> = [(7, 70)]
        var a: RedBlackTreeMultiMap<Int, Int> = [(1, 10)]; let b = a
        _ = a.updateValue(0, at: c.startIndex); check(b.map(\.value) == [10])
      }
    }
  }
#endif
