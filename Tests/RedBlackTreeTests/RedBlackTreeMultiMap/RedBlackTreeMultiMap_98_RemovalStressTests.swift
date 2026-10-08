#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeMultiMapRemovalStressTests: RedBlackTreeTestCase {

    func testRemovingEveryElementWhileIteratingAMultiMapEmptiesIt() {
      var multimap: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<2_000).flatMap { [($0, $0), ($0, $0)] })

      for element in multimap {
        multimap.eraseMulti(element.key)
      }

      XCTAssertTrue(multimap.isEmpty)
    }

    func testRemovingEveryElementWhileIteratingAnElementRangeEmptiesIt() {
      var multimap: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<2_000).flatMap { [($0, $0), ($0, $0)] })
      let range = multimap[multimap.lowerBound(0)..<multimap.endIndex]

      for element in range {
        multimap.eraseMulti(element.key)
      }

      XCTAssertTrue(multimap.isEmpty)
    }

    func testRemovingMaterializedElementRangeEmptiesMultiMap() {
      var multimap: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<2_000).flatMap { [($0, $0), ($0, $0)] })
      let range = multimap[multimap.lowerBound(0)..<multimap.endIndex]

      for element in range + [] {
        multimap.eraseMulti(element.key)
      }

      XCTAssertTrue(multimap.isEmpty)
    }

    func testEraseByBoundRangeMatchesReferenceFilterForEveryBoundaryPair() {
      let source = [1, 1, 3, 3, 5, 7, 9, 9]

      for l in 0..<10 {
        for h in l...10 {
          var members = RedBlackTreeMultiMap<Int, Int>(
            keysWithValues: source.map { ($0, $0) })
          _ = members.erase(members.lowerBound(l)..<members.upperBound(h))
          XCTAssertEqual(members.map(\.key), source.filter { !(l...h).contains($0) })
        }
      }
    }
  }
#endif
