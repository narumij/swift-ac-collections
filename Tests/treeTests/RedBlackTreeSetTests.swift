//
//  SortedSetTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/09/16.
//

#if DEBUG
  import XCTest

  @testable import RedBlackTreeModule

  extension RedBlackTreeSet {
    func left(_ p: Element) -> Int {
      _read {
        $0.distance(__first: $0.__begin_node, __last: $0.__lower_bound(p, $0.__root(), $0.end()))
      }
    }
    func right(_ p: Element) -> Int {
      _read {
        $0.distance(__first: $0.__begin_node, __last: $0.__upper_bound(p, $0.__root(), $0.end()))
      }
    }
    var elements: [Element] {
      map { $0 }
    }
  }

  final class RedBlackTreeSetTests: XCTestCase {

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitEmtpy() throws {
      let set = RedBlackTreeSet<Int>()
      XCTAssertEqual(set.elements, [])
      XCTAssertEqual(set._count, 0)
      XCTAssertTrue(set.isEmpty)
    }

    func testInitRange() throws {
      let set = RedBlackTreeSet<Int>(0..<10000)
      XCTAssertEqual(set.elements, (0..<10000) + [])
      XCTAssertEqual(set._count, 10000)
      XCTAssertFalse(set.isEmpty)
    }

    func testInitCollection1() throws {
      let set = RedBlackTreeSet<Int>(0..<10000)
      XCTAssertEqual(set.elements, (0..<10000) + [])
      XCTAssertEqual(set._count, 10000)
      XCTAssertFalse(set.isEmpty)
    }

    func testInitCollection2() throws {
      let set = RedBlackTreeSet<Int>([2, 3, 3, 0, 0, 1, 1, 1])
      XCTAssertEqual(set.elements, [0, 1, 2, 3])
      XCTAssertEqual(set._count, 4)
      XCTAssertFalse(set.isEmpty)
    }

    func testRemove() throws {
      var set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set.remove(0), 0)
      XCTAssertFalse(set.elements.isEmpty)
      XCTAssertEqual(set.remove(1), 1)
      XCTAssertFalse(set.elements.isEmpty)
      XCTAssertEqual(set.remove(2), 2)
      XCTAssertFalse(set.elements.isEmpty)
      XCTAssertEqual(set.remove(3), 3)
      XCTAssertFalse(set.elements.isEmpty)
      XCTAssertEqual(set.remove(4), 4)
      XCTAssertTrue(set.elements.isEmpty)
      XCTAssertEqual(set.remove(0), nil)
      XCTAssertTrue(set.elements.isEmpty)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertTrue(set.elements.isEmpty)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertTrue(set.elements.isEmpty)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertTrue(set.elements.isEmpty)
      XCTAssertEqual(set.remove(4), nil)
      XCTAssertTrue(set.elements.isEmpty)
    }

    func testRemoveAt() throws {
      var set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set.___remove(at: set.___header.__begin_node), 0)
      XCTAssertEqual(set.elements, [1, 2, 3, 4])
      XCTAssertEqual(set.___remove(at: set.___header.__begin_node), 1)
      XCTAssertEqual(set.elements, [2, 3, 4])
      XCTAssertEqual(set.___remove(at: set.___header.__begin_node), 2)
      XCTAssertEqual(set.elements, [3, 4])
      XCTAssertEqual(set.___remove(at: set.___header.__begin_node), 3)
      XCTAssertEqual(set.elements, [4])
      XCTAssertEqual(set.___remove(at: set.___header.__begin_node), 4)
      XCTAssertEqual(set.elements, [])
      XCTAssertEqual(set.___remove(at: set.___header.__begin_node), nil)
    }

    func testInsert() throws {
      var set = RedBlackTreeSet<Int>([])
      XCTAssertEqual(set.insert(0).inserted, true)
      XCTAssertEqual(set.insert(1).inserted, true)
      XCTAssertEqual(set.insert(2).inserted, true)
      XCTAssertEqual(set.insert(3).inserted, true)
      XCTAssertEqual(set.insert(4).inserted, true)
      XCTAssertEqual(set.insert(0).inserted, false)
      XCTAssertEqual(set.insert(1).inserted, false)
      XCTAssertEqual(set.insert(2).inserted, false)
      XCTAssertEqual(set.insert(3).inserted, false)
      XCTAssertEqual(set.insert(4).inserted, false)
    }

    func test_LT_GT() throws {
      var set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set._count, 5)
      XCTAssertEqual(set.lessThan(-1), nil)
      XCTAssertEqual(set.greaterThan(-1), 0)
      XCTAssertEqual(set.lessThan(0), nil)
      XCTAssertEqual(set.greaterThan(0), 1)
      XCTAssertEqual(set.lessThan(1), 0)
      XCTAssertEqual(set.greaterThan(1), 2)
      XCTAssertEqual(set.lessThan(2), 1)
      XCTAssertEqual(set.greaterThan(2), 3)
      XCTAssertEqual(set.lessThan(3), 2)
      XCTAssertEqual(set.greaterThan(3), 4)
      XCTAssertEqual(set.lessThan(4), 3)
      XCTAssertEqual(set.greaterThan(4), nil)
      XCTAssertEqual(set.lessThan(5), 4)
      XCTAssertEqual(set.greaterThan(5), nil)
      XCTAssertEqual(set.remove(1), 1)
      XCTAssertEqual(set.remove(3), 3)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.elements, [0, 2, 4])
      XCTAssertEqual(set.lessThan(-1), nil)
      XCTAssertEqual(set.greaterThan(-1), 0)
      XCTAssertEqual(set.lessThan(0), nil)
      XCTAssertEqual(set.greaterThan(0), 2)
      XCTAssertEqual(set.lessThan(1), 0)
      XCTAssertEqual(set.greaterThan(1), 2)
      XCTAssertEqual(set.lessThan(2), 0)
      XCTAssertEqual(set.greaterThan(2), 4)
      XCTAssertEqual(set.lessThan(3), 2)
      XCTAssertEqual(set.greaterThan(3), 4)
      XCTAssertEqual(set.lessThan(4), 2)
      XCTAssertEqual(set.greaterThan(4), nil)
      XCTAssertEqual(set.lessThan(5), 4)
      XCTAssertEqual(set.greaterThan(5), nil)
      XCTAssertEqual(set.remove(2), 2)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.elements, [0, 4])
      XCTAssertEqual(set.lessThan(-1), nil)
      XCTAssertEqual(set.greaterThan(-1), 0)
      XCTAssertEqual(set.lessThan(0), nil)
      XCTAssertEqual(set.greaterThan(0), 4)
      XCTAssertEqual(set.lessThan(1), 0)
      XCTAssertEqual(set.greaterThan(1), 4)
      XCTAssertEqual(set.lessThan(2), 0)
      XCTAssertEqual(set.greaterThan(2), 4)
      XCTAssertEqual(set.lessThan(3), 0)
      XCTAssertEqual(set.greaterThan(3), 4)
      XCTAssertEqual(set.lessThan(4), 0)
      XCTAssertEqual(set.greaterThan(4), nil)
      XCTAssertEqual(set.lessThan(5), 4)
      XCTAssertEqual(set.greaterThan(5), nil)
      XCTAssertEqual(set.remove(0), 0)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.remove(4), 4)
      XCTAssertEqual(set.lessThan(-1), nil)
      XCTAssertEqual(set.greaterThan(-1), nil)
      XCTAssertEqual(set.lessThan(0), nil)
      XCTAssertEqual(set.greaterThan(0), nil)
      XCTAssertEqual(set.lessThan(1), nil)
      XCTAssertEqual(set.greaterThan(1), nil)
      XCTAssertEqual(set.lessThan(2), nil)
      XCTAssertEqual(set.greaterThan(2), nil)
      XCTAssertEqual(set.lessThan(3), nil)
      XCTAssertEqual(set.greaterThan(3), nil)
      XCTAssertEqual(set.lessThan(4), nil)
      XCTAssertEqual(set.greaterThan(4), nil)
      XCTAssertEqual(set.lessThan(5), nil)
      XCTAssertEqual(set.greaterThan(5), nil)
      XCTAssertEqual(set.elements, [])
    }

    func testContains() throws {
      var set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set._count, 5)
      XCTAssertEqual(set.contains(-1), false)
      XCTAssertEqual(set.contains(0), true)
      XCTAssertEqual(set.contains(1), true)
      XCTAssertEqual(set.contains(2), true)
      XCTAssertEqual(set.contains(3), true)
      XCTAssertEqual(set.contains(4), true)
      XCTAssertEqual(set.contains(5), false)
      XCTAssertEqual(set.remove(1), 1)
      XCTAssertEqual(set.remove(3), 3)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.elements, [0, 2, 4])
      XCTAssertEqual(set.contains(-1), false)
      XCTAssertEqual(set.contains(0), true)
      XCTAssertEqual(set.contains(1), false)
      XCTAssertEqual(set.contains(2), true)
      XCTAssertEqual(set.contains(3), false)
      XCTAssertEqual(set.contains(4), true)
      XCTAssertEqual(set.contains(5), false)
      XCTAssertEqual(set.remove(2), 2)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.elements, [0, 4])
      XCTAssertEqual(set.contains(-1), false)
      XCTAssertEqual(set.contains(0), true)
      XCTAssertEqual(set.contains(1), false)
      XCTAssertEqual(set.contains(2), false)
      XCTAssertEqual(set.contains(3), false)
      XCTAssertEqual(set.contains(4), true)
      XCTAssertEqual(set.contains(5), false)
      XCTAssertEqual(set.remove(0), 0)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.remove(4), 4)
      XCTAssertEqual(set.contains(-1), false)
      XCTAssertEqual(set.contains(0), false)
      XCTAssertEqual(set.contains(1), false)
      XCTAssertEqual(set.contains(2), false)
      XCTAssertEqual(set.contains(3), false)
      XCTAssertEqual(set.contains(4), false)
      XCTAssertEqual(set.contains(5), false)
      XCTAssertEqual(set.elements, [])
    }

    func test_LE_GE() throws {
      var set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set._count, 5)
      XCTAssertEqual(set.lessThanOrEqual(-1), nil)
      XCTAssertEqual(set.greaterThanOrEqual(-1), 0)
      XCTAssertEqual(set.lessThanOrEqual(0), 0)
      XCTAssertEqual(set.greaterThanOrEqual(0), 0)
      XCTAssertEqual(set.lessThanOrEqual(1), 1)
      XCTAssertEqual(set.greaterThanOrEqual(1), 1)
      XCTAssertEqual(set.lessThanOrEqual(2), 2)
      XCTAssertEqual(set.greaterThanOrEqual(2), 2)
      XCTAssertEqual(set.lessThanOrEqual(3), 3)
      XCTAssertEqual(set.greaterThanOrEqual(3), 3)
      XCTAssertEqual(set.lessThanOrEqual(4), 4)
      XCTAssertEqual(set.greaterThanOrEqual(4), 4)
      XCTAssertEqual(set.lessThanOrEqual(5), 4)
      XCTAssertEqual(set.greaterThanOrEqual(5), nil)
      XCTAssertEqual(set.remove(1), 1)
      XCTAssertEqual(set.remove(3), 3)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.elements, [0, 2, 4])
      XCTAssertEqual(set.lessThanOrEqual(-1), nil)
      XCTAssertEqual(set.greaterThanOrEqual(-1), 0)
      XCTAssertEqual(set.lessThanOrEqual(0), 0)
      XCTAssertEqual(set.greaterThanOrEqual(0), 0)
      XCTAssertEqual(set.lessThanOrEqual(1), 0)
      XCTAssertEqual(set.greaterThanOrEqual(1), 2)
      XCTAssertEqual(set.lessThanOrEqual(2), 2)
      XCTAssertEqual(set.greaterThanOrEqual(2), 2)
      XCTAssertEqual(set.lessThanOrEqual(3), 2)
      XCTAssertEqual(set.greaterThanOrEqual(3), 4)
      XCTAssertEqual(set.lessThanOrEqual(4), 4)
      XCTAssertEqual(set.greaterThanOrEqual(4), 4)
      XCTAssertEqual(set.lessThanOrEqual(5), 4)
      XCTAssertEqual(set.greaterThanOrEqual(5), nil)
      XCTAssertEqual(set.remove(2), 2)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.elements, [0, 4])
      XCTAssertEqual(set.lessThanOrEqual(-1), nil)
      XCTAssertEqual(set.greaterThanOrEqual(-1), 0)
      XCTAssertEqual(set.lessThanOrEqual(0), 0)
      XCTAssertEqual(set.greaterThanOrEqual(0), 0)
      XCTAssertEqual(set.lessThanOrEqual(1), 0)
      XCTAssertEqual(set.greaterThanOrEqual(1), 4)
      XCTAssertEqual(set.lessThanOrEqual(2), 0)
      XCTAssertEqual(set.greaterThanOrEqual(2), 4)
      XCTAssertEqual(set.lessThanOrEqual(3), 0)
      XCTAssertEqual(set.greaterThanOrEqual(3), 4)
      XCTAssertEqual(set.lessThanOrEqual(4), 4)
      XCTAssertEqual(set.greaterThanOrEqual(4), 4)
      XCTAssertEqual(set.lessThanOrEqual(5), 4)
      XCTAssertEqual(set.greaterThanOrEqual(5), nil)
      XCTAssertEqual(set.remove(0), 0)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.remove(4), 4)
      XCTAssertEqual(set.lessThanOrEqual(-1), nil)
      XCTAssertEqual(set.greaterThanOrEqual(-1), nil)
      XCTAssertEqual(set.lessThanOrEqual(0), nil)
      XCTAssertEqual(set.greaterThanOrEqual(0), nil)
      XCTAssertEqual(set.lessThanOrEqual(1), nil)
      XCTAssertEqual(set.greaterThanOrEqual(1), nil)
      XCTAssertEqual(set.lessThanOrEqual(2), nil)
      XCTAssertEqual(set.greaterThanOrEqual(2), nil)
      XCTAssertEqual(set.lessThanOrEqual(3), nil)
      XCTAssertEqual(set.greaterThanOrEqual(3), nil)
      XCTAssertEqual(set.lessThanOrEqual(4), nil)
      XCTAssertEqual(set.greaterThanOrEqual(4), nil)
      XCTAssertEqual(set.lessThanOrEqual(5), nil)
      XCTAssertEqual(set.greaterThanOrEqual(5), nil)
      XCTAssertEqual(set.elements, [])
    }

    func testLeftRight() throws {
      var set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set._count, 5)
      XCTAssertEqual(set.left(-1).index, 0)
      //        XCTAssertEqual(set.elements.count{ $0 < -1 }, 0)
      XCTAssertEqual(set.left(0).index, 0)
      //        XCTAssertEqual(set.elements.count{ $0 < 0 }, 0)
      XCTAssertEqual(set.left(1).index, 1)
      //        XCTAssertEqual(set.elements.count{ $0 < 1 }, 1)
      XCTAssertEqual(set.left(2).index, 2)
      XCTAssertEqual(set.left(3).index, 3)
      XCTAssertEqual(set.left(4).index, 4)
      XCTAssertEqual(set.left(5).index, 5)
      XCTAssertEqual(set.left(6).index, 5)
      XCTAssertEqual(set.right(-1).index, 0)
      //        XCTAssertEqual(set.elements.count{ $0 <= -1 }, 0)
      XCTAssertEqual(set.right(0).index, 1)
      //        XCTAssertEqual(set.elements.count{ $0 <= 0 }, 1)
      XCTAssertEqual(set.right(1).index, 2)
      //        XCTAssertEqual(set.elements.count{ $0 <= 1 }, 2)
      XCTAssertEqual(set.right(2).index, 3)
      XCTAssertEqual(set.right(3).index, 4)
      XCTAssertEqual(set.right(4).index, 5)
      XCTAssertEqual(set.right(5).index, 5)
      XCTAssertEqual(set.right(6).index, 5)
      XCTAssertEqual(set.remove(1), 1)
      XCTAssertEqual(set.remove(3), 3)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.elements, [0, 2, 4])
      XCTAssertEqual(set.left(-1).index, 0)
      XCTAssertEqual(set.left(0).index, 0)
      XCTAssertEqual(set.left(1).index, 1)
      XCTAssertEqual(set.left(2).index, 1)
      XCTAssertEqual(set.left(3).index, 2)
      XCTAssertEqual(set.left(4).index, 2)
      XCTAssertEqual(set.left(5).index, 3)
      XCTAssertEqual(set.right(-1).index, 0)
      XCTAssertEqual(set.right(0).index, 1)
      XCTAssertEqual(set.right(1).index, 1)
      XCTAssertEqual(set.right(2).index, 2)
      XCTAssertEqual(set.right(3).index, 2)
      XCTAssertEqual(set.right(4).index, 3)
      XCTAssertEqual(set.right(5).index, 3)
      XCTAssertEqual(set.remove(2), 2)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.elements, [0, 4])
      XCTAssertEqual(set.left(-1).index, 0)
      XCTAssertEqual(set.left(0).index, 0)
      XCTAssertEqual(set.left(1).index, 1)
      XCTAssertEqual(set.left(2).index, 1)
      XCTAssertEqual(set.left(3).index, 1)
      XCTAssertEqual(set.left(4).index, 1)
      XCTAssertEqual(set.left(5).index, 2)
      XCTAssertEqual(set.right(-1).index, 0)
      XCTAssertEqual(set.right(0).index, 1)
      XCTAssertEqual(set.right(1).index, 1)
      XCTAssertEqual(set.right(2).index, 1)
      XCTAssertEqual(set.right(3).index, 1)
      XCTAssertEqual(set.right(4).index, 2)
      XCTAssertEqual(set.right(5).index, 2)
      XCTAssertEqual(set.remove(0), 0)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.remove(4), 4)
      XCTAssertEqual(set.left(-1).index, 0)
      XCTAssertEqual(set.left(0).index, 0)
      XCTAssertEqual(set.left(1).index, 0)
      XCTAssertEqual(set.left(2).index, 0)
      XCTAssertEqual(set.left(3).index, 0)
      XCTAssertEqual(set.left(4).index, 0)
      XCTAssertEqual(set.left(5).index, 0)
      XCTAssertEqual(set.right(-1).index, 0)
      XCTAssertEqual(set.right(0).index, 0)
      XCTAssertEqual(set.right(1).index, 0)
      XCTAssertEqual(set.right(2).index, 0)
      XCTAssertEqual(set.right(3).index, 0)
      XCTAssertEqual(set.right(4).index, 0)
      XCTAssertEqual(set.right(5).index, 0)
      XCTAssertEqual(set.elements, [])
    }

    func testMinMax() throws {
      let set = RedBlackTreeSet<Int>([5, 2, 3, 1, 0])
      XCTAssertEqual(set.max(), 5)
      XCTAssertEqual(set.min(), 0)
    }

    func testSequence() throws {
      let set = RedBlackTreeSet<Int>([5, 2, 3, 1, 0])
      XCTAssertEqual(set.map { $0 }, [0, 1, 2, 3, 5])
    }

    func testArrayAccess1() throws {
      let set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 0)], 0)
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 1)], 1)
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 2)], 2)
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 3)], 3)
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 4)], 4)
    }

    func testArrayAccess2() throws {
      let set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -5)], 0)
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -4)], 1)
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -3)], 2)
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -2)], 3)
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -1)], 4)
    }
    
    func testIndexLimit1() throws {
      let set = Set<Int>([0, 1, 2, 3, 4])
      XCTAssertNotEqual(set.index(set.startIndex, offsetBy: 4, limitedBy: set.index(set.startIndex, offsetBy: 4)), nil)
      XCTAssertEqual(set.index(set.startIndex, offsetBy: 5, limitedBy: set.index(set.startIndex, offsetBy: 4)), nil)
      XCTAssertEqual(set.index(set.startIndex, offsetBy: 5, limitedBy: set.endIndex), set.endIndex)
      XCTAssertEqual(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
//      XCTAssertEqual(set.index(set.endIndex, offsetBy: -6, limitedBy: set.startIndex), nil)
    }

    func testIndexLimit2() throws {
      let set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
      XCTAssertNotEqual(set.index(set.startIndex, offsetBy: 4, limitedBy: set.index(set.startIndex, offsetBy: 4)), nil)
      XCTAssertEqual(set.index(set.startIndex, offsetBy: 5, limitedBy: set.index(set.startIndex, offsetBy: 4)), nil)
      XCTAssertEqual(set.index(set.startIndex, offsetBy: 5, limitedBy: set.endIndex), set.endIndex)
      XCTAssertEqual(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
    }

    func testRandom() throws {
      var set = RedBlackTreeSet<Int>()
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.insert(i)
        XCTAssertTrue(set._read { $0.__tree_invariant($0.__root()) })
      }
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.remove(i)
        XCTAssertTrue(set._read { $0.__tree_invariant($0.__root()) })
      }
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.insert(i)
        XCTAssertTrue(set._read { $0.__tree_invariant($0.__root()) })
      }
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.remove(i)
        XCTAssertTrue(set._read { $0.__tree_invariant($0.__root()) })
      }
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.insert(i)
        XCTAssertTrue(set._read { $0.__tree_invariant($0.__root()) })
      }
      for i in set {
        set.remove(i)
        XCTAssertTrue(set._read { $0.__tree_invariant($0.__root()) })
      }
    }

    func testLiteral() throws {
      let set: RedBlackTreeSet<Int> = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5]
      XCTAssertEqual(set.map { $0 }, [1, 2, 3, 4, 5])
    }

    class A: Hashable, Comparable {
      static func < (lhs: A, rhs: A) -> Bool {
        lhs.x < rhs.x
      }
      static func == (lhs: A, rhs: A) -> Bool {
        lhs.x == rhs.x
      }
      let x: Int
      let label: String
      init(x: Int, label: String) {
        self.x = x
        self.label = label
      }
      func hash(into hasher: inout Hasher) {
        hasher.combine(x)
      }
    }

    func testRedBlackTreeSetUpdate() throws {
      let a = A(x: 3, label: "a")
      let b = A(x: 3, label: "b")
      var s: RedBlackTreeSet<A> = [a]
      XCTAssertFalse(a === b)
      XCTAssertTrue(s.update(with: b) === a)
      XCTAssertTrue(s.update(with: a) === b)
    }

    func testRedBlackTreeSetInsert() throws {
      let a = A(x: 3, label: "a")
      let b = A(x: 3, label: "b")
      var s: RedBlackTreeSet<A> = []
      XCTAssertFalse(a === b)
      do {
        let r = s.insert(a)
        XCTAssertEqual(r.inserted, true)
        XCTAssertTrue(r.memberAfterInsert === a)
      }
      do {
        let r = s.insert(b)
        XCTAssertEqual(r.inserted, false)
        XCTAssertTrue(r.memberAfterInsert === a)
      }
    }

    func testSetRemove() throws {
      var s: Set<Int> = [1, 2, 3, 4]
      let i = s.firstIndex(of: 2)!

      s.remove(at: i)
      // Attempting to access Set elements using an invalid index
      //      s.remove(at: i)
      //      s.remove(at: s.endIndex)
    }

    func testRedBlackTreeSetRemove() throws {
      var s: RedBlackTreeSet<Int> = [1, 2, 3, 4]
      XCTAssertEqual(s.first, 1)
      let i = s.firstIndex(of: 2)!
      s.remove(at: i)
      XCTAssertEqual(s.map { $0 }, [1, 3, 4])
      s.removeAll(keepingCapacity: true)
      XCTAssertEqual(s.map { $0 }, [])
      XCTAssertGreaterThanOrEqual(s.capacity, 3)
      s.removeAll(keepingCapacity: false)
      XCTAssertEqual(s.map { $0 }, [])
      XCTAssertGreaterThanOrEqual(s.capacity, 0)
      // Attempting to access Set elements using an invalid index
      //      s.remove(at: i)
      //      s.remove(at: s.endIndex)
      XCTAssertNil(s.first)
      //      s.removeFirst()
    }

    func testRedBlackTreeSetLowerBound() throws {
      let numbers: RedBlackTreeSet = [1, 3, 5, 7, 9]
      XCTAssertEqual(numbers.lowerBound(4).pointer, 2)
    }

    func testRedBlackTreeSetUpperBound() throws {
      let numbers: RedBlackTreeSet = [1, 3, 5, 7, 9]
      XCTAssertEqual(numbers.upperBound(7).pointer, 4)
    }

    func testRedBlackTreeCapacity() throws {
      var numbers: RedBlackTreeSet<Int> = .init(minimumCapacity: 3)
      XCTAssertGreaterThanOrEqual(numbers.capacity, 3)
      numbers.reserveCapacity(4)
      XCTAssertGreaterThanOrEqual(numbers.capacity, 4)
    }

    func testRedBlackTreeConveniences() throws {
      let numbers: RedBlackTreeSet = [1, 3, 5, 7, 9]

      XCTAssertEqual(numbers.lessThan(4), 3)
      XCTAssertEqual(numbers.lessThanOrEqual(4), 3)
      XCTAssertEqual(numbers.lessThan(5), 3)
      XCTAssertEqual(numbers.lessThanOrEqual(5), 5)

      XCTAssertEqual(numbers.greaterThan(6), 7)
      XCTAssertEqual(numbers.greaterThanOrEqual(6), 7)
      XCTAssertEqual(numbers.greaterThan(5), 7)
      XCTAssertEqual(numbers.greaterThanOrEqual(5), 5)
    }

    func testRedBlackTreeSetFirstIndex() throws {
      var members: RedBlackTreeSet = [1, 3, 5, 7, 9]
      XCTAssertEqual(members.firstIndex(of: 3), .init(1))
      XCTAssertEqual(members.firstIndex(of: 2), nil)
      XCTAssertEqual(members.firstIndex(where: { $0 > 3 }), .init(2))
      XCTAssertEqual(members.firstIndex(where: { $0 > 9 }), nil)
      XCTAssertEqual(members.sorted(), [1, 3, 5, 7, 9])
      XCTAssertEqual(members.removeFirst(), 1)
      XCTAssertEqual(members.removeFirst(), 3)
      XCTAssertEqual(members.removeFirst(), 5)
      XCTAssertEqual(members.removeFirst(), 7)
      XCTAssertEqual(members.removeFirst(), 9)
    }

    func testPerformanceDistanceFromTo() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        // BidirectionalCollectionの実装の場合、0.3sec
        // 木の場合、0.08sec
        // 片方がendIndexの場合、その部分だけO(1)となるよう修正
        XCTAssertEqual(s.distance(from: s.endIndex, to: s.startIndex), -1_000_000)
      }
    }

    func testPerformanceIndexOffsetBy1() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.index(s.startIndex, offsetBy: 1_000_000), s.endIndex)
      }
    }

    func testPerformanceIndexOffsetBy2() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.index(s.endIndex, offsetBy: -1_000_000), s.startIndex)
      }
    }

    func testPerformanceFirstIndex1() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 1_000_000 - 1), s.index(before: s.endIndex))
      }
    }

    func testPerformanceFirstIndex2() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 0), s.startIndex)
      }
    }

    func testPerformanceFirstIndex3() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 1_000_000), nil)
      }
    }

    func testPerformanceFirstIndex4() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 - 1 }), s.index(before: s.endIndex))
      }
    }

    func testPerformanceFirstIndex5() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(where: { $0 >= 0 }), s.startIndex)
      }
    }

    func testPerformanceFirstIndex6() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 }), nil)
      }
    }
  }
#endif
