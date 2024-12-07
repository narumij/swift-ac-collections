//
//  RedBlackTreeStorageTests.swift
//  swift-tree
//
//  Created by narumij on 2024/09/19.
//

import XCTest
@testable import RedBlackTreeModule

typealias RedBlackTreeStorage = RedBlackTree.Storage

extension RedBlackTreeStorage {
    
    @inlinable
    var count: Int {
        get {
            var it = header.__begin_node
            if it == .end {
                return 0
            }
            var c = 0
            repeat {
                c += 1
                it = _update{ $0.__tree_next_iter(it) }
            } while it != .end
            return c
        }
    }
    
    @inlinable
    var __left_: _NodePtr {
        get { header.__left_ }
        set { header.__left_ = newValue }
    }
    
    @inlinable
    func __root() -> _NodePtr {
        header.__left_
    }
    @inlinable
    func __root(_ p: _NodePtr) {
        header.__left_ = p
    }
    @inlinable
    func
    __tree_invariant(_ __root: _NodePtr) -> Bool {
        _update{ $0.__tree_invariant(__root) }
    }
    @inlinable
    func
    __tree_min(_ __x: _NodePtr) -> _NodePtr {
        _update{ $0.__tree_min(__x) }
    }
    @inlinable
    func
    __tree_max(_ __x: _NodePtr) -> _NodePtr {
        _update{ $0.__tree_max(__x) }
    }
    @inlinable
    func
    __tree_left_rotate(_ __x: _NodePtr) {
        _update{ $0.__tree_left_rotate(__x) }
    }
    @inlinable
    func
    __tree_right_rotate(_ __x: _NodePtr) {
        _update{ $0.__tree_right_rotate(__x) }
    }
    @inlinable
    func
    __tree_balance_after_insert(_ __root: _NodePtr, _ __x: _NodePtr) {
        _update{ $0.__tree_balance_after_insert(__root, __x) }
    }
}

final class RedBlackTreeStorageTests: XCTestCase {
    
    func fixtureEmpty(_ tree: inout RedBlackTreeStorage<Int>) {
        tree.nodes = [
        ]
        print(tree.nodes.graphviz())
        tree.__root(.nullptr)
        XCTAssertTrue(tree.__tree_invariant(tree.__root()))
    }

    func fixture0_10_20(_ tree: inout RedBlackTreeStorage<Int>) {
        tree.nodes = [
            .init(__is_black_: true,  __left_: 1,   __right_: 2  , __parent_: .end),
            .init(__is_black_: false, __left_: nil, __right_: nil, __parent_: 0   ),
            .init(__is_black_: false, __left_: nil, __right_: nil, __parent_: 0   ),
        ]
        tree.values = [
            10,
            0,
            20,
        ]
        print(tree.nodes.graphviz())
        tree.__root(0)
        XCTAssertTrue(tree.__tree_invariant(tree.__root()))
    }
    
    func fixture0_1_2_3_4_5_6(_ tree: inout RedBlackTreeStorage<Int>) {
        tree.nodes = [
            .init(__is_black_:  true, __left_:   1, __right_:   4, __parent_: .end),
            .init(__is_black_: false, __left_:   2, __right_:   3, __parent_:    0),
            .init(__is_black_:  true, __left_: nil, __right_: nil, __parent_:    1),
            .init(__is_black_:  true, __left_: nil, __right_: nil, __parent_:    1),
            .init(__is_black_: false, __left_:   5, __right_:   6, __parent_:    0),
            .init(__is_black_:  true, __left_: nil, __right_: nil, __parent_:    4),
            .init(__is_black_:  true, __left_: nil, __right_: nil, __parent_:    4),
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
        print(tree.nodes.graphviz())
        tree.__root(0)
        tree.header.size = tree.nodes.count
        tree.header.__begin_node = 2
        XCTAssertTrue(tree.__tree_invariant(tree.__root()))
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRootInvaliant() throws {
        
        var tree = RedBlackTreeStorage<Int>()
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
    
    func testFixtures() {
        
        var tree = RedBlackTreeStorage<Int>()
        fixtureEmpty(&tree)
        fixture0_10_20(&tree)
        fixture0_1_2_3_4_5_6(&tree)
    }
    
    func testMin() {
        var tree = RedBlackTreeStorage<Int>()
        fixture0_10_20(&tree)
        XCTAssertEqual(tree.__tree_min(tree.__root()), 1)
        fixture0_1_2_3_4_5_6(&tree)
        XCTAssertEqual(tree.__tree_min(tree.__root()), 2)
    }

    func testMax() {
        var tree = RedBlackTreeStorage<Int>()
        fixture0_10_20(&tree)
        XCTAssertEqual(tree.__tree_max(tree.__root()), 2)
        fixture0_1_2_3_4_5_6(&tree)
        XCTAssertEqual(tree.__tree_max(tree.__root()), 6)
    }
    
    func testRotate() throws {
        var tree = RedBlackTreeStorage<Int>()

        tree.nodes = [
            .init(__is_black_:  true, __left_:   1, __right_:   2, __parent_: .end),
            .init(__is_black_: false, __left_: nil, __right_: nil, __parent_:    0),
            .init(__is_black_: false, __left_:   3, __right_:   4, __parent_:    0),
            .init(__is_black_:  true, __left_: nil, __right_: nil, __parent_:    2),
            .init(__is_black_:  true, __left_: nil, __right_: nil, __parent_:    2),
        ]
        tree.__root(0)

        let initial = tree.nodes
        
        print(tree.nodes.graphviz())
        XCTAssertFalse(tree.__tree_invariant(tree.__root()))

        tree.__tree_left_rotate(tree.__root())
        print(tree.nodes.graphviz())
        
        var next = initial
        next[0] = .init(__is_black_:  true, __left_:   1, __right_:   3, __parent_:    2)
        next[2] = .init(__is_black_: false, __left_:   0, __right_:   4, __parent_: .end)
        next[3] = .init(__is_black_:  true, __left_: nil, __right_: nil, __parent_:    0)

        XCTAssertEqual(tree.__left_, 2)
        XCTAssertEqual(tree.nodes[0], next[0])
        XCTAssertEqual(tree.nodes[1], next[1])
        XCTAssertEqual(tree.nodes[2], next[2])
        XCTAssertEqual(tree.nodes[3], next[3])
        XCTAssertEqual(tree.nodes[4], next[4])

        tree.__tree_right_rotate(2)
        print(tree.nodes.graphviz())
        
        XCTAssertEqual(tree.nodes, initial)
    }
    
    func testBalancing0() throws {
        var tree = RedBlackTreeStorage<Int>()
        fixtureEmpty(&tree)
        tree.__left_ = .node(tree.nodes.count)
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

    func testRemove3() throws {
        
        var tree = RedBlackTreeStorage<Int>()
        _ = tree.__insert_unique(0)
        _ = tree.__insert_unique(1)
        _ = tree.__insert_unique(2)
        XCTAssertEqual(tree._update{ $0.__tree_min($0.__root()) }, tree.header.__begin_node)
        for i in 0..<3 {
            _ = tree.__erase_unique(i)
            print(tree.nodes.graphviz())
            if tree.__root() != .nullptr {
                XCTAssertEqual(tree._update{ $0.__tree_min($0.__root()) }, tree.header.__begin_node)
            }
            XCTAssertEqual(tree.count, 2 - i)
        }
    }

    func testRemove2() throws {
        
        var tree = RedBlackTreeStorage<Int>()
        for i in 0..<2 {
            _ = tree.__insert_unique(i)
        }
//        fixture0_1_2_3_4_5_6(&tree)
        XCTAssertEqual(tree._update{ $0.__tree_min($0.__root()) }, tree.header.__begin_node)
        print(tree.nodes.graphviz())
        for i in 0..<2 {
            XCTAssertTrue(tree.__erase_unique(i) == 1, "i = \(i)")
            print(tree.nodes.graphviz())
            print("__root():",tree.__root())
            XCTAssertTrue(tree.__tree_invariant(tree.__root()))
            XCTAssertEqual(tree.__root() == .nullptr ? .end : tree._update{ $0.__tree_min($0.__root()) }, tree.header.__begin_node)
            XCTAssertEqual(tree.count, 1 - i, "i = \(i)")
        }
    }

    func testRemove7() throws {
        
        var tree = RedBlackTreeStorage<Int>()
        for i in 0..<7 {
            _ = tree.__insert_unique(i)
        }
//        fixture0_1_2_3_4_5_6(&tree)
        XCTAssertEqual(tree._update{ $0.__tree_min($0.__root()) }, tree.header.__begin_node)
        print(tree.nodes.graphviz())
        for i in 0..<7 {
            XCTAssertTrue(tree.__erase_unique(i) == 1, "i = \(i)")
            print(tree.nodes.graphviz())
            print("__root():",tree.__root())
            XCTAssertTrue(tree.__tree_invariant(tree.__root()))
            XCTAssertEqual(tree.__root() == .nullptr ? .end : tree._update{ $0.__tree_min($0.__root()) }, tree.header.__begin_node)
            XCTAssertEqual(tree.count, 6 - i, "i = \(i)")
        }
    }
    
    func testFindEqual0() throws {
        var tree = RedBlackTreeStorage<Int>()
        fixtureEmpty(&tree)
        do {
            var __parent: _NodePtr = .nullptr
            var __k = 5
            let __child    = tree.__find_equal(&__parent, __k)
            XCTAssertEqual(__parent, .end)
            XCTAssertEqual(__child, .__left_(.end))
        }
        do {
            tree.__left_ = nil
            var __parent: _NodePtr = .nullptr
            var __k = 5
            let __child    = tree.__find_equal(&__parent, __k)
            XCTAssertEqual(__parent, .end)
            XCTAssertEqual(__child, .__left_(.end))
        }
    }
    
    func testFindEqual1() throws {
        var tree = RedBlackTreeStorage<Int>()
        fixture0_10_20(&tree)
        do {
            var __parent: _NodePtr = .nullptr
            var __k = -1
            let __child    = tree.__find_equal(&__parent, __k)
            XCTAssertEqual(__parent.index, __child.index)
            XCTAssertEqual(__parent, 1)
            XCTAssertEqual(__child, .__left_(1))
        }
        do {
            var __parent: _NodePtr = .nullptr
            var __k = 0
            let __child    = tree.__find_equal(&__parent, __k)
            XCTAssertNotEqual(__parent.index, __child.index)
            XCTAssertEqual(__parent, 1)
            XCTAssertEqual(__child, .__left_(0))
        }
        do {
            var __parent: _NodePtr = .nullptr
            var __k = 5
            let __child    = tree.__find_equal(&__parent, __k)
            XCTAssertEqual(__parent.index, __child.index)
            XCTAssertEqual(__parent, 1)
            XCTAssertEqual(__child, .__right_(1))
        }
        do {
            var __parent: _NodePtr = .nullptr
            var __k = 10
            let __child    = tree.__find_equal(&__parent, __k)
            XCTAssertNotEqual(__parent.index, __child.index)
            XCTAssertEqual(__parent, 0)
            XCTAssertEqual(__child, .__left_(.end))
        }
        do {
            var __parent: _NodePtr = .nullptr
            var __k = 15
            let __child    = tree.__find_equal(&__parent, __k)
            XCTAssertEqual(__parent.index, __child.index)
            XCTAssertEqual(__parent, 2)
            XCTAssertEqual(__child, .__left_(2))
        }
        do {
            var __parent: _NodePtr = .nullptr
            var __k = 20
            let __child    = tree.__find_equal(&__parent, __k)
            XCTAssertNotEqual(__parent.index, __child.index)
            XCTAssertEqual(__parent, 2)
            XCTAssertEqual(__child, .__right_(0))
        }
        do {
            var __parent: _NodePtr = .nullptr
            var __k = 21
            let __child    = tree.__find_equal(&__parent, __k)
            XCTAssertEqual(__parent.index, __child.index)
            XCTAssertEqual(__parent, 2)
            XCTAssertEqual(__child, .__right_(2))
        }
    }
    
    func testInsert0() throws {
        
        var tree = RedBlackTreeStorage<Int>()
        fixtureEmpty(&tree)
        for i in 0 ..< 10000 {
            XCTAssertTrue(tree.__insert_unique(i).__inserted)
            XCTAssertTrue(tree.__tree_invariant(tree.__root()))
        }
    }

    func testPerformanceExample() throws {
        
        throw XCTSkip()
        
        // 分解前 1.04 sec
        // 分解後 1.82 sec (ただしリリースビルドでの速度変化なし)
        
        // This is an example of a performance test case.
        
        var tree = RedBlackTreeStorage<Int>()
        fixtureEmpty(&tree)
        tree.reserveCapacity(1_000_000)

        self.measure {
            // Put the code you want to measure the time of here.
            for i in 0 ..< 1_000_000 {
                _ = tree.__insert_unique(i)
            }
        }
    }
}
