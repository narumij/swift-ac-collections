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
