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
