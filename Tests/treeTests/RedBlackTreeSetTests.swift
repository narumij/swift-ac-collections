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
      _read { $0.distance(__first: $0.__begin_node, __last: $0.__lower_bound(p, $0.__root(), $0.end())) }
    }
    func right(_ p: Element) -> Int {
      _read { $0.distance(__first: $0.__begin_node, __last: $0.__upper_bound(p, $0.__root(), $0.end())) }
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
      XCTAssertEqual(set.__remove(at: set.___header.__begin_node), 0)
      XCTAssertEqual(set.elements, [1, 2, 3, 4])
      XCTAssertEqual(set.__remove(at: set.___header.__begin_node), 1)
      XCTAssertEqual(set.elements, [2, 3, 4])
      XCTAssertEqual(set.__remove(at: set.___header.__begin_node), 2)
      XCTAssertEqual(set.elements, [3, 4])
      XCTAssertEqual(set.__remove(at: set.___header.__begin_node), 3)
      XCTAssertEqual(set.elements, [4])
      XCTAssertEqual(set.__remove(at: set.___header.__begin_node), 4)
      XCTAssertEqual(set.elements, [])
      XCTAssertEqual(set.__remove(at: set.___header.__begin_node), nil)
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
      XCTAssertEqual(set.greatorThan(-1), 0)
      XCTAssertEqual(set.lessThan(0), nil)
      XCTAssertEqual(set.greatorThan(0), 1)
      XCTAssertEqual(set.lessThan(1), 0)
      XCTAssertEqual(set.greatorThan(1), 2)
      XCTAssertEqual(set.lessThan(2), 1)
      XCTAssertEqual(set.greatorThan(2), 3)
      XCTAssertEqual(set.lessThan(3), 2)
      XCTAssertEqual(set.greatorThan(3), 4)
      XCTAssertEqual(set.lessThan(4), 3)
      XCTAssertEqual(set.greatorThan(4), nil)
      XCTAssertEqual(set.lessThan(5), 4)
      XCTAssertEqual(set.greatorThan(5), nil)
      XCTAssertEqual(set.remove(1), 1)
      XCTAssertEqual(set.remove(3), 3)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.elements, [0, 2, 4])
      XCTAssertEqual(set.lessThan(-1), nil)
      XCTAssertEqual(set.greatorThan(-1), 0)
      XCTAssertEqual(set.lessThan(0), nil)
      XCTAssertEqual(set.greatorThan(0), 2)
      XCTAssertEqual(set.lessThan(1), 0)
      XCTAssertEqual(set.greatorThan(1), 2)
      XCTAssertEqual(set.lessThan(2), 0)
      XCTAssertEqual(set.greatorThan(2), 4)
      XCTAssertEqual(set.lessThan(3), 2)
      XCTAssertEqual(set.greatorThan(3), 4)
      XCTAssertEqual(set.lessThan(4), 2)
      XCTAssertEqual(set.greatorThan(4), nil)
      XCTAssertEqual(set.lessThan(5), 4)
      XCTAssertEqual(set.greatorThan(5), nil)
      XCTAssertEqual(set.remove(2), 2)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.elements, [0, 4])
      XCTAssertEqual(set.lessThan(-1), nil)
      XCTAssertEqual(set.greatorThan(-1), 0)
      XCTAssertEqual(set.lessThan(0), nil)
      XCTAssertEqual(set.greatorThan(0), 4)
      XCTAssertEqual(set.lessThan(1), 0)
      XCTAssertEqual(set.greatorThan(1), 4)
      XCTAssertEqual(set.lessThan(2), 0)
      XCTAssertEqual(set.greatorThan(2), 4)
      XCTAssertEqual(set.lessThan(3), 0)
      XCTAssertEqual(set.greatorThan(3), 4)
      XCTAssertEqual(set.lessThan(4), 0)
      XCTAssertEqual(set.greatorThan(4), nil)
      XCTAssertEqual(set.lessThan(5), 4)
      XCTAssertEqual(set.greatorThan(5), nil)
      XCTAssertEqual(set.remove(0), 0)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.remove(4), 4)
      XCTAssertEqual(set.lessThan(-1), nil)
      XCTAssertEqual(set.greatorThan(-1), nil)
      XCTAssertEqual(set.lessThan(0), nil)
      XCTAssertEqual(set.greatorThan(0), nil)
      XCTAssertEqual(set.lessThan(1), nil)
      XCTAssertEqual(set.greatorThan(1), nil)
      XCTAssertEqual(set.lessThan(2), nil)
      XCTAssertEqual(set.greatorThan(2), nil)
      XCTAssertEqual(set.lessThan(3), nil)
      XCTAssertEqual(set.greatorThan(3), nil)
      XCTAssertEqual(set.lessThan(4), nil)
      XCTAssertEqual(set.greatorThan(4), nil)
      XCTAssertEqual(set.lessThan(5), nil)
      XCTAssertEqual(set.greatorThan(5), nil)
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
      XCTAssertEqual(set.lessEqual(-1), nil)
      XCTAssertEqual(set.greatorEqual(-1), 0)
      XCTAssertEqual(set.lessEqual(0), 0)
      XCTAssertEqual(set.greatorEqual(0), 0)
      XCTAssertEqual(set.lessEqual(1), 1)
      XCTAssertEqual(set.greatorEqual(1), 1)
      XCTAssertEqual(set.lessEqual(2), 2)
      XCTAssertEqual(set.greatorEqual(2), 2)
      XCTAssertEqual(set.lessEqual(3), 3)
      XCTAssertEqual(set.greatorEqual(3), 3)
      XCTAssertEqual(set.lessEqual(4), 4)
      XCTAssertEqual(set.greatorEqual(4), 4)
      XCTAssertEqual(set.lessEqual(5), 4)
      XCTAssertEqual(set.greatorEqual(5), nil)
      XCTAssertEqual(set.remove(1), 1)
      XCTAssertEqual(set.remove(3), 3)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.elements, [0, 2, 4])
      XCTAssertEqual(set.lessEqual(-1), nil)
      XCTAssertEqual(set.greatorEqual(-1), 0)
      XCTAssertEqual(set.lessEqual(0), 0)
      XCTAssertEqual(set.greatorEqual(0), 0)
      XCTAssertEqual(set.lessEqual(1), 0)
      XCTAssertEqual(set.greatorEqual(1), 2)
      XCTAssertEqual(set.lessEqual(2), 2)
      XCTAssertEqual(set.greatorEqual(2), 2)
      XCTAssertEqual(set.lessEqual(3), 2)
      XCTAssertEqual(set.greatorEqual(3), 4)
      XCTAssertEqual(set.lessEqual(4), 4)
      XCTAssertEqual(set.greatorEqual(4), 4)
      XCTAssertEqual(set.lessEqual(5), 4)
      XCTAssertEqual(set.greatorEqual(5), nil)
      XCTAssertEqual(set.remove(2), 2)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.elements, [0, 4])
      XCTAssertEqual(set.lessEqual(-1), nil)
      XCTAssertEqual(set.greatorEqual(-1), 0)
      XCTAssertEqual(set.lessEqual(0), 0)
      XCTAssertEqual(set.greatorEqual(0), 0)
      XCTAssertEqual(set.lessEqual(1), 0)
      XCTAssertEqual(set.greatorEqual(1), 4)
      XCTAssertEqual(set.lessEqual(2), 0)
      XCTAssertEqual(set.greatorEqual(2), 4)
      XCTAssertEqual(set.lessEqual(3), 0)
      XCTAssertEqual(set.greatorEqual(3), 4)
      XCTAssertEqual(set.lessEqual(4), 4)
      XCTAssertEqual(set.greatorEqual(4), 4)
      XCTAssertEqual(set.lessEqual(5), 4)
      XCTAssertEqual(set.greatorEqual(5), nil)
      XCTAssertEqual(set.remove(0), 0)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertEqual(set.remove(4), 4)
      XCTAssertEqual(set.lessEqual(-1), nil)
      XCTAssertEqual(set.greatorEqual(-1), nil)
      XCTAssertEqual(set.lessEqual(0), nil)
      XCTAssertEqual(set.greatorEqual(0), nil)
      XCTAssertEqual(set.lessEqual(1), nil)
      XCTAssertEqual(set.greatorEqual(1), nil)
      XCTAssertEqual(set.lessEqual(2), nil)
      XCTAssertEqual(set.greatorEqual(2), nil)
      XCTAssertEqual(set.lessEqual(3), nil)
      XCTAssertEqual(set.greatorEqual(3), nil)
      XCTAssertEqual(set.lessEqual(4), nil)
      XCTAssertEqual(set.greatorEqual(4), nil)
      XCTAssertEqual(set.lessEqual(5), nil)
      XCTAssertEqual(set.greatorEqual(5), nil)
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
    
    func testSetUpdate() throws {
      let a = A(x: 3, label: "a")
      let b = A(x: 3, label: "b")
      var s: Set<A> = [a]
      XCTAssertFalse(a === b)
      XCTAssertTrue(s.update(with: b) === a)
      XCTAssertTrue(s.update(with: a) === b)
    }
    
    func testRedBlackTreeSetUpdate() throws {
      let a = A(x: 3, label: "a")
      let b = A(x: 3, label: "b")
      var s: RedBlackTreeSet<A> = [a]
      XCTAssertFalse(a === b)
      XCTAssertTrue(s.update(with: b) === a)
      XCTAssertTrue(s.update(with: a) === b)
    }
    
    func testSetInsert() throws {
      let a = A(x: 3, label: "a")
      let b = A(x: 3, label: "b")
      var s: Set<A> = []
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
    
    func testRedBlackTreeSetRemove() throws {
      var s: Set<Int> = [1,2,3,4]
      let i = s.firstIndex(of: 2)!
      s.remove(at: i)
      // Attempting to access Set elements using an invalid index
//      s.remove(at: i)
//      s.remove(at: s.endIndex)
    }
    
    func testRedBlackTreeRedBlackTreeSetRemove() throws {
      var s: RedBlackTreeSet<Int> = [1,2,3,4]
      let i = s.firstIndex(of: 2)!
      s.remove(at: i)
      // Attempting to access Set elements using an invalid index
//      s.remove(at: i)
//      s.remove(at: s.endIndex)
    }
    
  }
#endif
