//
//  ___UnsafeRangeBaseV2.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

extension ___UnsafeRangeBaseV2 {
  
  @inlinable
  @inline(__always)
  internal func ___first_tracking_tag(where predicate: (_PayloadValue) throws -> Bool) rethrows -> _TrackingTag? {
    var result: _TrackingTag?
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
    var raw: _TrackingTag = .nullptr
    try __tree_.___for_each(__p: _start, __l: _end) { __p, cont in
      if try predicate(__tree_[__p]) {
        raw = __p.trackingTag
        cont = false
      }
    }
    return .create(raw)
  }
}
