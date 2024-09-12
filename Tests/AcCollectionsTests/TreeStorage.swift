//
//  File.swift
//  
//
//  Created by narumij on 2024/09/11.
//

import Foundation
@testable import AcCollections

enum BlackOrRed: Equatable {
    case black
    case red
}

class TreeStorage<Element>: ___tree_base, ___tree_find_base, ___tree_insert_base where Element: Equatable, Element: ExpressibleByIntegerLiteral, Element: Comparable {
    
    typealias Element = Element
    
    typealias _NodePtr = HandlePtr<Handle>
    typealias _NodeRef = HandlePtr<Handle>.Reference
    
    static var value_comp: (Element, Element) -> Bool { (<) }

    var begin_ptr: BasePtr = .end
    var end_ptr: BasePtr = .end
    var items: [Item] = []
    
    struct Item: Equatable, NodeItemProtocol {
        var color: BlackOrRed = .black
        var parent: BasePtr
        var left: BasePtr
        var right: BasePtr
        var element: Element
    }
    
    struct Iterator: Equatable, ___tree_iterator_protocol {
        var __ptr_: TreeStorage<Element>._NodePtr
        var __end_: TreeStorage<Element>._NodePtr
        var __begin_: TreeStorage<Element>._NodePtr
//        init(_ p: TreeStorage<Element>._NodePtr,_ e: TreeStorage<Element>._NodePtr) { __ptr_ = p; __end_ = e }
        func reference() -> reference { __ptr_.__self_ref }
        func pointer() -> pointer { __ptr_ }
    }
    
    struct Handle: Equatable, TreeHandleProtocol {
        static func == (lhs: TreeStorage<Element>.Handle, rhs: TreeStorage<Element>.Handle) -> Bool {
            lhs.storage === rhs.storage
        }
        subscript(index: Int) -> TreeStorage<Element>.Item {
            get { storage.items[index] }
            nonmutating set { storage.items[index] = newValue }
        }
        var __left_: BasePtr {
            get { storage.end_ptr }
            nonmutating set { storage.end_ptr = newValue }
        }
        let storage: TreeStorage<Element>
    }
    
    var handle: Handle { .init(storage: self) }
    
    func node(_ n: Int) -> _NodePtr { .node(handle, n) }
    func end() -> _NodePtr { .end(handle) }
    
    var __root: _NodePtr {
        get { __end_node.__left_ }
        set {
            __end_node.__left_ = newValue
            if newValue != .none {
                newValue.__parent_ = .end(handle)
            }
        }
    }
    
    var __begin_node: _NodePtr {
        get { begin_ptr.handlePtr(handle) }
        set { begin_ptr = newValue.basePtr }
    }
    
    var __end_node: _NodePtr { .end(handle) }
    
//    var __end_iter: Iterator { .init(end_ptr.handlePtr(handle), __end_node, __begin_: _NodePtr) }
    
    func ___construct_node() -> _NodePtr {
        let node = _NodePtr.node(handle, items.count)
        items.append(.init(isBlack: false, parent: nil, left: nil, right: nil, __value_: 0))
        return node
    }
    
    func iterator(_ p: _NodePtr) -> Iterator {
        .init(__ptr_: p, __end_: end(), __begin_: Self.__tree_min(p))
    }
    
    var size: Int = 0
}

extension TreeStorage.Item {
    init(isBlack: Bool, parent: BasePtr = nil, left: BasePtr = nil, right: BasePtr = nil, __value_: Element) {
        self.color = isBlack ? .black : .red
        self.parent = parent
        self.left = left
        self.right = right
        self.element = __value_
    }
    var isBlack: Bool {
        get { color == .black }
        set { color = newValue ? .black : .red }
    }
    var __value_: Element {
        get { element }
        set { element = newValue }
    }
}

