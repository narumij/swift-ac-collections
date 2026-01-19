//
//  ClosedRange+RBT.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

extension ClosedRange: _UnsafeNodePtrType, RedBlackTreeRangeExpression {

  public func _relativeRange<_Key,B>(relative: (Bound) -> B, after: (B) -> B) -> (B, B)
  where Bound == RedBlackTreeBound<_Key> {
    let lower = relative(lowerBound)
    let upper = relative(upperBound)
    return (lower, after(upper))
  }
  
  public func __relativeRange<_Key, R>(
    relative: (Bound) -> _NodePtr,
    after: (_NodePtr) -> _NodePtr,
    hoge: (_NodePtr, _NodePtr) -> R
  )
    -> R
  where Bound == RedBlackTreeBound<_Key> {
    
    withExtendedLifetime(self) {
      let l = relative(lowerBound)
      let u = relative(upperBound)
      return hoge(l, after(u))
    }
  }

  public func __relativeRange<_Key>(relative: (Bound) -> _NodePtr, after: (_NodePtr) -> _NodePtr) -> (_NodePtr, _NodePtr)
  where Bound == RedBlackTreeBound<_Key> {
    let l = relative(lowerBound)
    let u = relative(upperBound)
    return (l, after(u))
  }
}
