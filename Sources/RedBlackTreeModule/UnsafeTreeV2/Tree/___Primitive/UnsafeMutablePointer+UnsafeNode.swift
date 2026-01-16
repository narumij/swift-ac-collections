//
//  UnsafeMutablePointer+UnsafeNode.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @inlinable @inline(__always)
  static var nullptr: _NodePtr {
    _read { yield UnsafeNode.nullptr }
  }

  @inlinable
  var __left_: _NodePtr {
    @inline(__always) _read { yield pointee.__left_ }
    @inline(__always) _modify { yield &pointee.__left_ }
  }

  @inlinable
  var __right_: _NodePtr {
    @inline(__always) _read { yield pointee.__right_ }
    @inline(__always) _modify { yield &pointee.__right_ }
  }

  @inlinable
  var __parent_: _NodePtr {
    @inline(__always) _read { yield pointee.__parent_ }
    @inline(__always) _modify { yield &pointee.__parent_ }
  }

  @inlinable
  var __parent_unsafe: _NodePtr {
    @inline(__always) _read { yield pointee.__parent_ }
    @inline(__always) _modify { yield &pointee.__parent_ }
  }

  @inlinable
  var __is_black_: Bool {
    @inline(__always) _read { yield pointee.__is_black_ }
    @inline(__always) _modify { yield &pointee.__is_black_ }
  }
}

//extension UnsafeMutablePointer where Pointee == UnsafeNode {
//  @inlinable @inline(__always)
//  var isGarbaged: Bool { pointee.isGarbaged }
//}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  @inline(__always)
  func __value_<_Value>() -> UnsafeMutablePointer<_Value> {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }

  @inlinable
  @inline(__always)
  func __value_<_Value>(as t: _Value.Type) -> UnsafeMutablePointer<_Value> {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }

  @inlinable
  @inline(__always)
  func __key<Base: ScalarValueComparer>(with t: Base.Type) -> UnsafeMutablePointer<Base._Key> {
    __value_()
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  @inline(__always)
  func _advanced(raw bytes: Int) -> UnsafeMutablePointer {
    UnsafeMutableRawPointer(self)
      .advanced(by: bytes)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  func _advanced(with stride: Int, count: Int) -> UnsafeMutablePointer {
    _advanced(raw: (MemoryLayout<UnsafeNode>.stride + stride) * count)
  }

  @inlinable
  @inline(__always)
  func _advanced<_Value>(with t: _Value.Type, count: Int) -> UnsafeMutablePointer {
    _advanced(raw: (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride) * count)
  }
}
