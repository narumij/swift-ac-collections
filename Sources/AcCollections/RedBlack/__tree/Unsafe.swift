import Foundation

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
        get { _header.pointee.end_left_ptr }
        nonmutating set { _header.pointee.end_left_ptr = newValue }
    }
}

struct UnsafeTree<Allocator, Comparer, Item>: ___tree_base, ___tree_find_base, ___tree_insert_base, ___tree_base_iter_basic_members, ___tree_remove_base, ___tree_find, ___tree_insert_unique, ___tree_erase_unique
where Item: NodeItemProtocol,
      Allocator: AllocatorProtocol,
      Comparer: ComparerProtocol,
      Item.Element == Comparer.Element
{
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
    typealias _NodePtr = HandlePtr<Handle>
    typealias _NodeRef = HandlePtr<Handle>.Reference
    typealias _NodeIter = _NodePtr
    typealias Element = Item.Element

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
        _buffer[p.index!].clear()
        _allocator.delete(p.basePtr)
    }
}

extension UnsafeTree: HandlePtrFactory { }
