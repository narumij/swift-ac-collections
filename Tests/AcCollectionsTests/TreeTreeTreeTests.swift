//
//  TreeTreeTreeTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/09/15.
//

import XCTest
import Collections
@testable import AcCollections

final class TreeTreeTreeTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    typealias TreeBase = RedBlackTree<TreeNodeAllocator, StandardComparer<Int>, Int>
    typealias Base = TreeBase.__unsafe_tree

    func fixtureEmpty(_ tree: TreeBase) {
        tree.buffer = [
        ]
        print(tree.buffer.graphviz())
        tree._update {
            $0.__root = .none
        }
        XCTAssertTrue(tree._update{ Base.__tree_invariant($0.__root) })
    }

    func fixture0_10_20(_ tree: TreeBase) {
        tree.buffer = [
            .init(isBlack: true, parent: .end, left: 1, right: 2, ___value_: 10),
            .init(isBlack: false, parent: 0, left: nil, right: nil, ___value_: 0),
            .init(isBlack: false, parent: 0, left: nil, right: nil, ___value_: 20),
        ]
        print(tree.buffer.graphviz())
        tree._update { $0.__root = $0.__node(0) }
        XCTAssertTrue(tree._update{ Base.__tree_invariant($0.__root) })
    }
    
    func fixture0_1_2_3_4_5_6(_ tree: TreeBase) {
        tree.buffer = [
            .init(isBlack: true, parent: .end, left: 1, right: 4, ___value_: 3),
            .init(isBlack: false, parent: 0, left: 2, right: 3, ___value_: 1),
            .init(isBlack: true, parent: 1, left: nil, right: nil, ___value_: 0),
            .init(isBlack: true, parent: 1, left: nil, right: nil, ___value_: 2),
            .init(isBlack: false, parent: 0, left: 5, right: 6, ___value_: 5),
            .init(isBlack: true, parent: 4, left: nil, right: nil, ___value_: 4),
            .init(isBlack: true, parent: 4, left: nil, right: nil, ___value_: 6),
        ]
        print(tree.buffer.graphviz())
        tree._update { $0.__root = $0.__node(0) }
        XCTAssertTrue(tree._update{ Base.__tree_invariant($0.__root) })
    }
    
    func testIterNext() throws {
        let tree = TreeBase()
        fixture0_10_20(tree)
        tree._update { tree in
            var __ptr_ = tree.__node(1)
            XCTAssertEqual(__ptr_.__value_, 0)
            XCTAssertEqual(__ptr_, tree.__node(1))
            XCTAssertEqual(Base.__tree_next(__ptr_), Base.__tree_next_iter(__ptr_))
            __ptr_ = Base.__tree_next_iter(__ptr_)
            XCTAssertEqual(__ptr_.__value_, 10)
            XCTAssertEqual(__ptr_, tree.__node(0))
            XCTAssertEqual(Base.__tree_next(__ptr_), Base.__tree_next_iter(__ptr_))
            __ptr_ = Base.__tree_next_iter(__ptr_)
            XCTAssertEqual(__ptr_.__value_, 20)
            XCTAssertEqual(__ptr_, tree.__node(2))
            XCTAssertEqual(Base.__tree_next(__ptr_), Base.__tree_next_iter(__ptr_))
            __ptr_ = Base.__tree_next_iter(__ptr_)
            XCTAssertEqual(__ptr_, tree.__end())
        }
    }
    
    func testIterPrev() throws {
        let tree = TreeBase()
        fixture0_1_2_3_4_5_6(tree)
        
        tree._update { tree in
            var __ptr_ = tree.__node(6)
            XCTAssertEqual(__ptr_.__value_, 6)
            XCTAssertEqual(__ptr_, tree.__node(6))
            __ptr_ = Base.__tree_prev_iter(__ptr_)
            XCTAssertEqual(__ptr_.__value_, 5)
            XCTAssertEqual(__ptr_, tree.__node(4))
            __ptr_ = Base.__tree_prev_iter(__ptr_)
            XCTAssertEqual(__ptr_.__value_, 4)
            XCTAssertEqual(__ptr_, tree.__node(5))
            __ptr_ = Base.__tree_prev_iter(__ptr_)
            XCTAssertEqual(__ptr_.__value_, 3)
            XCTAssertEqual(__ptr_, tree.__node(0))
            __ptr_ = Base.__tree_prev_iter(__ptr_)
            XCTAssertEqual(__ptr_.__value_, 2)
            XCTAssertEqual(__ptr_, tree.__node(3))
            __ptr_ = Base.__tree_prev_iter(__ptr_)
            XCTAssertEqual(__ptr_.__value_, 1)
            XCTAssertEqual(__ptr_, tree.__node(1))
            __ptr_ = Base.__tree_prev_iter(__ptr_)
            XCTAssertEqual(__ptr_.__value_, 0)
            XCTAssertEqual(__ptr_, tree.__node(2))
            
            __ptr_ = tree.__end()
            __ptr_ = Base.__tree_prev_iter(__ptr_)
            XCTAssertEqual(__ptr_.__value_, 6)
            XCTAssertEqual(__ptr_, tree.__node(6))
        }
    }
    
    func testIterator() throws {
        let tree = TreeBase()
        fixture0_1_2_3_4_5_6(tree)

        tree._update { tree in
            
            var it = tree.__node(2)
            XCTAssertEqual(it.__ptr_.__value_, 0)
            XCTAssertEqual(it.__ptr_, tree.__node(2))
            _ = it.next()
            XCTAssertEqual(it.__ptr_.__value_, 1)
            XCTAssertEqual(it.__ptr_, tree.__node(1))
            _ = it.next()
            XCTAssertEqual(it.__ptr_.__value_, 2)
            XCTAssertEqual(it.__ptr_, tree.__node(3))
            _ = it.next()
            XCTAssertEqual(it.__ptr_.__value_, 3)
            XCTAssertEqual(it.__ptr_, tree.__node(0))
            _ = it.next()
            XCTAssertEqual(it.__ptr_.__value_, 4)
            XCTAssertEqual(it.__ptr_, tree.__node(5))
            _ = it.next()
            XCTAssertEqual(it.__ptr_.__value_, 5)
            XCTAssertEqual(it.__ptr_, tree.__node(4))
            _ = it.next()
            XCTAssertEqual(it.__ptr_.__value_, 6)
            XCTAssertEqual(it.__ptr_, tree.__node(6))
            _ = it.next()
            XCTAssertEqual(it.__ptr_, tree.__end())
            _ = it.prev()
            XCTAssertEqual(it.__ptr_.__value_, 6)
            XCTAssertEqual(it.__ptr_, tree.__node(6))
            _ = it.prev()
            XCTAssertEqual(it.__ptr_.__value_, 5)
            XCTAssertEqual(it.__ptr_, tree.__node(4))
            _ = it.prev()
            XCTAssertEqual(it.__ptr_.__value_, 4)
            XCTAssertEqual(it.__ptr_, tree.__node(5))
            _ = it.prev()
            XCTAssertEqual(it.__ptr_.__value_, 3)
            XCTAssertEqual(it.__ptr_, tree.__node(0))
            _ = it.prev()
            XCTAssertEqual(it.__ptr_.__value_, 2)
            XCTAssertEqual(it.__ptr_, tree.__node(3))
            _ = it.prev()
            XCTAssertEqual(it.__ptr_.__value_, 1)
            XCTAssertEqual(it.__ptr_, tree.__node(1))
            _ = it.prev()
            XCTAssertEqual(it.__ptr_.__value_, 0)
            XCTAssertEqual(it.__ptr_, tree.__node(2))
            
            //        it.prev()
            //        XCTAssertEqual(it.__ptr_.__value_, 0)
            //        XCTAssertEqual(it.__ptr_, storage.node(2))
        }
    }

    func testExample() throws {
        let tree = TreeBase()

        tree.buffer = [
            .init(isBlack: true, parent: .end, left: nil, right: nil, ___value_: 0),
        ]
        tree._update { tree in
            tree.__root = tree.__node(0)
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
        
        tree.buffer = [
            .init(isBlack: false, parent: .end, left: nil, right: nil, ___value_: 0),
        ]
        tree._update { tree in
            XCTAssertFalse(Base.__tree_invariant(tree.__root))
        }
    }
    
    func testExample000() throws {
        let tree = TreeBase()

        tree.buffer = [
            .init(isBlack: true, parent: .end, left: 2,right: nil, ___value_: 0),
        ]
        tree.ensureReserved(count: 1)
        XCTAssertEqual(tree.buffer.count, 2)
        XCTAssertEqual(tree.allocator.reserved, 1)
        
        tree._update { tree in
            tree.__root = tree.__node(0)
            let newNode = tree.__construct_node(0)
            let root = tree.__root
            root.__left_ = newNode
            newNode.__parent_ = root
            XCTAssertTrue(Base.__tree_is_left_child(newNode))
        }
    }

    func testExample00() throws {
        let tree = TreeBase()

        tree.buffer = [
            .init(isBlack: true, parent: .end, left: 2, right: nil, ___value_: 0),
        ]
        
        tree.ensureReserved(count: 1)
        
        tree._update { tree in
            tree.__root = tree.__node(0)
            
            let newNode = tree.__construct_node(0)
            XCTAssertEqual(newNode.index, 1)
            let root = tree.__root
            root.__left_ = newNode
            XCTAssertEqual(root.__left_.index, 1)
            newNode.__parent_ = root
            XCTAssertEqual(newNode.__parent_.index, 0)
            newNode.__is_black_ = true
            
            XCTAssertEqual(true, newNode.__is_black_)
            XCTAssertFalse(Base.__tree_invariant(tree.__root))
            Base.__tree_balance_after_insert(tree.__root, newNode)
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
            // 新しいノードは、左右両方とも葉ノードなので、赤が必須
            XCTAssertEqual(false, newNode.__is_black_)
        }
    }
    
    func testRotate() throws {
        let tree = TreeBase()

        tree.buffer = [
            .init(isBlack: true, parent: .end, left: 1, right: 2, ___value_: 0),
            .init(isBlack: false, parent: 0, left: nil, right: nil, ___value_: 0),
            .init(isBlack: false, parent: 0, left: 3,right: 4, ___value_: 0),
            .init(isBlack: true, parent: 2, left: nil,right: nil, ___value_: 0),
            .init(isBlack: true, parent: 2, left: nil,right: nil, ___value_: 0),
        ]
//        let _tree = tree
        let initial = tree.buffer
        tree._update { tree in
            tree.__root = tree.__node(0)
            
            print(tree._buffer.contents.graphviz())
            XCTAssertFalse(Base.__tree_invariant(tree.__root))
            
            Base.__tree_left_rotate(tree.__root)
            print(tree._buffer.contents.graphviz())

            var next = initial
            next[0] = .init(isBlack: true, parent: 2, left: 1, right: 3, ___value_: 0)
            next[2] = .init(isBlack: false, parent: .end, left: 0, right: 4, ___value_: 0)
            next[3] = .init(isBlack: true, parent: 0, left: nil, right: nil, ___value_: 0)
            
            XCTAssertEqual(tree._header.pointee.end_left_ptr, 2)
            XCTAssertEqual(tree._buffer[0], next[0])
            XCTAssertEqual(tree._buffer[1], next[1])
            XCTAssertEqual(tree._buffer[2], next[2])
            XCTAssertEqual(tree._buffer[3], next[3])
            XCTAssertEqual(tree._buffer[4], next[4])
            
            Base.__tree_right_rotate(tree.__node(2))
            print(tree._buffer.contents.graphviz())

            XCTAssertEqual(tree._buffer.contents, initial)
        }
    }

    func testExample2() throws {
        let tree = TreeBase()

        tree.buffer = [
            .init(isBlack: true, parent: .end, left: 1, right: 2, ___value_: 0), // 1
            .init(isBlack: true, parent: 0, left: 3,right: 5, ___value_: 0), // 2
            .init(isBlack: true, parent: 0, left: nil,right: 4, ___value_: 0), // 3
            .init(isBlack: false, parent: 1, left: nil,right: nil, ___value_: 0), // 4
            .init(isBlack: false, parent: 2, left: nil,right: nil, ___value_: 0), // 5
            .init(isBlack: false, parent: 1, left: nil,right: nil, ___value_: 0), // 6
        ]
        tree._update { tree in
            tree.__root = tree.__node(0)
            
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
            
            XCTAssertEqual(Base.__tree_min(tree.__node(0)), tree.__node(3))
            XCTAssertEqual(Base.__tree_max(tree.__node(0)), tree.__node(4))
            
            XCTAssertEqual(Base.__tree_next(tree.__node(3)), tree.__node(1))
            XCTAssertEqual(Base.__tree_next(tree.__node(1)), tree.__node(5))
            XCTAssertEqual(Base.__tree_next(tree.__node(5)), tree.__node(0))
            XCTAssertEqual(Base.__tree_next(tree.__node(0)), tree.__node(2))
            XCTAssertEqual(Base.__tree_next(tree.__node(2)), tree.__node(4))
            
            XCTAssertEqual(Base.__tree_leaf(tree.__node(2)), tree.__node(4))
            
            print(tree._buffer.contents.graphviz())
            let lastData = tree._buffer.contents
            Base.__tree_balance_after_insert(tree.__node(1), tree.__node(5))
            print(tree._buffer.contents.graphviz())
            
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
            
            XCTAssertEqual(tree._buffer[0], lastData[0])
            XCTAssertEqual(tree._buffer[1], lastData[1])
            XCTAssertEqual(tree._buffer[2], lastData[2])
            XCTAssertEqual(tree._buffer[3], lastData[3])
            XCTAssertEqual(tree._buffer[4], lastData[4])
            XCTAssertEqual(tree._buffer[5], lastData[5])
            XCTAssertEqual(tree._buffer[5], lastData[5])
            
            XCTAssertEqual(Base.__tree_min(tree.__node(0)), tree.__node(3))
            XCTAssertEqual(Base.__tree_max(tree.__node(0)), tree.__node(4))
            
            XCTAssertEqual(Base.__tree_next(tree.__node(3)), tree.__node(1))
            XCTAssertEqual(Base.__tree_next(tree.__node(1)), tree.__node(5))
            XCTAssertEqual(Base.__tree_next(tree.__node(5)), tree.__node(0))
            XCTAssertEqual(Base.__tree_next(tree.__node(0)), tree.__node(2))
            XCTAssertEqual(Base.__tree_next(tree.__node(2)), tree.__node(4))
        }
    }
    


    
    func testExample2_1() throws {
        let tree = TreeBase()

        tree.buffer = []
        tree._update { tree in
            
            tree.__root = nil
            
            XCTAssertEqual(tree._buffer.count, 0)
            XCTAssertEqual(tree.__root, nil)
            //        XCTAssertEqual(storage.__root.__parent_, nil)
            //        XCTAssertEqual(storage.__root.__left_, nil)
            //        XCTAssertEqual(storage.__root.__right_, nil)
            
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
            
            tree.__end_node.__left_ = tree.__node(tree._buffer.count)
        }
        
        tree.buffer.append(.init(isBlack: true, parent: .end, left: nil, right: nil, ___value_: 0))
            
        tree._update { tree in
            XCTAssertEqual(tree._buffer.count, 1)
            XCTAssertNotEqual(tree.__root, nil)
            XCTAssertNotEqual(tree.__root.__parent_, nil)
            XCTAssertEqual(tree.__root.__left_, nil)
            XCTAssertEqual(tree.__root.__right_, nil)
            
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
            
            Base.__tree_balance_after_insert(tree.__root, tree.__node(0))
            
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
    }
    
    func testExample2_2() throws {
        let tree = TreeBase()

        tree.buffer = [
            .init(isBlack: true, parent: .end, left: 1, right: nil, ___value_: 0),
            .init(isBlack: false, parent: 0, left: nil, right: nil, ___value_: 0),
        ]
        
        tree._update { tree in
            tree.__root = tree.__node(0)
            
            XCTAssertEqual(tree.__root, tree.__node(0))
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
        
        print(tree.buffer.graphviz())
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
        
        
        let newNode = BasePtr.node(tree.buffer.count)
        tree.buffer[1].left = .node(tree.buffer.count)
        tree.buffer.append(.init(isBlack: true, parent: 1, left: nil, right: nil, ___value_: 0))
        
        print(tree.buffer.graphviz())
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
        
        tree._update { tree in
            XCTAssertFalse(Base.__tree_invariant(tree.__root))
            Base.__tree_balance_after_insert(tree.__root, newNode.handlePtr(tree.handle))
        }
        
        print(tree.buffer.graphviz())
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
        
        tree._update { tree in
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
    }
    

    func testExample3() throws {
        let tree = TreeBase()

        tree.buffer = [
            .init(isBlack: true, parent: .end, left: 1,right: 2, ___value_: 0),
            .init(isBlack: true, parent: 0, left: 3,right: 5, ___value_: 0),
            .init(isBlack: true, parent: 0, left: nil,right: 4, ___value_: 0),
            .init(isBlack: false, parent: 1, left: nil,right: nil, ___value_: 0),
            .init(isBlack: false, parent: 2, left: nil,right: nil, ___value_: 0),
            .init(isBlack: false, parent: 1, left: nil,right: nil, ___value_: 0),
        ]
        tree._update { tree in
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
            
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
        
        print(tree.buffer.graphviz())
        let lastData = tree.buffer
        
        tree._update { tree in
            Base.__tree_remove(tree.__root, tree.__node(5))
        }
        
        print(tree.buffer.graphviz())
        
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

        tree._update { tree in
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
            
            XCTAssertEqual(tree._buffer[0], lastData[0])
            XCTAssertEqual(tree._buffer[1], .init(isBlack: true, parent: 0, left: 3, right: nil, ___value_: 0))
            XCTAssertEqual(tree._buffer[2], .init(isBlack: true, parent: 0, left: nil, right: 4, ___value_: 0))
            XCTAssertEqual(tree._buffer[3], lastData[3])
            XCTAssertEqual(tree._buffer[4], lastData[4])
            
            XCTAssertEqual(Base.__tree_min(tree.__node(0)), tree.__node(3))
            XCTAssertEqual(Base.__tree_max(tree.__node(0)), tree.__node(4))
            
            XCTAssertEqual(Base.__tree_next(tree.__node(3)), tree.__node(1))
            XCTAssertEqual(Base.__tree_next(tree.__node(1)), tree.__node(0))
            XCTAssertEqual(Base.__tree_next(tree.__node(0)), tree.__node(2))
            XCTAssertEqual(Base.__tree_next(tree.__node(2)), tree.__node(4))
        }
    }
    
    func testExample4() throws {
        let tree = TreeBase()
        
        fixture0_1_2_3_4_5_6(tree)
        
        tree._update { tree in
            Base.__tree_remove(tree.__root, tree.__node(3))
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
        fixture0_1_2_3_4_5_6(tree)
        tree._update { tree in
            Base.__tree_remove(tree.__root, tree.__node(5))
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
        fixture0_1_2_3_4_5_6(tree)
        tree._update { tree in
            Base.__tree_remove(tree.__root, tree.__node(4))
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
        fixture0_1_2_3_4_5_6(tree)
        tree._update { tree in
            Base.__tree_remove(tree.__root, tree.__node(1))
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
        fixture0_1_2_3_4_5_6(tree)
        tree._update { tree in
            Base.__tree_remove(tree.__root, tree.__node(2))
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
        fixture0_1_2_3_4_5_6(tree)
        tree._update { tree in
            Base.__tree_remove(tree.__root, tree.__node(0))
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
    }
    
    func testFindLeafLow() throws {
        let tree = TreeBase()

        fixtureEmpty(tree)
        
        tree._update { tree in
            var parent = tree.__none()
            let result = tree.__find_leaf_low(&parent, -10)
            XCTAssertEqual(parent, tree.__end())
            XCTAssertEqual(result, .__left_(tree.__end()))
        }

        fixture0_10_20(tree)

        tree._update { tree in
            var parent = tree.__none()
            let result = tree.__find_leaf_low(&parent, -10)
            XCTAssertEqual(parent, tree.__node(1))
            XCTAssertEqual(parent.__value_, 0)
            XCTAssertEqual(result, .__left_(tree.__node(1)))
        }
        
        tree._update { tree in
            var parent = tree.__none()
            let result = tree.__find_leaf_low(&parent, 10)
            XCTAssertEqual(parent, tree.__node(1))
            XCTAssertEqual(parent.__value_, 0)
            XCTAssertEqual(result, .__right_(tree.__node(1)))
        }

        tree._update { tree in
            var parent = tree.__none()
            let result = tree.__find_leaf_low(&parent, 30)
            XCTAssertEqual(parent, tree.__node(2))
            XCTAssertEqual(parent.__value_, 20)
            XCTAssertEqual(result, .__right_(tree.__node(2)))
        }
    }
    
    func testFindLeafHigh() throws {
        let tree = TreeBase()

        fixtureEmpty(tree)
        
        tree._update { tree in
            var parent = tree.__none()
            let result = tree.__find_leaf_high(&parent, 10)
            XCTAssertEqual(parent, tree.__end())
            XCTAssertEqual(result, .__left_(tree.__end()))
        }

        fixture0_10_20(tree)

        tree._update { tree in
            var parent = tree.__root
            let result = tree.__find_leaf_high(&parent, 0)
            XCTAssertEqual(parent, tree.__node(1))
            XCTAssertEqual(parent.__value_, 0)
            XCTAssertEqual(result, .__right_(tree.__node(1)))
        }
        
        tree._update { tree in
            var parent = tree.__root
            let result = tree.__find_leaf_high(&parent, 10)
            XCTAssertEqual(parent, tree.__node(2))
            XCTAssertEqual(parent.__value_, 20)
            XCTAssertEqual(result, .__left_(tree.__node(2)))
        }
        
        tree._update { tree in
            var parent = tree.__root
            let result = tree.__find_leaf_high(&parent, 20)
            XCTAssertEqual(parent, tree.__node(2))
            XCTAssertEqual(parent.__value_, 20)
            XCTAssertEqual(result, .__right_(tree.__node(2)))
        }
    }
    
    func testFindEqual() throws {
        let tree = TreeBase()

        fixtureEmpty(tree)
        
        tree._update { tree in
            var parent = tree.__none()
            let result = tree.__find_equal(&parent, 10)
            XCTAssertEqual(parent, tree.__end())
            XCTAssertEqual(result, .__left_(tree.__end()))
        }

        fixture0_10_20(tree)

        tree._update { tree in
            var parent = tree.__root
            let result = tree.__find_equal(&parent, 0)
            XCTAssertEqual(parent, tree.__root.__left_)
            XCTAssertEqual(parent.__value_, 0)
            XCTAssertEqual(result, tree.__root.__left_ref)
        }
        tree._update { tree in
            var parent = tree.__root
            let result = tree.__find_equal(&parent, 10)
            XCTAssertEqual(parent, tree.__root)
            XCTAssertEqual(parent.__value_, 10)
            XCTAssertEqual(result, tree.__end_node.__left_ref)
        }
        tree._update { tree in
            var parent = tree.__root
            let result = tree.__find_equal(&parent, 20)
            XCTAssertEqual(parent, tree.__root.__right_)
            XCTAssertEqual(parent.__value_, 20)
            XCTAssertEqual(result, tree.__root.__right_ref)
        }
    }
    
    func testHoge() throws {
        let tree = TreeBase()
        
        fixtureEmpty(tree)
        
        
        tree._update { tree in
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
        
        for i in 0..<10 {
            tree.ensureReserved(count: 1)
            try tree._update { tree in
                let result = tree.__insert_unique(i)
                XCTAssertTrue(result.__inserted)
                XCTAssertEqual(tree._header.pointee.size, i + 1)
                XCTAssertTrue(try Base.__tree_invariant__(tree.__root))
            }
            print(tree.buffer.graphviz())
        }
        
        print(tree.buffer.graphviz())
    }
    
    func testHoge3() throws {
        let tree = TreeBase()
        
        fixtureEmpty(tree)
        
        tree._update { tree in
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
        
        for i in (0..<200).map({ _ in (0..<1000).randomElement()! }) {
            tree.ensureReserved(count: 1)
            try tree._update { tree in
                _ = tree.__insert_unique(i)
                XCTAssertTrue(try Base.__tree_invariant__(tree.__root))
            }
//            print(tree.buffer.graphviz())
        }
        
        print(tree.buffer.graphviz())
        
        while tree.buffer.count != tree.allocator.reserved {
            let i = tree.buffer.indices.filter{ tree.buffer[$0].___value_ != nil }.randomElement()!
            print(tree.allocator.reserved)
            tree._update { tree in
                _ = tree.__remove_node_pointer(tree.__node(i))
                XCTAssertTrue(Base.__tree_invariant(tree.__root))
                tree.destroy(tree.__node(i))
            }
//            print(tree.buffer.graphviz())
        }
    }

    func testHoge4() throws {
        let tree = TreeBase()
        
        fixtureEmpty(tree)
        
        tree._update { tree in
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
        
        for i in (0..<200).map({ _ in (0..<1000).randomElement()! }) {
            tree.ensureReserved(count: 1)
            try tree._update { tree in
                _ = tree.__insert_unique(i)
                XCTAssertTrue(try Base.__tree_invariant__(tree.__root))
            }
//            print(tree.buffer.graphviz())
        }
        
        print(tree.buffer.graphviz())
        
        while tree.buffer.count != tree.allocator.reserved {
            let i = tree.buffer.indices.filter{ tree.buffer[$0].___value_ != nil }.randomElement()!
            print(tree.allocator.reserved)
            tree._update { tree in
//                _ = tree.__erase_unique(tree._buffer[i].__value_)
//                _ = tree.__remove_node_pointer(tree.__node(i))
                _ = tree.erase(tree.__node(i))
                XCTAssertTrue(Base.__tree_invariant(tree.__root))
//                tree.destroy(tree.__node(i))
            }
//            print(tree.buffer.graphviz())
        }
    }
    
    func testHoge5() throws {
        let tree = TreeBase()
        
        fixtureEmpty(tree)
        
        tree._update { tree in
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
        }
        
        for i in (0..<200).map({ _ in (0..<1000).randomElement()! }) {
            tree.ensureReserved(count: 1)
            try tree._update { tree in
                _ = tree.__insert_unique(i)
                XCTAssertTrue(try Base.__tree_invariant__(tree.__root))
            }
//            print(tree.buffer.graphviz())
        }
        
        print(tree.buffer.graphviz2())
        
        while tree.buffer.count != tree.allocator.reserved {
            let i = tree.buffer.indices.filter{ tree.buffer[$0].___value_ != nil }.randomElement()!
            print(tree.allocator.reserved)
            tree._update { tree in
                _ = tree.__erase_unique(tree._buffer[i].__value_)
//                _ = tree.__remove_node_pointer(tree.__node(i))
//                _ = tree.erase(tree.__node(i))
                XCTAssertTrue(Base.__tree_invariant(tree.__root))
//                tree.destroy(tree.__node(i))
            }
//            print(tree.buffer.graphviz())
        }
    }
    
    func testHoge2() throws {
        let tree = TreeBase()

        fixtureEmpty(tree)
        
        tree.ensureReserved(count: 10)
        
        try tree._update { tree in
            XCTAssertTrue(Base.__tree_invariant(tree.__root))
            
            for i in (0..<10).map({ $0 * 10 }) {
                let result = tree.__insert_unique(i)
                XCTAssertTrue(result.__inserted)
                XCTAssertTrue(try Base.__tree_invariant__(tree.__root))
                print(tree._buffer.contents.graphviz())
            }
        }
        
        print(tree.buffer.graphviz())
        
        tree._update { tree in
            XCTAssertEqual(
                tree.__lower_bound(10, tree.__root, tree.__none()),
                tree.__node(1))
        }
        
        tree._update { tree in
            XCTAssertEqual(
                tree.__upper_bound(10, tree.__root, tree.__none()),
                tree.__node(2))
        }

    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }


}
