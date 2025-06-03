import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeSetEnumeratedSequenceTests: XCTestCase {

  #if DEBUG && false
    /// EnumuratedSequenceのforEachが正しく動作すること
    func test_enumeratedSequence_forEach() {
      // 事前条件: 集合に[10, 20, 30]
      let set = RedBlackTreeSet([10, 20, 30])
      let enumerated = set.rawIndexedElements

      var elements: [(offset: RawIndex, element: Int)] = []
      enumerated.forEach { pair in
        elements.append((pair.rawIndex, pair.element))
      }

      // 事後条件: offsetは順序どおり、elementも順序どおり
      XCTAssertEqual(
        elements.map { $0.offset.rawValue },
        [0, 1, 2].map { set.index(set.startIndex, offsetBy: $0).rawValue })
      XCTAssertEqual(elements.map { $0.element }, [10, 20, 30])
    }

    /// SubSequenceのEnumuratedSequenceのforEachが正しく動作すること
    func test_subSequence_enumeratedSequence_forEach() {
      // 事前条件: 集合に[10, 20, 30, 40, 50]
      let set = RedBlackTreeSet([10, 20, 30, 40, 50])
      let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [20,30,40]
      let enumerated = sub.rawIndexedElements

      var elements: [(offset: RawIndex, element: Int)] = []
      enumerated.forEach { pair in
        elements.append((pair.rawIndex, pair.element))
      }

      // 事後条件: offsetは順序どおり、elementも順序どおり
      XCTAssertEqual(
        elements.map { $0.offset.rawValue },
        [1, 2, 3].map { set.index(set.startIndex, offsetBy: $0).rawValue })
      XCTAssertEqual(elements.map { $0.element }, [20, 30, 40])
    }
  #endif
}

extension RedBlackTreeSetEnumeratedSequenceTests {

  #if DEBUG && false
    /// EnumuratedSequenceのmakeIterator()で順序通りに列挙できること
    func test_enumeratedSequence_makeIterator() {
      let set = RedBlackTreeSet([10, 20, 30])
      let enumerated = set.rawIndexedElements

      var iterator = enumerated.makeIterator()
      var elements: [(offset: RawIndex, element: Int)] = []
      while let pair = iterator.next() {
        elements.append((pair.rawIndex, pair.element))
      }

      XCTAssertEqual(
        elements.map { $0.offset.rawValue },
        [0, 1, 2].map { set.index(set.startIndex, offsetBy: $0).rawValue })
      XCTAssertEqual(elements.map { $0.element }, [10, 20, 30])
    }

    /// SubSequenceのEnumuratedSequenceのmakeIterator()で順序通りに列挙できること
    func test_subSequence_enumeratedSequence_makeIterator() {
      let set = RedBlackTreeSet([10, 20, 30, 40, 50])
      let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [20,30,40]
      let enumerated = sub.rawIndexedElements

      var iterator = enumerated.makeIterator()
      var elements: [(offset: RawIndex, element: Int)] = []
      while let pair = iterator.next() {
        elements.append((pair.rawIndex, pair.element))
      }

      XCTAssertEqual(
        elements.map { $0.offset.rawValue },
        [1, 2, 3].map { set.index(set.startIndex, offsetBy: $0).rawValue })
      XCTAssertEqual(elements.map { $0.element }, [20, 30, 40])
    }
  #endif
}
