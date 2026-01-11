//
//  UnsafeTreeHandleBase.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/10.
//

@usableFromInline
protocol UnsafeTreeHandleBase: TreeNodeProtocol & _TreeValue & UnsafeTreePointer {
  var header: UnsafeMutablePointer<UnsafeTreeV2Buffer<_Value>.Header> { get }
  var origin: UnsafeMutablePointer<UnsafeTreeV2Origin> { get }
}

extension UnsafeTreeHandleBase {

  @inlinable
  @inline(__always)
  public var nullptr: _NodePtr { origin.pointee.nullptr }

  @inlinable
  @inline(__always)
  public var end: _NodePtr { origin.pointee.end_ptr }
}

// MARK: - TreeEndNodeProtocol

extension UnsafeTreeHandleBase {

  @inlinable
  @inline(__always)
  func __left_(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__left_
  }

  @inlinable
  @inline(__always)
  func __left_unsafe(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__left_
  }

  @inlinable
  @inline(__always)
  func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    lhs.pointee.__left_ = rhs
  }
}

// MARK: - TreeNodeProtocol

extension UnsafeTreeHandleBase {

  @inlinable
  @inline(__always)
  func __right_(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__right_
  }

  @inlinable
  @inline(__always)
  func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    lhs.pointee.__right_ = rhs
  }

  @inlinable
  @inline(__always)
  func __is_black_(_ p: _NodePtr) -> Bool {
    return p.pointee.__is_black_
  }

  @inlinable
  @inline(__always)
  func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) {
    lhs.pointee.__is_black_ = rhs
  }

  @inlinable
  @inline(__always)
  func __parent_(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__parent_
  }

  @inlinable
  @inline(__always)
  func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    lhs.pointee.__parent_ = rhs
  }

  @inlinable
  @inline(__always)
  func __parent_unsafe(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__parent_
  }
}

// MARK: -

extension UnsafeTreeHandleBase {

  @inlinable
  @inline(__always)
  func __left_ref(_ p: _NodePtr) -> _NodeRef {
    return withUnsafeMutablePointer(to: &p.pointee.__left_) { $0 }
  }

  @inlinable
  @inline(__always)
  func __right_ref(_ p: _NodePtr) -> _NodeRef {
    return withUnsafeMutablePointer(to: &p.pointee.__right_) { $0 }
  }

  @inlinable
  @inline(__always)
  public func __ptr_(_ rhs: _NodeRef) -> _NodePtr {
    rhs.pointee
  }

  @inlinable
  @inline(__always)
  func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr) {
    lhs.pointee = rhs
  }
}

// MARK: - BeginNodeProtocol

extension UnsafeTreeHandleBase {

  @inlinable
  public var __begin_node_: _NodePtr {

    @inline(__always) get {
      origin.pointee.begin_ptr
    }

    @inline(__always)
    nonmutating set {
      origin.pointee.begin_ptr = newValue
    }
  }
}

// MARK: - EndNodeProtocol

extension UnsafeTreeHandleBase {

  @inlinable
  @inline(__always)
  var __end_node: _NodePtr {
    origin.pointee.end_ptr
  }
}

// MARK: - RootProtocol

extension UnsafeTreeHandleBase {

  #if !DEBUG
    @nonobjc
    @inlinable
    @inline(__always)
    internal var __root: _NodePtr {
      origin.pointee.end_node.__left_
    }
  #else
    @inlinable
    @inline(__always)
    internal var __root: _NodePtr {
      get { end.pointee.__left_ }
      set { end.pointee.__left_ = newValue }
    }
  #endif

  // MARK: - RootPtrProtocol

  @inlinable
  @inline(__always)
  internal func __root_ptr() -> _NodeRef {
    withUnsafeMutablePointer(to: &origin.pointee.end_node.__left_) { $0 }
  }
}

// MARK: - SizeProtocol

extension UnsafeTreeHandleBase {

  @inlinable
  var __size_: Int {
    @inline(__always) get {
      header.pointee.count
    }
    nonmutating set {
      /* NOP */
    }
  }
}

// MARK: - AllocatorProtocol

extension UnsafeTreeHandleBase {

  @inlinable
  @inline(__always)
  public func __construct_node(_ k: _Value) -> _NodePtr {
    header.pointee.__construct_node(k)
  }

  @inlinable
  @inline(__always)
  internal func destroy(_ p: _NodePtr) {
    header.pointee.___pushRecycle(p)
  }
}

extension UnsafeTreeHandleBase {

  @inlinable
  @inline(__always)
  internal func __value_(_ p: _NodePtr) -> _Value {
    UnsafePair<_Value>.valuePointer(p)!.pointee
  }

  @inlinable
  @inline(__always)
  internal func ___element(_ p: _NodePtr, _ __v: _Value) {
    UnsafePair<_Value>.valuePointer(p)!.pointee = __v
  }
}
