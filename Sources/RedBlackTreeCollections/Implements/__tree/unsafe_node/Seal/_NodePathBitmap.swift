//
//  _NodePathBitmap.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/27.
//

enum _NodePathBitmap {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  #if USE_INT128
    public typealias NodePathBitmap = UInt128
  #else
    public typealias NodePathBitmap = UInt64
  #endif

  case path(NodePathBitmap)
  case end

  init(_ p: _NodePtr) {
    self = p.___is_end ? .end : .path(p.___ptr_bitmap())
  }
}

extension _NodePathBitmap: Comparable {}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  #if USE_INT128
    @available(macOS 15.0, *)
    @inlinable
    internal func ___ptr_bitmap() -> UInt128 {
      ___ptr_bitmap_128()
    }
  #else
    @inlinable
    internal func ___ptr_bitmap() -> UInt64 {
      ___ptr_bitmap_64()
    }
  #endif
}
