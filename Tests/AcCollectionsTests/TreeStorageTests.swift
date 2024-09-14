//
//  StorageTests.swift
//  
//
//  Created by narumij on 2024/09/12.
//

import XCTest
@testable import AcCollections

final class TreeStorageTests: XCTestCase {
    
    func __construct_node(_ k: tree_type.__value_type) -> tree_type.__node_ptr_type {
        tree.___construct_node(k)
    }
    
    func destroy(_ k: tree_type.__node_ptr_type) {
        tree.items.removeAll()
    }
    
    typealias tree_type = TreeStorage<Int>
    
    typealias __value_type = tree_type.__value_type
    
    typealias __node_ptr_type = tree_type.__node_ptr_type
    
    typealias __node_ref_type = tree_type.__node_ref_type
    
    
    let tree = TreeStorage<Int>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    fileprivate typealias TreeBase = TreeStorage<Int>

    func fixtureEmpty() {
        tree.items = [
        ]
        print(tree.items.graphviz())
        tree.__root = .none
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
    }

    func fixture0_10_20() {
        tree.items = [
            .init(isBlack: true, parent: .end, left: 1, right: 2, __value_: 10),
            .init(isBlack: false, parent: 0, left: nil, right: nil, __value_: 0),
            .init(isBlack: false, parent: 0, left: nil, right: nil, __value_: 20),
        ]
        print(tree.items.graphviz())
        tree.__root = tree.__node(0)
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
    }
    
    func fixture0_1_2_3_4_5_6() {
        tree.items = [
            .init(isBlack: true, parent: .end, left: 1, right: 4, __value_: 3),
            .init(isBlack: false, parent: 0, left: 2, right: 3, __value_: 1),
            .init(isBlack: true, parent: 1, left: nil, right: nil, __value_: 0),
            .init(isBlack: true, parent: 1, left: nil, right: nil, __value_: 2),
            .init(isBlack: false, parent: 0, left: 5, right: 6, __value_: 5),
            .init(isBlack: true, parent: 4, left: nil, right: nil, __value_: 4),
            .init(isBlack: true, parent: 4, left: nil, right: nil, __value_: 6),
        ]
        print(tree.items.graphviz())
        tree.__root = tree.__node(0)
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
    }

    
    func testIterNext() throws {
        fixture0_10_20()
        var __ptr_ = tree.__node(1)
        XCTAssertEqual(__ptr_.__value_, 0)
        XCTAssertEqual(__ptr_, tree.__node(1))
        XCTAssertEqual(TreeBase.__tree_next(__ptr_), TreeBase.__tree_next_iter(__ptr_))
        __ptr_ = TreeBase.__tree_next_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 10)
        XCTAssertEqual(__ptr_, tree.__node(0))
        XCTAssertEqual(TreeBase.__tree_next(__ptr_), TreeBase.__tree_next_iter(__ptr_))
        __ptr_ = TreeBase.__tree_next_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 20)
        XCTAssertEqual(__ptr_, tree.__node(2))
        XCTAssertEqual(TreeBase.__tree_next(__ptr_), TreeBase.__tree_next_iter(__ptr_))
        __ptr_ = TreeBase.__tree_next_iter(__ptr_)
        XCTAssertEqual(__ptr_, tree.__end())
    }
    
    func testIterPrev() throws {
        fixture0_1_2_3_4_5_6()
        
        var __ptr_ = tree.__node(6)
        XCTAssertEqual(__ptr_.__value_, 6)
        XCTAssertEqual(__ptr_, tree.__node(6))
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 5)
        XCTAssertEqual(__ptr_, tree.__node(4))
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 4)
        XCTAssertEqual(__ptr_, tree.__node(5))
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 3)
        XCTAssertEqual(__ptr_, tree.__node(0))
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 2)
        XCTAssertEqual(__ptr_, tree.__node(3))
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 1)
        XCTAssertEqual(__ptr_, tree.__node(1))
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 0)
        XCTAssertEqual(__ptr_, tree.__node(2))
        
        __ptr_ = tree.__end()
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 6)
        XCTAssertEqual(__ptr_, tree.__node(6))
    }
    
    func testIterator() throws {
        fixture0_1_2_3_4_5_6()

        var it = tree.iterator(tree.__node(2))
        XCTAssertEqual(it.__ptr_.__value_, 0)
        XCTAssertEqual(it.__ptr_, tree.__node(2))
        it.next()
        XCTAssertEqual(it.__ptr_.__value_, 1)
        XCTAssertEqual(it.__ptr_, tree.__node(1))
        it.next()
        XCTAssertEqual(it.__ptr_.__value_, 2)
        XCTAssertEqual(it.__ptr_, tree.__node(3))
        it.next()
        XCTAssertEqual(it.__ptr_.__value_, 3)
        XCTAssertEqual(it.__ptr_, tree.__node(0))
        it.next()
        XCTAssertEqual(it.__ptr_.__value_, 4)
        XCTAssertEqual(it.__ptr_, tree.__node(5))
        it.next()
        XCTAssertEqual(it.__ptr_.__value_, 5)
        XCTAssertEqual(it.__ptr_, tree.__node(4))
        it.next()
        XCTAssertEqual(it.__ptr_.__value_, 6)
        XCTAssertEqual(it.__ptr_, tree.__node(6))
        it.next()
        XCTAssertEqual(it.__ptr_, tree.__end())
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 6)
        XCTAssertEqual(it.__ptr_, tree.__node(6))
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 5)
        XCTAssertEqual(it.__ptr_, tree.__node(4))
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 4)
        XCTAssertEqual(it.__ptr_, tree.__node(5))
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 3)
        XCTAssertEqual(it.__ptr_, tree.__node(0))
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 2)
        XCTAssertEqual(it.__ptr_, tree.__node(3))
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 1)
        XCTAssertEqual(it.__ptr_, tree.__node(1))
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 0)
        XCTAssertEqual(it.__ptr_, tree.__node(2))
        
//        it.prev()
//        XCTAssertEqual(it.__ptr_.__value_, 0)
//        XCTAssertEqual(it.__ptr_, storage.node(2))
    }

    func testExample() throws {
        
        tree.items = [
            .init(isBlack: true, parent: .end, left: nil, right: nil, __value_: 0),
        ]
        tree.__root = tree.__node(0)
        
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
        
        tree.items = [
            .init(isBlack: false, parent: .end, left: nil, right: nil, __value_: 0),
        ]
        XCTAssertFalse(TreeBase.__tree_invariant(tree.__root))
    }
    
    func testExample000() throws {
        
        tree.items = [
            .init(isBlack: true, parent: .end, left: 2,right: nil, __value_: 0),
        ]
        tree.__root = tree.__node(0)

        let newNode = tree.___construct_node(0)
        let root = tree.__root
        root.__left_ = newNode
        newNode.__parent_ = root
        XCTAssertTrue(TreeBase.__tree_is_left_child(newNode))
    }

    func testExample00() throws {
        
        tree.items = [
            .init(isBlack: true, parent: .end, left: 2, right: nil, __value_: 0),
        ]
        tree.__root = tree.__node(0)

        let newNode = tree.___construct_node(0)
        XCTAssertEqual(newNode.index, 1)
        let root = tree.__root
        root.__left_ = newNode
        XCTAssertEqual(root.__left_.index, 1)
        newNode.__parent_ = root
        XCTAssertEqual(newNode.__parent_.index, 0)
        newNode.__is_black_ = true
        
        XCTAssertEqual(true, newNode.__is_black_)
        XCTAssertFalse(TreeBase.__tree_invariant(tree.__root))
        TreeBase.__tree_balance_after_insert(tree.__root, newNode)
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
        // 新しいノードは、左右両方とも葉ノードなので、赤が必須
        XCTAssertEqual(false, newNode.__is_black_)
    }
    
    func testRotate() throws {
        
        tree.items = [
            .init(isBlack: true, parent: .end, left: 1, right: 2, __value_: 0),
            .init(isBlack: false, parent: 0, left: nil, right: nil, __value_: 0),
            .init(isBlack: false, parent: 0, left: 3,right: 4, __value_: 0),
            .init(isBlack: true, parent: 2, left: nil,right: nil, __value_: 0),
            .init(isBlack: true, parent: 2, left: nil,right: nil, __value_: 0),
        ]
        tree.__root = tree.__node(0)

        let initial = tree.items
        
        print(tree.items.graphviz())
        XCTAssertFalse(TreeBase.__tree_invariant(tree.__root))

        TreeBase.__tree_left_rotate(tree.__root)
        print(tree.items.graphviz())
        
        var next = initial
        next[0] = .init(isBlack: true, parent: 2, left: 1, right: 3, __value_: 0)
        next[2] = .init(isBlack: false, parent: .end, left: 0, right: 4, __value_: 0)
        next[3] = .init(isBlack: true, parent: 0, left: nil, right: nil, __value_: 0)

        XCTAssertEqual(tree.header.end_ptr, 2)
        XCTAssertEqual(tree.items[0], next[0])
        XCTAssertEqual(tree.items[1], next[1])
        XCTAssertEqual(tree.items[2], next[2])
        XCTAssertEqual(tree.items[3], next[3])
        XCTAssertEqual(tree.items[4], next[4])

        TreeBase.__tree_right_rotate(tree.__node(2))
        print(tree.items.graphviz())
        
        XCTAssertEqual(tree.items, initial)
    }

    
    func testExample2() throws {
        
        tree.items = [
            .init(isBlack: true, parent: .end, left: 1, right: 2, __value_: 0), // 1
            .init(isBlack: true, parent: 0, left: 3,right: 5, __value_: 0), // 2
            .init(isBlack: true, parent: 0, left: nil,right: 4, __value_: 0), // 3
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0), // 4
            .init(isBlack: false, parent: 2, left: nil,right: nil, __value_: 0), // 5
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0), // 6
        ]
        tree.__root = tree.__node(0)

        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
        
        XCTAssertEqual(TreeBase.__tree_min(tree.__node(0)), tree.__node(3))
        XCTAssertEqual(TreeBase.__tree_max(tree.__node(0)), tree.__node(4))
        
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(3)), tree.__node(1))
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(1)), tree.__node(5))
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(5)), tree.__node(0))
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(0)), tree.__node(2))
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(2)), tree.__node(4))
        
        XCTAssertEqual(TreeBase.__tree_leaf(tree.__node(2)), tree.__node(4))
        
        print(tree.items.graphviz())
        let lastData = tree.items
        TreeBase.__tree_balance_after_insert(tree.__node(1), tree.__node(5))
        print(tree.items.graphviz())

        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))

        XCTAssertEqual(tree.items[0], lastData[0])
        XCTAssertEqual(tree.items[1], lastData[1])
        XCTAssertEqual(tree.items[2], lastData[2])
        XCTAssertEqual(tree.items[3], lastData[3])
        XCTAssertEqual(tree.items[4], lastData[4])
        XCTAssertEqual(tree.items[5], lastData[5])
        XCTAssertEqual(tree.items[5], lastData[5])

        XCTAssertEqual(TreeBase.__tree_min(tree.__node(0)), tree.__node(3))
        XCTAssertEqual(TreeBase.__tree_max(tree.__node(0)), tree.__node(4))
        
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(3)), tree.__node(1))
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(1)), tree.__node(5))
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(5)), tree.__node(0))
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(0)), tree.__node(2))
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(2)), tree.__node(4))
    }
    
    func testExample2_1() throws {
        
        tree.items = []
        tree.__root = nil

        XCTAssertEqual(tree.items.count, 0)
        XCTAssertEqual(tree.__root, nil)
//        XCTAssertEqual(storage.__root.__parent_, nil)
//        XCTAssertEqual(storage.__root.__left_, nil)
//        XCTAssertEqual(storage.__root.__right_, nil)

        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))

        tree.__end_node.__left_ = tree.__node(tree.items.count)
        tree.items.append(.init(isBlack: true, parent: .end, left: nil, right: nil, __value_: 0))
        
        XCTAssertEqual(tree.items.count, 1)
        XCTAssertNotEqual(tree.__root, nil)
        XCTAssertNotEqual(tree.__root.__parent_, nil)
        XCTAssertEqual(tree.__root.__left_, nil)
        XCTAssertEqual(tree.__root.__right_, nil)

        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))

        TreeBase.__tree_balance_after_insert(tree.__root, tree.__node(0))

        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
    }
    
    func testExample2_2() throws {
        
        tree.items = [
            .init(isBlack: true, parent: .end, left: 1, right: nil, __value_: 0),
            .init(isBlack: false, parent: 0, left: nil, right: nil, __value_: 0),
        ]
        tree.__root = tree.__node(0)
        
        XCTAssertEqual(tree.__root, tree.__node(0))
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))

        print(tree.items.graphviz())
        /* graphviz
         digraph {
             node [shape = circle; style = filled; fillcolor = red;];
             0;
             2;
             node [shape = circle; fillcolor = black; fontcolor = white;];
             0 -> 1 [label = "left";];
             1 -> 2 [label = "left";];
             node [shape = circle; fillcolor = black; fontcolor = white;];
         }
         */

        let newNode = tree.__node(tree.items.count)
        tree.items[1].left = .node(tree.items.count)
        tree.items.append(.init(isBlack: true, parent: 1, left: nil, right: nil, __value_: 0))
        
        print(tree.items.graphviz())
        /* graphviz
         digraph {
             node [shape = circle; style = filled; fillcolor = red;];
             0;
             2;
             node [shape = circle; fillcolor = black; fontcolor = white;];
             0 -> 1 [label = "left";];
             1 -> 2 [label = "left";];
             2 -> 3 [label = "left";];
             node [shape = circle; fillcolor = black; fontcolor = white;];
         }
         */
        
        XCTAssertFalse(TreeBase.__tree_invariant(tree.__root))
        TreeBase.__tree_balance_after_insert(tree.__root, newNode)
        
        print(tree.items.graphviz())
        /* graphviz
         digraph {
             node [shape = circle; style = filled; fillcolor = red;];
             0;
             1;
             3;
             node [shape = circle; fillcolor = black; fontcolor = white;];
             0 -> 2 [label = "left";];
             2 -> 3 [label = "left";];
             node [shape = circle; fillcolor = black; fontcolor = white;];
             2 -> 1 [label = "right";];
         }
         */
        
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
    }
    
    func testExample3() throws {

        tree.items = [
            .init(isBlack: true, parent: .end, left: 1,right: 2, __value_: 0),
            .init(isBlack: true, parent: 0, left: 3,right: 5, __value_: 0),
            .init(isBlack: true, parent: 0, left: nil,right: 4, __value_: 0),
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0),
            .init(isBlack: false, parent: 2, left: nil,right: nil, __value_: 0),
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0),
        ]
        tree.__root = tree.__node(0)
        
        /* graphviz
         digraph {
             node [shape = circle; style = filled; fillcolor = red;];
             0;
             4;
             5;
             6;
             node [shape = circle; fillcolor = black; fontcolor = white;];
             0 -> 1 [label = "left";];
             1 -> 2 [label = "left";];
             2 -> 4 [label = "left";];
             node [shape = circle; fillcolor = black; fontcolor = white;];
             1 -> 3 [label = "right";];
             2 -> 6 [label = "right";];
             3 -> 5 [label = "right";];
         }
         */
        
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))

        print(tree.items.graphviz())
        let lastData = tree.items
        TreeBase.__tree_remove(tree.__root, tree.__node(5))
        print(tree.items.graphviz())
        
        /*
         digraph {
             node [shape = circle; style = filled; fillcolor = red;];
             0;
             4;
             5;
             node [shape = circle; fillcolor = black; fontcolor = white;];
             0 -> 1 [label = "left";];
             1 -> 2 [label = "left";];
             2 -> 4 [label = "left";];
             node [shape = circle; fillcolor = black; fontcolor = white;];
             1 -> 3 [label = "right";];
             3 -> 5 [label = "right";];
         }
         */

        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))

        XCTAssertEqual(tree.items[0], lastData[0])
        XCTAssertEqual(tree.items[1], .init(isBlack: true, parent: 0, left: 3, right: nil, __value_: 0))
        XCTAssertEqual(tree.items[2], .init(isBlack: true, parent: 0, left: nil, right: 4, __value_: 0))
        XCTAssertEqual(tree.items[3], lastData[3])
        XCTAssertEqual(tree.items[4], lastData[4])

        XCTAssertEqual(TreeBase.__tree_min(tree.__node(0)), tree.__node(3))
        XCTAssertEqual(TreeBase.__tree_max(tree.__node(0)), tree.__node(4))
        
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(3)), tree.__node(1))
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(1)), tree.__node(0))
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(0)), tree.__node(2))
        XCTAssertEqual(TreeBase.__tree_next(tree.__node(2)), tree.__node(4))
    }
    
    func testExample4() throws {
        
        fixture0_1_2_3_4_5_6()
        TreeBase.__tree_remove(tree.__root, tree.__node(3))
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
        fixture0_1_2_3_4_5_6()
        TreeBase.__tree_remove(tree.__root, tree.__node(5))
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
        fixture0_1_2_3_4_5_6()
        TreeBase.__tree_remove(tree.__root, tree.__node(4))
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
        fixture0_1_2_3_4_5_6()
        TreeBase.__tree_remove(tree.__root, tree.__node(1))
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
        fixture0_1_2_3_4_5_6()
        TreeBase.__tree_remove(tree.__root, tree.__node(2))
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
        fixture0_1_2_3_4_5_6()
        TreeBase.__tree_remove(tree.__root, tree.__node(0))
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
    }
    
    func testFindLeafLow() throws {
        
        fixtureEmpty()
        
        do {
            var parent = tree.__none()
            let result = tree.__find_leaf_low(&parent, -10)
            XCTAssertEqual(parent, tree.__end())
            XCTAssertEqual(result, .__left_(tree.__end()))
        }

        fixture0_10_20()

        do {
            var parent = tree.__none()
            let result = tree.__find_leaf_low(&parent, -10)
            XCTAssertEqual(parent, tree.__node(1))
            XCTAssertEqual(parent.__value_, 0)
            XCTAssertEqual(result, .__left_(tree.__node(1)))
        }
        
        do {
            var parent = tree.__none()
            let result = tree.__find_leaf_low(&parent, 10)
            XCTAssertEqual(parent, tree.__node(1))
            XCTAssertEqual(parent.__value_, 0)
            XCTAssertEqual(result, .__right_(tree.__node(1)))
        }

        do {
            var parent = tree.__none()
            let result = tree.__find_leaf_low(&parent, 30)
            XCTAssertEqual(parent, tree.__node(2))
            XCTAssertEqual(parent.__value_, 20)
            XCTAssertEqual(result, .__right_(tree.__node(2)))
        }
    }
    
    func testFindLeafHigh() throws {
        
        fixtureEmpty()
        
        do {
            var parent = tree.__none()
            let result = tree.__find_leaf_high(&parent, 10)
            XCTAssertEqual(parent, tree.__end())
            XCTAssertEqual(result, .__left_(tree.__end()))
        }

        fixture0_10_20()

        do {
            var parent = tree.__root
            let result = tree.__find_leaf_high(&parent, 0)
            XCTAssertEqual(parent, tree.__node(1))
            XCTAssertEqual(parent.__value_, 0)
            XCTAssertEqual(result, .__right_(tree.__node(1)))
        }
        
        do {
            var parent = tree.__root
            let result = tree.__find_leaf_high(&parent, 10)
            XCTAssertEqual(parent, tree.__node(2))
            XCTAssertEqual(parent.__value_, 20)
            XCTAssertEqual(result, .__left_(tree.__node(2)))
        }
        
        do {
            var parent = tree.__root
            let result = tree.__find_leaf_high(&parent, 20)
            XCTAssertEqual(parent, tree.__node(2))
            XCTAssertEqual(parent.__value_, 20)
            XCTAssertEqual(result, .__right_(tree.__node(2)))
        }
    }
    
    func testFindEqual() throws {
        
        fixtureEmpty()
        
        do {
            var parent = tree.__none()
            let result = tree.__find_equal(&parent, 10)
            XCTAssertEqual(parent, tree.__end())
            XCTAssertEqual(result, .__left_(tree.__end()))
        }

        fixture0_10_20()

        do {
            var parent = tree.__root
            let result = tree.__find_equal(&parent, 0)
            XCTAssertEqual(parent, tree.__root.__left_)
            XCTAssertEqual(parent.__value_, 0)
            XCTAssertEqual(result, tree.__root.__left_ref)
        }
        do {
            var parent = tree.__root
            let result = tree.__find_equal(&parent, 10)
            XCTAssertEqual(parent, tree.__root)
            XCTAssertEqual(parent.__value_, 10)
            XCTAssertEqual(result, tree.__end_node.__left_ref)
        }
        do {
            var parent = tree.__root
            let result = tree.__find_equal(&parent, 20)
            XCTAssertEqual(parent, tree.__root.__right_)
            XCTAssertEqual(parent.__value_, 20)
            XCTAssertEqual(result, tree.__root.__right_ref)
        }
    }

    
#if false
    func testHoge() throws {
        
        fixtureEmpty()
        
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
        
        for i in 0..<10 {
            let result = __insert_unique(i)
            XCTAssertTrue(result.__inserted)
            XCTAssertTrue(try TreeBase.__tree_invariant__(tree.__root))
            print(tree.items.graphviz())
        }
        
        print(tree.items.graphviz())
        
    }
    
    func testHoge2() throws {
        
        fixtureEmpty()
        
        XCTAssertTrue(TreeBase.__tree_invariant(tree.__root))
        
        for i in (0..<10).map({ $0 * 10 }) {
            let result = __insert_unique(i)
            XCTAssertTrue(result.__inserted)
            XCTAssertTrue(try TreeBase.__tree_invariant__(tree.__root))
            print(tree.items.graphviz())
        }
        
        print(tree.items.graphviz())
        
        do {
            XCTAssertEqual(
                tree.__lower_bound(10, tree.__root, tree.__none()),
                tree.__node(1))
        }
        
        do {
            XCTAssertEqual(
                tree.__upper_bound(10, tree.__root, tree.__none()),
                tree.__node(2))
        }

    }
#endif
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
