import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetFuzzTests: RedBlackTreeTestCase {

  func test_randomMutationsMatchSwiftSet() {
    let iterations = 100
    let operations = 1_000
    var rng = SplitMix64(seed: 0xDEAD_BEEF)

    for _ in 0..<iterations {
      var redBlackTreeSet = RedBlackTreeSet<Int>()
      var swiftSet = Set<Int>()

      for _ in 0..<operations {
        let value = Int(rng.next() & 0xFF) - 128
        let action = rng.next() & 3

        switch action {
        case 0:
          XCTAssertEqual(redBlackTreeSet.insert(value).inserted, swiftSet.insert(value).inserted)
        case 1:
          XCTAssertEqual(redBlackTreeSet.remove(value), swiftSet.remove(value))
        case 2 where !redBlackTreeSet.isEmpty:
          XCTAssertEqual(redBlackTreeSet.removeFirst(), swiftSet.min()!)
          swiftSet.remove(swiftSet.min()!)
        case 3 where !redBlackTreeSet.isEmpty:
          XCTAssertEqual(redBlackTreeSet.removeLast(), swiftSet.max()!)
          swiftSet.remove(swiftSet.max()!)
        default:
          continue
        }

        XCTAssertEqual(Array(redBlackTreeSet), swiftSet.sorted())
        XCTAssertTrue(redBlackTreeSet.___tree_invariant_for_fuzz())
      }
    }
  }

  func test_randomInsertAndEraseMatchesReferenceAndMaintainsTreeInvariant() {
    var rng = SplitMix64(seed: 0xDEADBEEF)
    var set = RedBlackTreeSet<Int>()
    var reference = Set<Int>()

    for _ in 0..<3 {
      for _ in 0..<1000 {
        let v = Int(rng.next() % 500)
        set.insert(v)
        reference.insert(v)
        XCTAssertEqual(Array(set), reference.sorted())
        XCTAssertTrue(set.___tree_invariant_for_fuzz())
      }
      for _ in 0..<1000 {
        let v = Int(rng.next() % 500)
        set.remove(v)
        reference.remove(v)
        XCTAssertEqual(Array(set), reference.sorted())
        XCTAssertTrue(set.___tree_invariant_for_fuzz())
      }
    }
  }
}
