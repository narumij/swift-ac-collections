  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeDictionaryRemovalStressTests: RedBlackTreeTestCase {

    func testRemovingEveryElementWhileIteratingADictionaryEmptiesIt() {
      var dictionary: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<5_000).map { ($0, $0) })

      for element in dictionary {
        dictionary.removeValue(forKey: element.key)
      }

      XCTAssertTrue(dictionary.isEmpty)
    }

    func testRemovingEveryElementWhileIteratingAnElementRangeEmptiesIt() {
      var dictionary: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<5_000).map { ($0, $0) })

      for element in dictionary.elements(in: 0..<10_000) {
        dictionary.removeValue(forKey: element.key)
      }

      XCTAssertTrue(dictionary.isEmpty)
    }

    func testRemovingMaterializedElementRangeEmptiesDictionary() {
      var dictionary: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<5_000).map { ($0, $0) })

      for element in dictionary.elements(in: 0..<10_000) + [] {
        dictionary.removeValue(forKey: element.key)
      }

      XCTAssertTrue(dictionary.isEmpty)
    }

    func testEraseByBoundRangeMatchesReferenceFilterForEveryBoundaryPair() {
      let source = [1, 3, 5, 7, 9]

      for l in 0..<10 {
        for h in l...10 {
          var members = RedBlackTreeDictionary<Int, Int>(
            uniqueKeysWithValues: source.map { ($0, $0) })
          _ = members.erase(members.lowerBound(l)..<members.upperBound(h))
          XCTAssertEqual(
            members.map(\.key), source.filter { !(l...h).contains($0) })
        }
      }
    }
  }
