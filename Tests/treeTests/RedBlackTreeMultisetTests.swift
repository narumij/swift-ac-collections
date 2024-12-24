//
//  SortedSetTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/09/16.
//

#if DEBUG
  import XCTest
  @testable import RedBlackTreeModule

  #if true
    extension RedBlackTreeMultiset {

      @inlinable
      var _count: Int {
        var it = ___header.__begin_node
        if it == .end {
          return 0
        }
        var c = 0
        repeat {
          c += 1
          it = _read { $0.__tree_next_iter(it) }
        } while it != .end
        return c
      }

      @inlinable var __left_: _NodePtr {
        get { ___header.__left_ }
        set { ___header.__left_ = newValue }
      }

      @inlinable func __left_(_ p: _NodePtr) -> _NodePtr {
        _read { $0.__left_(p) }
      }

      @inlinable func __right_(_ p: _NodePtr) -> _NodePtr {
        _read { $0.__right_(p) }
      }

      @inlinable
      func __root() -> _NodePtr {
        __left_
      }
      @inlinable
      mutating func __root(_ p: _NodePtr) {
        __left_ = p
      }
      @inlinable
      func
        __tree_invariant(_ __root: _NodePtr) -> Bool
      {
        _read { $0.__tree_invariant(__root) }
      }
      @inlinable
      func
        __tree_min(_ __x: _NodePtr) -> _NodePtr
      {
        _read { $0.__tree_min(__x) }
      }
      @inlinable
      func
        __tree_max(_ __x: _NodePtr) -> _NodePtr
      {
        _read { $0.__tree_max(__x) }
      }
      @inlinable
      mutating func
        __tree_left_rotate(_ __x: _NodePtr)
      {
        _update { $0.__tree_left_rotate(__x) }
      }
      @inlinable
      mutating func
        __tree_right_rotate(_ __x: _NodePtr)
      {
        _update { $0.__tree_right_rotate(__x) }
      }
      @inlinable
      mutating func
        __tree_balance_after_insert(_ __root: _NodePtr, _ __x: _NodePtr)
      {
        _update { $0.__tree_balance_after_insert(__root, __x) }
      }
    }

    extension RedBlackTreeMultiset {
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
    }
  #endif

  extension RedBlackTreeMultiset {
    var elements: [Element] {
      map { $0 }
    }
  }

  final class RedBlackTreeMultisetTests: XCTestCase {

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitEmtpy() throws {
      let set = RedBlackTreeMultiset<Int>()
      XCTAssertEqual(set.elements, [])
      XCTAssertEqual(set._count, 0)
      XCTAssertTrue(set.isEmpty)
      XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 0)
    }

    func testRedBlackTreeCapacity() throws {
      var numbers: RedBlackTreeMultiset<Int> = .init(minimumCapacity: 3)
      XCTAssertGreaterThanOrEqual(numbers.capacity, 3)
      numbers.reserveCapacity(4)
      XCTAssertGreaterThanOrEqual(numbers.capacity, 4)
    }

    func testInitRange() throws {
      let set = RedBlackTreeMultiset<Int>(0..<10000)
      XCTAssertEqual(set.elements, (0..<10000) + [])
      XCTAssertEqual(set._count, 10000)
      XCTAssertFalse(set.isEmpty)
      XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 10000)
    }

    func testInitCollection1() throws {
      let set = RedBlackTreeMultiset<Int>(0..<10000)
      XCTAssertEqual(set.elements, (0..<10000) + [])
      XCTAssertEqual(set._count, 10000)
      XCTAssertFalse(set.isEmpty)
      XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 10000)
    }

    func testInitCollection2() throws {
      let set = RedBlackTreeMultiset<Int>([2, 3, 3, 0, 0, 1, 1, 1])
      XCTAssertEqual(set.elements, [0, 0, 1, 1, 1, 2, 3, 3])
      XCTAssertEqual(set._count, 8)
      XCTAssertFalse(set.isEmpty)
      XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), set.count)
    }

    func testExample3() throws {
      let b: RedBlackTreeMultiset<Int> = [1, 2, 3]
      XCTAssertEqual(b.distance(from: b.startIndex, to: b.endIndex), b.count)
    }

    func testSmoke() throws {
      let b: RedBlackTreeMultiset<Int> = [1, 2, 3]
      print(b)
      debugPrint(b)
    }

    func testRemove() throws {
      var set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
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
      var set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
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
      var set = RedBlackTreeMultiset<Int>([])
      XCTAssertEqual(set.insert(0).inserted, true)
      XCTAssertEqual(set.insert(1).inserted, true)
      XCTAssertEqual(set.insert(2).inserted, true)
      XCTAssertEqual(set.insert(3).inserted, true)
      XCTAssertEqual(set.insert(4).inserted, true)
      XCTAssertEqual(set.insert(0).inserted, true)
      XCTAssertEqual(set.insert(1).inserted, true)
      XCTAssertEqual(set.insert(2).inserted, true)
      XCTAssertEqual(set.insert(3).inserted, true)
      XCTAssertEqual(set.insert(4).inserted, true)
    }

    func testContains() throws {
      var set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
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

    func testLeftRight() throws {
      var set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set._count, 5)
      XCTAssertEqual(set.left(-1).index, 0)
      //      XCTAssertEqual(set.elements.count { $0 < -1 }, 0)
      XCTAssertEqual(set.left(0).index, 0)
      //      XCTAssertEqual(set.elements.count { $0 < 0 }, 0)
      XCTAssertEqual(set.left(1).index, 1)
      //      XCTAssertEqual(set.elements.count { $0 < 1 }, 1)
      XCTAssertEqual(set.left(2).index, 2)
      XCTAssertEqual(set.left(3).index, 3)
      XCTAssertEqual(set.left(4).index, 4)
      XCTAssertEqual(set.left(5).index, 5)
      XCTAssertEqual(set.left(6).index, 5)
      XCTAssertEqual(set.right(-1).index, 0)
      //      XCTAssertEqual(set.elements.count { $0 <= -1 }, 0)
      XCTAssertEqual(set.right(0).index, 1)
      //      XCTAssertEqual(set.elements.count { $0 <= 0 }, 1)
      XCTAssertEqual(set.right(1).index, 2)
      //      XCTAssertEqual(set.elements.count { $0 <= 1 }, 2)
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
      let set = RedBlackTreeMultiset<Int>([5, 2, 3, 1, 0])
      XCTAssertEqual(set.max(), 5)
      XCTAssertEqual(set.min(), 0)
    }

    func testSequence() throws {
      let set = RedBlackTreeMultiset<Int>([5, 2, 3, 1, 0])
      XCTAssertEqual(set.map { $0 }, [0, 1, 2, 3, 5])
    }

    func testArrayAccess1() throws {
      let set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 0)], 0)
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 1)], 1)
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 2)], 2)
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 3)], 3)
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 4)], 4)
    }

    func testArrayAccess2() throws {
      let set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -5)], 0)
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -4)], 1)
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -3)], 2)
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -2)], 3)
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -1)], 4)
    }

    func testIndexLimit1() throws {
      let set = Set<Int>([0, 1, 2, 3, 4])
      XCTAssertNotEqual(
        set.index(set.startIndex, offsetBy: 4, limitedBy: set.index(set.startIndex, offsetBy: 4)),
        nil)
      XCTAssertEqual(
        set.index(set.startIndex, offsetBy: 5, limitedBy: set.index(set.startIndex, offsetBy: 4)),
        nil)
      XCTAssertEqual(set.index(set.startIndex, offsetBy: 5, limitedBy: set.endIndex), set.endIndex)
      XCTAssertEqual(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
      XCTAssertEqual(set.index(set.endIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
      //      XCTAssertEqual(set.index(set.endIndex, offsetBy: -6, limitedBy: set.startIndex), nil)
    }

    func testIndexLimit2() throws {
      let set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
      XCTAssertNotEqual(
        set.index(set.startIndex, offsetBy: 4, limitedBy: set.index(set.startIndex, offsetBy: 4)),
        nil)
      XCTAssertEqual(
        set.index(set.startIndex, offsetBy: 5, limitedBy: set.index(set.startIndex, offsetBy: 4)),
        nil)
      XCTAssertEqual(set.index(set.startIndex, offsetBy: 5, limitedBy: set.endIndex), set.endIndex)
      XCTAssertEqual(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
      XCTAssertEqual(set.index(set.endIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
    }

    func testIndexLimit3() throws {
      let set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set.startIndex, .node(0))
      XCTAssertEqual(set.index(before: set.endIndex), .node(4))
      XCTAssertEqual(set.index(set.endIndex, offsetBy: -1), .node(4))
      XCTAssertEqual(set.index(set.endIndex, offsetBy: -1, limitedBy: set.startIndex), .node(4))
      XCTAssertEqual(set.index(set.endIndex, offsetBy: -5), .node(0))
      XCTAssertEqual(set.index(set.endIndex, offsetBy: -5), set.startIndex)
      XCTAssertNotEqual(
        set.index(set.endIndex, offsetBy: -4, limitedBy: set.index(set.endIndex, offsetBy: -4)),
        nil)
      XCTAssertEqual(
        set.index(set.endIndex, offsetBy: -5, limitedBy: set.index(set.endIndex, offsetBy: -4)),
        nil)
      XCTAssertEqual(
        set.index(set.endIndex, offsetBy: -5, limitedBy: set.startIndex),
        set.startIndex)
      XCTAssertEqual(
        set.index(set.endIndex, offsetBy: -6, limitedBy: set.startIndex),
        nil)
      XCTAssertEqual(
        set.index(set.startIndex, offsetBy: -6, limitedBy: set.startIndex),
        nil)
    }

    func testRandom() throws {
      var set = RedBlackTreeMultiset<Int>()
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
      let set: RedBlackTreeMultiset<Int> = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5]
      XCTAssertEqual(set.map { $0 }, [1, 1, 2, 2, 3, 3, 4, 4, 5, 5])
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

    //    func testRedBlackTreeSetUpdate() throws {
    //      let a = A(x: 3, label: "a")
    //      let b = A(x: 3, label: "b")
    //      var s: RedBlackTreeMultiset<A> = [a]
    //      XCTAssertFalse(a === b)
    //      XCTAssertTrue(s.update(with: b) === a)
    //      XCTAssertTrue(s.update(with: a) === b)
    //    }

    func testRedBlackTreeSetInsert() throws {
      let a = A(x: 3, label: "a")
      let b = A(x: 3, label: "b")
      var s: RedBlackTreeMultiset<A> = []
      XCTAssertFalse(a === b)
      do {
        let r = s.insert(a)
        XCTAssertEqual(r.inserted, true)
        XCTAssertTrue(r.memberAfterInsert === a)
      }
      do {
        // 重複を受け付けるので、setと挙動が異なる
        let r = s.insert(b)
        XCTAssertEqual(r.inserted, true)
        XCTAssertTrue(r.memberAfterInsert === b)
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
      var s: RedBlackTreeMultiset<Int> = [1, 2, 3, 4]
      XCTAssertEqual(s.first, 1)
      let i = s.firstIndex(of: 2)!
      XCTAssertEqual(s.last, 4)
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
      XCTAssertNil(s.last)
      //      s.removeFirst()
    }

    func testRedBlackTreeSetLowerBound() throws {
      let numbers: RedBlackTreeMultiset = [1, 3, 5, 7, 9]
      XCTAssertEqual(numbers.lowerBound(4).pointer, 2)
    }

    func testRedBlackTreeSetUpperBound() throws {
      let numbers: RedBlackTreeMultiset = [1, 3, 5, 7, 9]
      XCTAssertEqual(numbers.upperBound(7).pointer, 4)
    }

    func testRedBlackTreeConveniences() throws {
      let numbers: RedBlackTreeMultiset = [1, 3, 5, 7, 9]

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
      var members: RedBlackTreeMultiset = [1, 3, 5, 7, 9]
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

    func testRedBlackTreeSetRemoveLast() throws {
      var members: RedBlackTreeMultiset = [1, 3, 5, 7, 9]
      XCTAssertEqual(members.removeLast(), 9)
      XCTAssertEqual(members.removeLast(), 7)
      XCTAssertEqual(members.removeLast(), 5)
      XCTAssertEqual(members.removeLast(), 3)
      XCTAssertEqual(members.removeLast(), 1)
    }

    func testEqualtable() throws {
      XCTAssertEqual(RedBlackTreeMultiset<Int>(), [])
      XCTAssertNotEqual(RedBlackTreeMultiset<Int>(), [1])
      XCTAssertEqual([1] as RedBlackTreeMultiset<Int>, [1])
      XCTAssertNotEqual([1, 1] as RedBlackTreeMultiset<Int>, [1])
      XCTAssertNotEqual([1, 2] as RedBlackTreeMultiset<Int>, [1, 1])
    }
    
    func testContainsAllSatisfy() throws {
      let dict = [1, 2, 2, 2, 3, 3, 4, 5] as RedBlackTreeMultiset<Int>
      XCTAssertEqual(dict.first, 1)
      XCTAssertEqual(dict.last, 5)
      XCTAssertEqual(dict.first(where: { $0 > 4}), 5)
      XCTAssertEqual(dict.firstIndex(where: { $0 > 4 }), dict.index(before: dict.endIndex))
      XCTAssertEqual(dict.first(where: { $0 > 5}), nil)
      XCTAssertEqual(dict.firstIndex(where: { $0 > 5 }), nil)
      XCTAssertTrue(dict.contains(where: { $0 > 3 }))
      XCTAssertFalse(dict.contains(where: { $0 > 5 }))
      XCTAssertTrue(dict.allSatisfy({ $0 > 0 }))
      XCTAssertFalse(dict.allSatisfy({ $0 > 1 }))
    }
    
    func testForEach() throws {
      let dict = [1,2,2,3] as RedBlackTreeMultiset<Int>
      var d: [Int] = []
      dict.forEach { v in
        d.append(v)
      }
      XCTAssertEqual(d, [1,2,2,3])
    }

    func testPerformanceDistanceFromTo() throws {
      throw XCTSkip()
      let s: RedBlackTreeMultiset<Int> = .init(0..<1_000_000)
      self.measure {
        // BidirectionalCollectionの実装の場合、0.3sec
        // 木の場合、0.08sec
        // 片方がendIndexの場合、その部分だけO(1)となるよう修正
        XCTAssertEqual(s.distance(from: s.endIndex, to: s.startIndex), -1_000_000)
      }
    }

    func testPerformanceIndexOffsetBy1() throws {
      throw XCTSkip()
      let s: RedBlackTreeMultiset<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.index(s.startIndex, offsetBy: 1_000_000), s.endIndex)
      }
    }

    func testPerformanceIndexOffsetBy2() throws {
      throw XCTSkip()
      let s: RedBlackTreeMultiset<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.index(s.endIndex, offsetBy: -1_000_000), s.startIndex)
      }
    }

    func testPerformanceFirstIndex1() throws {
      throw XCTSkip()
      let s: RedBlackTreeMultiset<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 1_000_000 - 1), s.index(before: s.endIndex))
      }
    }

    func testPerformanceFirstIndex2() throws {
      throw XCTSkip()
      let s: RedBlackTreeMultiset<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 0), s.startIndex)
      }
    }

    func testPerformanceFirstIndex3() throws {
      throw XCTSkip()
      let s: RedBlackTreeMultiset<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 1_000_000), nil)
      }
    }

    func testPerformanceFirstIndex4() throws {
      throw XCTSkip()
      let s: RedBlackTreeMultiset<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 - 1 }), s.index(before: s.endIndex))
      }
    }

    func testPerformanceFirstIndex5() throws {
      throw XCTSkip()
      let s: RedBlackTreeMultiset<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(where: { $0 >= 0 }), s.startIndex)
      }
    }

    func testPerformanceFirstIndex6() throws {
      throw XCTSkip()
      let s: RedBlackTreeMultiset<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 }), nil)
      }
    }
  }
#endif
