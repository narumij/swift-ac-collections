//
//  RangeExpressionInvalidIndexMultiMapTests.swift
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

  struct RedBlackTreeMultiMapDeathTests {

    // RBT-048: Index-based replacement requires a valid element index.
    @Test
    func updatingEndIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var map = RedBlackTreeMultiMap<Int, Int>(keysWithValues: [(1, 10), (2, 20), (3, 30)])
        map.updateValue(100, at: map.endIndex)
      }
    }

    @Test
    func updatingRemovedIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var map = RedBlackTreeMultiMap<Int, Int>(keysWithValues: [(1, 10), (2, 20), (3, 30)])
        let index = map.startIndex
        map.remove(at: index)
        map.updateValue(100, at: index)
      }
    }


    #if !COMPATIBLE_ATCODER_2025
      /// 空のMultiMapでも、他の木の要素を指すIndex範囲のeraseは検査で停止すること
      /// (空のときにCoWを省いても、範囲の検査は省かない)。
      @Test
      func erasingForeignRangeFromEmptyMultiMap_terminatesProcess() async {
        await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
          let source = RedBlackTreeMultiMap<Int, String>(
            keysWithValues: (0..<8).map { ($0, "\($0)") })
          var target = RedBlackTreeMultiMap<Int, String>()
          let lower = source.index(source.startIndex, offsetBy: 2)
          let upper = source.index(source.startIndex, offsetBy: 6)
          target.erase(lower..<upper)
        }
      }
    #endif

    @Test
    func emptyStartIndexSubscript_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        let map = RedBlackTreeMultiMap<Int, Int>()
        _ = map[map.startIndex]
      }
    }

    @Test
    func removingEmptyStartIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var map = RedBlackTreeMultiMap<Int, Int>()
        map.remove(at: map.startIndex)
      }
    }

    @Test
    func removingEndIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var map = RedBlackTreeMultiMap<Int, Int>(keysWithValues: (0..<100).map { ($0, $0) })
        map.remove(at: map.endIndex)
      }
    }

    @Test
    func removingFirstFromEmptyMultiMap_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var map = RedBlackTreeMultiMap<Int, Int>()
        map.removeFirst()
      }
    }

    @Test
    func removingLastFromEmptyMultiMap_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var map = RedBlackTreeMultiMap<Int, Int>()
        map.removeLast()
      }
    }

    @Test
    func `MultiMapでlowerがupperより大きい場合、SIGSEGV以外の方法で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
        let lower = map.index(map.startIndex, offsetBy: 3)
        let upper = map.index(map.startIndex, offsetBy: 1)
        _ = map[lower..<upper]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiMapで削除済みインデックスを使った場合、SIGSEGV以外の方法で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
        let lower = map.index(map.startIndex, offsetBy: 2)
        map.remove(at: lower)
        _ = map[lower...]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiMapでlowerがupperより大きい場合、subscript erase(where:)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
        let lower = map.index(map.startIndex, offsetBy: 3)
        let upper = map.index(map.startIndex, offsetBy: 1)
        map[lower..<upper].erase(where: { _ in false })
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiMapでlowerがupperより大きい場合、map.erase(where:)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
        let lower = map.index(map.startIndex, offsetBy: 3)
        let upper = map.index(map.startIndex, offsetBy: 1)
        map.erase(lower..<upper) { _ in false }
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiMapでlowerがupperより大きい場合、map.eraseがSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
        let lower = map.index(map.startIndex, offsetBy: 3)
        let upper = map.index(map.startIndex, offsetBy: 1)
        _ = map.erase(lower..<upper)
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiMapでIndexRangeを別の木に対して使った場合、subscript getがSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let source: RedBlackTreeMultiMap = [0: "a", 1: "b", 1: "c", 2: "d"]
        let range = source.equalRange(1)
        let target: RedBlackTreeMultiMap = [10: "x", 11: "y", 12: "z"]
        _ = target[range]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiMapでIndexRangeを別の木に対して使った場合、subscript _modifyがSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let source: RedBlackTreeMultiMap = [0: "a", 1: "b", 1: "c", 2: "d"]
        let range = source.equalRange(1)
        var target: RedBlackTreeMultiMap = [10: "x", 11: "y", 12: "z"]
        target[range].erase(where: { _ in false })
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiMapでIndexRangeを別の木に対して使った場合、map.eraseがSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let source: RedBlackTreeMultiMap = [0: "a", 1: "b", 1: "c", 2: "d"]
        let range = source.equalRange(1)
        var target: RedBlackTreeMultiMap = [10: "x", 11: "y", 12: "z"]
        target.erase(range)
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiMapでIndexRangeを別の木に対して使った場合、map.erase(where:)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let source: RedBlackTreeMultiMap = [0: "a", 1: "b", 1: "c", 2: "d"]
        let range = source.equalRange(1)
        var target: RedBlackTreeMultiMap = [10: "x", 11: "y", 12: "z"]
        target.erase(range) { _ in false }
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func endIndexSubscript_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        let map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c"]
        _ = map[map.endIndex]
      }
    }

    @Test
    func `MultiMapでClosedRange(endIndex...startIndex)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c"]
        _ = map[map.endIndex...map.startIndex]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `MultiMapでClosedRange(startIndex...endIndex)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let map: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c"]
        _ = map[map.startIndex...map.endIndex]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func indexBeforeStartIndex_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let map: RedBlackTreeMultiMap = (0..<10).map { ($0, $0) }.reduce(into: RedBlackTreeMultiMap<Int, Int>()) { $0.insert(key: $1.0, value: $1.1) }
        var i = map.startIndex
        i = map.index(before: i)
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func indexAfterEndIndex_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let map: RedBlackTreeMultiMap = (0..<10).map { ($0, $0) }.reduce(into: RedBlackTreeMultiMap<Int, Int>()) { $0.insert(key: $1.0, value: $1.1) }
        var i = map.endIndex
        i = map.index(after: i)
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func indexOffsetByBeyondBounds_terminatesWithoutInvalidMemoryAccess() async {
      let result1 = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let map: RedBlackTreeMultiMap = (0..<10).map { ($0, $0) }.reduce(into: RedBlackTreeMultiMap<Int, Int>()) { $0.insert(key: $1.0, value: $1.1) }
        var i = map.startIndex
        i = map.index(i, offsetBy: -1)
      }
      expectNoInvalidMemoryAccess(result1)

      let result2 = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let map: RedBlackTreeMultiMap = (0..<10).map { ($0, $0) }.reduce(into: RedBlackTreeMultiMap<Int, Int>()) { $0.insert(key: $1.0, value: $1.1) }
        var i = map.endIndex
        i = map.index(i, offsetBy: 1)
      }
      expectNoInvalidMemoryAccess(result2)
    }

    @Test
    func indexOffsetByLimitedByBeyondBounds_terminatesWithoutInvalidMemoryAccess() async {
      let result1 = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let map: RedBlackTreeMultiMap = (0..<10).map { ($0, $0) }.reduce(into: RedBlackTreeMultiMap<Int, Int>()) { $0.insert(key: $1.0, value: $1.1) }
        let i = map.startIndex
        _ = map.index(i, offsetBy: -1, limitedBy: map.endIndex)
      }
      expectNoInvalidMemoryAccess(result1)

      let result2 = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let map: RedBlackTreeMultiMap = (0..<10).map { ($0, $0) }.reduce(into: RedBlackTreeMultiMap<Int, Int>()) { $0.insert(key: $1.0, value: $1.1) }
        let i = map.endIndex
        _ = map.index(i, offsetBy: 1, limitedBy: map.startIndex)
      }
      expectNoInvalidMemoryAccess(result2)
    }

    @Test
    func formIndexOffsetByLimitedByBeyondBounds_terminatesWithoutInvalidMemoryAccess() async {
      let result1 = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let map: RedBlackTreeMultiMap = (0..<10).map { ($0, $0) }.reduce(into: RedBlackTreeMultiMap<Int, Int>()) { $0.insert(key: $1.0, value: $1.1) }
        var i = map.startIndex
        _ = map.formIndex(&i, offsetBy: -1, limitedBy: map.endIndex)
      }
      expectNoInvalidMemoryAccess(result1)

      let result2 = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let map: RedBlackTreeMultiMap = (0..<10).map { ($0, $0) }.reduce(into: RedBlackTreeMultiMap<Int, Int>()) { $0.insert(key: $1.0, value: $1.1) }
        var i = map.endIndex
        _ = map.formIndex(&i, offsetBy: 1, limitedBy: map.startIndex)
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

  struct RedBlackTreeMultiMapRangePredicatePropagationTests {
    // A subprocess keeps the pre-fix fatalError from terminating the test runner.
    @Test func predicateErrorPropagatesFromIndexRange() async {
      await #expect(processExitsWith: .exitCode(0)) {
        struct PredicateFailure: Error {}
        let original = RedBlackTreeMultiMap<Int, Int>(keysWithValues: [(1, 10), (2, 20), (3, 30)])
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
        let original = RedBlackTreeMultiMap<Int, Int>(keysWithValues: [(1, 10), (2, 20), (3, 30)])
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
  extension RedBlackTreeMultiMapDeathTests {
    // RBT-076: 確保サイズが桁あふれする容量は、確保前に停止すること。
    @Test func extremeMinimumCapacity_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = RedBlackTreeMultiMap<Int, Int>(minimumCapacity: Int.max)
      }
    }
  }
#endif

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMapDeathTests {
    // 同じキーの並びの中で前後が逆になったIndex範囲は、ビューを作らずに停止すること。
    @Test func invertedIndexRangeWithinEqualKeys_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        let map: RedBlackTreeMultiMap = [(0, "z"), (1, "a"), (1, "b"), (1, "c"), (2, "x")]
        let first = map.index(after: map.startIndex)
        let second = map.index(after: first)
        _ = map[second..<first]
      }
    }
  }
#endif

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMapDeathTests {
    // RBT-047/048: 共有中でも、無効なIndexによる値の更新は停止すること。
    @Test
    func updatingSharedEndIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var map = RedBlackTreeMultiMap<Int, String>(keysWithValues: [(1, "a")])
        let shared = map
        withExtendedLifetime(shared) {
          map.updateValue("x", at: map.endIndex)
        }
      }
    }

    @Test
    func updatingSharedRemovedIndex_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var map = RedBlackTreeMultiMap<Int, String>(keysWithValues: [(1, "a"), (1, "b")])
        let removed = map.startIndex
        map.remove(at: removed)
        let shared = map
        withExtendedLifetime(shared) {
          map.updateValue("x", at: removed)
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

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025 && !USE_LAZY_DETACH
  /// 容量を保ったまま全削除したMultiMapと、削除前に取ったIndex・IndexRange。
  private func multiMapAfterRemoveAllKeepingCapacity()
    -> (tree: RedBlackTreeMultiMap<String, String>, stale: RedBlackTreeMultiMap<String, String>.Index, staleRange: RedBlackTreeIndexRange)
  {
    var t = RedBlackTreeMultiMap<String, String>()
    for c in "abc" { t.insert(key: freshElement(c), value: freshElement(c)) }
    let stale = t.index(after: t.startIndex)
    let staleRange = t.equalRange(freshElement("b"))
    t.removeAll(keepingCapacity: true)
    t.insert(key: freshElement("x"), value: freshElement("x"))
    return (t, stale, staleRange)
  }

  // RBT-104: 範囲を受け取るAPIに、容量保持の全削除より前に取ったIndex・IndexRangeを渡しても、破棄済みの中身を読む前に停止すること。
  struct RedBlackTreeMultiMapRemoveAllKeepingCapacityDeathTests {

    @Test
    func containsSubrangeIndexRange_returnsFalse() {
      let (t, _, staleRange) = multiMapAfterRemoveAllKeepingCapacity()
      #expect(!t.containsSubrange(staleRange))
    }

    @Test
    func containsSubrangeExpression_returnsFalse() {
      let (t, stale, _) = multiMapAfterRemoveAllKeepingCapacity()
      #expect(!t.containsSubrange(stale..<t.endIndex))
    }

    @Test
    func subscriptIndexRangeFirst_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (t, _, staleRange) = multiMapAfterRemoveAllKeepingCapacity()
        _ = t[staleRange].first
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func subscriptExpressionFirst_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        let (t, stale, _) = multiMapAfterRemoveAllKeepingCapacity()
        _ = t[stale..<t.endIndex].first
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func eraseIndexRange_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, _, staleRange) = multiMapAfterRemoveAllKeepingCapacity()
        _ = t.erase(staleRange)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func eraseExpression_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, stale, _) = multiMapAfterRemoveAllKeepingCapacity()
        _ = t.erase(stale..<t.endIndex)
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func eraseIndexRangeWhere_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, _, staleRange) = multiMapAfterRemoveAllKeepingCapacity()
        _ = t.erase(staleRange, where: { _ in true })
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func eraseExpressionWhere_terminatesWithoutInvalidMemoryAccess() async {
      let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
        var (t, stale, _) = multiMapAfterRemoveAllKeepingCapacity()
        _ = t.erase(stale..<t.endIndex, where: { _ in true })
      }
      expectNoInvalidMemoryAccess(result)
    }
  }
#endif
