//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

@frozen
public struct RedBlackTreeKeyOnlyRangeView<Container>: UnsafeMutableTreeHostV2
where
  Container: ___Root,
  Container.Base: ___TreeBase & ScalarValueTrait
{

  @inlinable
  internal init(__tree_: UnsafeTreeV2<Container.Base>, _start: _SealedPtr, _end: _SealedPtr) {
    self.__tree_ = __tree_
    self._sealed_start = _start
    self._sealed_end = _end
  }

  public typealias Base = Container.Base
  public typealias Index = UnsafeIndexV3
  public typealias Element = Container.Base._PayloadValue

  @usableFromInline
  internal var __tree_: Tree

  public var startIndex: Index {
    ___index(_sealed_start.pointer!)
  }

  public var endIndex: Index {
    ___index(_sealed_end.pointer!)
  }

  @usableFromInline var _sealed_start: _SealedPtr
  @usableFromInline var _sealed_end: _SealedPtr
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeKeyOnlyRangeView {
    package var _copyCount: UInt {
      __tree_.copyCount
    }
  }
#endif

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  internal mutating func _ensureUnique() {
    // 異なる木のインデックスを無効扱いにするための準備措置
    // Viewだけはインデックス引き継ぎが必要

    // 元の木がユニーク参照では無かった場合、コピーが発生する
    let copied = __tree_.__ensureUnique()

    // コピーが発生した場合インデックス引き継ぎを行う
    if copied {
      // コピー木であることがわかっているので千本引きが確実に行える（ハズレ無し）
      _sealed_start = __tree_.__retrieve_(_sealed_start.purified.tag)
      _sealed_end = __tree_.__retrieve_(_sealed_end.purified.tag)
    }
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  var _raw_range: (_NodePtr, _NodePtr) {
    guard
      let _start = _sealed_start.purified.pointer,
      let _end = _sealed_end.purified.pointer
    else {
      return (__tree_.__end_node, __tree_.__end_node)
    }
    assert(_start == _end || ___ptr_comp_bitmap(_start, _end))
    assert(___ptr_comp_bitmap(_start, _end) == ___ptr_comp_multi(_start, _end))
    return (_start, _end)
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  func ___index(_ p: _NodePtr) -> _LazyTieWrappedPtr {
    __tree_.index(p)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeKeyOnlyRangeView: Sequence {}

  extension RedBlackTreeKeyOnlyRangeView {

    /// - Complexity: O(1)
    @inlinable
    public __consuming func makeIterator() -> UnsafeIterator.ValueObverse<Container.Base> {
      let (_start, _end) = _raw_range
      return .init(start: _start, end: _end, tree: __tree_)
    }
  }
#endif

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(`count`)
  @inlinable
  public __consuming func sorted() -> [Element] {
    let (_start, _end) = _raw_range
    return __tree_.___copy_to_array(_start, _end)
  }

  /// - Complexity: O(`count`)
  @inlinable
  public __consuming func reversed() -> [Element] {
    let (_start, _end) = _raw_range
    return __tree_.___rev_copy_to_array(_start, _end)
  }
}

// MARK: -

public protocol ScalarBaseInit: ___Root
where Self.Base: ___TreeBase & ScalarValueTrait {
  static func _create(_ view: RedBlackTreeKeyOnlyRangeView<Self>) -> Self
}

extension RedBlackTreeSet: ScalarBaseInit {
  public static func _create(_ view: RedBlackTreeKeyOnlyRangeView<Self>) -> Self {
    .init(__tree_: view.__tree_)
  }
}

extension RedBlackTreeMultiSet: ScalarBaseInit {
  public static func _create(_ view: RedBlackTreeKeyOnlyRangeView<Self>) -> Self {
    .init(__tree_: view.__tree_)
  }
}

extension RedBlackTreeKeyOnlyRangeView where Container: ScalarBaseInit {
  public func unranged() -> Container { ._create(self) }
}

// MARK: -

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  public var isEmpty: Bool {
    let (l, u) = _raw_range
    return l != u
  }

  /// - Complexity: O(`count`)
  @inlinable
  public var count: Int {
    let (l, u) = _raw_range
    return (try? ___safe_distance(l, u).get()) ?? 0
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  public var first: Element? {
    let (_start, _end) = _raw_range
    guard _start != _end else { return nil }
    return Base.__payload_(_start)
  }

  @inlinable
  public var last: Element? {
    let (_start, _end) = _raw_range
    guard _start != _end else { return nil }
    return Base.__payload_(__tree_prev_iter(_end))
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  @discardableResult
  public mutating func popFirst() -> Element? {
    _ensureUnique()
    let (_start, _end) = _raw_range
    guard _start != _end else { return nil }
    let (_p, _r) = __tree_._unchecked_remove(at: _start)
    _sealed_start = _p.uncheckedSeal
    return _r
  }

  @inlinable
  @discardableResult
  public mutating func popLast() -> Element? {
    _ensureUnique()
    let (_start, _end) = _raw_range
    guard _start != _end else { return nil }
    return __tree_._unchecked_remove(at: __tree_.__tree_prev_iter(_end)).payload
  }

  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard let element = popFirst() else {
      preconditionFailure(.emptyFirst)
    }
    return element
  }

  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard let element = popLast() else {
      preconditionFailure(.emptyLast)
    }
    return element
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  @discardableResult
  public mutating func erase() -> Index {
    _ensureUnique()
    let (_start, _end) = _raw_range
    // ややチェックが甘いので末端チェック付き削除が必要
    return ___index(__tree_.___erase_range(_start, _end))
  }

  @inlinable
  public mutating func erase(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
    _ensureUnique()
    let (_start, _end) = _raw_range
    let result = try __tree_.___erase_ragen_if(_start.unchecked, _end.unchecked, shouldBeRemoved)
    assert(result.error == nil)
  }
}

#if !COMPATIBLE_ATCODER_2025
extension RedBlackTreeKeyOnlyRangeView where _PayloadValue: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    elementsEqual(other, by: ==)
  }
}

extension RedBlackTreeKeyOnlyRangeView where _PayloadValue: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    lexicographicallyPrecedes(other, by: <)
  }
}

extension RedBlackTreeKeyOnlyRangeView: Equatable where _PayloadValue: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs._isIdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeKeyOnlyRangeView: Comparable where _PayloadValue: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs._isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}
#endif

#if swift(>=5.5)
  extension RedBlackTreeKeyOnlyRangeView: @unchecked Sendable
  where Element: Sendable {}
#endif

// MARK: - Is Identical To

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  public func _isIdentical(to other: Self) -> Bool {
    let (_start, _end) = _raw_range
    let (_other_start, _other_end) = other._raw_range
    return __tree_.isIdentical(to: other.__tree_) && _start == _other_start
      && _end == _other_end
  }
}

// MARK: -

extension RedBlackTreeKeyOnlyRangeView where Base: _BaseNode_PtrRangeCompInterface {

  @inlinable
  package func isValid(index: Index) -> Bool {
    let i = __tree_.__purified_(index)  // __retrieve_でもテストは通る
    guard let i = i.accessible.pointer else { return false }
    let (_start, _end) = _raw_range
    return Base.___ptr_range_comp(_start, i, _end)
  }
}
