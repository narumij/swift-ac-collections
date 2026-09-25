//
//  Test.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/30.
//

#if DEATH_TEST
  import RedBlackTreeCollections
  import Testing

  struct DeathTest {

    @Test func `endIndex cannot be subscripted`() async {
      await #expect(processExitsWith: .failure) {
        let set: RedBlackTreeSet<Int> = [1, 2, 3]
        _ = set[set.endIndex]
      }
    }

    @Test func `removed index cannot be subscripted`() async {
      await #expect(processExitsWith: .failure) {
        var set: RedBlackTreeSet<Int> = [1, 2, 3]
        let index = set.firstIndex(of: 2)!
        set.remove(at: index)
        _ = set[index]
      }
    }

    // AtCoder 2025互換のUnsafeIndexV2は、ALLOW_CROSS_TREE_INDEXにかかわらず
    // 別の木に由来するインデックスを拒否しないため、通常モードでのみ検証する。
    #if !COMPATIBLE_ATCODER_2025 && !ALLOW_CROSS_TREE_INDEX
      @Test func `index from another tree cannot be subscripted`() async {
        await #expect(processExitsWith: .failure) {
          let set: RedBlackTreeSet<Int> = [1, 2, 3]
          let other: RedBlackTreeSet<Int> = [4, 5, 6]
          _ = set[other.startIndex]
        }
      }
    #endif

    @Test func `インデックスによる区間不正はtrapすること、その1`() async {
      await #expect(processExitsWith: .failure) {
        let a = RedBlackTreeSet<Int>(0..<100)

        _ = a[a.lowerBound(50)...a.lowerBound(10)] + [] == []
      }
    }

    @Test func `インデックスによる区間不正はtrapすること、その2`() async {
      await #expect(processExitsWith: .failure) {
        let a = RedBlackTreeSet<Int>(0..<100)

        _ = a[a.endIndex...a.startIndex] + [] == []
      }
    }

    @Test func `インデックスによる区間不正はtrapすること、その3`() async {
      await #expect(processExitsWith: .failure) {
        let a = RedBlackTreeSet<Int>(0..<100)

        _ = a[a.startIndex...a.endIndex] + [] == []
      }
    }

    #if ENABLE_OFFSET_OVERFLOW_GUARD
      @Test func `オフセット計算のオーバーフロー限界を超えたサイズはトラップすること、その1`() async {
        await #expect(processExitsWith: .failure) {
          _ = RedBlackTreeSet<Int>(minimumCapacity: Int.max)
        }
      }

      @Test func `オフセット計算のオーバーフロー限界を超えたサイズはトラップすること、その2`() async {
        await #expect(processExitsWith: .failure) {
          var a = RedBlackTreeSet<Int>()
          a.reserveCapacity(Int.max)
        }
      }

      @Test func `オフセット計算のオーバーフロー限界を超えたサイズはトラップすること、その3`() async {
        await #expect(processExitsWith: .failure) {
          var a = RedBlackTreeSet<Int>()
          var b = a
          a.reserveCapacity(Int.max)
        }
      }
    #endif

    #if !COMPATIBLE_ATCODER_2025
      @Test func `文字列のインデックス範囲外の挙動と同様にする、その1`() async {
        await #expect(processExitsWith: .failure) {
          let str = "abcdef"
          var i = str.startIndex
          i = str.index(before: i)
        }
        await #expect(processExitsWith: .failure) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.startIndex
          i = a.index(before: i)
        }
      }

      @Test func `文字列のインデックス範囲外の挙動と同様にする、その2`() async {
        await #expect(processExitsWith: .failure) {
          let str = "abcdef"
          var i = str.endIndex
          i = str.index(after: i)
        }
        await #expect(processExitsWith: .failure) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.endIndex
          i = a.index(after: i)
        }
      }

      @Test func `文字列のインデックス範囲外の挙動と同様にする、その3`() async {
        await #expect(processExitsWith: .failure) {
          let str = "abcdef"
          var i = str.startIndex
          i = str.index(i, offsetBy: -1)
        }
        await #expect(processExitsWith: .failure) {
          let str = "abcdef"
          var i = str.endIndex
          i = str.index(i, offsetBy: 1)
        }
        await #expect(processExitsWith: .failure) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.startIndex
          i = a.index(i, offsetBy: -1)
        }
        await #expect(processExitsWith: .failure) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.endIndex
          i = a.index(i, offsetBy: 1)
        }
      }

      @Test func `文字列のインデックス範囲外の挙動と同様にする、その4`() async {
        await #expect(processExitsWith: .failure) {
          let str = "abcdef"
          var i = str.startIndex
          _ = str.index(i, offsetBy: -1, limitedBy: str.endIndex)
        }
        await #expect(processExitsWith: .failure) {
          let str = "abcdef"
          var i = str.endIndex
          _ = str.index(i, offsetBy: 1, limitedBy: str.startIndex)
        }
        await #expect(processExitsWith: .failure) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.startIndex
          _ = a.index(i, offsetBy: -1, limitedBy: a.endIndex)
        }
        await #expect(processExitsWith: .failure) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.endIndex
          _ = a.index(i, offsetBy: 1, limitedBy: a.startIndex)
        }
      }

      @Test func `文字列のインデックス範囲外の挙動と同様にする、その5`() async {
        await #expect(processExitsWith: .failure) {
          let str = "abcdef"
          var i = str.startIndex
          _ = str.formIndex(&i, offsetBy: -1, limitedBy: str.endIndex)
        }
        await #expect(processExitsWith: .failure) {
          let str = "abcdef"
          var i = str.endIndex
          _ = str.formIndex(&i, offsetBy: 1, limitedBy: str.startIndex)
        }
        await #expect(processExitsWith: .failure) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.startIndex
          _ = a.formIndex(&i, offsetBy: -1, limitedBy: a.endIndex)
        }
        await #expect(processExitsWith: .failure) {
          let a = RedBlackTreeSet<Int>(0..<10)
          var i = a.endIndex
          _ = a.formIndex(&i, offsetBy: 1, limitedBy: a.startIndex)
        }
      }

      #if !ALLOW_CROSS_TREE_INDEX
        @Test func `インデックス挙動の確認`() async {
          await #expect(processExitsWith: .failure) {
            var a = RedBlackTreeSet<Int>(0..<10)
            let b = a
            let i = a.startIndex
            a.insert(10)  // CoW発生
            _ = a[i]  // mutation後のstaleはContainer-Designで許容されている。トラップさえしてればいい
            // aからとったインデックスだから有効であって欲しい気はするが、そうしなくても構わない
          }
        }
      #endif
    #endif

  }
#endif
