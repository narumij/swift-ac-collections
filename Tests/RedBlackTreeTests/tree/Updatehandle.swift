import Foundation

#if DEBUG
@testable import RedBlackTreeModule

@frozen
@usableFromInline
struct _UnsafeUpdateHandle<Element: Comparable> {

  @inlinable
  @inline(__always)
  init(
    __header_ptr: UnsafeMutablePointer<___RedBlackTree.___Header>,
    __node_ptr: UnsafeMutablePointer<___RedBlackTree.___Node>,
    __value_ptr: UnsafeMutablePointer<Element>
  ) {
    self.__header_ptr = __header_ptr
    self.__node_ptr = __node_ptr
    self.__value_ptr = __value_ptr
  }
  @usableFromInline
  let __header_ptr: UnsafeMutablePointer<___RedBlackTree.___Header>
  @usableFromInline
  let __node_ptr: UnsafeMutablePointer<___RedBlackTree.___Node>
  @usableFromInline
  let __value_ptr: UnsafeMutablePointer<Element>
}

//extension _UnsafeUpdateHandle: ___RedBlackTreeUpdateHandleImpl {}
extension _UnsafeUpdateHandle: FindProtocol & FindEqualProtocol {
    @inlinable
    func value_comp(_ a: Element, _ b: Element) -> Bool {
        a < b
    }
}
extension _UnsafeUpdateHandle: InsertNodeAtProtocol {}
extension _UnsafeUpdateHandle: RemoveProtocol {}
extension _UnsafeUpdateHandle: RootProtocol & ValueProtocol { }

extension _UnsafeUpdateHandle {

  @inlinable @inline(__always)
  func __value_(_ p: _NodePtr) -> Element { __value_ptr[p] }
}

extension _UnsafeUpdateHandle {

  @inlinable
  var __left_: _NodePtr {
    @inline(__always) get { __header_ptr.pointee.__left_ }
    nonmutating set { __header_ptr.pointee.__left_ = newValue }
  }

  @inlinable
  var __begin_node: _NodePtr {
    @inline(__always) get { __header_ptr.pointee.__begin_node }
    nonmutating set { __header_ptr.pointee.__begin_node = newValue }
  }

  @inlinable
  var size: Int {
    @inline(__always) get { __header_ptr.pointee.size }
    nonmutating set { __header_ptr.pointee.size = newValue }
  }
}

extension _UnsafeUpdateHandle {

  @inlinable
  @inline(__always)
  func __parent_(_ p: _NodePtr) -> _NodePtr {
    __node_ptr[p].__parent_
  }
  @inlinable
  @inline(__always)
  func __left_(_ p: _NodePtr) -> _NodePtr {
    p == .end ? __left_ : __node_ptr[p].__left_
  }
  @inlinable
  @inline(__always)
  func __right_(_ p: _NodePtr) -> _NodePtr {
    __node_ptr[p].__right_
  }
  @inlinable
  @inline(__always)
  func __is_black_(_ p: _NodePtr) -> Bool {
    __node_ptr[p].__is_black_
  }
  @inlinable
  @inline(__always)
  func __parent_unsafe(_ p: _NodePtr) -> _NodePtr {
    __parent_(p)
  }
}

extension _UnsafeUpdateHandle {

  @inlinable
  func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) {
    __node_ptr[lhs].__is_black_ = rhs
  }
  @inlinable
  func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    __node_ptr[lhs].__parent_ = rhs
  }
  @inlinable
  func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    if lhs == .end {
      __left_ = rhs
    } else {
      __node_ptr[lhs].__left_ = rhs
    }
  }
  @inlinable
  func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    __node_ptr[lhs].__right_ = rhs
  }
}

#endif
