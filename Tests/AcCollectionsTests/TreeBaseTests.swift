//
//  TreeBaseTests.swift
//  
//
//  Created by narumij on 2024/09/10.
//

import XCTest
@testable import AcCollections

fileprivate enum TreeBase: ___tree_base {
    fileprivate static var data: [RedBlackNode] {
        get { _data }
        set { _data = newValue }
    }
    fileprivate static func node(_ n: Int) -> BasePtr {
        .node(n)
    }
    static var __root: BasePtr {
        get { __end_node.__left_ }
        set { __end_node.__left_ = newValue }
    }
    static var __end_node: BasePtr {
        .end
    }
    static func ___construct_node() -> BasePtr {
        let node = BasePtr.node(_data.count)
        _data.append(.init(isBlack: false, parent: nil, left: nil, right: nil, __value_: 0))
        return node
    }
}

class TreeBaseTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        TreeBase.data = [
            .init(isBlack: true, parent: .end, left: nil,right: nil, __value_: 0),
        ]
        TreeBase.__root = .node(0)
        
        XCTAssertTrue(TreeBase.__tree_invariant(TreeBase.__root))
        
        TreeBase.data = [
            .init(isBlack: false, parent: .end, left: nil,right: nil, __value_: 0),
        ]
        XCTAssertFalse(TreeBase.__tree_invariant(TreeBase.__root))
    }

    func testExample000() throws {
        
        TreeBase.data = [
            .init(isBlack: true, parent: .end, left: 2, right: nil, __value_: 0),
        ]
        TreeBase.__root = .node(0)

        let newNode = TreeBase.___construct_node()
        let root = TreeBase.__root
        root.__left_ = newNode
        newNode.__parent_ = root
        XCTAssertTrue(Tree.__tree_is_left_child(newNode))
    }

    func testExample00() throws {
        
        TreeBase.data = [
            .init(isBlack: true, parent: .end, left: 2,right: nil, __value_: 0),
        ]
        TreeBase.__root = .node(0)

        let newNode = TreeBase.___construct_node()
        let root = TreeBase.__root
        root.__left_ = newNode
        newNode.__parent_ = root
        newNode.__is_black_ = true
        
        XCTAssertEqual(true, newNode.__is_black_)
        XCTAssertFalse(TreeBase.__tree_invariant(TreeBase.__root))
        TreeBase.__tree_balance_after_insert(TreeBase.__root, newNode)
        XCTAssertTrue(TreeBase.__tree_invariant(TreeBase.__root))
        // 新しいノードは、左右両方とも葉ノードなので、赤が必須
        XCTAssertEqual(false, newNode.__is_black_)
    }
    
    func testRotate() throws {
        
        TreeBase.data = [
            .init(isBlack: true, parent: .end, left: 1, right: 2, __value_: 0),
            .init(isBlack: false, parent: 0, left: nil, right: nil, __value_: 0),
            .init(isBlack: false, parent: 0, left: 3,right: 4, __value_: 0),
            .init(isBlack: true, parent: 2, left: nil,right: nil, __value_: 0),
            .init(isBlack: true, parent: 2, left: nil,right: nil, __value_: 0),
        ]
        TreeBase.__root = .node(0)

        let initial = TreeBase.data
        
        print(TreeBase.data.graphviz())
        XCTAssertFalse(TreeBase.__tree_invariant(TreeBase.__root))

        TreeBase.__tree_left_rotate(TreeBase.__root)
        print(TreeBase.data.graphviz())
        
        var next = initial
        next[0] = .init(isBlack: true, parent: 2, left: 1, right: 3, __value_: 0)
        next[2] = .init(isBlack: false, parent: .end, left: 0, right: 4, __value_: 0)
        next[3] = .init(isBlack: true, parent: 0, left: nil, right: nil, __value_: 0)

        XCTAssertEqual(_left, 2)
        XCTAssertEqual(TreeBase.data[0], next[0])
        XCTAssertEqual(TreeBase.data[1], next[1])
        XCTAssertEqual(TreeBase.data[2], next[2])
        XCTAssertEqual(TreeBase.data[3], next[3])
        XCTAssertEqual(TreeBase.data[4], next[4])

        TreeBase.__tree_right_rotate(TreeBase.node(2))
        print(TreeBase.data.graphviz())
        
        XCTAssertEqual(TreeBase.data, initial)
    }

    
    func testExample2() throws {
        
        TreeBase.data = [
            .init(isBlack: true, parent: .end, left: 1, right: 2, __value_: 0), // 1
            .init(isBlack: true, parent: 0, left: 3,right: 5, __value_: 0), // 2
            .init(isBlack: true, parent: 0, left: nil,right: 4, __value_: 0), // 3
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0), // 4
            .init(isBlack: false, parent: 2, left: nil,right: nil, __value_: 0), // 5
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0), // 6
        ]
        TreeBase.__root = .node(0)

        XCTAssertTrue(TreeBase.__tree_invariant(TreeBase.__root))

        XCTAssertEqual(TreeBase.__tree_min(TreeBase.node(0)), TreeBase.node(3))
        XCTAssertEqual(TreeBase.__tree_max(TreeBase.node(0)), TreeBase.node(4))
        
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(3)), TreeBase.node(1))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(1)), TreeBase.node(5))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(5)), TreeBase.node(0))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(0)), TreeBase.node(2))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(2)), TreeBase.node(4))
        
        XCTAssertEqual(TreeBase.__tree_leaf(TreeBase.node(2)), TreeBase.node(4))
        
        print(TreeBase.data.graphviz())
        let lastData = TreeBase.data
        TreeBase.__tree_balance_after_insert(TreeBase.node(1), TreeBase.node(5))
        print(TreeBase.data.graphviz())

        XCTAssertTrue(TreeBase.__tree_invariant(TreeBase.__root))

        XCTAssertEqual(TreeBase.data[0], lastData[0])
        XCTAssertEqual(TreeBase.data[1], lastData[1])
        XCTAssertEqual(TreeBase.data[2], lastData[2])
        XCTAssertEqual(TreeBase.data[3], lastData[3])
        XCTAssertEqual(TreeBase.data[4], lastData[4])
        XCTAssertEqual(TreeBase.data[5], lastData[5])
        XCTAssertEqual(TreeBase.data[5], lastData[5])

        XCTAssertEqual(TreeBase.__tree_min(TreeBase.node(0)), TreeBase.node(3))
        XCTAssertEqual(TreeBase.__tree_max(TreeBase.node(0)), TreeBase.node(4))
        
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(3)), TreeBase.node(1))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(1)), TreeBase.node(5))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(5)), TreeBase.node(0))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(0)), TreeBase.node(2))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(2)), TreeBase.node(4))
    }
    
    func testExample2_1() throws {
        
        TreeBase.data = []
        TreeBase.__root = nil

        XCTAssertEqual(TreeBase.data.count, 0)
        XCTAssertEqual(TreeBase.__root, nil)
        XCTAssertEqual(TreeBase.__root.__parent_, nil)
        XCTAssertEqual(TreeBase.__root.__left_, nil)
        XCTAssertEqual(TreeBase.__root.__right_, nil)

        XCTAssertTrue(TreeBase.__tree_invariant(TreeBase.__root))

        TreeBase.__end_node.__left_ = .node(TreeBase.data.count)
        TreeBase.data.append(.init(isBlack: true, parent: .end, left: nil, right: nil, __value_: 0))
        
        XCTAssertEqual(TreeBase.data.count, 1)
        XCTAssertNotEqual(TreeBase.__root, nil)
        XCTAssertNotEqual(TreeBase.__root.__parent_, nil)
        XCTAssertEqual(TreeBase.__root.__left_, nil)
        XCTAssertEqual(TreeBase.__root.__right_, nil)

        XCTAssertTrue(TreeBase.__tree_invariant(TreeBase.__root))

        TreeBase.__tree_balance_after_insert(TreeBase.__root, TreeBase.node(0))

        XCTAssertTrue(TreeBase.__tree_invariant(TreeBase.__root))
    }
    
    func testExample2_2() throws {
        
        TreeBase.data = [
            .init(isBlack: true, parent: .end, left: 1, right: nil, __value_: 0),
            .init(isBlack: false, parent: 0, left: nil, right: nil, __value_: 0),
        ]
        TreeBase.__root = .node(0)
        
        XCTAssertEqual(TreeBase.__root, .node(0))
        XCTAssertTrue(TreeBase.__tree_invariant(TreeBase.__root))

        // print(TreeBase.data.graphviz())
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

        let newNode = TreeBase.node(TreeBase.data.count)
        TreeBase.data[1].left = .node(TreeBase.data.count)
        TreeBase.data.append(.init(isBlack: true, parent: 1, left: nil, right: nil, __value_: 0))
        
        // print(TreeBase.data.graphviz())
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
        
        XCTAssertFalse(TreeBase.__tree_invariant(TreeBase.__root))
        TreeBase.__tree_balance_after_insert(TreeBase.__root, newNode)
        
        // print(TreeBase.data.graphviz())
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
        
        XCTAssertTrue(TreeBase.__tree_invariant(TreeBase.__root))
    }
    
    func testExample3() throws {

        TreeBase.data = [
            .init(isBlack: true, parent: .end, left: 1,right: 2, __value_: 0),
            .init(isBlack: true, parent: 0, left: 3,right: 5, __value_: 0),
            .init(isBlack: true, parent: 0, left: nil,right: 4, __value_: 0),
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0),
            .init(isBlack: false, parent: 2, left: nil,right: nil, __value_: 0),
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0),
        ]
        TreeBase.__root = .node(0)
        
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
        
        XCTAssertTrue(TreeBase.__tree_invariant(TreeBase.__root))

        print(TreeBase.data.graphviz())
        let lastData = TreeBase.data
        TreeBase.__tree_remove(TreeBase.__root, TreeBase.node(5))
        print(TreeBase.data.graphviz())
        
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

        XCTAssertTrue(TreeBase.__tree_invariant(TreeBase.__root))

        XCTAssertEqual(TreeBase.data[0], lastData[0])
        XCTAssertEqual(TreeBase.data[1], .init(isBlack: true, parent: 0, left: 3, right: nil, __value_: 0))
        XCTAssertEqual(TreeBase.data[2], .init(isBlack: true, parent: 0, left: nil, right: 4, __value_: 0))
        XCTAssertEqual(TreeBase.data[3], lastData[3])
        XCTAssertEqual(TreeBase.data[4], lastData[4])

        XCTAssertEqual(TreeBase.__tree_min(TreeBase.node(0)), TreeBase.node(3))
        XCTAssertEqual(TreeBase.__tree_max(TreeBase.node(0)), TreeBase.node(4))
        
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(3)), TreeBase.node(1))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(1)), TreeBase.node(0))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(0)), TreeBase.node(2))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(2)), TreeBase.node(4))
    }
    
    func testExample4() throws {
        
        TreeBase.data = [
            .init(isBlack: true, parent: .end, left: 1,right: 2, __value_: 0),
            .init(isBlack: true, parent: 0, left: 3,right: 5, __value_: 0),
            .init(isBlack: true, parent: 0, left: nil,right: 4, __value_: 0),
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0),
            .init(isBlack: false, parent: 2, left: nil,right: nil, __value_: 0),
            .init(isBlack: false, parent: 1, left: nil,right: nil, __value_: 0),
        ]
        TreeBase.__root = .node(0)

        XCTAssertTrue(TreeBase.__tree_invariant(TreeBase.__root))

        print(TreeBase.data.graphviz())
        let lastData = TreeBase.data
        TreeBase.__tree_remove(TreeBase.__root, TreeBase.node(3))
        print(TreeBase.data.graphviz())

        XCTAssertTrue(TreeBase.__tree_invariant(TreeBase.__root))

        XCTAssertEqual(TreeBase.data[0], lastData[0])
        XCTAssertEqual(TreeBase.data[1], .init(isBlack: true, parent: 0, left: nil, right: 5, __value_: 0))
        XCTAssertEqual(TreeBase.data[2], .init(isBlack: true, parent: 0, left: nil, right: 4, __value_: 0))
        XCTAssertEqual(TreeBase.data[3], lastData[3])
        XCTAssertEqual(TreeBase.data[4], lastData[4])
        XCTAssertEqual(TreeBase.data[5], .init(isBlack: false, parent: 1, left: nil, right: nil, __value_: 0))

        XCTAssertEqual(TreeBase.__tree_min(TreeBase.node(0)), TreeBase.node(1))
        XCTAssertEqual(TreeBase.__tree_max(TreeBase.node(0)), TreeBase.node(4))
        
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(1)), TreeBase.node(5))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(5)), TreeBase.node(0))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(0)), TreeBase.node(2))
        XCTAssertEqual(TreeBase.__tree_next(TreeBase.node(2)), TreeBase.node(4))
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
