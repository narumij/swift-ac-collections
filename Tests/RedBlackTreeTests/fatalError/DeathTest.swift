//
//  Test.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/30.
//

#if DEATH_TEST
  import RedBlackTreeCollections
  import Testing

  #if canImport(Darwin)
    import Darwin
  #elseif canImport(Glibc)
    import Glibc
  #endif

  struct DeathTest {

    /// 異常終了した理由が、不正なメモリアクセスではないことを確認する。
    ///
    /// `fatalError` / `preconditionFailure` / `assert` などによる停止方法は問わない。
    /// Address Sanitizer 有効時には SIGABRT になる場合があるため、
    /// シグナルを固定せず、ASan の診断内容を確認する。
    private func expectNoInvalidMemoryAccess(_ result: ExitTest.Result?) {
      // #expect(processExitsWith:) 自体が失敗している場合は、
      // 既に issue が記録されているので重ねて報告しない。
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

    @Test func `endIndex cannot be subscripted`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let set: RedBlackTreeSet<Int> = [1, 2, 3]
        _ = set[set.endIndex]
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test func `removed index cannot be subscripted`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        var set: RedBlackTreeSet<Int> = [1, 2, 3]
        let index = set.firstIndex(of: 2)!
        set.remove(at: index)
        _ = set[index]
      }
      expectNoInvalidMemoryAccess(result)
    }

    // AtCoder 2025互換のUnsafeIndexV2は、ALLOW_CROSS_TREE_INDEXにかかわらず
    // 別の木に由来するインデックスを拒否しないため、通常モードでのみ検証する。
    #if !COMPATIBLE_ATCODER_2025 && !ALLOW_CROSS_TREE_INDEX
      @Test func `index from another tree cannot be subscripted`() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let set: RedBlackTreeSet<Int> = [1, 2, 3]
          let other: RedBlackTreeSet<Int> = [4, 5, 6]
          _ = set[other.startIndex]
        }
        expectNoInvalidMemoryAccess(result)
      }
    #endif

    @Test func `インデックスによる区間不正はtrapすること、その1`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let a = RedBlackTreeSet<Int>(0..<100)
        _ = a[a.lowerBound(50)...a.lowerBound(10)] + [] == []
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test func `インデックスによる区間不正はtrapすること、その2`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let a = RedBlackTreeSet<Int>(0..<100)
        _ = a[a.endIndex...a.startIndex] + [] == []
      }
      expectNoInvalidMemoryAccess(result)
    }

    @Test func `インデックスによる区間不正はtrapすること、その3`() async {
      let result = await #expect(
        processExitsWith: .failure,
        observing: [\.standardErrorContent]
      ) {
        let a = RedBlackTreeSet<Int>(0..<100)
        _ = a[a.startIndex...a.endIndex] + [] == []
      }
      expectNoInvalidMemoryAccess(result)
    }

    #if ENABLE_OFFSET_OVERFLOW_GUARD
      @Test func `オフセット計算のオーバーフロー限界を超えたサイズはトラップすること、その1`() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          _ = RedBlackTreeSet<Int>(minimumCapacity: Int.max)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test func `オフセット計算のオーバーフロー限界を超えたサイズはトラップすること、その2`() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          var a = RedBlackTreeSet<Int>()
          a.reserveCapacity(Int.max)
        }
        expectNoInvalidMemoryAccess(result)
      }

      @Test func `オフセット計算のオーバーフロー限界を超えたサイズはトラップすること、その3`() async {
        let result = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          var a = RedBlackTreeSet<Int>()
          let b = a
          a.reserveCapacity(Int.max)
          _ = b
        }
        expectNoInvalidMemoryAccess(result)
      }
    #endif

    #if !COMPATIBLE_ATCODER_2025
      @Test func `文字列のインデックス範囲外の挙動と同様にする、その1`() async {
        let result1 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let str = "abcdef"
          var i = str.startIndex
          i = str.index(before: i)
        }
        expectNoInvalidMemoryAccess(result1)

        let result2 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.startIndex
          i = a.index(before: i)
        }
        expectNoInvalidMemoryAccess(result2)
      }

      @Test func `文字列のインデックス範囲外の挙動と同様にする、その2`() async {
        let result1 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let str = "abcdef"
          var i = str.endIndex
          i = str.index(after: i)
        }
        expectNoInvalidMemoryAccess(result1)

        let result2 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.endIndex
          i = a.index(after: i)
        }
        expectNoInvalidMemoryAccess(result2)
      }

      @Test func `文字列のインデックス範囲外の挙動と同様にする、その3`() async {
        let result1 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let str = "abcdef"
          var i = str.startIndex
          i = str.index(i, offsetBy: -1)
        }
        expectNoInvalidMemoryAccess(result1)

        let result2 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let str = "abcdef"
          var i = str.endIndex
          i = str.index(i, offsetBy: 1)
        }
        expectNoInvalidMemoryAccess(result2)

        let result3 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.startIndex
          i = a.index(i, offsetBy: -1)
        }
        expectNoInvalidMemoryAccess(result3)

        let result4 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.endIndex
          i = a.index(i, offsetBy: 1)
        }
        expectNoInvalidMemoryAccess(result4)
      }

      @Test func `文字列のインデックス範囲外の挙動と同様にする、その4`() async {
        let result1 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let str = "abcdef"
          let i = str.startIndex
          _ = str.index(i, offsetBy: -1, limitedBy: str.endIndex)
        }
        expectNoInvalidMemoryAccess(result1)

        let result2 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let str = "abcdef"
          let i = str.endIndex
          _ = str.index(i, offsetBy: 1, limitedBy: str.startIndex)
        }
        expectNoInvalidMemoryAccess(result2)

        let result3 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let a = RedBlackTreeSet<Int>(0..<10)
          let i = a.startIndex
          _ = a.index(i, offsetBy: -1, limitedBy: a.endIndex)
        }
        expectNoInvalidMemoryAccess(result3)

        let result4 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let a = RedBlackTreeSet<Int>(0..<10)
          let i = a.endIndex
          _ = a.index(i, offsetBy: 1, limitedBy: a.startIndex)
        }
        expectNoInvalidMemoryAccess(result4)
      }

      @Test func `文字列のインデックス範囲外の挙動と同様にする、その5`() async {
        let result1 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let str = "abcdef"
          var i = str.startIndex
          _ = str.formIndex(&i, offsetBy: -1, limitedBy: str.endIndex)
        }
        expectNoInvalidMemoryAccess(result1)

        let result2 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let str = "abcdef"
          var i = str.endIndex
          _ = str.formIndex(&i, offsetBy: 1, limitedBy: str.startIndex)
        }
        expectNoInvalidMemoryAccess(result2)

        let result3 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.startIndex
          _ = a.formIndex(&i, offsetBy: -1, limitedBy: a.endIndex)
        }
        expectNoInvalidMemoryAccess(result3)

        let result4 = await #expect(
          processExitsWith: .failure,
          observing: [\.standardErrorContent]
        ) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.endIndex
          _ = a.formIndex(&i, offsetBy: 1, limitedBy: a.startIndex)
        }
        expectNoInvalidMemoryAccess(result4)
      }

      #if !ALLOW_CROSS_TREE_INDEX
        @Test func `インデックス挙動の確認`() async {
          let result = await #expect(
            processExitsWith: .failure,
            observing: [\.standardErrorContent]
          ) {
            var a = RedBlackTreeSet<Int>(0..<10)
            let b = a
            let i = a.startIndex
            a.insert(10)  // CoW発生
            _ = a[i]
            // mutation後のstaleはContainer-Designで許容されている。
            // トラップさえしていればよい。
            _ = b
          }
          expectNoInvalidMemoryAccess(result)
        }
      #endif
    #endif
  }
#endif
