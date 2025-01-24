import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

@usableFromInline
protocol NodeBase {
  var __right_: _NodePtr { get set }
  var __left_: _NodePtr { get set }
  var __parent_: _NodePtr { get set }
  var __is_black_: Bool { get set }
}

@usableFromInline
enum VC: ScalarValueComparer {
  @usableFromInline
  typealias _Key = Int
  @usableFromInline
  typealias Element = Int
}

#if DEBUG
  extension NodeBase {

    @inlinable
    var node: ___RedBlackTree.___Node {
      get { .init(self) }
      set {
        __is_black_ = newValue.__is_black_
        __left_ = newValue.__left_
        __right_ = newValue.__right_
        __parent_ = newValue.__parent_
      }
    }
  }
  extension ___RedBlackTree.___Tree.Node: NodeBase {}
#endif

#if DEBUG
  typealias RedBlackTree___Tree = ___RedBlackTree.___Tree<VC>

  extension ___RedBlackTree.___Node {

    @inlinable
    init<Node: NodeBase>(_ node: Node) {
      self.init(
        __is_black_: node.__is_black_,
        __left_: node.__left_,
        __right_: node.__right_,
        __parent_: node.__parent_
      )
    }
  }

  extension ___RedBlackTree.___Tree {

#if false
    @inlinable
    var nodes: [___RedBlackTree.___Node] {
      get {
        (0..<count).map { .init(__node_ptr[$0]) }
      }
      set {
        header.initializedCount = newValue.count
        newValue.enumerated().forEach {
          i, v in __node_ptr[i].node = v
        }
      }
    }

    @inlinable
    var values: [Element] {
      get {
        (0..<count).map { __node_ptr[$0].__value_ }
      }
      set {
        header.initializedCount = newValue.count
        newValue.enumerated().forEach {
          i, v in __node_ptr[i].__value_ = v
        }
      }
    }
#else
    @inlinable
    var nodes: [___RedBlackTree.___Node] {
      get {
        (0..<_header.initializedCount).map {
          .init(__is_black_: __is_black_($0),
                __left_: __left_($0),
                __right_: __right_($0),
                __parent_: __parent_($0))
        }
      }
      set {
        ___clearDestroy()
        _header.initializedCount = newValue.count
        newValue.enumerated().forEach {
          i, v in
          __is_black_(i, v.__is_black_)
          __left_(i, v.__left_)
          __right_(i, v.__right_)
          __parent_(i, v.__parent_)
        }
      }
    }
    
    @inlinable
    var values: [Element] {
      get {
        (0..<_header.initializedCount).map {
          ___element($0)
        }
      }
      set {
        _header.initializedCount = newValue.count
        newValue.enumerated().forEach {
          i, v in
          ___element(i, v)
        }
      }
    }
#endif

    @inlinable
    func __root(_ p: _NodePtr) {
      __header_ptr.pointee.__left_ = p
    }

    @inlinable
    var validCount: Int {
      var c = 0
      for i in 0..<count {
        c += ___is_valid(i) ? 1 : 0
      }
      return c
    }
  }
#endif

final class ___RedBlackTree___TreeTests: XCTestCase {

  #if DEBUG
    func fixtureEmpty(_ tree: inout RedBlackTree___Tree) {
      tree.nodes = []
//      print(tree.graphviz())
      tree.__root(.nullptr)
      XCTAssertTrue(tree.__tree_invariant(tree.__root()))
    }

    func fixture0_10_20(_ tree: inout RedBlackTree___Tree) {
      tree.nodes = [
        .init(__is_black_: true, __left_: 1, __right_: 2, __parent_: .end),
        .init(__is_black_: false, __left_: nil, __right_: nil, __parent_: 0),
        .init(__is_black_: false, __left_: nil, __right_: nil, __parent_: 0),
      ]
      tree.values = [
        10,
        0,
        20,
      ]
//      print(tree.graphviz())
      tree.__root(0)
      XCTAssertTrue(tree.__tree_invariant(tree.__root()))
    }

    func fixture0_1_2_3_4_5_6(_ tree: inout RedBlackTree___Tree) {
      tree.nodes = [
        .init(__is_black_: true, __left_: 1, __right_: 4, __parent_: .end),
        .init(__is_black_: false, __left_: 2, __right_: 3, __parent_: 0),
        .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 1),
        .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 1),
        .init(__is_black_: false, __left_: 5, __right_: 6, __parent_: 0),
        .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 4),
        .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 4),
      ]
      tree.values = [
        3,
        1,
        0,
        2,
        4,
        5,
        6,
      ]
//      print(tree.graphviz())
      tree.__root(0)
      tree.size = tree.nodes.count
      tree.header.__begin_node = 2
      XCTAssertTrue(tree.__tree_invariant(tree.__root()))
    }

#if TREE_INVARIANT_CHECKS
    func testRootInvaliant() throws {

      let tree = RedBlackTree___Tree.create(minimumCapacity: 8)
      XCTAssertTrue(tree.__tree_invariant(tree.__root()))

      tree.nodes = [
        .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: .end)
      ]

      tree.__root(.nullptr)
      XCTAssertFalse(tree.__tree_invariant(0))

      tree.__root(0)
      XCTAssertTrue(tree.__tree_invariant(tree.__root()))

      tree.nodes = [
        .init(__is_black_: false, __left_: nil, __right_: nil, __parent_: .end)
      ]
      XCTAssertFalse(tree.__tree_invariant(tree.__root()))

      tree.nodes = [
        .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: nil)
      ]
      XCTAssertFalse(tree.__tree_invariant(tree.__root()))
    }
#endif

    func testFixtures() {

      var tree = RedBlackTree___Tree.create(minimumCapacity: 8)
      fixtureEmpty(&tree)
      fixture0_10_20(&tree)
      fixture0_1_2_3_4_5_6(&tree)
    }

    func testMin() {
      var tree = RedBlackTree___Tree.create(minimumCapacity: 8)
      fixture0_10_20(&tree)
      XCTAssertEqual(tree.__tree_min(tree.__root()), 1)
      fixture0_1_2_3_4_5_6(&tree)
      XCTAssertEqual(tree.__tree_min(tree.__root()), 2)
    }

    func testMax() {
      var tree = RedBlackTree___Tree.create(minimumCapacity: 8)
      fixture0_10_20(&tree)
      XCTAssertEqual(tree.__tree_max(tree.__root()), 2)
      fixture0_1_2_3_4_5_6(&tree)
      XCTAssertEqual(tree.__tree_max(tree.__root()), 6)
    }

#if TREE_INVARIANT_CHECKS
    func testRotate() throws {
      let tree = RedBlackTree___Tree.create(minimumCapacity: 8)

      tree.nodes = [
        .init(__is_black_: true, __left_: 1, __right_: 2, __parent_: .end),
        .init(__is_black_: false, __left_: nil, __right_: nil, __parent_: 0),
        .init(__is_black_: false, __left_: 3, __right_: 4, __parent_: 0),
        .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 2),
        .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 2),
      ]
      tree.__root(0)

      let initial = tree.nodes

//      print(tree.graphviz())
      XCTAssertFalse(tree.__tree_invariant(tree.__root()))

      tree.__tree_left_rotate(tree.__root())
//      print(tree.graphviz())

      var next = initial
      next[0] = .init(__is_black_: true, __left_: 1, __right_: 3, __parent_: 2)
      next[2] = .init(__is_black_: false, __left_: 0, __right_: 4, __parent_: .end)
      next[3] = .init(__is_black_: true, __left_: nil, __right_: nil, __parent_: 0)

      XCTAssertEqual(tree.__root(), 2)
      XCTAssertEqual(tree.nodes[0], next[0])
      XCTAssertEqual(tree.nodes[1], next[1])
      XCTAssertEqual(tree.nodes[2], next[2])
      XCTAssertEqual(tree.nodes[3], next[3])
      XCTAssertEqual(tree.nodes[4], next[4])

      tree.__tree_right_rotate(2)
//      print(tree.graphviz())

      XCTAssertEqual(tree.nodes, initial)
    }
#endif

#if TREE_INVARIANT_CHECKS
    func testBalancing0() throws {
      var tree = RedBlackTree___Tree.create(minimumCapacity: 8)
      fixtureEmpty(&tree)
      tree.__root(.node(tree.nodes.count))
      tree.nodes.append(.init(__is_black_: false, __left_: nil, __right_: nil, __parent_: .end))
      XCTAssertEqual(tree.nodes.count, 1)
      XCTAssertNotEqual(tree.__root(), nil)
      //        XCTAssertNotEqual(tree.__parent_(tree.__root()), nil)
      XCTAssertEqual(tree.__left_(tree.__root()), nil)
      XCTAssertEqual(tree.__right_(tree.__root()), nil)
      XCTAssertFalse(tree.__tree_invariant(tree.__root()))
      tree.__tree_balance_after_insert(tree.__root(), 0)
      XCTAssertTrue(tree.__tree_invariant(tree.__root()))
    }
#endif

    func testRemove3() throws {

      //        throw XCTSkip("Not implemented")

      let tree = RedBlackTree___Tree.create(minimumCapacity: 8)
      _ = tree.__insert_unique(0)
      _ = tree.__insert_unique(1)
      _ = tree.__insert_unique(2)
      XCTAssertEqual(tree.__tree_min(tree.__root()), tree.header.__begin_node)
      for i in 0..<3 {
        _ = tree.___erase_unique(i)
//        print(tree.graphviz())
        if tree.__root() != .nullptr {
          XCTAssertEqual(tree.__tree_min(tree.__root()), tree.header.__begin_node)
        }
        XCTAssertEqual(tree.count, 2 - i)
      }
    }

    func testRemove2() throws {

      //        throw XCTSkip("Not implemented")

      let tree = RedBlackTree___Tree.create(minimumCapacity: 8)
      for i in 0..<2 {
        _ = tree.__insert_unique(i)
      }
      //        fixture0_1_2_3_4_5_6(&tree)
      XCTAssertEqual(tree.__tree_min(tree.__root()), tree.header.__begin_node)
//      print(tree.nodes.graphviz())
//      print(tree.graphviz())
      for i in 0..<2 {
        XCTAssertTrue(tree.___erase_unique(i) == true, "i = \(i)")
//        print(tree.graphviz())
        print("__root():", tree.__root())
        XCTAssertTrue(tree.__tree_invariant(tree.__root()))
        XCTAssertEqual(
          tree.__root() == .nullptr ? .end : tree.__tree_min(tree.__root()),
          tree.header.__begin_node)
        XCTAssertEqual(tree.count, 1 - i, "i = \(i)")
      }
    }

    func testRemove7() throws {

      //        throw XCTSkip("Not implemented")

      let tree = RedBlackTree___Tree.create(minimumCapacity: 16)
      for i in 0..<7 {
        _ = tree.__insert_unique(i)
      }
      //        fixture0_1_2_3_4_5_6(&tree)
      XCTAssertEqual(tree.__tree_min(tree.__root()), tree.header.__begin_node)
//      print(tree.graphviz())
      for i in 0..<7 {
        XCTAssertTrue(tree.___erase_unique(i) == true, "i = \(i)")
//        print(tree.graphviz())
        print("__root():", tree.__root())
        XCTAssertTrue(tree.__tree_invariant(tree.__root()))
        XCTAssertEqual(
          tree.__root() == .nullptr ? .end : tree.__tree_min(tree.__root()),
          tree.header.__begin_node)
        XCTAssertEqual(tree.count, 6 - i, "i = \(i)")
      }
    }

    func testFindEqual0() throws {
      var tree = RedBlackTree___Tree.create(minimumCapacity: 16)
      fixtureEmpty(&tree)
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 5
        let __child = tree.__find_equal(&__parent, __k)
        XCTAssertEqual(__parent, .end)
        XCTAssertEqual(__child, .__left_(.end))
      }
      do {
        tree.__root(nil)
        var __parent: _NodePtr = .nullptr
        let __k = 5
        let __child = tree.__find_equal(&__parent, __k)
        XCTAssertEqual(__parent, .end)
        XCTAssertEqual(__child, .__left_(.end))
      }
    }

    func testFindEqual1() throws {
      var tree = RedBlackTree___Tree.create(minimumCapacity: 16)
      fixture0_10_20(&tree)
      do {
        var __parent: _NodePtr = .nullptr
        let __k = -1
        let __child = tree.__find_equal(&__parent, __k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 1)
        XCTAssertEqual(__child, .__left_(1))
      }
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 0
        let __child = tree.__find_equal(&__parent, __k)
        XCTAssertNotEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 1)
        XCTAssertEqual(__child, .__left_(0))
      }
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 5
        let __child = tree.__find_equal(&__parent, __k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 1)
        XCTAssertEqual(__child, .__right_(1))
      }
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 10
        let __child = tree.__find_equal(&__parent, __k)
        XCTAssertNotEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 0)
        XCTAssertEqual(__child, .__left_(.end))
      }
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 15
        let __child = tree.__find_equal(&__parent, __k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 2)
        XCTAssertEqual(__child, .__left_(2))
      }
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 20
        let __child = tree.__find_equal(&__parent, __k)
        XCTAssertNotEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 2)
        XCTAssertEqual(__child, .__right_(0))
      }
      do {
        var __parent: _NodePtr = .nullptr
        let __k = 21
        let __child = tree.__find_equal(&__parent, __k)
        XCTAssertEqual(__parent.index, __child.index)
        XCTAssertEqual(__parent, 2)
        XCTAssertEqual(__child, .__right_(2))
      }
    }

#if ENABLE_PERFORMANCE_TESTING
    func testInsert0() throws {

//      throw XCTSkip("slow")

      var tree = RedBlackTree___Tree.create(withCapacity: 10000 + 1)
      fixtureEmpty(&tree)
      for i in 0..<10000 {
        XCTAssertTrue(tree.__insert_unique(i).__inserted)
        XCTAssertTrue(tree.__tree_invariant(tree.__root()))
      }
    }

    func testPerformanceExample() throws {

//      throw XCTSkip()

      // 分解前 1.04 sec
      // 分解後 1.82 sec (ただしリリースビルドでの速度変化なし)

      // This is an example of a performance test case.

      var tree = RedBlackTree___Tree.create(withCapacity: 1_000_000 + 1)
      fixtureEmpty(&tree)
      //        tree.reserveCapacity(1_000_000)

      self.measure {
        // Put the code you want to measure the time of here.
        for i in 0..<1_000_000 {
          _ = tree.__insert_unique(i)
        }
      }
    }
#endif
  
  #endif
  
#if DEBUG
  func testMisc() throws {
    let tree = RedBlackTree___Tree.create(minimumCapacity: 16)
    _ = tree.__insert_unique(0)
    _ = tree.__insert_unique(1)
    _ = tree.__insert_unique(2)
    _ = tree.__insert_unique(3)
    _ = tree.__insert_unique(4)
    _ = tree.__insert_unique(5)
    XCTAssertTrue(tree.___ptr_less_than(tree.lower_bound(0), tree.lower_bound(1)))
    XCTAssertTrue(tree.___ptr_less_than(tree.lower_bound(1), tree.lower_bound(2)))
    XCTAssertTrue(tree.___ptr_less_than(tree.lower_bound(2), tree.lower_bound(3)))
    XCTAssertTrue(tree.___ptr_less_than(tree.lower_bound(3), tree.lower_bound(4)))
    XCTAssertTrue(tree.___ptr_less_than(tree.lower_bound(4), tree.lower_bound(5)))
    XCTAssertTrue(tree.___ptr_less_than(tree.lower_bound(5), .end))
    XCTAssertFalse(tree.___ptr_less_than(tree.lower_bound(0), tree.lower_bound(0)))
    XCTAssertFalse(tree.___ptr_less_than(tree.lower_bound(1), tree.lower_bound(1)))
    XCTAssertFalse(tree.___ptr_less_than(tree.lower_bound(2), tree.lower_bound(2)))
    XCTAssertFalse(tree.___ptr_less_than(tree.lower_bound(3), tree.lower_bound(3)))
    XCTAssertFalse(tree.___ptr_less_than(tree.lower_bound(4), tree.lower_bound(4)))
    XCTAssertFalse(tree.___ptr_less_than(tree.lower_bound(5), tree.lower_bound(5)))
    XCTAssertFalse(tree.___ptr_less_than(.end, .end))
    XCTAssertFalse(tree.___ptr_less_than(tree.lower_bound(1), tree.lower_bound(0)))
    XCTAssertFalse(tree.___ptr_less_than(tree.lower_bound(2), tree.lower_bound(1)))
    XCTAssertFalse(tree.___ptr_less_than(tree.lower_bound(3), tree.lower_bound(2)))
    XCTAssertFalse(tree.___ptr_less_than(tree.lower_bound(4), tree.lower_bound(3)))
    XCTAssertFalse(tree.___ptr_less_than(tree.lower_bound(5), tree.lower_bound(4)))
    XCTAssertFalse(tree.___ptr_less_than(.end, tree.lower_bound(5)))
  }
  
  func testMisc2() throws {
    let tree = RedBlackTree___Tree.create(minimumCapacity: 16)
    _ = tree.__insert_unique(0)
    _ = tree.__insert_unique(1)
    _ = tree.__insert_unique(2)
    _ = tree.__insert_unique(3)
    _ = tree.__insert_unique(4)
    _ = tree.__insert_unique(5)
    XCTAssertFalse(tree.___ptr_greator_than(tree.lower_bound(0), tree.lower_bound(1)))
    XCTAssertFalse(tree.___ptr_greator_than(tree.lower_bound(1), tree.lower_bound(2)))
    XCTAssertFalse(tree.___ptr_greator_than(tree.lower_bound(2), tree.lower_bound(3)))
    XCTAssertFalse(tree.___ptr_greator_than(tree.lower_bound(3), tree.lower_bound(4)))
    XCTAssertFalse(tree.___ptr_greator_than(tree.lower_bound(4), tree.lower_bound(5)))
    XCTAssertFalse(tree.___ptr_greator_than(tree.lower_bound(5), .end))
    XCTAssertFalse(tree.___ptr_greator_than(tree.lower_bound(0), tree.lower_bound(0)))
    XCTAssertFalse(tree.___ptr_greator_than(tree.lower_bound(1), tree.lower_bound(1)))
    XCTAssertFalse(tree.___ptr_greator_than(tree.lower_bound(2), tree.lower_bound(2)))
    XCTAssertFalse(tree.___ptr_greator_than(tree.lower_bound(3), tree.lower_bound(3)))
    XCTAssertFalse(tree.___ptr_greator_than(tree.lower_bound(4), tree.lower_bound(4)))
    XCTAssertFalse(tree.___ptr_greator_than(tree.lower_bound(5), tree.lower_bound(5)))
    XCTAssertFalse(tree.___ptr_greator_than(.end, .end))
    XCTAssertTrue(tree.___ptr_greator_than(tree.lower_bound(1), tree.lower_bound(0)))
    XCTAssertTrue(tree.___ptr_greator_than(tree.lower_bound(2), tree.lower_bound(1)))
    XCTAssertTrue(tree.___ptr_greator_than(tree.lower_bound(3), tree.lower_bound(2)))
    XCTAssertTrue(tree.___ptr_greator_than(tree.lower_bound(4), tree.lower_bound(3)))
    XCTAssertTrue(tree.___ptr_greator_than(tree.lower_bound(5), tree.lower_bound(4)))
    XCTAssertTrue(tree.___ptr_greator_than(.end, tree.lower_bound(5)))
  }
  
  func testMisc3() throws {
    let tree = RedBlackTree___Tree.create(minimumCapacity: 16)
    _ = tree.__insert_unique(0)
    _ = tree.__insert_unique(1)
    _ = tree.__insert_unique(2)
    _ = tree.__insert_unique(3)
    _ = tree.__insert_unique(4)
    _ = tree.__insert_unique(5)
    XCTAssertTrue(tree.___ptr_less_than_or_equal(tree.lower_bound(0), tree.lower_bound(1)))
    XCTAssertTrue(tree.___ptr_less_than_or_equal(tree.lower_bound(1), tree.lower_bound(2)))
    XCTAssertTrue(tree.___ptr_less_than_or_equal(tree.lower_bound(2), tree.lower_bound(3)))
    XCTAssertTrue(tree.___ptr_less_than_or_equal(tree.lower_bound(3), tree.lower_bound(4)))
    XCTAssertTrue(tree.___ptr_less_than_or_equal(tree.lower_bound(4), tree.lower_bound(5)))
    XCTAssertTrue(tree.___ptr_less_than_or_equal(tree.lower_bound(5), .end))
    XCTAssertTrue(tree.___ptr_less_than_or_equal(tree.lower_bound(0), tree.lower_bound(0)))
    XCTAssertTrue(tree.___ptr_less_than_or_equal(tree.lower_bound(1), tree.lower_bound(1)))
    XCTAssertTrue(tree.___ptr_less_than_or_equal(tree.lower_bound(2), tree.lower_bound(2)))
    XCTAssertTrue(tree.___ptr_less_than_or_equal(tree.lower_bound(3), tree.lower_bound(3)))
    XCTAssertTrue(tree.___ptr_less_than_or_equal(tree.lower_bound(4), tree.lower_bound(4)))
    XCTAssertTrue(tree.___ptr_less_than_or_equal(tree.lower_bound(5), tree.lower_bound(5)))
    XCTAssertTrue(tree.___ptr_less_than_or_equal(.end, .end))
    XCTAssertFalse(tree.___ptr_less_than_or_equal(tree.lower_bound(1), tree.lower_bound(0)))
    XCTAssertFalse(tree.___ptr_less_than_or_equal(tree.lower_bound(2), tree.lower_bound(1)))
    XCTAssertFalse(tree.___ptr_less_than_or_equal(tree.lower_bound(3), tree.lower_bound(2)))
    XCTAssertFalse(tree.___ptr_less_than_or_equal(tree.lower_bound(4), tree.lower_bound(3)))
    XCTAssertFalse(tree.___ptr_less_than_or_equal(tree.lower_bound(5), tree.lower_bound(4)))
    XCTAssertFalse(tree.___ptr_less_than_or_equal(.end, tree.lower_bound(5)))
  }

  func testMisc4() throws {
    let tree = RedBlackTree___Tree.create(minimumCapacity: 16)
    _ = tree.__insert_unique(0)
    _ = tree.__insert_unique(1)
    _ = tree.__insert_unique(2)
    _ = tree.__insert_unique(3)
    _ = tree.__insert_unique(4)
    _ = tree.__insert_unique(5)
    XCTAssertFalse(tree.___ptr_greator_than_or_equal(tree.lower_bound(0), tree.lower_bound(1)))
    XCTAssertFalse(tree.___ptr_greator_than_or_equal(tree.lower_bound(1), tree.lower_bound(2)))
    XCTAssertFalse(tree.___ptr_greator_than_or_equal(tree.lower_bound(2), tree.lower_bound(3)))
    XCTAssertFalse(tree.___ptr_greator_than_or_equal(tree.lower_bound(3), tree.lower_bound(4)))
    XCTAssertFalse(tree.___ptr_greator_than_or_equal(tree.lower_bound(4), tree.lower_bound(5)))
    XCTAssertFalse(tree.___ptr_greator_than_or_equal(tree.lower_bound(5), .end))
    XCTAssertTrue(tree.___ptr_greator_than_or_equal(tree.lower_bound(0), tree.lower_bound(0)))
    XCTAssertTrue(tree.___ptr_greator_than_or_equal(tree.lower_bound(1), tree.lower_bound(1)))
    XCTAssertTrue(tree.___ptr_greator_than_or_equal(tree.lower_bound(2), tree.lower_bound(2)))
    XCTAssertTrue(tree.___ptr_greator_than_or_equal(tree.lower_bound(3), tree.lower_bound(3)))
    XCTAssertTrue(tree.___ptr_greator_than_or_equal(tree.lower_bound(4), tree.lower_bound(4)))
    XCTAssertTrue(tree.___ptr_greator_than_or_equal(tree.lower_bound(5), tree.lower_bound(5)))
    XCTAssertTrue(tree.___ptr_greator_than_or_equal(.end, .end))
    XCTAssertTrue(tree.___ptr_greator_than_or_equal(tree.lower_bound(1), tree.lower_bound(0)))
    XCTAssertTrue(tree.___ptr_greator_than_or_equal(tree.lower_bound(2), tree.lower_bound(1)))
    XCTAssertTrue(tree.___ptr_greator_than_or_equal(tree.lower_bound(3), tree.lower_bound(2)))
    XCTAssertTrue(tree.___ptr_greator_than_or_equal(tree.lower_bound(4), tree.lower_bound(3)))
    XCTAssertTrue(tree.___ptr_greator_than_or_equal(tree.lower_bound(5), tree.lower_bound(4)))
    XCTAssertTrue(tree.___ptr_greator_than_or_equal(.end, tree.lower_bound(5)))
  }
  
  func testMisc5() throws {
    let tree = RedBlackTree___Tree.create(minimumCapacity: 16)
    _ = tree.__insert_unique(0)
    _ = tree.__insert_unique(1)
    _ = tree.__insert_unique(2)
    _ = tree.__insert_unique(3)
    _ = tree.__insert_unique(4)
    _ = tree.__insert_unique(5)
    XCTAssertFalse(tree.___ptr_closed_range_contains(tree.lower_bound(1), tree.lower_bound(4), tree.lower_bound(0)))
    XCTAssertTrue(tree.___ptr_closed_range_contains(tree.lower_bound(1), tree.lower_bound(4), tree.lower_bound(1)))
    XCTAssertTrue(tree.___ptr_closed_range_contains(tree.lower_bound(1), tree.lower_bound(4), tree.lower_bound(4)))
    XCTAssertFalse(tree.___ptr_closed_range_contains(tree.lower_bound(1), tree.lower_bound(4), tree.lower_bound(5)))
    XCTAssertFalse(tree.___ptr_closed_range_contains(tree.lower_bound(1), tree.lower_bound(4), tree.__end_node()))
    XCTAssertFalse(tree.___ptr_closed_range_contains(tree.lower_bound(2), tree.lower_bound(3), tree.lower_bound(1)))
    XCTAssertTrue(tree.___ptr_closed_range_contains(tree.lower_bound(2), tree.lower_bound(3), tree.lower_bound(2)))
    XCTAssertTrue(tree.___ptr_closed_range_contains(tree.lower_bound(2), tree.lower_bound(3), tree.lower_bound(3)))
    XCTAssertFalse(tree.___ptr_closed_range_contains(tree.lower_bound(2), tree.lower_bound(3), tree.lower_bound(4)))
    XCTAssertFalse(tree.___ptr_closed_range_contains(tree.lower_bound(2), tree.lower_bound(3), tree.__end_node()))
  }
#endif
}
