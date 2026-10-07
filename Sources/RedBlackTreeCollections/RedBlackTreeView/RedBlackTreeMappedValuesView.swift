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

// swapAt可能にする

// multimap, dictionary用のView, SubView

#if !COMPATIBLE_ATCODER_2025
  @frozen
  /// A mutable view of mapped values in a contiguous dictionary or multimap range.
  ///
  /// Assigning through this view changes mapped values without changing their
  /// keys or the collection's key order.
  public struct RedBlackTreeMappedValuesView<Container>: UnsafeMutableTreeHostV2
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
    public typealias Index = RedBlackTreeIndex
    public typealias Element = Container.Base._MappedValue
    public typealias Key = Container.Base._Key
    public typealias Value = Container.Base._MappedValue

    @usableFromInline
    internal var __tree_: Tree

    /// The position of the first mapped value in a nonempty view.
    public var startIndex: Index {
      ___index(_sealed_start.pointer!)
    }

    /// The view's “past the end” position.
    public var endIndex: Index {
      ___index(_sealed_end.pointer!)
    }

    @usableFromInline var _sealed_start: _SealedPtr
    @usableFromInline var _sealed_end: _SealedPtr
  }

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    extension RedBlackTreeMappedValuesView {
      package var _copyCount: UInt {
        __tree_.copyCount
      }
    }
  #endif

  extension RedBlackTreeMappedValuesView {

    /// Returns whether two views reference the same tree and the same range boundaries.
    ///
    /// - Parameter other: Another view to compare by identity.
    /// - Returns: `true` if both views have identical storage and bounds; otherwise, `false`.
    /// - Complexity: O(1)
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

  extension RedBlackTreeMappedValuesView {

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


  extension RedBlackTreeMappedValuesView {

    @inlinable
    func ___index(_ p: _NodePtr) -> _LazyTiedPtr {
      __tree_.index(p)
    }
  }

  #if !COMPATIBLE_ATCODER_2025
    extension RedBlackTreeMappedValuesView: Sequence {}

    extension RedBlackTreeMappedValuesView {

      /// Returns an iterator over mapped values in ascending key order.
      ///
      /// - Complexity: O(1)
      @inlinable
      public __consuming func makeIterator() -> UnsafeIterator.MappedValueObverse<Base> {
        let (_start, _end) = _raw_range
        return .init(start: _start, end: _end, tree: __tree_)
      }
    }
  #endif

  extension RedBlackTreeMappedValuesView
  where Base: _BaseNode_KeyInterface, Base._Key: Comparable {

    /// Accesses the element at the specified position.
    ///
    /// - Parameter position: A valid element index within this view.
    /// - Precondition: `position` identifies an element inside the view.
    ///
    /// - Complexity: O(1).
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always)
      get {
        return __tree_._unsafeAddress(position).pointee.tuple.value
      }
      set {
        _ensureUnique()
        // TODO: unsafeMutableAddressにしたい
        __tree_._unsafeMutableAddress(position).pointee.tuple.value = newValue
      }
    }
  }

  extension RedBlackTreeMappedValuesView
  where Base: _BaseNode_KeyInterface, Base._Key: Comparable {

    /// Exchanges the mapped values at two positions without changing their keys.
    ///
    /// - Parameters:
    ///   - i: A valid element index within this view.
    ///   - j: Another valid element index within this view.
    /// - Precondition: Both indices identify elements inside the view.
    /// - Complexity: O(1).
    public mutating func swapAt(_ i: Index, _ j: Index) {
      _ensureUnique()

      let __i = __tree_.__purified_(i)
      let __j = __tree_.__purified_(j)
      guard let i = __i.accessible.pointer,
        let j = __j.accessible.pointer
      else {
        fatalError(.invalidIndex)
      }
      swap(
        &Base.__mapped_value_ptr(i).pointee,
        &Base.__mapped_value_ptr(j).pointee
      )
    }
  }

  // MARK: -

  extension RedBlackTreeMappedValuesView {

    /// - Complexity: O(1)
    @inlinable
    public var isEmpty: Bool {
      let (l, u) = _raw_range
      return l == u
    }

    /// The number of mapped values in the view.
    ///
    /// - Complexity: O(`count`)
    @inlinable
    public var count: Int {
      let (l, u) = _raw_range
      return (try? ___safe_distance(l, u).get()) ?? 0
    }
  }

  extension RedBlackTreeMappedValuesView {

    /// The first mapped value, or `nil` if the view is empty.
    ///
    /// - Complexity: O(1)
    @inlinable
    public var first: Element? {
      let (_start, _end) = _raw_range
      guard _start != _end else { return nil }
      return Base.__mapped_value_(_start)
    }

    /// The last mapped value, or `nil` if the view is empty.
    ///
    /// - Complexity: O(1)
    @inlinable
    public var last: Element? {
      let (_start, _end) = _raw_range
      guard _start != _end else { return nil }
      return Base.__mapped_value_(__tree_prev_iter(_end))
    }
  }

  extension RedBlackTreeMappedValuesView {

    /// Removes the first pair and returns its mapped value, or returns `nil` if the view is empty.
    @inlinable
    @discardableResult
    public mutating func popFirst() -> Element? {
      // 空の場合はensureUnique()による無駄なコピーを避けるため、
      // 範囲が空かどうかをコピー前に確認する。
      guard _raw_range.0 != _raw_range.1 else { return nil }
      _ensureUnique()
      let (_start, _) = _raw_range
      let (_p, _r) = __tree_._unchecked_remove(at: _start)
      _sealed_start = _p.uncheckedSeal
      return Base.___mapped_value(_r)
    }

    /// Removes the last pair and returns its mapped value, or returns `nil` if the view is empty.
    @inlinable
    @discardableResult
    public mutating func popLast() -> Element? {
      guard _raw_range.0 != _raw_range.1 else { return nil }
      _ensureUnique()
      let (_, _end) = _raw_range
      return Base.___mapped_value(
        __tree_._unchecked_remove(at: __tree_.__tree_prev_iter(_end)).payload)
    }

    /// Removes the first pair and returns its mapped value.
    ///
    /// - Precondition: The view isn't empty.
    @inlinable
    @discardableResult
    public mutating func removeFirst() -> Element {
      guard let element = popFirst() else {
        preconditionFailure(.emptyFirst)
      }
      return element
    }

    /// Removes the last pair and returns its mapped value.
    ///
    /// - Precondition: The view isn't empty.
    @inlinable
    @discardableResult
    public mutating func removeLast() -> Element {
      guard let element = popLast() else {
        preconditionFailure(.emptyLast)
      }
      return element
    }
  }

  extension RedBlackTreeMappedValuesView {

    /// Removes every key-value pair represented by this mapped-values view.
    ///
    /// - Returns: The index immediately following the removed range.
    @inlinable
    @discardableResult
    public mutating func erase() -> Index {
      // 空の場合はensureUnique()による無駄なコピーを避ける。
      guard _raw_range.0 != _raw_range.1 else { return ___index(_raw_range.1) }
      _ensureUnique()
      let (_start, _end) = _raw_range
      // ややチェックが甘いので末端チェック付き削除が必要
      return ___index(try! __tree_.___erase_range(_start, _end).get())
    }

    /// Removes pairs whose mapped values satisfy `shouldBeRemoved`.
    ///
    /// - Parameter shouldBeRemoved: A predicate that returns `true` for each mapped value to remove.
    @inlinable
    public mutating func erase(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
      guard _raw_range.0 != _raw_range.1 else { return }
      _ensureUnique()
      let (_start, _end) = _raw_range
      let result = try __tree_.___erase_range_if(_start.unchecked, _end.unchecked) {
        try shouldBeRemoved(Base.___mapped_value($0))
      }
      assert(result.error == nil)
    }
  }

  #if swift(>=5.5)
    extension RedBlackTreeMappedValuesView: @unchecked Sendable
    where Element: Sendable {}
  #endif

  // MARK: - Is Identical To

  extension RedBlackTreeMappedValuesView {

    /// Returns whether two views reference the same tree and the same range boundaries.
    ///
    /// Identity is stronger than element equality and can be checked without
    /// traversing the range.
    ///
    /// - Parameter other: Another view to compare by identity.
    /// - Returns: `true` if both views have identical storage and bounds;
    ///   otherwise, `false`.
    /// - Complexity: O(1)
    @inlinable
    internal func _isIdentical(to other: Self) -> Bool {
      let (_start, _end) = _raw_range
      let (_other_start, _other_end) = other._raw_range
      return __tree_.isIdentical(to: other.__tree_) && _start == _other_start
        && _end == _other_end
    }
  }

  // MARK: -

  extension RedBlackTreeMappedValuesView
  where Base: _BaseNode_KeyInterface, Base._Key: Comparable {

    /// Returns whether the given index refers to an element in this view.
    ///
    /// The view's end position is not an element. An index outside the view,
    /// or an invalid or stale index, returns `false`.
    ///
    /// - Parameter index: The index to validate.
    /// - Returns: `true` if `index` identifies an accessible element inside this view; otherwise, `false`.
    /// - Complexity: O(log *n*) in the worst case, where *n* is the number of
    ///   elements in the base collection.
    @inlinable
    public func isElement(at index: Index) -> Bool {
      guard
        let index = __tree_.__purified_(index).accessible.pointer,
        let start = _sealed_start.purified.pointer,
        let end = _sealed_end.purified.pointer
      else {
        return false
      }

      let result = _NodeKey<Base>.isInHalfOpenRange(
        first: (start, nil),
        position: (index, nil),
        last: (end, nil)
      )
      return result.result
    }
  }

  extension RedBlackTreeMappedValuesView {

    /// Returns whether the given index is this view's valid end position.
    ///
    /// A view's end position may refer to an element in its base collection.
    /// An invalid or stale index returns `false`.
    ///
    /// - Parameter index: The index to validate.
    /// - Returns: `true` if `index` is this view's `endIndex`; otherwise, `false`.
    /// - Complexity: O(1)
    @inlinable
    public func isEnd(_ index: Index) -> Bool {
      guard
        let index = __tree_.__purified_(index).pointer,
        let end = _sealed_end.purified.pointer
      else {
        return false
      }
      return index == end
    }
  }
#endif
