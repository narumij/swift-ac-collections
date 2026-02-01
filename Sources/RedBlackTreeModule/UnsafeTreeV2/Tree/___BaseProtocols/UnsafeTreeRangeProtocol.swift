//
//  ___UnsafeRangeBaseV2.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

@usableFromInline
protocol UnsafeTreeRangeProtocol: UnsafeTreeRangeBaseInterface, _PayloadValueBride {}

extension UnsafeTreeRangeProtocol {
  
  @inlinable
  @inline(__always)
  internal var ___is_empty: Bool {
    __tree_.count == 0 || _start == _end
  }

  @inlinable
  @inline(__always)
  internal var ___first: _PayloadValue? {
    ___is_empty ? nil : __tree_[_start]
  }

  @inlinable
  @inline(__always)
  internal var ___last: _PayloadValue? {
    ___is_empty ? nil : __tree_[__tree_.__tree_prev_iter(_end)]
  }
}

extension UnsafeTreeRangeProtocol {
  
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

extension UnsafeTreeRangeProtocol {
  
  @inlinable
  @inline(__always)
  internal func _isTriviallyIdentical(to other: Self) -> Bool {
    __tree_.isTriviallyIdentical(to: other.__tree_) && _start == other._start && _end == other._end
  }
}
