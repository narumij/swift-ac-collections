//
//  ___UnsafeRangeBaseV2.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

extension UnsafeTreeRangeInterface {
  
  @inlinable
  @inline(__always)
  internal func ___first_tracking_tag(where predicate: (_PayloadValue) throws -> Bool) rethrows -> _RawTrackingTag? {
    var result: _RawTrackingTag?
    try __tree_.___for_each(__p: _start, __l: _end) { __p, cont in
      if try predicate(__tree_[__p]) {
        result = __p.trackingTag
        cont = false
      }
    }
    return result
  }
  
  @inlinable
  @inline(__always)
  internal func ___first_tracking_tag(where predicate: (_PayloadValue) throws -> Bool) rethrows -> RedBlackTreeTrackingTag {
    var raw: _RawTrackingTag = .nullptr
    try __tree_.___for_each(__p: _start, __l: _end) { __p, cont in
      if try predicate(__tree_[__p]) {
        raw = __p.trackingTag
        cont = false
      }
    }
    return .create(raw)
  }
}
