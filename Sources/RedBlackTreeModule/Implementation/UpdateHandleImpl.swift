import Foundation

@usableFromInline
protocol UpdateHandleImpl: RefSetImpl & RootImpl & RootPtrImpl {
  associatedtype Element
  var __header_ptr: UnsafeMutablePointer<RedBlackTree.Header> { get }
  var __node_ptr: UnsafeMutablePointer<RedBlackTree.Node> { get }
  var __value_ptr: UnsafeMutablePointer<Element> { get }
}

extension UpdateHandleImpl {

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

extension UpdateHandleImpl {

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

extension UpdateHandleImpl {

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

extension UpdateHandleImpl {

  @inlinable
  @inline(__always)
  func __value_(_ p: _NodePtr) -> Element { __value_ptr[p] }
}
