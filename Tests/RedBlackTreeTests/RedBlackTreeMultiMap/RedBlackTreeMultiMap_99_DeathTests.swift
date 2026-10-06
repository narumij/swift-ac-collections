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
