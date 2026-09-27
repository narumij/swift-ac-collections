//
//  _NodeKey.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/27.
//

@usableFromInline
enum _NodeKey<Base: _BaseNode_KeyInterface>
where Base._NodePtr == UnsafeMutablePointer<UnsafeNode>, Base._Key: Comparable {

  case key(Base._Key)
  case end

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  init(_ p: _NodePtr) {
    self = p.___is_end ? .end : .key(Base.__get_value(p))
  }
}

extension _NodeKey: Comparable {}

extension _NodeKey {
  
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
  where Base._NodePtr == UnsafeMutablePointer<UnsafeNode>, Base._Key: Comparable {
    if lhs.node == rhs.node {
      return (false, lhs.bitmap, rhs.bitmap)
    }
    
    let lk = _NodeKey(lhs.node)
    let rk = _NodeKey(rhs.node)
    
    if lk < rk {
      return (true, lhs.bitmap, rhs.bitmap)
    }
    
    if lk > rk {
      return (false, lhs.bitmap, rhs.bitmap)
    }
    
    return _NodePathBitmap.lessThan(lhs: lhs, rhs: rhs)
  }
}
