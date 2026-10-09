//
//  RangeExpressionInvalidIndexMultiSetTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEATH_TEST
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
#endif
