//
//  UnsafeTree+Ref.swift
//  UnsafeTree
//
//  Created by narumij on 2026/01/01.
//

extension UnsafeTree {
  
  @nonobjc
  @inlinable
  @inline(__always)
  func __left_ref(_ p: _NodePtr) -> _NodeRef {
    return withUnsafeMutablePointer(to: &p!.pointee.__left_) { $0 }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func __right_ref(_ p: _NodePtr) -> _NodeRef {
    return withUnsafeMutablePointer(to: &p!.pointee.__right_) { $0 }
  }

  @nonobjc
  @inlinable
  @inline(__always)
  public func __ptr_(_ rhs: _NodeRef) -> _NodePtr {
    rhs.pointee
  }

  @nonobjc
  @inlinable
  @inline(__always)
  func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr) {
    lhs.pointee = rhs
  }
}
