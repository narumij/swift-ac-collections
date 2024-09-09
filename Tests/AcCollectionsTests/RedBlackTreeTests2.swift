//
//  RedBlackTreeTests2.swift
//  
//
//  Created by narumij on 2024/09/08.
//

import XCTest
@testable import AcCollections

typealias RedBlackNode = Item

extension Array where Element == RedBlackNode {
    
    func graphviz() -> String {
        let header = """
        digraph {
        """
        let red = "node [shape = circle style=filled fillcolor=red];"
        let black = """
        node [shape = circle fillcolor=black fontcolor=white];
        """
        let hooter = """
        }
        """
        return header +
        red + (startIndex ..< endIndex).filter{ !self[$0].isBlack }.map{"\($0)"}.joined(separator: " ") + "\n" +
        black +
        (startIndex ..< endIndex).filter{ self[$0].left != nil }.map{ "\($0) -> \(self[$0].left!) [label = \"left\"];" }.joined(separator: "\n") +
        black +
        (startIndex ..< endIndex).filter{ self[$0].right != nil }.map{ "\($0) -> \(self[$0].right!) [label = \"right\"];" }.joined(separator: "\n") + "\n" +
        hooter
    }
}

public typealias Pointer = RawOffset

var _data: [RedBlackNode] = []

extension RawOffset {
    static func node(_ n: Int) -> Self {
        .offset(n)
    }
}

extension Pointer: ___tree_base { 
    static var __root: Pointer {
        __end_node.__left_
    }
    static var __end_node: Pointer! {
        .node(0)
    }
}

extension Pointer: __node_base_pointer {
    
    static var data: [RedBlackNode] { get { _data } set { _data = newValue } }
    
    public var __right_: Pointer {
        get {
            if case .offset(let int) = self,
               let r = Self.data[int].right {
                return .node(r)
            }
            return .none
        }
        nonmutating set {
            switch self {
            case .offset(let int):
                if case .offset(let n) = newValue {
                    Self.data[int].right = n
                } else {
                    Self.data[int].right = nil
                }
            case .none:
                break
            }
        }
    }
    public var __parent_: Pointer {
        get {
            if case .offset(let int) = self,
               let p = Self.data[int].parent {
                return .node(p)
            }
            return .none
        }
        nonmutating set {
            switch self {
            case .offset(let int):
                if case .offset(let n) = newValue {
                    Self.data[int].parent = n
                } else {
                    Self.data[int].parent = nil
                }
            case .none:
                break
            }
        }
    }
    public var __is_black_: Bool {
        get {
            if case .offset(let int) = self {
                return Self.data[int].isBlack
            }
            return false
        }
        nonmutating set {
            switch self {
            case .offset(let int):
                Self.data[int].isBlack = newValue
            case .none:
                break
            }
        }
    }
    public var __left_: Pointer {
        get {
            if case .offset(let int) = self,
               let l = Self.data[int].left {
                return .node(l)
            }
            return .none
        }
        nonmutating set {
            switch self {
            case .offset(let int):
                if case .offset(let n) = newValue {
                    Self.data[int].left = n
                } else {
                    Self.data[int].left = nil
                }
            case .none:
                break
            }
        }
    }
    public func __parent_unsafe() -> Pointer { __parent_ }
}

extension Pointer {

    enum Reference {
        case __parent_(Pointer)
        case __left_(Pointer)
        case __right_(Pointer)
        var referencee: Pointer {
            get {
                switch self {
                case .__parent_(let p):
                    return p.__parent_
                case .__left_(let p):
                    return p.__left_
                case .__right_(let p):
                    return p.__right_
                }
            }
            nonmutating set {
                switch self {
                case .__parent_(let p):
                    p.__parent_ = newValue
                case .__left_(let p):
                    p.__left_ = newValue
                case .__right_(let p):
                    p.__right_ = newValue
                }
            }
        }
    }
    
    var __parent_ref: Reference {
        .__parent_(self)
    }
    
    var __left_ref: Reference {
        .__left_(self)
    }
    
    var __right_ref: Reference {
        .__right_(self)
    }
}

enum __tree_error: Swift.Error {
    case error(Int,Any,String)
}

extension Pointer {
    
    static func
    __tree_sub_invariant__<_NodePtr>(_ __x: _NodePtr) throws -> Int
    where _NodePtr: __node_base_pointer
    {
        if (__x == nil) {
            return 1; }
          // parent consistency checked by caller
          // check __x->__left_ consistency
        if (__x.__left_ != nil && __x.__left_.__parent_ != __x) {
            return 0; }
          // check __x->__right_ consistency
        if (__x.__right_ != nil && __x.__right_.__parent_ != __x) {
            return 0; }
          // check __x->__left_ != __x->__right_ unless both are nullptr
        if (__x.__left_ == __x.__right_ && __x.__left_ != nil) {
            return 0; }
          // If this is red, neither child can be red
        if (!__x.__is_black_) {
            if (__x.__left_ != nil && !__x.__left_.__is_black_) {
                return 0; }
            if (__x.__right_ != nil && !__x.__right_.__is_black_) {
                return 0; }
          }
        let __h = try __tree_sub_invariant__(__x.__left_);
        if (__h == 0) {
            return 0; } // invalid left subtree
        if (try __h != __tree_sub_invariant__(__x.__right_)) {
            return 0; }                   // invalid or different height right subtree
        return __h + (__x.__is_black_ ? 1 : 0); // return black height of this node
    }
    
    static func
    __tree_invariant__<_NodePtr>(_ __root: _NodePtr) throws -> Bool
    where _NodePtr: __node_base_pointer
    {
        if (__root == nil) {
            return true; }
        // check __x->__parent_ consistency
        if (__root.__parent_ == nil) {
            throw __tree_error.error(#line,__root, "check __x->__parent_ consistency"); }
        if (!__tree_is_left_child(__root)) {
            throw __tree_error.error(#line,__root,"__tree_is_not_left_child"); }
        // root must be black
        if (!__root.__is_black_) {
            throw __tree_error.error(#line,__root,"__root_is_not_black"); }
        // do normal node checks
        if try __tree_sub_invariant__(__root) == 0 {
            throw __tree_error.error(#line,__root,"__tree_sub_invariant(__root) == 0");
        }
        return true
    }
}

final class RedBlackTreeTests2: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        Pointer.data = [
            .init(isBlack: false, parent: nil, left: nil,right: 1),
            .init(isBlack: false, parent: 0, left: nil,right: nil),
        ]
        XCTAssertFalse(Pointer.__tree_is_left_child(Pointer.node(1)))
        XCTAssertTrue(Pointer.__tree_invariant(Pointer.__root))

        Pointer.data = [
            .init(isBlack: false, parent: nil, left: 1,right: nil),
            .init(isBlack: true, parent: 0, left: 2,right: nil),
            .init(isBlack: false, parent: 1, left: nil,right: nil),
        ]
        XCTAssertTrue(Pointer.__tree_is_left_child(Pointer.node(1)))
        XCTAssertTrue(Pointer.__tree_invariant(Pointer.__root))
    }
    
    func testRotate() throws {
        
        Pointer.data = [
            .init(isBlack: false, parent: nil, left: 1, right: nil),
            .init(isBlack: true, parent: 0, left: 2,right: 3),
            .init(isBlack: false, parent: 1, left: nil, right: nil),
            .init(isBlack: false, parent: 1, left: 4,right: 5),
            .init(isBlack: true, parent: 3, left: nil,right: nil),
            .init(isBlack: true, parent: 3, left: nil,right: nil),
        ]
        let initial = Pointer.data
        
        print(Pointer.data.graphviz())
        XCTAssertFalse(Pointer.__tree_invariant(Pointer.__root))

        Pointer.__tree_left_rotate(Pointer.node(1))
        print(Pointer.data.graphviz())
        
        var next = initial
        next[0] = .init(isBlack: false, left: 3)
        next[1] = .init(isBlack: true, parent: 3, left: 2, right: 4)
        next[3] = .init(isBlack: false, parent: 0, left: 1, right: 5)
        next[4] = .init(isBlack: true, parent: 1)

        XCTAssertEqual(Pointer.data[0], next[0])
        XCTAssertEqual(Pointer.data[1], next[1])
        XCTAssertEqual(Pointer.data[2], next[2])
        XCTAssertEqual(Pointer.data[3], next[3])
        XCTAssertEqual(Pointer.data[4], next[4])
        XCTAssertEqual(Pointer.data[5], next[5])

        Pointer.__tree_right_rotate(Pointer.node(3))
        print(Pointer.data.graphviz())
        
        XCTAssertEqual(Pointer.data, initial)
    }

    
    func testExample2() throws {
        
        Pointer.data = [
            .init(isBlack: false, left: 1),
            .init(isBlack: true, parent: 0, left: 2, right: 3), // 1
            .init(isBlack: true, parent: 1, left: 4,right: 6), // 2
            .init(isBlack: true, parent: 1, left: nil,right: 5), // 3
            .init(isBlack: false, parent: 2, left: nil,right: nil), // 4
            .init(isBlack: false, parent: 3, left: nil,right: nil), // 5
            .init(isBlack: false, parent: 2, left: nil,right: nil), // 6
        ]
        
        XCTAssertNoThrow(try Pointer.__tree_invariant__(Pointer.__root))
        
        XCTAssertEqual(Pointer.__tree_min(Pointer.node(1)), Pointer.node(4))
        XCTAssertEqual(Pointer.__tree_max(Pointer.node(1)), Pointer.node(5))
        
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(4)), Pointer.node(2))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(2)), Pointer.node(6))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(6)), Pointer.node(1))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(1)), Pointer.node(3))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(3)), Pointer.node(5))
        
        XCTAssertEqual(Pointer.__tree_leaf(Pointer.node(3)), Pointer.node(5))
        
        print(Pointer.data.graphviz())
        let lastData = Pointer.data
        Pointer.__tree_balance_after_insert(Pointer.node(1), Pointer.node(6))
        print(Pointer.data.graphviz())

        XCTAssertTrue(Pointer.__tree_invariant(Pointer.__root))

        XCTAssertEqual(Pointer.data[0], lastData[0])
        XCTAssertEqual(Pointer.data[1], lastData[1])
        XCTAssertEqual(Pointer.data[2], lastData[2])
        XCTAssertEqual(Pointer.data[3], lastData[3])
        XCTAssertEqual(Pointer.data[4], lastData[4])
        XCTAssertEqual(Pointer.data[5], lastData[5])
        XCTAssertEqual(Pointer.data[6], lastData[6])

        XCTAssertEqual(Pointer.__tree_min(Pointer.node(1)), Pointer.node(4))
        XCTAssertEqual(Pointer.__tree_max(Pointer.node(1)), Pointer.node(5))
        
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(4)), Pointer.node(2))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(2)), Pointer.node(6))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(6)), Pointer.node(1))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(1)), Pointer.node(3))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(3)), Pointer.node(5))
    }
    
    func testExample2_1() throws {
        
        Pointer.data = [
            .init(isBlack: false),
        ]
        
        XCTAssertEqual(Pointer.data.count, 1)
        XCTAssertEqual(Pointer.__root, nil)
        XCTAssertEqual(Pointer.__root.__parent_, nil)
        XCTAssertEqual(Pointer.__root.__left_, nil)
        XCTAssertEqual(Pointer.__root.__right_, nil)

        XCTAssertTrue(Pointer.__tree_invariant(Pointer.__root))

        Pointer.__end_node.__left_ = .node(Pointer.data.count)
        Pointer.data.append(.init(isBlack: true, parent: 0))
        
        XCTAssertEqual(Pointer.data.count, 2)
        XCTAssertNotEqual(Pointer.__root, nil)
        XCTAssertNotEqual(Pointer.__root.__parent_, nil)
        XCTAssertEqual(Pointer.__root.__left_, nil)
        XCTAssertEqual(Pointer.__root.__right_, nil)

        XCTAssertTrue(Pointer.__tree_invariant(Pointer.__root))

        Pointer.__tree_balance_after_insert(Pointer.__root, Pointer.node(1))

        XCTAssertTrue(Pointer.__tree_invariant(Pointer.__root))
    }
    
    func testExample2_2() throws {
        
        Pointer.data = [
            .init(isBlack: false, parent: nil, left: 1,right: nil),
            .init(isBlack: true, parent: 0, left: 2, right: nil),
            .init(isBlack: false, parent: 1, left: nil,right: nil),
        ]
        XCTAssertEqual(Pointer.__root, .node(1))
        XCTAssertNoThrow(try Pointer.__tree_invariant__(Pointer.__root))

        // print(Pointer.data.graphviz())
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

        let newNode = Pointer.node(Pointer.data.count)
        Pointer.data[2].left = Pointer.data.count
        Pointer.data.append(.init(isBlack: true, parent: 2, left: nil, right: nil))
        
        // print(Pointer.data.graphviz())
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
        
        XCTAssertThrowsError(try Pointer.__tree_invariant__(Pointer.__root))
        Pointer.__tree_balance_after_insert(Pointer.__root, Pointer.node(newNode.index!))
        
        // print(Pointer.data.graphviz())
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
        
        XCTAssertTrue(try Pointer.__tree_invariant__(Pointer.__root))
    }
    
    func testExample3() throws {

        Pointer.data = [
            .init(isBlack: false, parent: nil, left: 1,right: nil),
            .init(isBlack: true, parent: 0, left: 2,right: 3),
            .init(isBlack: true, parent: 1, left: 4,right: 6),
            .init(isBlack: true, parent: 1, left: nil,right: 5),
            .init(isBlack: false, parent: 2, left: nil,right: nil),
            .init(isBlack: false, parent: 3, left: nil,right: nil),
            .init(isBlack: false, parent: 2, left: nil,right: nil),
        ]
        
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
        
        XCTAssertNoThrow(try Pointer.__tree_invariant__(Pointer.__root))

        print(Pointer.data.graphviz())
        let lastData = Pointer.data
        Pointer.__tree_remove(Pointer.__root, Pointer.node(6))
        print(Pointer.data.graphviz())
        
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

        XCTAssertTrue(Pointer.__tree_invariant(Pointer.__root))

        XCTAssertEqual(Pointer.data[0], lastData[0])
        XCTAssertEqual(Pointer.data[1], lastData[1])
        XCTAssertEqual(Pointer.data[2], .init(isBlack: true, parent: 1, left: 4, right: nil))
        XCTAssertEqual(Pointer.data[3], .init(isBlack: true, parent: 1, left: nil, right: 5))
        XCTAssertEqual(Pointer.data[4], lastData[4])
        XCTAssertEqual(Pointer.data[5], lastData[5])

        XCTAssertEqual(Pointer.__tree_min(Pointer.node(1)), Pointer.node(4))
        XCTAssertEqual(Pointer.__tree_max(Pointer.node(1)), Pointer.node(5))
        
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(4)), Pointer.node(2))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(2)), Pointer.node(1))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(1)), Pointer.node(3))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(3)), Pointer.node(5))
    }
    
    func testExample4() throws {
        
        Pointer.data = [
            .init(isBlack: false, parent: nil, left: 1,right: nil),
            .init(isBlack: true, parent: 0, left: 2,right: 3),
            .init(isBlack: true, parent: 1, left: 4,right: 6),
            .init(isBlack: true, parent: 1, left: nil,right: 5),
            .init(isBlack: false, parent: 2, left: nil,right: nil),
            .init(isBlack: false, parent: 3, left: nil,right: nil),
            .init(isBlack: false, parent: 2, left: nil,right: nil),
        ]
        XCTAssertTrue(Pointer.__tree_invariant(Pointer.__root))

        print(Pointer.data.graphviz())
        let lastData = Pointer.data
        Pointer.__tree_remove(Pointer.node(1), Pointer.node(4))
        print(Pointer.data.graphviz())

        XCTAssertTrue(Pointer.__tree_invariant(Pointer.__root))

        XCTAssertEqual(Pointer.data[0], lastData[0])
        XCTAssertEqual(Pointer.data[1], lastData[1])
        XCTAssertEqual(Pointer.data[2], .init(isBlack: true, parent: 1, left: nil, right: 6))
        XCTAssertEqual(Pointer.data[3], .init(isBlack: true, parent: 1, left: nil, right: 5))
        XCTAssertEqual(Pointer.data[4], lastData[4])
        XCTAssertEqual(Pointer.data[5], lastData[5])
        XCTAssertEqual(Pointer.data[6], .init(isBlack: false, parent: 2, left: nil, right: nil))

        XCTAssertEqual(Pointer.__tree_min(Pointer.node(1)), Pointer.node(2))
        XCTAssertEqual(Pointer.__tree_max(Pointer.node(1)), Pointer.node(5))
        
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(2)), Pointer.node(6))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(6)), Pointer.node(1))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(1)), Pointer.node(3))
        XCTAssertEqual(Pointer.__tree_next(Pointer.node(3)), Pointer.node(5))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
