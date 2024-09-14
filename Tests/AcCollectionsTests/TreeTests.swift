//
//  TreeTests.swift
//  
//
//  Created by narumij on 2024/09/10.
//

import XCTest
@testable import AcCollections

enum __tree_error: Swift.Error {
    case error(Int, Any, String)
}

struct Tree {
    static var value_comp: (Int, Int) -> Bool { (<) }
    
    var __end_node: BasePtr {
        BasePtr.__end_node
    }
    typealias Element = Int
    
    typealias _Node = BasePtr
    typealias _NodeRef = BasePtr.Reference
    
    var data: [NodeItem] {
        get { _data }
        set { _data = newValue }
    }
}

extension BasePtr {
    public typealias __node_ref_type = Reference
}

extension Tree: ___tree_find_base {
    typealias __node_ref_type = BasePtr.Reference
    
    typealias __value_type = Element
    
    typealias __node_ptr_type = BasePtr
    
    func addressof(_ ptr: _NodeRef) -> _NodeRef {
        ptr
    }
    
    var __root: BasePtr {
        get { __end_node.__left_ }
        nonmutating set { __end_node.__left_ = newValue }
    }
    
    var __root_ptr: BasePtr.Reference {
        __root.__self_ref
    }
}

// MARK: -

final class TreeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFindLeafLow() throws {
        
        var tree = Tree()
        tree.data = [
            .init(isBlack: true, parent: .end, left: nil, right: nil, __value_: 5),
        ]
        tree.__root = .node(0)

        do {
            var parent = tree.__root
            let result = tree.__find_leaf_low(&parent, 5)
            XCTAssertEqual(result, .__left_(tree.__root))
        }
    }
    
    func testFindLeafHigh() throws {
        
        var tree = Tree()
        tree.data = [
            .init(isBlack: true, parent: .end, left: nil, right: nil, __value_: 5),
        ]
        tree.__root = .node(0)

        do {
            var parent = tree.__root
            let result = tree.__find_leaf_high(&parent, 5)
            XCTAssertEqual(result, .__right_(tree.__root))
        }
    }
    
    func testFindEqual() throws {
        
        var tree = Tree()
        tree.data = [
            .init(isBlack: true, parent: .end, left: nil, right: nil, __value_: 10),
        ]
        tree.__root = .node(0)

        do {
            var parent = tree.__root
            let result = tree.__find_equal(&parent, 0)
            XCTAssertEqual(result, tree.__root.__left_ref)
        }
        do {
            var parent = tree.__root
            let result = tree.__find_equal(&parent, 10)
            XCTAssertEqual(result, tree.__root.__self_ref)
        }
        do {
            var parent = tree.__root
            let result = tree.__find_equal(&parent, 20)
            XCTAssertEqual(result, tree.__root.__right_ref)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
