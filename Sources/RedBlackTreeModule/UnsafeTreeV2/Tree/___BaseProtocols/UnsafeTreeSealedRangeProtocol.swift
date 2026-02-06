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
  internal var ___is_empty: Bool {
    __tree_.count == 0 || _sealed_start == _sealed_end
  }

  @inlinable
  @inline(__always)
  internal var ___first: _PayloadValue? {
    ___is_empty
      ? nil
      : try? _sealed_start
        .map { __tree_[$0.pointer] }
        .get()
  }

  @inlinable
  @inline(__always)
  internal var ___last: _PayloadValue? {
    ___is_empty
      ? nil
      : try? _sealed_end
        .map { __tree_.__tree_prev_iter($0.pointer) }
        .map { __tree_[$0] }
        .get()
  }
}

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

extension UnsafeTreeSealedRangeProtocol {

  @inlinable
  @inline(__always)
  internal func _isTriviallyIdentical(to other: Self) -> Bool {
    __tree_.isTriviallyIdentical(to: other.__tree_)
      && _sealed_start == other._sealed_start
      && _sealed_end == other._sealed_end
  }
}
