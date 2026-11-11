//
//  RangeExpressionInvalidIndexMultiSetTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Foundation
  import RedBlackTreeCollections
  import Testing

  private func expectNoInvalidMemoryAccess(_ result: ExitTest.Result?) {
    // #expect(processExitsWith:) 自体が失敗した場合は、
    // すでに issue が記録されているので追加では報告しない。
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

  struct RedBlackTreeMultiSetDeathTests {

    // RBT-048: Index-based replacement requires a valid element index.
    @Test
    func updatingEndIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeMultiSet([1, 2, 3])
        set.update(1, at: set.endIndex)
      }
    }

    @Test
    func updatingRemovedIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeMultiSet([1, 2, 3])
        let index = set.startIndex
        set.remove(at: index)
        set.update(1, at: index)
      }
    }

    // Replacement stays at the same position, so it must preserve equality.
    @Test
    func updatingWithNonEquivalentMember_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeMultiSet([1, 2, 3])
        set.update(99, at: set.startIndex)
      }
    }


    #if !COMPATIBLE_ATCODER_2025
      /// 空のMultiSetでも、他の木の要素を指すIndex範囲のeraseは検査で停止すること
      /// (空のときにCoWを省いても、範囲の検査は省かない)。
      @Test
      func erasingForeignRangeFromEmptyMultiSet_terminatesProcess() async {
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let source = RedBlackTreeMultiSet(0..<8)
          var target = RedBlackTreeMultiSet<Int>()
          let lower = source.index(source.startIndex, offsetBy: 2)
          let upper = source.index(source.startIndex, offsetBy: 6)
          target.erase(lower..<upper)
        }
      }
    #endif

    @Test
    func emptyStartIndexSubscript_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        let set = RedBlackTreeMultiSet<Int>()
        _ = set[set.startIndex]
      }
    }

    @Test
    func removingEmptyStartIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeMultiSet<Int>()
        set.remove(at: set.startIndex)
      }
    }

    @Test
    func removingEndIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeMultiSet<Int>(0..<100)
        set.remove(at: set.endIndex)
      }
    }

    @Test
    func removingFirstFromEmptyMultiSet_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeMultiSet<Int>()
        set.removeFirst()
      }
    }

    @Test
    func removingLastFromEmptyMultiSet_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeMultiSet<Int>()
        set.removeLast()
      }
    }

    @Test
    func `MultiSetでlowerがupperより大きい場合、SIGSEGV以外の方法で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        let lower = set.index(set.startIndex, offsetBy: 6)
        let upper = set.index(set.startIndex, offsetBy: 2)
        _ = set[lower..<upper]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiSetで削除済みインデックスを使った場合、SIGSEGV以外の方法で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        let lower = set.index(set.startIndex, offsetBy: 3)
        set.remove(at: lower)
        _ = set[lower...]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiSetでlowerがupperより大きい場合、subscript erase(where:)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        let lower = set.index(set.startIndex, offsetBy: 6)
        let upper = set.index(set.startIndex, offsetBy: 2)
        set[lower..<upper].erase(where: { _ in false })
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiSetでlowerがupperより大きい場合、set.erase(where:)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        let lower = set.index(set.startIndex, offsetBy: 6)
        let upper = set.index(set.startIndex, offsetBy: 2)
        set.erase(lower..<upper) { _ in false }
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiSetでlowerがupperより大きい場合、set.eraseがSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        let lower = set.index(set.startIndex, offsetBy: 6)
        let upper = set.index(set.startIndex, offsetBy: 2)
        _ = set.erase(lower..<upper)
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiSetでIndexRangeを別の木に対して使った場合、subscript getがSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let source = RedBlackTreeMultiSet<Int>([0, 1, 1, 2, 3])
        let range = source.equalRange(1)
        let target = RedBlackTreeMultiSet<Int>([10, 11, 12])
        _ = target[range]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiSetでIndexRangeを別の木に対して使った場合、subscript _modifyがSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let source = RedBlackTreeMultiSet<Int>([0, 1, 1, 2, 3])
        let range = source.equalRange(1)
        var target = RedBlackTreeMultiSet<Int>([10, 11, 12])
        target[range].erase(where: { _ in false })
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiSetでIndexRangeを別の木に対して使った場合、set.eraseがSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let source = RedBlackTreeMultiSet<Int>([0, 1, 1, 2, 3])
        let range = source.equalRange(1)
        var target = RedBlackTreeMultiSet<Int>([10, 11, 12])
        target.erase(range)
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiSetでIndexRangeを別の木に対して使った場合、set.erase(where:)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let source = RedBlackTreeMultiSet<Int>([0, 1, 1, 2, 3])
        let range = source.equalRange(1)
        var target = RedBlackTreeMultiSet<Int>([10, 11, 12])
        target.erase(range) { _ in false }
      }

      expectNoInvalidMemoryAccess(result)
    }

    // insert(_:hint:)の境界hintは有効なhintであり、プロセスは正常終了しなければならない。
    // 修正前に停止していた経路を本体ランナーから隔離して検証する。

    @Test
    func insertWithEndIndexHintIntoNonEmptyMultiSet_exitsSuccessfully() async {
      await #expect(processExitsWith: .success) {
        var set = RedBlackTreeMultiSet<Int>([10])
        let index = set.insert(20, hint: set.endIndex)
        precondition(set[index] == 20)
        precondition(Array(set) == [10, 20])
      }
    }

    @Test
    func insertNewLeastWithStartIndexHint_exitsSuccessfully() async {
      await #expect(processExitsWith: .success) {
        var set = RedBlackTreeMultiSet<Int>([10, 20])
        let index = set.insert(5, hint: set.startIndex)
        precondition(index == set.startIndex)
        precondition(Array(set) == [5, 10, 20])
      }
    }

    @Test
    func insertEquivalentToFirstWithStartIndexHint_exitsSuccessfully() async {
      await #expect(processExitsWith: .success) {
        var set = RedBlackTreeMultiSet<Int>([10, 20])
        let index = set.insert(10, hint: set.startIndex)
        precondition(index == set.startIndex)
        precondition(Array(set) == [10, 10, 20])
      }
    }

    @Test
    func insertWithHintIntoEmptyMultiSet_exitsSuccessfully() async {
      await #expect(processExitsWith: .success) {
        var set = RedBlackTreeMultiSet<Int>()
        precondition(set.startIndex == set.endIndex)
        let index = set.insert(10, hint: set.endIndex)
        precondition(set[index] == 10)
        precondition(Array(set) == [10])
      }
    }

    @Test
    func endIndexSubscript_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        let set = RedBlackTreeMultiSet<Int>([0, 1, 2])
        _ = set[set.endIndex]
      }
    }

    @Test
    func `MultiSetでClosedRange(endIndex...startIndex)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let set = RedBlackTreeMultiSet<Int>([0, 1, 2])
        _ = set[set.endIndex...set.startIndex]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiSetでClosedRange(startIndex...endIndex)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let set = RedBlackTreeMultiSet<Int>([0, 1, 2])
        _ = set[set.startIndex...set.endIndex]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func indexBeforeStartIndex_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let set = RedBlackTreeMultiSet<Int>(0..<10)
        var i = set.startIndex
        i = set.index(before: i)
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func indexAfterEndIndex_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let set = RedBlackTreeMultiSet<Int>(0..<10)
        var i = set.endIndex
        i = set.index(after: i)
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func indexOffsetByBeyondBounds_terminatesWithoutInvalidMemoryAccess() async {
      let result1 = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let set = RedBlackTreeMultiSet<Int>(0..<10)
        var i = set.startIndex
        i = set.index(i, offsetBy: -1)
      }
      expectNoInvalidMemoryAccess(result1)

      let result2 = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let set = RedBlackTreeMultiSet<Int>(0..<10)
        var i = set.endIndex
        i = set.index(i, offsetBy: 1)
      }
      expectNoInvalidMemoryAccess(result2)
    }

    @Test
    func indexOffsetByLimitedByBeyondBounds_terminatesWithoutInvalidMemoryAccess() async {
      let result1 = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let set = RedBlackTreeMultiSet<Int>(0..<10)
        let i = set.startIndex
        _ = set.index(i, offsetBy: -1, limitedBy: set.endIndex)
      }
      expectNoInvalidMemoryAccess(result1)

      let result2 = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let set = RedBlackTreeMultiSet<Int>(0..<10)
        let i = set.endIndex
        _ = set.index(i, offsetBy: 1, limitedBy: set.startIndex)
      }
      expectNoInvalidMemoryAccess(result2)
    }

    @Test
    func formIndexOffsetByLimitedByBeyondBounds_terminatesWithoutInvalidMemoryAccess() async {
      let result1 = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let set = RedBlackTreeMultiSet<Int>(0..<10)
        var i = set.startIndex
        _ = set.formIndex(&i, offsetBy: -1, limitedBy: set.endIndex)
      }
      expectNoInvalidMemoryAccess(result1)

      let result2 = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let set = RedBlackTreeMultiSet<Int>(0..<10)
        var i = set.endIndex
        _ = set.formIndex(&i, offsetBy: 1, limitedBy: set.startIndex)
      }
      expectNoInvalidMemoryAccess(result2)
    }
  }
#endif  // DEATH_TEST && !COMPATIBLE_ATCODER_2025

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import Testing
  #if canImport(Darwin)
    import Darwin
  #elseif canImport(Glibc)
    import Glibc
  #endif

  struct RedBlackTreeMultiSetRangePredicatePropagationTests {
    // A subprocess keeps the pre-fix fatalError from terminating the test runner.
    @Test func predicateErrorPropagatesFromIndexRange() async {
      await #expect(processExitsWith: .exitCode(0)) {
        struct PredicateFailure: Error {}
        let original = RedBlackTreeMultiSet([1, 2, 3])
        var receiver = original
        let lo = receiver.startIndex
        let hi = receiver.endIndex
        var calls = 0
        do {
          try receiver.erase(lo..<hi, where: { _ in
            calls += 1
            if calls == 2 { throw PredicateFailure() }
            return true
          })
          exit(81) // Returning normally would swallow the error.
        } catch is PredicateFailure {
          guard calls == 2, original.count == 3 else { exit(82) }
          exit(0)
        } catch {
          exit(83) // The original error must not be replaced.
        }
      }
    }
    // A subprocess keeps the pre-fix fatalError from terminating the test runner.
    @Test func predicateErrorPropagatesFromIndexRangeExpression() async {
      await #expect(processExitsWith: .exitCode(0)) {
        struct PredicateFailure: Error {}
        let original = RedBlackTreeMultiSet([1, 2, 3])
        var receiver = original
        let lo = receiver.startIndex
        var calls = 0
        do {
          try receiver.erase(lo..., where: { _ in
            calls += 1
            if calls == 2 { throw PredicateFailure() }
            return true
          })
          exit(81) // Returning normally would swallow the error.
        } catch is PredicateFailure {
          guard calls == 2, original.count == 3 else { exit(82) }
          exit(0)
        } catch {
          exit(83) // The original error must not be replaced.
        }
      }
    }
  }
#endif

#if DEATH_TEST && ENABLE_OFFSET_OVERFLOW_GUARD && !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSetDeathTests {
    // RBT-076: 確保サイズが桁あふれする容量は、確保前に停止すること。
    @Test func extremeMinimumCapacity_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = RedBlackTreeMultiSet<Int>(minimumCapacity: Int.max)
      }
    }
  }
#endif

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSetDeathTests {
    // 同じキーの並びの中で前後が逆になったIndex範囲は、ビューを作らずに停止すること。
    @Test func invertedIndexRangeWithinEqualKeys_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        let multiset: RedBlackTreeMultiSet = [0, 1, 1, 1, 2]
        let first = multiset.index(after: multiset.startIndex)
        let second = multiset.index(after: first)
        _ = multiset[second..<first]
      }
    }
  }
#endif

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSetDeathTests {
    // RBT-047/048: 共有中でも、無効なIndexや==が成り立たない値による更新は停止すること。
    @Test
    func updatingSharedWithNonEquivalentMember_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeMultiSet([1, 2, 3])
        let shared = set
        withExtendedLifetime(shared) {
          set.update(99, at: set.startIndex)
        }
      }
    }

    @Test
    func updatingSharedEndIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeMultiSet([1, 2, 3])
        let shared = set
        withExtendedLifetime(shared) {
          set.update(1, at: set.endIndex)
        }
      }
    }

    @Test
    func updatingSharedRemovedIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeMultiSet([1, 1, 1])
        let removed = set.index(after: set.startIndex)
        set.remove(at: removed)
        let shared = set
        withExtendedLifetime(shared) {
          set.update(1, at: removed)
        }
      }
    }
  }
#endif

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  /// 消したときに文字列の領域が解放されるよう、毎回新しく作る要素。
  private func freshElement(_ c: Character) -> String {
    String(repeating: c, count: 40)
  }
#endif

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  /// 容量を保ったまま全削除したMultiSetと、削除前に取ったIndex・IndexRange。
  private func multiSetAfterRemoveAllKeepingCapacity()
    -> (tree: RedBlackTreeMultiSet<String>, stale: RedBlackTreeMultiSet<String>.Index, staleRange: RedBlackTreeIndexRange)
  {
    var t = RedBlackTreeMultiSet<String>()
    for c in "abc" { t.insert(freshElement(c)) }
    let stale = t.index(after: t.startIndex)
    let staleRange = t.equalRange(freshElement("b"))
    t.removeAll(keepingCapacity: true)
    t.insert(freshElement("x"))
    return (t, stale, staleRange)
  }

  // RBT-104: 範囲を受け取るAPIに、容量保持の全削除より前に取ったIndex・IndexRangeを渡しても、破棄済みの中身を読む前に停止すること。
  struct RedBlackTreeMultiSetRemoveAllKeepingCapacityDeathTests {

    @Test
    func containsSubrangeIndexRange_returnsFalse() {
      let (t, _, staleRange) = multiSetAfterRemoveAllKeepingCapacity()
      #expect(!t.containsSubrange(staleRange))
    }

    @Test
    func containsSubrangeExpression_returnsFalse() {
      let (t, stale, _) = multiSetAfterRemoveAllKeepingCapacity()
      #expect(!t.containsSubrange(stale..<t.endIndex))
    }

    @Test
    func subscriptIndexRangeFirst_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (t, _, staleRange) = multiSetAfterRemoveAllKeepingCapacity()
        _ = t[staleRange].first
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func subscriptExpressionFirst_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (t, stale, _) = multiSetAfterRemoveAllKeepingCapacity()
        _ = t[stale..<t.endIndex].first
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func eraseIndexRange_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, _, staleRange) = multiSetAfterRemoveAllKeepingCapacity()
        _ = t.erase(staleRange)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func eraseExpression_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, stale, _) = multiSetAfterRemoveAllKeepingCapacity()
        _ = t.erase(stale..<t.endIndex)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func eraseIndexRangeWhere_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, _, staleRange) = multiSetAfterRemoveAllKeepingCapacity()
        _ = t.erase(staleRange, where: { _ in true })
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func eraseExpressionWhere_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, stale, _) = multiSetAfterRemoveAllKeepingCapacity()
        _ = t.erase(stale..<t.endIndex, where: { _ in true })
      }
      expectNoInvalidMemoryAccess(result)
    }
  }
#endif
