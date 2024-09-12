//
//  StorageTests.swift
//  
//
//  Created by narumij on 2024/09/12.
//

import XCTest
@testable import AcCollections

final class TreeStorageTests: XCTestCase {
    
    let storage = TreeStorage<Int>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    fileprivate typealias TreeBase = TreeStorage<Int>
    
    func testIterNext() throws {
        storage.items = [
            .init(isBlack: true, parent: .end, left: 1, right: 4, __value_: 3),
            .init(isBlack: false, parent: 0, left: 2, right: 3, __value_: 1),
            .init(isBlack: true, parent: 1, left: nil, right: nil, __value_: 0),
            .init(isBlack: true, parent: 1, left: nil, right: nil, __value_: 2),
            .init(isBlack: false, parent: 0, left: 5, right: 6, __value_: 5),
            .init(isBlack: true, parent: 4, left: nil, right: nil, __value_: 4),
            .init(isBlack: true, parent: 4, left: nil, right: nil, __value_: 6),
        ]
        print(storage.items.graphviz())
        storage.__root = storage.node(0)
        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))
        
        var __ptr_ = storage.node(2)
        XCTAssertEqual(__ptr_.__value_, 0)
        XCTAssertEqual(__ptr_, storage.node(2))
        XCTAssertEqual(TreeBase.__tree_next(__ptr_), TreeBase.__tree_next_iter(__ptr_))
        __ptr_ = TreeBase.__tree_next_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 1)
        XCTAssertEqual(__ptr_, storage.node(1))
        XCTAssertEqual(TreeBase.__tree_next(__ptr_), TreeBase.__tree_next_iter(__ptr_))
        __ptr_ = TreeBase.__tree_next_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 2)
        XCTAssertEqual(__ptr_, storage.node(3))
        XCTAssertEqual(TreeBase.__tree_next(__ptr_), TreeBase.__tree_next_iter(__ptr_))
        __ptr_ = TreeBase.__tree_next_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 3)
        XCTAssertEqual(__ptr_, storage.node(0))
        XCTAssertEqual(TreeBase.__tree_next(__ptr_), TreeBase.__tree_next_iter(__ptr_))
        __ptr_ = TreeBase.__tree_next_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 4)
        XCTAssertEqual(__ptr_, storage.node(5))
        XCTAssertEqual(TreeBase.__tree_next(__ptr_), TreeBase.__tree_next_iter(__ptr_))
        __ptr_ = TreeBase.__tree_next_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 5)
        XCTAssertEqual(__ptr_, storage.node(4))
        XCTAssertEqual(TreeBase.__tree_next(__ptr_), TreeBase.__tree_next_iter(__ptr_))
        __ptr_ = TreeBase.__tree_next_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 6)
        XCTAssertEqual(__ptr_, storage.node(6))
        XCTAssertEqual(TreeBase.__tree_next(__ptr_), TreeBase.__tree_next_iter(__ptr_))
        __ptr_ = TreeBase.__tree_next_iter(__ptr_)
        XCTAssertEqual(__ptr_, storage.end())
    }
    
    func testIterPrev() throws {
        storage.items = [
            .init(isBlack: true, parent: .end, left: 1, right: 4, __value_: 3),
            .init(isBlack: false, parent: 0, left: 2, right: 3, __value_: 1),
            .init(isBlack: true, parent: 1, left: nil, right: nil, __value_: 0),
            .init(isBlack: true, parent: 1, left: nil, right: nil, __value_: 2),
            .init(isBlack: false, parent: 0, left: 5, right: 6, __value_: 5),
            .init(isBlack: true, parent: 4, left: nil, right: nil, __value_: 4),
            .init(isBlack: true, parent: 4, left: nil, right: nil, __value_: 6),
        ]
        print(storage.items.graphviz())
        storage.__root = storage.node(0)
        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))

        var __ptr_ = storage.node(6)
        XCTAssertEqual(__ptr_.__value_, 6)
        XCTAssertEqual(__ptr_, storage.node(6))
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 5)
        XCTAssertEqual(__ptr_, storage.node(4))
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 4)
        XCTAssertEqual(__ptr_, storage.node(5))
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 3)
        XCTAssertEqual(__ptr_, storage.node(0))
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 2)
        XCTAssertEqual(__ptr_, storage.node(3))
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 1)
        XCTAssertEqual(__ptr_, storage.node(1))
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 0)
        XCTAssertEqual(__ptr_, storage.node(2))
        
        __ptr_ = storage.end()
        __ptr_ = TreeBase.__tree_prev_iter(__ptr_)
        XCTAssertEqual(__ptr_.__value_, 6)
        XCTAssertEqual(__ptr_, storage.node(6))
    }
    
    func testIterator() throws {
        storage.items = [
            .init(isBlack: true, parent: .end, left: 1, right: 4, __value_: 3),
            .init(isBlack: false, parent: 0, left: 2, right: 3, __value_: 1),
            .init(isBlack: true, parent: 1, left: nil, right: nil, __value_: 0),
            .init(isBlack: true, parent: 1, left: nil, right: nil, __value_: 2),
            .init(isBlack: false, parent: 0, left: 5, right: 6, __value_: 5),
            .init(isBlack: true, parent: 4, left: nil, right: nil, __value_: 4),
            .init(isBlack: true, parent: 4, left: nil, right: nil, __value_: 6),
        ]
        print(storage.items.graphviz())
        storage.__root = storage.node(0)
//        storage.end_ptr = .node(6)
        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))

        var it = storage.iterator(storage.node(2))
        XCTAssertEqual(it.__ptr_.__value_, 0)
        XCTAssertEqual(it.__ptr_, storage.node(2))
        it.next()
        XCTAssertEqual(it.__ptr_.__value_, 1)
        XCTAssertEqual(it.__ptr_, storage.node(1))
        it.next()
        XCTAssertEqual(it.__ptr_.__value_, 2)
        XCTAssertEqual(it.__ptr_, storage.node(3))
        it.next()
        XCTAssertEqual(it.__ptr_.__value_, 3)
        XCTAssertEqual(it.__ptr_, storage.node(0))
        it.next()
        XCTAssertEqual(it.__ptr_.__value_, 4)
        XCTAssertEqual(it.__ptr_, storage.node(5))
        it.next()
        XCTAssertEqual(it.__ptr_.__value_, 5)
        XCTAssertEqual(it.__ptr_, storage.node(4))
        it.next()
        XCTAssertEqual(it.__ptr_.__value_, 6)
        XCTAssertEqual(it.__ptr_, storage.node(6))
        it.next()
        XCTAssertEqual(it.__ptr_, storage.end())
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 6)
        XCTAssertEqual(it.__ptr_, storage.node(6))
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 5)
        XCTAssertEqual(it.__ptr_, storage.node(4))
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 4)
        XCTAssertEqual(it.__ptr_, storage.node(5))
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 3)
        XCTAssertEqual(it.__ptr_, storage.node(0))
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 2)
        XCTAssertEqual(it.__ptr_, storage.node(3))
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 1)
        XCTAssertEqual(it.__ptr_, storage.node(1))
        it.prev()
        XCTAssertEqual(it.__ptr_.__value_, 0)
        XCTAssertEqual(it.__ptr_, storage.node(2))
        
//        it.prev()
//        XCTAssertEqual(it.__ptr_.__value_, 0)
//        XCTAssertEqual(it.__ptr_, storage.node(2))
    }

    func testExample() throws {
        
        storage.items = [
            .init(isBlack: true, parent: .end, left: nil, right: nil, __value_: 0),
        ]
        storage.__root = storage.node(0)
        
        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))
        
        storage.items = [
            .init(isBlack: false, parent: .end, left: nil, right: nil, __value_: 0),
        ]
        XCTAssertFalse(TreeBase.__tree_invariant(storage.__root))
    }
    
    func testExample000() throws {
        
        storage.items = [
            .init(isBlack: true, parent: .end, left: 2,right: nil, __value_: 0),
        ]
        storage.__root = storage.node(0)

        let newNode = storage.___construct_node()
        let root = storage.__root
        root.__left_ = newNode
        newNode.__parent_ = root
        XCTAssertTrue(TreeBase.__tree_is_left_child(newNode))
    }

    func testExample00() throws {
        
        storage.items = [
            .init(isBlack: true, parent: .end, left: 2, right: nil, __value_: 0),
        ]
        storage.__root = storage.node(0)

        let newNode = storage.___construct_node()
        XCTAssertEqual(newNode.index, 1)
        let root = storage.__root
        root.__left_ = newNode
        XCTAssertEqual(root.__left_.index, 1)
        newNode.__parent_ = root
        XCTAssertEqual(newNode.__parent_.index, 0)
        newNode.__is_black_ = true
        
        XCTAssertEqual(true, newNode.__is_black_)
        XCTAssertFalse(TreeBase.__tree_invariant(storage.__root))
        TreeBase.__tree_balance_after_insert(storage.__root, newNode)
        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))
        // 新しいノードは、左右両方とも葉ノードなので、赤が必須
        XCTAssertEqual(false, newNode.__is_black_)
    }
    
    func testRotate() throws {
        
        storage.items = [
            .init(isBlack: true, parent: .end, left: 1, right: 2, __value_: 0),
            .init(isBlack: false, parent: 0, left: nil, right: nil, __value_: 0),
            .init(isBlack: false, parent: 0, left: 3,right: 4, __value_: 0),
            .init(isBlack: true, parent: 2, left: nil,right: nil, __value_: 0),
            .init(isBlack: true, parent: 2, left: nil,right: nil, __value_: 0),
        ]
        storage.__root = storage.node(0)

        let initial = storage.items
        
        print(storage.items.graphviz())
        XCTAssertFalse(TreeBase.__tree_invariant(storage.__root))

        TreeBase.__tree_left_rotate(storage.__root)
        print(storage.items.graphviz())
        
        var next = initial
        next[0] = .init(isBlack: true, parent: 2, left: 1, right: 3, __value_: 0)
        next[2] = .init(isBlack: false, parent: .end, left: 0, right: 4, __value_: 0)
        next[3] = .init(isBlack: true, parent: 0, left: nil, right: nil, __value_: 0)

        XCTAssertEqual(storage.end_ptr, 2)
        XCTAssertEqual(storage.items[0], next[0])
        XCTAssertEqual(storage.items[1], next[1])
        XCTAssertEqual(storage.items[2], next[2])
        XCTAssertEqual(storage.items[3], next[3])
        XCTAssertEqual(storage.items[4], next[4])

        TreeBase.__tree_right_rotate(storage.node(2))
        print(storage.items.graphviz())
        
        XCTAssertEqual(storage.items, initial)
    }

    
    func testExample2() throws {
        
        storage.items = [
            .init(isBlack: true, parent: .end, left: 1, right: 2, __value_: 0), // 1
            .init(isBlack: true, parent: 0, left: 3,right: 5, __value_: 0), // 2
            .init(isBlack: true, parent: 0, left: nil,right: 4, __value_: 0), // 3
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0), // 4
            .init(isBlack: false, parent: 2, left: nil,right: nil, __value_: 0), // 5
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0), // 6
        ]
        storage.__root = storage.node(0)

        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))
        
        XCTAssertEqual(TreeBase.__tree_min(storage.node(0)), storage.node(3))
        XCTAssertEqual(TreeBase.__tree_max(storage.node(0)), storage.node(4))
        
        XCTAssertEqual(TreeBase.__tree_next(storage.node(3)), storage.node(1))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(1)), storage.node(5))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(5)), storage.node(0))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(0)), storage.node(2))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(2)), storage.node(4))
        
        XCTAssertEqual(TreeBase.__tree_leaf(storage.node(2)), storage.node(4))
        
        print(storage.items.graphviz())
        let lastData = storage.items
        TreeBase.__tree_balance_after_insert(storage.node(1), storage.node(5))
        print(storage.items.graphviz())

        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))

        XCTAssertEqual(storage.items[0], lastData[0])
        XCTAssertEqual(storage.items[1], lastData[1])
        XCTAssertEqual(storage.items[2], lastData[2])
        XCTAssertEqual(storage.items[3], lastData[3])
        XCTAssertEqual(storage.items[4], lastData[4])
        XCTAssertEqual(storage.items[5], lastData[5])
        XCTAssertEqual(storage.items[5], lastData[5])

        XCTAssertEqual(TreeBase.__tree_min(storage.node(0)), storage.node(3))
        XCTAssertEqual(TreeBase.__tree_max(storage.node(0)), storage.node(4))
        
        XCTAssertEqual(TreeBase.__tree_next(storage.node(3)), storage.node(1))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(1)), storage.node(5))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(5)), storage.node(0))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(0)), storage.node(2))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(2)), storage.node(4))
    }
    
    func testExample2_1() throws {
        
        storage.items = []
        storage.__root = nil

        XCTAssertEqual(storage.items.count, 0)
        XCTAssertEqual(storage.__root, nil)
//        XCTAssertEqual(storage.__root.__parent_, nil)
//        XCTAssertEqual(storage.__root.__left_, nil)
//        XCTAssertEqual(storage.__root.__right_, nil)

        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))

        storage.__end_node.__left_ = storage.node(storage.items.count)
        storage.items.append(.init(isBlack: true, parent: .end, left: nil, right: nil, __value_: 0))
        
        XCTAssertEqual(storage.items.count, 1)
        XCTAssertNotEqual(storage.__root, nil)
        XCTAssertNotEqual(storage.__root.__parent_, nil)
        XCTAssertEqual(storage.__root.__left_, nil)
        XCTAssertEqual(storage.__root.__right_, nil)

        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))

        TreeBase.__tree_balance_after_insert(storage.__root, storage.node(0))

        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))
    }
    
    func testExample2_2() throws {
        
        storage.items = [
            .init(isBlack: true, parent: .end, left: 1, right: nil, __value_: 0),
            .init(isBlack: false, parent: 0, left: nil, right: nil, __value_: 0),
        ]
        storage.__root = storage.node(0)
        
        XCTAssertEqual(storage.__root, storage.node(0))
        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))

        print(storage.items.graphviz())
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

        let newNode = storage.node(storage.items.count)
        storage.items[1].left = .node(storage.items.count)
        storage.items.append(.init(isBlack: true, parent: 1, left: nil, right: nil, __value_: 0))
        
        print(storage.items.graphviz())
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
        
        XCTAssertFalse(TreeBase.__tree_invariant(storage.__root))
        TreeBase.__tree_balance_after_insert(storage.__root, newNode)
        
        print(storage.items.graphviz())
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
        
        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))
    }
    
    func testExample3() throws {

        storage.items = [
            .init(isBlack: true, parent: .end, left: 1,right: 2, __value_: 0),
            .init(isBlack: true, parent: 0, left: 3,right: 5, __value_: 0),
            .init(isBlack: true, parent: 0, left: nil,right: 4, __value_: 0),
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0),
            .init(isBlack: false, parent: 2, left: nil,right: nil, __value_: 0),
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0),
        ]
        storage.__root = storage.node(0)
        
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
        
        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))

        print(storage.items.graphviz())
        let lastData = storage.items
        TreeBase.__tree_remove(storage.__root, storage.node(5))
        print(storage.items.graphviz())
        
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

        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))

        XCTAssertEqual(storage.items[0], lastData[0])
        XCTAssertEqual(storage.items[1], .init(isBlack: true, parent: 0, left: 3, right: nil, __value_: 0))
        XCTAssertEqual(storage.items[2], .init(isBlack: true, parent: 0, left: nil, right: 4, __value_: 0))
        XCTAssertEqual(storage.items[3], lastData[3])
        XCTAssertEqual(storage.items[4], lastData[4])

        XCTAssertEqual(TreeBase.__tree_min(storage.node(0)), storage.node(3))
        XCTAssertEqual(TreeBase.__tree_max(storage.node(0)), storage.node(4))
        
        XCTAssertEqual(TreeBase.__tree_next(storage.node(3)), storage.node(1))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(1)), storage.node(0))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(0)), storage.node(2))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(2)), storage.node(4))
    }
    
    func testExample4() throws {
        
        storage.items = [
            .init(isBlack: true, parent: .end, left: 1,right: 2, __value_: 0),
            .init(isBlack: true, parent: 0, left: 3,right: 5, __value_: 0),
            .init(isBlack: true, parent: 0, left: nil,right: 4, __value_: 0),
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0),
            .init(isBlack: false, parent: 2, left: nil,right: nil, __value_: 0),
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0),
        ]
        storage.__root = storage.node(0)

        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))

        print(storage.items.graphviz())
        let lastData = storage.items
        TreeBase.__tree_remove(storage.__root, storage.node(3))
        print(storage.items.graphviz())

        XCTAssertTrue(TreeBase.__tree_invariant(storage.__root))

        XCTAssertEqual(storage.items[0], lastData[0])
        XCTAssertEqual(storage.items[1], .init(isBlack: true, parent: 0, left: nil, right: 5, __value_: 0))
        XCTAssertEqual(storage.items[2], .init(isBlack: true, parent: 0, left: nil, right: 4, __value_: 0))
        XCTAssertEqual(storage.items[3], lastData[3])
        XCTAssertEqual(storage.items[4], lastData[4])
        XCTAssertEqual(storage.items[5], .init(isBlack: false, parent: 1, left: nil, right: nil, __value_: 0))

        XCTAssertEqual(TreeBase.__tree_min(storage.node(0)), storage.node(1))
        XCTAssertEqual(TreeBase.__tree_max(storage.node(0)), storage.node(4))
        
        XCTAssertEqual(TreeBase.__tree_next(storage.node(1)), storage.node(5))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(5)), storage.node(0))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(0)), storage.node(2))
        XCTAssertEqual(TreeBase.__tree_next(storage.node(2)), storage.node(4))
    }
    
    func testFindLeafLow() throws {
        
        storage.items = [
            .init(isBlack: true, parent: .end, left: nil, right: nil, __value_: 5),
        ]
        storage.__root = storage.node(0)

        do {
            let result = storage.__find_leaf_low(&storage.__root, 5)
            XCTAssertEqual(result, .__left_(storage.__root))
        }
    }
    
    func testFindLeafHigh() throws {
        
        storage.items = [
            .init(isBlack: true, parent: .end, left: nil, right: nil, __value_: 5),
        ]
        storage.__root = storage.node(0)

        do {
            let result = storage.__find_leaf_high(&storage.__root, 5)
            XCTAssertEqual(result, .__right_(storage.__root))
        }
    }
    
    func testFindEqual() throws {
        
        storage.items = [
            .init(isBlack: true, parent: .end, left: nil, right: nil, __value_: 10),
        ]
        storage.__root = storage.node(0)

        do {
            let result = storage.__find_equal(&storage.__root, 0)
            XCTAssertEqual(result, storage.__root.__left_ref)
        }
        do {
            let result = storage.__find_equal(&storage.__root, 10)
            XCTAssertEqual(result, storage.__root.__self_ref)
        }
        do {
            let result = storage.__find_equal(&storage.__root, 20)
            XCTAssertEqual(result, storage.__root.__right_ref)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
