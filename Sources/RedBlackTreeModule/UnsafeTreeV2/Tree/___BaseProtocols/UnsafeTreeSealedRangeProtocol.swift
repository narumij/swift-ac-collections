//
//  UnsafeTreeSealedRangeProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/05.
//

@usableFromInline
protocol UnsafeTreeSealedRangeProtocol: UnsafeTreeSealedRangeBaseInterface, _PayloadValueBride {}

extension UnsafeTreeSealedRangeProtocol {

  @inlinable
  @inline(__always)
  internal func ___first(where predicate: (_PayloadValue) throws -> Bool) rethrows -> _PayloadValue?
  {
    var result: _PayloadValue?
    try __tree_.___for_each(__p: _sealed_start, __l: _sealed_end) { __p, cont in
      if try predicate(__tree_[__p]) {
        result = __tree_[__p]
        cont = false
      }
    }
    return result
  }
}

extension UnsafeTreeSealedRangeProtocol {

  @inlinable
  @inline(__always)
  internal func ___first_tracking_tag(where predicate: (_PayloadValue) throws -> Bool) rethrows
    -> TaggedSeal?
  {
    var __r = UnsafeNode.nullptr
    try __tree_.___for_each(__p: _sealed_start, __l: _sealed_end) { __p, cont in
      if try predicate(__tree_[__p]) {
        __r = __p
        cont = false
      }
    }
    return .taggedSealOrNil(__r)
  }
}
