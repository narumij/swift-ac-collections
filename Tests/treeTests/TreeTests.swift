//
//  TreeTests.swift
//  swift-tree
//
//  Created by narumij on 2024/09/20.
//

import XCTest
@testable import RedBlackTreeModule

extension RedBlackTree.Node {
    static var node: Self {
        .init(__is_black_: false, __left_: .nullptr, __right_: .nullptr, __parent_: .nullptr)
    }
}

final class TreeTests: XCTestCase, MemberProtocol, RootImpl, EndNodeProtocol {
    
    var  __nodes: [RedBlackTree.Node] = []
    var  __end_left: _NodePtr = .nullptr
    func __left_(_ p: _NodePtr)         -> _NodePtr { p == .end ? __end_left : __nodes[p].__left_ }
    func __right_(_ p: _NodePtr)        -> _NodePtr { __nodes[p].__right_ }
    func __parent_(_ p: _NodePtr)       -> _NodePtr { __nodes[p].__parent_ }
    func __is_black_(_ p: _NodePtr)     ->  Bool    { __nodes[p].__is_black_ }
    func __parent_unsafe(_ p: _NodePtr) -> _NodePtr { __nodes[p].__parent_ }
    func __construct_node() -> _NodePtr {
        let n = __nodes.count
        __nodes.append(.node)
        return n
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEmpty() throws {
        __nodes = []
        __end_left = .nullptr
        XCTAssertEqual(__root(), .nullptr)
    }

    func testIsLeftChild() throws {
        __nodes = [.node,.node]
        __nodes[0].__is_black_ = true
        __nodes[0].__parent_ = .end
        __end_left = 0
        XCTAssertTrue(__tree_is_left_child(__root()))
        XCTAssertTrue(__tree_invariant(__root()))
        __nodes[0].__left_ = 1
        __nodes[1].__parent_ = 0
        XCTAssertTrue(__tree_is_left_child(1))
        XCTAssertTrue(__tree_invariant(__root()))
        __nodes[0].__left_ = .nullptr
        __nodes[0].__right_ = 1
        XCTAssertFalse(__tree_is_left_child(1))
        XCTAssertTrue(__tree_invariant(__root()))
    }
    
    func testRootRedBlack() throws {
        __end_left = 0
        __nodes = [.node]
        __nodes[0].__is_black_ = true
        __nodes[0].__parent_ = .end
        XCTAssertTrue(__tree_invariant(__root()))
        __nodes[0].__is_black_ = false
        XCTAssertFalse(__tree_invariant(__root()))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
