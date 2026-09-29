#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeMultiSetRemovalStressTests: RedBlackTreeTestCase {

    func testRemovingEveryElementWhileIteratingEmptiesMultiSet() {
      var multiset: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })

      for element in multiset {
        multiset.eraseMulti(element)
      }

      XCTAssertTrue(multiset.isEmpty)
    }

    func testRemovingEveryElementWhileIteratingAnElementRangeEmptiesIt() {
      var multiset: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })
      let range = multiset[multiset.lowerBound(0)..<multiset.endIndex]

      for element in range {
        multiset.eraseMulti(element)
      }

      XCTAssertTrue(multiset.isEmpty)
    }

    func testRemovingMaterializedElementRangeEmptiesMultiSet() {
      var multiset: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })
      let range = multiset[multiset.lowerBound(0)..<multiset.endIndex]

      for element in range + [] {
        multiset.eraseMulti(element)
      }

      XCTAssertTrue(multiset.isEmpty)
    }

    func testEraseByBoundRangeMatchesReferenceFilterForEveryBoundaryPair() {
      let source = [1, 1, 3, 3, 5, 7, 9, 9]

      for l in 0..<10 {
        for h in l...10 {
          var members = RedBlackTreeMultiSet(source)
          _ = members.erase(members.lowerBound(l)..<members.upperBound(h))
          XCTAssertEqual(Array(members), source.filter { !(l...h).contains($0) })
        }
      }
    }
  }
#endif
