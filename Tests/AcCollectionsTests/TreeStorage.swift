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

class TreeStorage<Element>: ___tree_base, ___tree_find_base,  ___tree_insert_base where Element: Equatable, Element: ExpressibleByIntegerLiteral, Element: Comparable {
    typealias __node_iter_type = _NodePtr
    typealias __node_ptr_type = _NodePtr
    typealias __node_ref_type = _NodeRef
    typealias __value_type = Element
    
    func iterator(_ r: _NodeRef) -> _NodePtr {
        r.referencee
    }
    
    typealias Element = Element
    
    typealias _NodePtr = HandlePtr<Handle>
    typealias _NodeRef = HandlePtr<Handle>.Reference
    typealias _NodeIter = _NodePtr

    static var value_comp: (Element, Element) -> Bool { (<) }

    var header: TreeHeader = .init()
    var items: [Item] = []

    struct Item: Equatable, NodeItemProtocol {
        var isBlack: Bool
        var parent: BasePtr
        var left: BasePtr
        var right: BasePtr
        var __value_: Element
    }
    
    struct Handle: ___tree_const_base, TreeHandleProtocol {
        let storage: TreeStorage<Element>
        subscript(index: Int) -> TreeStorage<Element>.Item {
            get { storage.items[index] }
            nonmutating set { storage.items[index] = newValue }
        }
        var __left_: BasePtr {
            get { storage.header.end_ptr }
            nonmutating set { storage.header.end_ptr = newValue }
        }
    }
    
    var handle: Handle { .init(storage: self) }
    
    func __node(_ n: Int) -> _NodePtr { .node(handle, n) }
    func __end() -> _NodePtr { .end(handle) }
    func __none() -> _NodePtr { .none }
    
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
        get { header.begin_ptr.handlePtr(handle) }
        set { header.begin_ptr = newValue.basePtr }
    }
    
    var __end_node: _NodePtr { .end(handle) }
    
    func ___construct_node(_ k: Element) -> _NodePtr {
        let node = _NodePtr.node(handle, items.count)
        items.append(.init(isBlack: false, parent: nil, left: nil, right: nil, __value_: k))
        return node
    }
    
    var size: Int {
        get { header.size }
        set { header.size = newValue }
    }
}

extension TreeStorage: ___tree_storage {
    func find(_ __v: Element) -> _NodePtr {
        fatalError()
    }
    
    func begin() -> _NodePtr {
        fatalError()
    }
    
    func end() -> _NodePtr {
        fatalError()
    }
}

struct TreeHeader {
    var begin_ptr: BasePtr = .end
    var end_ptr: BasePtr = .end
    var size: Int = 0
}

struct UnsafeHandle<Item>: ___tree_const_base, TreeHandleProtocol where Item: NodeItemProtocol, Item.Element: Comparable {
    let _header: UnsafeMutablePointer<TreeHeader>
    let _buffer: UnsafeMutableBufferPointer<Item>
    subscript(index: Int) -> Item {
        get { _buffer[index] }
        nonmutating set { _buffer[index] = newValue }
    }
    var __left_: BasePtr {
        get { _header.pointee.end_ptr }
        nonmutating set { _header.pointee.end_ptr = newValue }
    }
}

struct UnsafeTree<Item>: ___tree_base, ___tree_find_base where Item: NodeItemProtocol, Item.Element: Comparable {

    let _header: UnsafeMutablePointer<TreeHeader>
    let _buffer: UnsafeMutableBufferPointer<Item>
    
    static var value_comp: (Element, Element) -> Bool { (<) }

    var handle: Handle { Handle(_header: _header, _buffer: _buffer) }
    
    typealias __node_iter_type = _NodePtr
    typealias __node_ptr_type = _NodePtr
    typealias __node_ref_type = _NodeRef
    typealias __value_type = Element
    
    typealias Handle = UnsafeHandle<Item>
    typealias Element = Item.Element
    typealias _NodePtr = HandlePtr<Handle>
    typealias _NodeRef = HandlePtr<Handle>.Reference
    typealias _NodeIter = _NodePtr
    
    func __node(_ n: Int) -> _NodePtr { .node(handle, n) }
    func __end() -> _NodePtr { .end(handle) }
    func __none() -> _NodePtr { .none }
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
        get { _header.pointee.begin_ptr.handlePtr(handle) }
        set { _header.pointee.begin_ptr = newValue.basePtr }
    }
    var __end_node: _NodePtr { .end(handle) }
    var size: Int {
        get { _header.pointee.size }
        set { _header.pointee.size = newValue }
    }
}


class TreeTreeTree<Element> {
    var header: TreeHeader = .init()
    var buffer: [Item] = []
    
    struct Item: NodeItemProtocol {
        var isBlack: Bool
        var parent: BasePtr
        var left: BasePtr
        var right: BasePtr
        var __value_: Element
    }
    
    func _update<R>(_ body: (UnsafeTree<Item>) -> R) -> R {
        withUnsafeMutablePointer(to: &header) { header in
            buffer.withUnsafeMutableBufferPointer { buffer in
                body(UnsafeTree(_header: header, _buffer: buffer))
            }
        }
    }
    
    func construct_node(_ k: Element) -> BasePtr {
        let result = BasePtr.node(buffer.count)
        buffer.append(.init(isBlack: false, parent: nil, left: nil, right: nil, __value_: k))
        return result
    }
}
