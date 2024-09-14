import Foundation
@testable import AcCollections

struct TreeHeader {
    var begin_ptr: BasePtr = .end
    var end_ptr: BasePtr = .end
    var size: Int = 0
}

struct UnsafeHandle<Item>: ___tree_const_base, TreeHandleProtocol where Item: NodeItemProtocol {
    let _header: UnsafeMutablePointer<TreeHeader>
    let _buffer: UnsafeMutableBufferPointer<Item>
    subscript(index: Int) -> Item {
        get { _buffer[index] }
        nonmutating set { _buffer[index] = newValue }
    }
    var __begin: BasePtr {
        _header.pointee.begin_ptr
    }
    var __end_left_: BasePtr {
        get { _header.pointee.end_ptr }
        nonmutating set { _header.pointee.end_ptr = newValue }
    }
}

protocol AllocatorProtocol {
    init()
    func create() -> BasePtr
    func delete(_ p: BasePtr)
    var reserved: Int { get }
    func reserve<C: Collection>(contentsOf newElements: C) where C.Element == BasePtr
}

protocol ComparerProtocol {
    associatedtype Element
    static func value_comp(_: Element, _: Element) -> Bool
}

struct UnsafeTree<Allocator, Comparer, Item>: ___tree_base, ___tree_find_base, ___tree_insert_base, ___tree_base_iter_basic_members, ___tree_remove_base, ___tree_work, ___tree_storage
where Item: NodeItemProtocol,
      Allocator: AllocatorProtocol,
      Comparer: ComparerProtocol,
      Item.Element == Comparer.Element
{
    func begin() -> _NodePtr {
        __begin_node
    }
    
    func end() -> _NodePtr {
        __end_node
    }
    
    let _allocator: Allocator
    let _header: UnsafeMutablePointer<TreeHeader>
    let _buffer: UnsafeMutableBufferPointer<Item>
    
    static var value_comp: (Element, Element) -> Bool { Comparer.value_comp }

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
        nonmutating set {
            __end_node.__left_ = newValue
            if newValue != .none {
                newValue.__parent_ = .end(handle)
            }
        }
    }
    var __begin_node: _NodePtr {
        get { _header.pointee.begin_ptr.handlePtr(handle) }
        nonmutating set { _header.pointee.begin_ptr = newValue.basePtr }
    }
    var __end_node: _NodePtr { .end(handle) }
    var size: Int {
        get { _header.pointee.size }
        nonmutating set { _header.pointee.size = newValue }
    }
    func __construct_node(_ k: Element) -> _NodePtr {
        let p = _allocator.create().handlePtr(handle)
        _buffer[p.index!].__value_ = k
        return p
    }
    func destroy(_ p: _NodePtr) {
        _allocator.delete(p.basePtr)
    }
//    func __insert_unique(_ x: __value_type) -> (ref: __node_ref_type, __inserted: Bool) {
//        return (__root_ptr, true)
//    }
}

enum StandardComparer<Element>: ComparerProtocol
where Element: Comparable {
    static func value_comp(_ l: Element, _ r: Element) -> Bool {
        l < r
    }
}

class TreeTreeTree<Allocator, Comparer, Element>
where Allocator: AllocatorProtocol,
      Comparer: ComparerProtocol,
      Comparer.Element == Element
{
    var allocator: Allocator = .init()
    var header: TreeHeader = .init()
    var buffer: [Item] = []
    
    typealias __unsafe_tree = UnsafeTree<Allocator, Comparer, Item>
    
    struct Item: NodeItemProtocol {
        var isBlack: Bool
        var parent: BasePtr
        var left: BasePtr
        var right: BasePtr
        var ___value_: Element?
        var __value_: Element {
            get { ___value_! }
            set { ___value_ = newValue }
        }
    }
    
    func _update<R>(_ body: (__unsafe_tree) throws -> R) rethrows -> R {
        try withUnsafeMutablePointer(to: &header) { header in
            try buffer.withUnsafeMutableBufferPointer { buffer in
                try body(__unsafe_tree(_allocator: allocator, _header: header, _buffer: buffer))
            }
        }
    }

    func ensureReserved(count: Int) {
        let current = allocator.reserved
        let add = max(0, count - current)
        for _ in 0..<add {
            allocator.reserve(contentsOf: [.node(buffer.count)])
            buffer.append(.init(isBlack: false, parent: nil, left: nil, right: nil))
        }
        
    }
}

extension TreeTreeTree.Item: Equatable where Element: Equatable { }
