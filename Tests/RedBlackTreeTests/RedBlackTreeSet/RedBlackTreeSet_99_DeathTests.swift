//
//  RangeExpressionInvalidIndexTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Foundation
  import RedBlackTreeCollections
  import Testing

  #if canImport(Darwin)
    import Darwin
  #elseif canImport(Glibc)
    import Glibc
  #endif

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

  struct RedBlackTreeSetDeathTests {

    #if !COMPATIBLE_ATCODER_2025
      /// 空のSetでも、他の木の要素を指すIndex範囲のeraseは検査で停止すること
      /// (空のときにCoWを省いても、範囲の検査は省かない)。
      @Test
      func erasingForeignRangeFromEmptySet_terminatesProcess() async {
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let source = RedBlackTreeSet(0..<8)
          var target = RedBlackTreeSet<Int>()
          let lower = source.index(source.startIndex, offsetBy: 2)
          let upper = source.index(source.startIndex, offsetBy: 6)
          target.erase(lower..<upper)
        }
      }
    #endif

    @Test
    func emptyStartIndexSubscript_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        let set = RedBlackTreeSet<Int>()
        _ = set[set.startIndex]
      }
    }

    @Test
    func removingEmptyStartIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeSet<Int>()
        set.remove(at: set.startIndex)
      }
    }

    @Test
    func removingEndIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeSet<Int>(0..<100)
        set.remove(at: set.endIndex)
      }
    }

    @Test
    func removingAnAlreadyRemovedIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeSet<Int>(0..<100)
        let removed = set.startIndex
        set.remove(at: removed)
        set.remove(at: removed)
      }
    }

    @Test
    func staleIndexSubscript_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var set = RedBlackTreeSet<Int>(0..<8)
        let stale = set.index(set.startIndex, offsetBy: 3)
        set.remove(at: stale)
        _ = set[stale]
      }

      expectNoInvalidMemoryAccess(result)

      guard let result else { return }
      let stderr = String(decoding: result.standardErrorContent, as: UTF8.self)
      #expect(stderr.contains("The pointer is being used as a different node"))
    }

    @Test
    func advancingStaleIndex_reportsReasonWithoutInvalidMemoryAccess() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var set = RedBlackTreeSet<Int>(0..<8)
        let stale = set.index(set.startIndex, offsetBy: 3)
        set.remove(at: stale)
        _ = set.index(after: stale)
      }

      expectNoInvalidMemoryAccess(result)

      guard let result else { return }
      let stderr = String(decoding: result.standardErrorContent, as: UTF8.self)
      #expect(stderr.contains("The pointer is being used as a different node"))
    }

    @Test
    func removingFirstFromEmptySet_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeSet<Int>()
        set.removeFirst()
      }
    }

    @Test
    func removingLastFromEmptySet_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeSet<Int>()
        set.removeLast()
      }
    }

    #if !ALLOW_CROSS_TREE_INDEX
      @Test
      func erasingRangeFromAnotherSet_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let source = RedBlackTreeSet(0..<8)
          var target = RedBlackTreeSet(100..<108)
          let lower = source.index(source.startIndex, offsetBy: 2)
          let upper = source.index(source.startIndex, offsetBy: 6)
          target.erase(lower..<upper)
        }
      }
    #endif

    @Test
    func `RangeExpressionでlowerがupperより大きい場合、SIGSEGV以外の方法で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let set = RedBlackTreeSet<Int>(0..<10)
        let lower = set.index(set.startIndex, offsetBy: 6)
        let upper = set.index(set.startIndex, offsetBy: 2)
        _ = set[lower..<upper]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `RangeExpressionでlowerがupperより大きい場合、SIGSEGV以外の方法で停止すること2`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var set = RedBlackTreeSet<Int>(0..<10)
        let lower = set.index(set.startIndex, offsetBy: 6)
        let upper = set.index(set.startIndex, offsetBy: 2)
        set[lower..<upper].erase()
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `RangeExpressionで削除済みインデックスを使った場合、SIGSEGV以外の方法で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var set = RedBlackTreeSet<Int>(0..<10)
        let lower = set.index(set.startIndex, offsetBy: 3)
        set.remove(at: lower)
        _ = set[lower...]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `RangeExpressionで削除済みインデックスを使った場合、SIGSEGV以外の方法で停止すること2`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var set = RedBlackTreeSet<Int>(0..<10)
        let lower = set.index(set.startIndex, offsetBy: 3)
        set.remove(at: lower)
        set[lower...].erase()
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `RangeExpressionでlowerがupperより大きい場合、subscript erase(where:)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var set = RedBlackTreeSet<Int>(0..<10)
        let lower = set.index(set.startIndex, offsetBy: 6)
        let upper = set.index(set.startIndex, offsetBy: 2)
        set[lower..<upper].erase(where: { _ in false })
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `RangeExpressionでlowerがupperより大きい場合、set.erase(where:)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var set = RedBlackTreeSet<Int>(0..<10)
        let lower = set.index(set.startIndex, offsetBy: 6)
        let upper = set.index(set.startIndex, offsetBy: 2)
        set.erase(lower..<upper) { _ in false }
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `RangeExpressionでlowerがupperより大きい場合、set.eraseがSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var set = RedBlackTreeSet<Int>(0..<10)
        let lower = set.index(set.startIndex, offsetBy: 6)
        let upper = set.index(set.startIndex, offsetBy: 2)
        set.erase(lower..<upper)
      }

      expectNoInvalidMemoryAccess(result)
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

  struct RedBlackTreeSetRangePredicatePropagationTests {
    // A subprocess keeps the pre-fix fatalError from terminating the test runner.
    @Test func predicateErrorPropagatesFromIndexRange() async {
      await #expect(processExitsWith: .exitCode(0)) {
        struct PredicateFailure: Error {}
        let original = RedBlackTreeSet([1, 2, 3])
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
        let original = RedBlackTreeSet([1, 2, 3])
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
  extension RedBlackTreeSetDeathTests {
    // RBT-076: 確保サイズが桁あふれする容量は、確保前に停止すること。
    @Test func extremeMinimumCapacity_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = RedBlackTreeSet<Int>(minimumCapacity: Int.max)
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

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025 && !USE_LAZY_DETACH
  /// 容量を保ったまま全削除したSetと、削除前に取ったIndex・IndexRange。
  private func setAfterRemoveAllKeepingCapacity()
    -> (tree: RedBlackTreeSet<String>, stale: RedBlackTreeSet<String>.Index, staleRange: RedBlackTreeIndexRange)
  {
    var t = RedBlackTreeSet<String>()
    for c in "abc" { t.insert(freshElement(c)) }
    let stale = t.index(after: t.startIndex)
    let staleRange = t.equalRange(freshElement("b"))
    t.removeAll(keepingCapacity: true)
    t.insert(freshElement("x"))
    return (t, stale, staleRange)
  }

  // RBT-104: 容量保持の全削除より前に取ったIndex・IndexRangeを渡しても、破棄済みの中身や古いリンクを読む前に停止すること。
  struct RedBlackTreeSetRemoveAllKeepingCapacityDeathTests {

    @Test
    func isElement_returnsFalse() {
      let (t, stale, _) = setAfterRemoveAllKeepingCapacity()
      #expect(!t.isElement(at: stale))
    }

    @Test
    func containsSubrangeIndexRange_returnsFalse() {
      let (t, _, staleRange) = setAfterRemoveAllKeepingCapacity()
      #expect(!t.containsSubrange(staleRange))
    }

    @Test
    func containsSubrangeExpression_returnsFalse() {
      let (t, stale, _) = setAfterRemoveAllKeepingCapacity()
      #expect(!t.containsSubrange(stale..<t.endIndex))
    }

    @Test
    func subscript_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (t, stale, _) = setAfterRemoveAllKeepingCapacity()
        _ = t[stale]
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func distance_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (t, stale, _) = setAfterRemoveAllKeepingCapacity()
        _ = t.distance(from: t.startIndex, to: stale)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func indexAfter_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (t, stale, _) = setAfterRemoveAllKeepingCapacity()
        _ = t.index(after: stale)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func indexBefore_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (t, stale, _) = setAfterRemoveAllKeepingCapacity()
        _ = t.index(before: stale)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func insertWithHint_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, stale, _) = setAfterRemoveAllKeepingCapacity()
        _ = t.insert(freshElement("y"), hint: stale)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func updateWithHint_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, stale, _) = setAfterRemoveAllKeepingCapacity()
        _ = t.update(freshElement("y"), hint: stale)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func subscriptIndexRangeFirst_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (t, _, staleRange) = setAfterRemoveAllKeepingCapacity()
        _ = t[staleRange].first
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func subscriptExpressionFirst_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (t, stale, _) = setAfterRemoveAllKeepingCapacity()
        _ = t[stale..<t.endIndex].first
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func eraseIndexRange_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, _, staleRange) = setAfterRemoveAllKeepingCapacity()
        _ = t.erase(staleRange)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func eraseExpression_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, stale, _) = setAfterRemoveAllKeepingCapacity()
        _ = t.erase(stale..<t.endIndex)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func eraseIndexRangeWhere_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, _, staleRange) = setAfterRemoveAllKeepingCapacity()
        _ = t.erase(staleRange, where: { _ in true })
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func eraseExpressionWhere_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, stale, _) = setAfterRemoveAllKeepingCapacity()
        _ = t.erase(stale..<t.endIndex, where: { _ in true })
      }
      expectNoInvalidMemoryAccess(result)
    }
  }
#endif

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025 && USE_COMPACT_NODE_METADATA
  /// 同じ場所を65536回使い回したあとに残る、最初に消した要素のIndex。
  private func indexAfterSlotReused65536Times()
    -> (set: RedBlackTreeSet<String>, stale: RedBlackTreeSet<String>.Index)
  {
    var set = RedBlackTreeSet<String>()
    set.insert(freshElement("a"))
    set.insert(freshElement("c"))
    set.insert(freshElement("b"))
    let stale = set.firstIndex(of: freshElement("b"))!
    set.remove(freshElement("b"))
    for _ in 0..<65535 {
      set.insert(freshElement("b"))
      set.remove(freshElement("b"))
    }
    return (set, stale)
  }

  // RBT-104: 同じ場所を何度使い回しても、消した要素のIndexは中身や古いリンクを読む前に停止すること。
  struct RedBlackTreeSetHeavilyReusedSlotDeathTests {

    @Test
    func isElement_returnsFalse() {
      let (set, stale) = indexAfterSlotReused65536Times()
      #expect(!set.isElement(at: stale))
    }

    @Test
    func containsSubrange_returnsFalse() {
      let (set, stale) = indexAfterSlotReused65536Times()
      #expect(!set.containsSubrange(stale..<set.endIndex))
    }

    @Test
    func removeAllKeepingCapacity_succeeds() {
      var (set, _) = indexAfterSlotReused65536Times()
      set.insert(freshElement("b"))
      set.removeAll(keepingCapacity: true)
      #expect(set.isEmpty)
    }

    @Test
    func subscript_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (set, stale) = indexAfterSlotReused65536Times()
        _ = set[stale]
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func distance_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (set, stale) = indexAfterSlotReused65536Times()
        _ = set.distance(from: set.startIndex, to: stale)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func indexAfter_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (set, stale) = indexAfterSlotReused65536Times()
        _ = set.index(after: stale)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func indexBefore_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (set, stale) = indexAfterSlotReused65536Times()
        _ = set.index(before: stale)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func insertWithHint_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (set, stale) = indexAfterSlotReused65536Times()
        _ = set.insert(freshElement("y"), hint: stale)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func updateWithHint_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (set, stale) = indexAfterSlotReused65536Times()
        _ = set.update(freshElement("y"), hint: stale)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func viewFirst_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (set, stale) = indexAfterSlotReused65536Times()
        _ = set[stale..<set.endIndex].first
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func eraseRange_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (set, stale) = indexAfterSlotReused65536Times()
        _ = set.erase(stale..<set.endIndex)
      }
      expectNoInvalidMemoryAccess(result)
    }
  }
#endif
