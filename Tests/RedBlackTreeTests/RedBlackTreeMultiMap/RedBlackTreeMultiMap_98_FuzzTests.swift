import RedBlackTreeCollections
import XCTest

#if !COMPATIBLE_ATCODER_2025
  final class RedBlackTreeMultiMapFuzzTests: RedBlackTreeTestCase {

    func test_randomInsertAndEraseMaintainsTreeInvariant() {
      var rng = SplitMix64(seed: 0xDEADBEEF)
      var multiMap = RedBlackTreeMultiMap<Int, Int>()

      for _ in 0..<3 {
        for _ in 0..<1000 {
          let v = Int(rng.next() % 500)
          multiMap.insert((v, v))
          XCTAssertTrue(multiMap.___tree_invariant())
        }
        for _ in 0..<1000 {
          let v = Int(rng.next() % 500)
          multiMap.eraseMulti(v)
          XCTAssertTrue(multiMap.___tree_invariant())
        }
      }
    }
  }
#endif
