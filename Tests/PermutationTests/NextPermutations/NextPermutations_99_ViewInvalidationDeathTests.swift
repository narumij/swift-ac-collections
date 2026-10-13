//
//  NextPermutations_99_ViewInvalidationDeathTests.swift
//  swift-ac-collections
//

// `NextPermutations.Permutation`（View）の実行時失効のTest as Specification（PERM-054 G2）。
// - 次の`next()`を呼ぶと、それが新しいViewを返しても`nil`を返しても、以前のViewは失効する
// - ownerが破棄されると、持ち出されたViewは失効する。要素storageを読む前に停止する
// - 失効は`startIndex`、`endIndex`、subscriptのどれから触っても検出される
// - 同じViewのcopyは、同じ世代の失効を共有する
// これはcompilerによる借用検査ではなく、実行時のprecondition失敗による停止の契約である。
// 停止signalはtarget共通の`expectedSwiftTrapSignal`（DarwinはSIGTRAP、LinuxはSIGILL）に完全一致させる。
//
// Viewを`next()`の後まで保持するのは、直後に停止を確かめるこのfileのtestの中だけに限る。

#if DEATH_TEST && !COMPATIBLE_ATCODER_2025
  import Testing
  import PermutationModule

  struct NextPermutations_99_ViewInvalidationDeathTests {

    // MARK: - 失効前（positive control）

    @Test func currentViewAndItsCopyAreReadableBeforeAdvancing() {
      var permutations = [1, 2, 3].nextPermutations()
      let p = permutations.next()!
      let copy = p
      #expect(p.startIndex == 0)
      #expect(p.endIndex == 3)
      #expect(p[0] == 1)
      #expect(copy[2] == 3)
    }

    // MARK: - 次の`next()`が新しいViewを返した後

    @Test func startIndexTrapsAfterNextReturnsNewView() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var permutations = [1, 2, 3].nextPermutations()
        let p = permutations.next()!
        _ = permutations.next()!
        _ = p.startIndex
      }
    }

    @Test func endIndexTrapsAfterNextReturnsNewView() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var permutations = [1, 2, 3].nextPermutations()
        let p = permutations.next()!
        _ = permutations.next()!
        _ = p.endIndex
      }
    }

    @Test func subscriptTrapsAfterNextReturnsNewView() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var permutations = [1, 2, 3].nextPermutations()
        let p = permutations.next()!
        _ = permutations.next()!
        _ = p[0]
      }
    }

    // MARK: - 終端の`next()`が`nil`を返した後

    @Test func subscriptTrapsAfterTerminalNextReturnsNil() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var permutations = [7].nextPermutations()
        let p = permutations.next()!
        let terminal = permutations.next()
        precondition(terminal == nil, "single element must yield exactly once")
        _ = p[0]
      }
    }

    @Test func startIndexTrapsAfterTerminalNextReturnsNil() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var permutations = [2, 1].nextPermutations()
        let p = permutations.next()!
        let terminal = permutations.next()
        precondition(terminal == nil, "descending order must yield exactly once")
        _ = p.startIndex
      }
    }

    // MARK: - ownerが破棄された後

    @Test func startIndexTrapsAfterOwnerIsDestroyed() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        func escapedView() -> NextPermutations<Int>.Permutation {
          var permutations = [1, 2, 3].nextPermutations()
          return permutations.next()!
        }
        let p = escapedView()
        _ = p.startIndex
      }
    }

    @Test func endIndexTrapsAfterOwnerIsDestroyed() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        func escapedView() -> NextPermutations<Int>.Permutation {
          var permutations = [1, 2, 3].nextPermutations()
          return permutations.next()!
        }
        let p = escapedView()
        _ = p.endIndex
      }
    }

    @Test func subscriptTrapsAfterOwnerIsDestroyed() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        func escapedView() -> NextPermutations<Int>.Permutation {
          var permutations = [1, 2, 3].nextPermutations()
          return permutations.next()!
        }
        let p = escapedView()
        _ = p[0]
      }
    }

    // MARK: - 同じViewのcopy

    @Test func copyOfViewTrapsAfterNext() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var permutations = [1, 2, 3].nextPermutations()
        let p = permutations.next()!
        let copy = p
        _ = permutations.next()!
        _ = copy[0]
      }
    }
  }
#endif
