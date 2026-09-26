//
//  RangeExpressionInvalidIndexDictionaryTests.swift
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

  struct RangeExpressionInvalidIndexDictionaryTests {

    @Test
    func `Dictionaryでlowerがupperより大きい場合、SIGSEGV以外の方法で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let dict: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
        let lower = dict.index(dict.startIndex, offsetBy: 3)
        let upper = dict.index(dict.startIndex, offsetBy: 1)
        _ = dict[lower..<upper]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `Dictionaryで削除済みインデックスを使った場合、SIGSEGV以外の方法で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var dict: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
        let lower = dict.index(dict.startIndex, offsetBy: 2)
        dict.remove(at: lower)
        _ = dict[lower...]
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `Dictionaryでlowerがupperより大きい場合、subscript erase(where:)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var dict: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
        let lower = dict.index(dict.startIndex, offsetBy: 3)
        let upper = dict.index(dict.startIndex, offsetBy: 1)
        dict[lower..<upper].erase(where: { _ in false })
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `Dictionaryでlowerがupperより大きい場合、dict.erase(where:)がSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var dict: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
        let lower = dict.index(dict.startIndex, offsetBy: 3)
        let upper = dict.index(dict.startIndex, offsetBy: 1)
        dict.erase(lower..<upper) { _ in false }
      }

      expectNoInvalidMemoryAccess(result)
    }

    @Test
    func `Dictionaryでlowerがupperより大きい場合、dict.eraseがSIGSEGV以外で停止すること`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var dict: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
        let lower = dict.index(dict.startIndex, offsetBy: 3)
        let upper = dict.index(dict.startIndex, offsetBy: 1)
        _ = dict.erase(lower..<upper)
      }

      expectNoInvalidMemoryAccess(result)
    }
  }
#endif  // DEATH_TEST && !COMPATIBLE_ATCODER_2025
