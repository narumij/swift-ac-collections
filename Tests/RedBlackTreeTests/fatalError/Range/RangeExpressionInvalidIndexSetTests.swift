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

  struct RangeExpressionInvalidIndexSetTests {

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
