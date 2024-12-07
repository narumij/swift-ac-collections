//
//  SortedSetTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/09/16.
//

#if DEBUG
  import XCTest
  @testable import RedBlackTreeModule

  extension RedBlackTreeMultiset {

    @inlinable
    var _count: Int {
      var it = header.__begin_node
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
      get { header.__left_ }
      set { header.__left_ = newValue }
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
    func left(_ p: Element) -> Int { distance(to: lower_bound(p)) }
    func right(_ p: Element) -> Int { distance(to: upper_bound(p)) }
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
    }

    func testInitRange() throws {
      let set = RedBlackTreeMultiset<Int>(0..<10000)
      XCTAssertEqual(set.elements, (0..<10000) + [])
      XCTAssertEqual(set._count, 10000)
      XCTAssertFalse(set.isEmpty)
    }

    func testInitCollection1() throws {
      let set = RedBlackTreeMultiset<Int>(0..<10000)
      XCTAssertEqual(set.elements, (0..<10000) + [])
      XCTAssertEqual(set._count, 10000)
      XCTAssertFalse(set.isEmpty)
    }

    func testInitCollection2() throws {
      let set = RedBlackTreeMultiset<Int>([2, 3, 3, 0, 0, 1, 1, 1])
      XCTAssertEqual(set.elements, [0, 0, 1, 1, 1, 2, 3, 3])
      XCTAssertEqual(set._count, 8)
      XCTAssertFalse(set.isEmpty)
    }

    func testRemove() throws {
      var set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set.remove(0), true)
      XCTAssertFalse(set.elements.isEmpty)
      XCTAssertEqual(set.remove(1), true)
      XCTAssertFalse(set.elements.isEmpty)
      XCTAssertEqual(set.remove(2), true)
      XCTAssertFalse(set.elements.isEmpty)
      XCTAssertEqual(set.remove(3), true)
      XCTAssertFalse(set.elements.isEmpty)
      XCTAssertEqual(set.remove(4), true)
      XCTAssertTrue(set.elements.isEmpty)
      XCTAssertEqual(set.remove(0), false)
      XCTAssertTrue(set.elements.isEmpty)
      XCTAssertEqual(set.remove(1), false)
      XCTAssertTrue(set.elements.isEmpty)
      XCTAssertEqual(set.remove(2), false)
      XCTAssertTrue(set.elements.isEmpty)
      XCTAssertEqual(set.remove(3), false)
      XCTAssertTrue(set.elements.isEmpty)
      XCTAssertEqual(set.remove(4), false)
      XCTAssertTrue(set.elements.isEmpty)
    }

    func testRemoveAt() throws {
      var set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set.remove(at: set.header.__begin_node), 0)
      XCTAssertEqual(set.elements, [1, 2, 3, 4])
      XCTAssertEqual(set.remove(at: set.header.__begin_node), 1)
      XCTAssertEqual(set.elements, [2, 3, 4])
      XCTAssertEqual(set.remove(at: set.header.__begin_node), 2)
      XCTAssertEqual(set.elements, [3, 4])
      XCTAssertEqual(set.remove(at: set.header.__begin_node), 3)
      XCTAssertEqual(set.elements, [4])
      XCTAssertEqual(set.remove(at: set.header.__begin_node), 4)
      XCTAssertEqual(set.elements, [])
      XCTAssertEqual(set.remove(at: set.header.__begin_node), nil)
    }

    func testInsert() throws {
      var set = RedBlackTreeMultiset<Int>([])
      XCTAssertEqual(set.insert(0), true)
      XCTAssertEqual(set.insert(1), true)
      XCTAssertEqual(set.insert(2), true)
      XCTAssertEqual(set.insert(3), true)
      XCTAssertEqual(set.insert(4), true)
      XCTAssertEqual(set.insert(0), true)
      XCTAssertEqual(set.insert(1), true)
      XCTAssertEqual(set.insert(2), true)
      XCTAssertEqual(set.insert(3), true)
      XCTAssertEqual(set.insert(4), true)
    }

    func test_LT_GT() throws {
      var set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set._count, 5)
      XCTAssertEqual(set.lt(-1), nil)
      XCTAssertEqual(set.gt(-1), 0)
      XCTAssertEqual(set.lt(0), nil)
      XCTAssertEqual(set.gt(0), 1)
      XCTAssertEqual(set.lt(1), 0)
      XCTAssertEqual(set.gt(1), 2)
      XCTAssertEqual(set.lt(2), 1)
      XCTAssertEqual(set.gt(2), 3)
      XCTAssertEqual(set.lt(3), 2)
      XCTAssertEqual(set.gt(3), 4)
      XCTAssertEqual(set.lt(4), 3)
      XCTAssertEqual(set.gt(4), nil)
      XCTAssertEqual(set.lt(5), 4)
      XCTAssertEqual(set.gt(5), nil)
      XCTAssertEqual(set.remove(1), true)
      XCTAssertEqual(set.remove(3), true)
      XCTAssertEqual(set.remove(1), false)
      XCTAssertEqual(set.remove(3), false)
      XCTAssertEqual(set.elements, [0, 2, 4])
      XCTAssertEqual(set.lt(-1), nil)
      XCTAssertEqual(set.gt(-1), 0)
      XCTAssertEqual(set.lt(0), nil)
      XCTAssertEqual(set.gt(0), 2)
      XCTAssertEqual(set.lt(1), 0)
      XCTAssertEqual(set.gt(1), 2)
      XCTAssertEqual(set.lt(2), 0)
      XCTAssertEqual(set.gt(2), 4)
      XCTAssertEqual(set.lt(3), 2)
      XCTAssertEqual(set.gt(3), 4)
      XCTAssertEqual(set.lt(4), 2)
      XCTAssertEqual(set.gt(4), nil)
      XCTAssertEqual(set.lt(5), 4)
      XCTAssertEqual(set.gt(5), nil)
      XCTAssertEqual(set.remove(2), true)
      XCTAssertEqual(set.remove(1), false)
      XCTAssertEqual(set.remove(2), false)
      XCTAssertEqual(set.remove(3), false)
      XCTAssertEqual(set.elements, [0, 4])
      XCTAssertEqual(set.lt(-1), nil)
      XCTAssertEqual(set.gt(-1), 0)
      XCTAssertEqual(set.lt(0), nil)
      XCTAssertEqual(set.gt(0), 4)
      XCTAssertEqual(set.lt(1), 0)
      XCTAssertEqual(set.gt(1), 4)
      XCTAssertEqual(set.lt(2), 0)
      XCTAssertEqual(set.gt(2), 4)
      XCTAssertEqual(set.lt(3), 0)
      XCTAssertEqual(set.gt(3), 4)
      XCTAssertEqual(set.lt(4), 0)
      XCTAssertEqual(set.gt(4), nil)
      XCTAssertEqual(set.lt(5), 4)
      XCTAssertEqual(set.gt(5), nil)
      XCTAssertEqual(set.remove(0), true)
      XCTAssertEqual(set.remove(1), false)
      XCTAssertEqual(set.remove(2), false)
      XCTAssertEqual(set.remove(3), false)
      XCTAssertEqual(set.remove(4), true)
      XCTAssertEqual(set.lt(-1), nil)
      XCTAssertEqual(set.gt(-1), nil)
      XCTAssertEqual(set.lt(0), nil)
      XCTAssertEqual(set.gt(0), nil)
      XCTAssertEqual(set.lt(1), nil)
      XCTAssertEqual(set.gt(1), nil)
      XCTAssertEqual(set.lt(2), nil)
      XCTAssertEqual(set.gt(2), nil)
      XCTAssertEqual(set.lt(3), nil)
      XCTAssertEqual(set.gt(3), nil)
      XCTAssertEqual(set.lt(4), nil)
      XCTAssertEqual(set.gt(4), nil)
      XCTAssertEqual(set.lt(5), nil)
      XCTAssertEqual(set.gt(5), nil)
      XCTAssertEqual(set.elements, [])
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
      XCTAssertEqual(set.remove(1), true)
      XCTAssertEqual(set.remove(3), true)
      XCTAssertEqual(set.remove(1), false)
      XCTAssertEqual(set.remove(3), false)
      XCTAssertEqual(set.elements, [0, 2, 4])
      XCTAssertEqual(set.contains(-1), false)
      XCTAssertEqual(set.contains(0), true)
      XCTAssertEqual(set.contains(1), false)
      XCTAssertEqual(set.contains(2), true)
      XCTAssertEqual(set.contains(3), false)
      XCTAssertEqual(set.contains(4), true)
      XCTAssertEqual(set.contains(5), false)
      XCTAssertEqual(set.remove(2), true)
      XCTAssertEqual(set.remove(1), false)
      XCTAssertEqual(set.remove(2), false)
      XCTAssertEqual(set.remove(3), false)
      XCTAssertEqual(set.elements, [0, 4])
      XCTAssertEqual(set.contains(-1), false)
      XCTAssertEqual(set.contains(0), true)
      XCTAssertEqual(set.contains(1), false)
      XCTAssertEqual(set.contains(2), false)
      XCTAssertEqual(set.contains(3), false)
      XCTAssertEqual(set.contains(4), true)
      XCTAssertEqual(set.contains(5), false)
      XCTAssertEqual(set.remove(0), true)
      XCTAssertEqual(set.remove(1), false)
      XCTAssertEqual(set.remove(2), false)
      XCTAssertEqual(set.remove(3), false)
      XCTAssertEqual(set.remove(4), true)
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
      var set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set._count, 5)
      XCTAssertEqual(set.le(-1), nil)
      XCTAssertEqual(set.ge(-1), 0)
      XCTAssertEqual(set.le(0), 0)
      XCTAssertEqual(set.ge(0), 0)
      XCTAssertEqual(set.le(1), 1)
      XCTAssertEqual(set.ge(1), 1)
      XCTAssertEqual(set.le(2), 2)
      XCTAssertEqual(set.ge(2), 2)
      XCTAssertEqual(set.le(3), 3)
      XCTAssertEqual(set.ge(3), 3)
      XCTAssertEqual(set.le(4), 4)
      XCTAssertEqual(set.ge(4), 4)
      XCTAssertEqual(set.le(5), 4)
      XCTAssertEqual(set.ge(5), nil)
      XCTAssertEqual(set.remove(1), true)
      XCTAssertEqual(set.remove(3), true)
      XCTAssertEqual(set.remove(1), false)
      XCTAssertEqual(set.remove(3), false)
      XCTAssertEqual(set.elements, [0, 2, 4])
      XCTAssertEqual(set.le(-1), nil)
      XCTAssertEqual(set.ge(-1), 0)
      XCTAssertEqual(set.le(0), 0)
      XCTAssertEqual(set.ge(0), 0)
      XCTAssertEqual(set.le(1), 0)
      XCTAssertEqual(set.ge(1), 2)
      XCTAssertEqual(set.le(2), 2)
      XCTAssertEqual(set.ge(2), 2)
      XCTAssertEqual(set.le(3), 2)
      XCTAssertEqual(set.ge(3), 4)
      XCTAssertEqual(set.le(4), 4)
      XCTAssertEqual(set.ge(4), 4)
      XCTAssertEqual(set.le(5), 4)
      XCTAssertEqual(set.ge(5), nil)
      XCTAssertEqual(set.remove(2), true)
      XCTAssertEqual(set.remove(1), false)
      XCTAssertEqual(set.remove(2), false)
      XCTAssertEqual(set.remove(3), false)
      XCTAssertEqual(set.elements, [0, 4])
      XCTAssertEqual(set.le(-1), nil)
      XCTAssertEqual(set.ge(-1), 0)
      XCTAssertEqual(set.le(0), 0)
      XCTAssertEqual(set.ge(0), 0)
      XCTAssertEqual(set.le(1), 0)
      XCTAssertEqual(set.ge(1), 4)
      XCTAssertEqual(set.le(2), 0)
      XCTAssertEqual(set.ge(2), 4)
      XCTAssertEqual(set.le(3), 0)
      XCTAssertEqual(set.ge(3), 4)
      XCTAssertEqual(set.le(4), 4)
      XCTAssertEqual(set.ge(4), 4)
      XCTAssertEqual(set.le(5), 4)
      XCTAssertEqual(set.ge(5), nil)
      XCTAssertEqual(set.remove(0), true)
      XCTAssertEqual(set.remove(1), false)
      XCTAssertEqual(set.remove(2), false)
      XCTAssertEqual(set.remove(3), false)
      XCTAssertEqual(set.remove(4), true)
      XCTAssertEqual(set.le(-1), nil)
      XCTAssertEqual(set.ge(-1), nil)
      XCTAssertEqual(set.le(0), nil)
      XCTAssertEqual(set.ge(0), nil)
      XCTAssertEqual(set.le(1), nil)
      XCTAssertEqual(set.ge(1), nil)
      XCTAssertEqual(set.le(2), nil)
      XCTAssertEqual(set.ge(2), nil)
      XCTAssertEqual(set.le(3), nil)
      XCTAssertEqual(set.ge(3), nil)
      XCTAssertEqual(set.le(4), nil)
      XCTAssertEqual(set.ge(4), nil)
      XCTAssertEqual(set.le(5), nil)
      XCTAssertEqual(set.ge(5), nil)
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
      XCTAssertEqual(set.remove(1), true)
      XCTAssertEqual(set.remove(3), true)
      XCTAssertEqual(set.remove(1), false)
      XCTAssertEqual(set.remove(3), false)
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
      XCTAssertEqual(set.remove(2), true)
      XCTAssertEqual(set.remove(1), false)
      XCTAssertEqual(set.remove(2), false)
      XCTAssertEqual(set.remove(3), false)
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
      XCTAssertEqual(set.remove(0), true)
      XCTAssertEqual(set.remove(1), false)
      XCTAssertEqual(set.remove(2), false)
      XCTAssertEqual(set.remove(3), false)
      XCTAssertEqual(set.remove(4), true)
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
      XCTAssertEqual(set[set.begin(), offsetBy: 0], 0)
      XCTAssertEqual(set[set.begin(), offsetBy: 1], 1)
      XCTAssertEqual(set[set.begin(), offsetBy: 2], 2)
      XCTAssertEqual(set[set.begin(), offsetBy: 3], 3)
      XCTAssertEqual(set[set.begin(), offsetBy: 4], 4)
    }

    func testArrayAccess2() throws {
      let set = RedBlackTreeMultiset<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set[set.end(), offsetBy: -5], 0)
      XCTAssertEqual(set[set.end(), offsetBy: -4], 1)
      XCTAssertEqual(set[set.end(), offsetBy: -3], 2)
      XCTAssertEqual(set[set.end(), offsetBy: -2], 3)
      XCTAssertEqual(set[set.end(), offsetBy: -1], 4)
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

  }
#endif
