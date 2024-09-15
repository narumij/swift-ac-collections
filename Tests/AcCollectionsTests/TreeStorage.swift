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
    
    func _iterator(_ r: _NodeRef) -> _NodePtr {
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
        var isNil: Bool { false }
        func clear() { }
    }
    
    struct Handle: ___tree_const_base, TreeHandleProtocol {
        let storage: TreeStorage<Element>
        subscript(index: Int) -> TreeStorage<Element>.Item {
            get { storage.items[index] }
            nonmutating set { storage.items[index] = newValue }
        }
        var __begin: BasePtr {
            storage.header.begin_ptr
        }
        var __end_left_: BasePtr {
            get { storage.header.end_left_ptr }
            nonmutating set { storage.header.end_left_ptr = newValue }
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

//extension TreeStorage: ___tree_storage {
//    func find(_ __v: Element) -> _NodePtr {
//        fatalError()
//    }
//    
//    func begin() -> _NodePtr {
//        fatalError()
//    }
//    
//    func end() -> _NodePtr {
//        fatalError()
//    }
//}

