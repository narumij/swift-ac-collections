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
