#if DEBUG && DEATH_TEST
  import Foundation
  import Testing

  @testable import RedBlackTreeCollections

  nonisolated(unsafe)
  private var internalStartNode = UnsafeNode(
    ___tracking_tag: 0,
    __left_: .nullptr,
    __right_: .nullptr,
    __parent_: .nullptr
  )

  nonisolated(unsafe)
  private var internalEndNode = UnsafeNode(
    ___tracking_tag: .end,
    __left_: .nullptr,
    __right_: .nullptr,
    __parent_: .nullptr
  )

  nonisolated
  private var internalStartPointer: UnsafeMutablePointer<UnsafeNode> {
    withUnsafeMutablePointer(to: &internalStartNode) { $0 }
  }

  nonisolated
  private var internalEndPointer: UnsafeMutablePointer<UnsafeNode> {
    withUnsafeMutablePointer(to: &internalEndNode) { $0 }
  }

  nonisolated
  struct RedBlackTreeInternalPointerDeathTests {

    enum SUT: UniqueMultiplicity {
      static func value_comp(_: Int, _: Int) -> Bool {
        fatalError()
      }

      static func __get_value(_: UnsafeMutablePointer<UnsafeNode>) -> Int {
        fatalError()
      }

      typealias _Key = Int
    }

    @Test
    func nullLeftPointer_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = SUT._MultiplicityHelper.___ptr_comp_unique(.nullptr, internalStartPointer)
      }
    }

    @Test
    func endLeftPointer_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = SUT._MultiplicityHelper.___ptr_comp_unique(internalEndPointer, internalStartPointer)
      }
    }

    @Test
    func nullRightPointer_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = SUT._MultiplicityHelper.___ptr_comp_unique(internalStartPointer, .nullptr)
      }
    }

    @Test
    func endRightPointer_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        _ = SUT._MultiplicityHelper.___ptr_comp_unique(internalStartPointer, internalEndPointer)
      }
    }
  }
#endif

#if DEBUG && DEATH_TEST && !COMPATIBLE_ATCODER_2025 && !USE_LAZY_DETACH
  extension RedBlackTreeInternalPointerDeathTests {
    // 生きた木で失効フラグだけを設定し、ノード比較へ進む前に拒否して停止すること。
    @Test func detachedIndexComparison_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        let tree: RedBlackTreeSet<Int> = [1, 2]
        let first = tree.startIndex
        let last = tree.index(before: tree.endIndex)
        withExtendedLifetime(tree) {
          first.lazyDetach.isDetached = true
          _ = first < last
        }
      }
    }
  }
#endif
