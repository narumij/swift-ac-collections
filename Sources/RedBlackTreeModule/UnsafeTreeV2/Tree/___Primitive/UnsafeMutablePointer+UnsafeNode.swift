//
//  UnsafeMutablePointer+UnsafeNode.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

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
