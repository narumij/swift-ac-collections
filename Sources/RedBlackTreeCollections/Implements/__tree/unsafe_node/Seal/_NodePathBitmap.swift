//
//  _NodePathBitmap.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/27.
//

@usableFromInline
enum _NodePathBitmap {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  #if USE_INT128
    public typealias NodePathBitmap = UInt128
  #else
    public typealias NodePathBitmap = UInt64
  #endif

  case path(NodePathBitmap)
  case end

  @inlinable
  init(_ p: _NodePtr) {
    self = p.___is_end ? .end : .path(p.___ptr_bitmap())
  }
}

extension _NodePathBitmap: Comparable {}

extension _NodePathBitmap {
  
  @inlinable
  static func lessThan(
    lhs: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?),
    rhs: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?)
  )
    -> (
      result: Bool,
      lhsBitmap: _NodePathBitmap?,
      rhsBitmap: _NodePathBitmap?
    )
  {
    let lhsBitmap = lhs.bitmap ?? _NodePathBitmap(lhs.node)
    let rhsBitmap = rhs.bitmap ?? _NodePathBitmap(rhs.node)
    return (lhsBitmap < rhsBitmap, lhsBitmap, rhsBitmap)
  }
}

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
