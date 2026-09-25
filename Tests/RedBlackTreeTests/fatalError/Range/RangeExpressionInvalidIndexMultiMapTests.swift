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

  struct RangeExpressionInvalidIndexMultiMapTests {

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
  }
#endif  // DEATH_TEST && !COMPATIBLE_ATCODER_2025
