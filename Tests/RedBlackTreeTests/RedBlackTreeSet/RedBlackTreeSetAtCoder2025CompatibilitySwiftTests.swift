#if DEATH_TEST && COMPATIBLE_ATCODER_2025
  import Foundation
  import RedBlackTreeCollections
  import Testing

  struct RedBlackTreeSetAtCoder2025CompatibilitySwiftTests {

    @Test
    func iteratorWhoseSourceWasMutated_terminatesProcess() async {
      await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
        var set = RedBlackTreeSet((0..<5).map { $0 * 5 })
        var iterator = set[set.firstIndex(of: 5)!..<set.lowerBound(20)].makeIterator()
        set.remove(10)
        #expect(iterator.next() == 5)
      }
    }
  }
#endif
