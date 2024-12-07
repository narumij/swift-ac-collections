import Foundation

@frozen
@usableFromInline
struct _UnsafeHandle<VC> where VC: ValueComparer {

  @inlinable
  @inline(__always)
  init(
    __header_ptr: UnsafePointer<RedBlackTree.Header>,
    __node_ptr: UnsafePointer<RedBlackTree.Node>,
    __value_ptr: UnsafePointer<Element>
  ) {
    self.__header_ptr = __header_ptr
    self.__node_ptr = __node_ptr
    self.__value_ptr = __value_ptr
  }
  @usableFromInline
  let __header_ptr: UnsafePointer<RedBlackTree.Header>
  @usableFromInline
  let __node_ptr: UnsafePointer<RedBlackTree.Node>
  @usableFromInline
  let __value_ptr: UnsafePointer<Element>
}

extension _UnsafeHandle: _UnsafeHandleCommon {

  @inlinable func __value_(_ p: _NodePtr) -> _Key {
    __value_(__value_ptr[p])
  }
}

extension _UnsafeHandle: ReadHandleImpl {}
extension _UnsafeHandle: NodeFindProtocol & NodeFindEtcProtocol & FindLeafEtcProtocol {}

@usableFromInline
protocol _UnsafeHandleBase {
  associatedtype VC: ValueComparer
  func _read<R>(_ body: (_UnsafeHandle<VC>) throws -> R) rethrows -> R
}

extension _UnsafeHandleBase {

  @inlinable
  func __ref_(_ rhs: _NodeRef) -> _NodePtr {
    _read { $0.__ref_(rhs) }
  }
  
  @inlinable
  func __find_leaf_high(_ __parent: inout _NodePtr, _ __v: VC._Key) -> _NodeRef {
    _read { $0.__find_leaf_high(&__parent, __v) }
  }

  @inlinable
  func __find_equal(_ __parent: inout _NodePtr, _ __v: VC._Key) -> _NodeRef {
    _read { $0.__find_equal(&__parent, __v) }
  }

  @inlinable
  func find(_ __v: VC._Key) -> _NodePtr {
    _read { $0.find(__v) }
  }
  
  @inlinable
  func
  __equal_range_multi(_ __k: VC._Key) -> (_NodePtr, _NodePtr) {
    _read { $0.__equal_range_multi(__k) }
  }
}

extension _UnsafeHandle {

  @inlinable func pointer(_ ptr: _NodePtr, offsetBy distance: Int) -> _NodePtr {
    var ptr = ptr
    var n = distance
    while n != 0 {
      if n > 0 {
        if ptr == .nullptr {
          ptr = __begin_node
        } else if ptr != .end {
          ptr = __tree_next_iter(ptr)
        }
        n -= 1
      }
      if n < 0 {
        if ptr == __begin_node {
          ptr = .nullptr
        } else {
          ptr = __tree_prev_iter(ptr)
        }
        n += 1
      }
    }
    return ptr
  }

  func distance(to ptr: _NodePtr) -> Int {
    var count = 0
    var p = __begin_node
    while p != .end {
      if p == ptr { break }
      p = __tree_next_iter(p)
      count += 1
    }
    return count
  }
}
