//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

@frozen
public struct RedBlackTreeKeyValueRangeView<Container>: UnsafeMutableTreeHostV2
where
  Container: ___Root,
  Container.Base: ___TreeBase & PairValueTrait
{

  @inlinable
  internal init(__tree_: UnsafeTreeV2<Base>, _start: _SealedPtr, _end: _SealedPtr) {
    self.__tree_ = __tree_
    self._sealed_start = _start
    self._sealed_end = _end
  }

  public typealias Base = Container.Base
  public typealias Index = UnsafeIndexV3
  public typealias Element = Container.Base.Element
  public typealias Key = Container.Base._Key
  public typealias Value = Container.Base._MappedValue

  @usableFromInline
  internal var __tree_: Tree

  public var startIndex: Index {
    _sealed_start.band(__tree_)
  }
  
  public var endIndex: Index {
    _sealed_end.band(__tree_)
  }

  @usableFromInline var _sealed_start: _SealedPtr
  @usableFromInline var _sealed_end: _SealedPtr
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeKeyValueRangeView {
    package var _copyCount: UInt {
      __tree_.copyCount
    }
  }
#endif

extension RedBlackTreeKeyValueRangeView {
  
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

extension RedBlackTreeKeyValueRangeView {

  @inlinable
  var _raw_range: (_NodePtr, _NodePtr) {
    guard
      let _start = _sealed_start.purified.pointer,
      let _end = _sealed_end.purified.pointer
    else {
      return (__tree_.__end_node, __tree_.__end_node)
    }
    return (_start, _end)
  }

  @inlinable
  var _safe_range: (_SafePtr, _SafePtr) {
    let _start = _sealed_start.purified.map(\.pointer)
    let _end = _sealed_end.purified.map(\.pointer)
    guard
      _start.error == nil, _end.error == nil
    else {
      return (__tree_.__end_node.unchecked, __tree_.__end_node.unchecked)
    }
    return (_start, _end)
  }

  @inlinable
  var _range: (_SealedPtr, _SealedPtr) {
    let _start = _sealed_start.purified
    let _end = _sealed_end.purified
    guard
      _start.error == nil, _end.error == nil
    else {
      return (__tree_.__end_node.uncheckedSeal, __tree_.__end_node.uncheckedSeal)
    }
    return (_start, _end)
  }
}

extension RedBlackTreeKeyValueRangeView {

  @inlinable
  func ___index(_ p: _NodePtr) -> _LazyTieWrappedPtr {
    __tree_.index(p)
  }

  @inlinable
  func ___index(_ p: _SealedPtr) -> _LazyTieWrappedPtr {
    p.band(__tree_)
  }
}

extension RedBlackTreeKeyValueRangeView: Sequence {}

extension RedBlackTreeKeyValueRangeView {

  /// - Complexity: O(1)
  @inlinable
  public __consuming func makeIterator() -> UnsafeIterator.KeyValueObverse<Base> {
    let (_start, _end) = _range
    #if !COMPATIBLE_ATCODER_2025
      return .init(start: _start.pointer!, end: _end.pointer!, tree: __tree_)
    #else
      return .init(start: _start, end: _end, tie: __tree_.tied)
    #endif
  }

  /// - Complexity: O(`count`)
  @inlinable
  public __consuming func sorted() -> [Element] {
    let (_start, _end) = _raw_range
    return __tree_.___copy_to_array(_start, _end, transform: Base.__element_)
  }

  /// - Complexity: O(`count`)
  @inlinable
  public __consuming func reversed() -> [Element] {
    let (_start, _end) = _raw_range
    return __tree_.___rev_copy_to_array(_start, _end, transform: Base.__element_)
  }
}

extension RedBlackTreeKeyValueRangeView {

  /// - Complexity: O(1)
  @inlinable
  public var keys: [Key] {
    let (_start, _end) = _raw_range
    return __tree_.___copy_to_array(_start, _end) { Base.__key_($0) }
  }

  /// - Complexity: O(1)
  @inlinable
  public var values: [Value] {
    let (_start, _end) = _raw_range
    return __tree_.___copy_to_array(_start, _end) { Base.__mapped_value_($0) }
  }
}

// MARK: -

public protocol KeyValueBaseInit: ___Root
where Base: ___TreeBase & PairValueTrait {
  static func _create(_ view: RedBlackTreeKeyValueRangeView<Self>) -> Self
}

extension RedBlackTreeDictionary: KeyValueBaseInit {
  public static func _create(_ view: RedBlackTreeKeyValueRangeView<Self>) -> Self {
    .init(__tree_: view.__tree_)
  }
}

extension RedBlackTreeMultiMap: KeyValueBaseInit {
  public static func _create(_ view: RedBlackTreeKeyValueRangeView<Self>) -> Self {
    .init(__tree_: view.__tree_)
  }
}

extension RedBlackTreeKeyValueRangeView where Container: KeyValueBaseInit {
  public func unranged() -> Container { ._create(self) }
}

// MARK: -

extension RedBlackTreeKeyValueRangeView {

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

extension RedBlackTreeKeyValueRangeView {

  /// - Complexity: O(1)
  @inlinable
  public var first: Element? {
    let (_start, _end) = _raw_range
    guard _start != _end else { return nil }
    return Base.__element_(_start)
  }

  @inlinable
  public var last: Element? {
    let (_start, _end) = _raw_range
    guard _start != _end else { return nil }
    return Base.__element_(__tree_prev_iter(_end))
  }
}

extension RedBlackTreeKeyValueRangeView {

  @inlinable
  @discardableResult
  public mutating func popFirst() -> Element? {
    _ensureUnique()
    let (_start, _end) = _raw_range
    guard _start != _end else { return nil }
    let (_p, _r) = __tree_._unchecked_remove(at: _start)
    _sealed_start = _p.uncheckedSeal
    return Base.__element_(_r)
  }

  @inlinable
  @discardableResult
  public mutating func popLast() -> Element? {
    _ensureUnique()
    let (_start, _end) = _raw_range
    guard _start != _end else { return nil }
    return Base.__element_(__tree_._unchecked_remove(at: __tree_.__tree_prev_iter(_end)).payload)
  }

  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    _ensureUnique()
    guard let element = popFirst() else {
      preconditionFailure(.emptyFirst)
    }
    return element
  }

  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    _ensureUnique()
    guard let element = popLast() else {
      preconditionFailure(.emptyLast)
    }
    return element
  }
}

extension RedBlackTreeKeyValueRangeView {

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
    let (_start, _end) = _safe_range
    let result = try __tree_.___erase_ragen_if(_start, _end) {
      try shouldBeRemoved(Base.__element_($0))
    }
    if case .failure(let e) = result {
      fatalError(errorMessage(e))
    }
  }
}

extension RedBlackTreeKeyValueRangeView where _PayloadValue: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    elementsEqual(other, by: ==)
  }
}

extension RedBlackTreeKeyValueRangeView where _PayloadValue: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    lexicographicallyPrecedes(other, by: <)
  }
}

extension RedBlackTreeKeyValueRangeView: Equatable where _PayloadValue: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs._isdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeKeyValueRangeView: Comparable where _PayloadValue: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs._isdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeKeyValueRangeView: @unchecked Sendable
  where Element: Sendable {}
#endif

// MARK: - Is Identical To

extension RedBlackTreeKeyValueRangeView {

  @inlinable
  public func _isdentical(to other: Self) -> Bool {
    let (_start, _end) = _raw_range
    let (_other_start, _other_end) = other._raw_range
    return __tree_.isIdentical(to: other.__tree_) && _start == _other_start
      && _end == _other_end
  }
}

// MARK: -

extension RedBlackTreeKeyValueRangeView where Base: _BaseNode_PtrRangeCompInterface {

  @inlinable
  package func isValid(index: Index) -> Bool {
    let i = __tree_.__purified_(index)  // __retrieve_でもテストは通る
    guard let i = i.accessible.pointer else { return false }
    let (_start, _end) = _raw_range
    return Base.___ptr_range_comp(_start, i, _end)
  }
}
