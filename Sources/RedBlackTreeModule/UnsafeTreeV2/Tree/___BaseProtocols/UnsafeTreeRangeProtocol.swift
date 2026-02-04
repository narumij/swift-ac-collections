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
  internal func _isTriviallyIdentical(to other: Self) -> Bool {
    __tree_.isTriviallyIdentical(to: other.__tree_) && _start == other._start && _end == other._end
  }
}
