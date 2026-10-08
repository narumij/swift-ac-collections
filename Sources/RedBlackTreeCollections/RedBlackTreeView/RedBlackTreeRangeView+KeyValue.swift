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

#if !COMPATIBLE_ATCODER_2025
  @frozen
  /// A mutable view over a contiguous range of a red-black-tree dictionary or multimap.
  ///
  /// The view preserves ascending key order. Mutating it applies copy-on-write
  /// and affects only elements inside the view's bounds.
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
    public typealias Index = RedBlackTreeIndex
    public typealias Element = Container.Base.Element
    public typealias Key = Container.Base._Key
    public typealias Value = Container.Base._MappedValue

    @usableFromInline
    internal var __tree_: Tree

    /// The position of the first key-value pair in a nonempty view.
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
      assert(_start == _end || ___ptr_comp_bitmap(_start, _end))
      assert(___ptr_comp_bitmap(_start, _end) == ___ptr_comp_multi(_start, _end))
      return (_start, _end)
    }
  }


  extension RedBlackTreeKeyValueRangeView {

    @inlinable
    func ___index(_ p: _NodePtr) -> _LazyTiedPtr {
      __tree_.index(p)
    }
  }

  #if !COMPATIBLE_ATCODER_2025
    extension RedBlackTreeKeyValueRangeView: Sequence {}

    extension RedBlackTreeKeyValueRangeView {

      /// Returns an iterator over key-value pairs in ascending key order.
      ///
      /// - Complexity: O(1)
      @inlinable
      public __consuming func makeIterator() -> UnsafeIterator.KeyValueObverse<Base> {
        let (_start, _end) = _raw_range
        return .init(start: _start, end: _end, tree: __tree_)
      }
    }
  #endif

  extension RedBlackTreeKeyValueRangeView {

    /// Returns the view's key-value pairs in ascending key order.
    ///
    /// - Complexity: O(`count`)
    @inlinable
    public __consuming func sorted() -> [Element] {
      let (_start, _end) = _raw_range
      return __tree_.___copy_to_array(_start, _end, transform: Base.__element_)
    }

    /// Returns the view's key-value pairs in descending key order.
    ///
    /// - Complexity: O(`count`)
    @inlinable
    public __consuming func reversed() -> [Element] {
      let (_start, _end) = _raw_range
      return __tree_.___rev_copy_to_array(_start, _end, transform: Base.__element_)
    }
  }

  #if !COMPATIBLE_ATCODER_2025
    #if false
      // 標準に倣うと、Collections適合が必要なのでこちらになる
      extension RedBlackTreeKeyValueRangeView {

        /// A sequence containing the keys in this view, in ascending order.
        ///
        /// - Complexity: O(1) to create the sequence.
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
    #else
      // そもそもCollections適合を捨ててるので、こちらで十分だが、迷っている
      extension RedBlackTreeKeyValueRangeView {

        public typealias Keys = RedBlackTreeIterator.Keys<Base>
        //      public typealias Values = RedBlackTreeIteratorV2.MappedValues<Base>

        /// - Complexity: O(1)
        @inlinable
        public var keys: Keys {
          let (_start, _end) = _raw_range
          return .init(start: _start, end: _end, tree: __tree_)
        }

        /// - Complexity: O(1)
        //      @inlinable
        //      public var values: Values {
        //        let (_start, _end) = _raw_range
        //        return .init(start: _start, end: _end, tree: __tree_)
        //      }

        public typealias Values = RedBlackTreeMappedValuesView<Container>

        @inlinable
        func makeValuesView() -> Values {
          Values(__tree_: __tree_, _start: _sealed_start, _end: _sealed_end)
        }

        // TODO: Restrict value-view mutations to indices contained in this key-value range.
        /// A mutable view of the mapped values inside this key-value range.
        ///
        /// Assigning a value doesn't change its key or the collection's key order.
        /// Structural removal through this view removes the corresponding key-value pair.
        @inlinable
        public var values: Values {
          @inline(__always) get {
            makeValuesView()
          }

          @inline(__always) _modify {
            var view = makeValuesView()
            defer {
              __tree_ = view.__tree_
              _sealed_start = view._sealed_start
              _sealed_end = view._sealed_end
            }
            yield &view
          }
        }
      }
    #endif
  #endif

  // MARK: -

  extension RedBlackTreeKeyValueRangeView {

    /// A Boolean value indicating whether the view contains no key-value pairs.
    ///
    /// - Complexity: O(1)
    @inlinable
    public var isEmpty: Bool {
      let (l, u) = _raw_range
      return l == u
    }

    /// The number of key-value pairs in the view.
    ///
    /// - Complexity: O(`count`)
    @inlinable
    public var count: Int {
      let (l, u) = _raw_range
      return (try? ___safe_distance(l, u).get()) ?? 0
    }
  }

  extension RedBlackTreeKeyValueRangeView {

    /// The first key-value pair, or `nil` if the view is empty.
    ///
    /// - Complexity: O(1)
    @inlinable
    public var first: Element? {
      let (_start, _end) = _raw_range
      guard _start != _end else { return nil }
      return Base.__element_(_start)
    }

    /// The last key-value pair, or `nil` if the view is empty.
    ///
    /// - Complexity: O(1)
    @inlinable
    public var last: Element? {
      let (_start, _end) = _raw_range
      guard _start != _end else { return nil }
      return Base.__element_(__tree_prev_iter(_end))
    }
  }

  extension RedBlackTreeKeyValueRangeView {

    /// Removes and returns the first key-value pair, or returns `nil` if the view is empty.
    @inlinable
    @discardableResult
    public mutating func popFirst() -> Element? {
      guard _raw_range.0 != _raw_range.1 else { return nil }
      _ensureUnique()
      let (_start, _) = _raw_range
      let (_p, _r) = __tree_._unchecked_remove(at: _start)
      _sealed_start = _p.uncheckedSeal
      return Base.__element_(_r)
    }

    /// Removes and returns the last key-value pair, or returns `nil` if the view is empty.
    @inlinable
    @discardableResult
    public mutating func popLast() -> Element? {
      guard _raw_range.0 != _raw_range.1 else { return nil }
      _ensureUnique()
      let (_, _end) = _raw_range
      return Base.__element_(__tree_._unchecked_remove(at: __tree_.__tree_prev_iter(_end)).payload)
    }

    /// Removes and returns the first key-value pair.
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

    /// Removes and returns the last key-value pair.
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

  extension RedBlackTreeKeyValueRangeView {

    /// Removes every key-value pair in the view.
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

    /// Removes the key-value pairs in the view that satisfy `shouldBeRemoved`.
    ///
    /// - Parameter shouldBeRemoved: A predicate that returns `true` for each pair to remove.
    @inlinable
    public mutating func erase(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
      guard _raw_range.0 != _raw_range.1 else { return }
      _ensureUnique()
      let (_start, _end) = _raw_range
      let result = try __tree_.___erase_range_if(_start.unchecked, _end.unchecked) {
        try shouldBeRemoved(Base.__element_($0))
      }
      assert(result.error == nil)
    }
  }

  #if !COMPATIBLE_ATCODER_2025
    extension RedBlackTreeKeyValueRangeView where _PayloadValue: Equatable {

      /// Returns whether this view and `other` contain equal key-value pairs in the same order.
      ///
      /// - Parameter other: A sequence to compare with this view.
      /// - Returns: `true` if both sequences contain the same pairs in the same order.
      /// - Complexity: O(*m*), where *m* is the lesser of the length of the
      ///   sequence and the length of `other`.
      @inlinable
      public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
      where OtherSequence: Sequence, Element == OtherSequence.Element {
        elementsEqual(other, by: ==)
      }
    }

    extension RedBlackTreeKeyValueRangeView where _PayloadValue: Comparable {

      /// Returns whether this view precedes `other` in lexicographical order.
      ///
      /// - Parameter other: A sequence to compare with this view.
      /// - Returns: `true` if this view lexicographically precedes `other`.
      /// - Complexity: O(*m*), where *m* is the lesser of the length of the
      ///   sequence and the length of `other`.
      @inlinable
      public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
      where OtherSequence: Sequence, Element == OtherSequence.Element {
        lexicographicallyPrecedes(other, by: <)
      }
    }

    extension RedBlackTreeKeyValueRangeView: Equatable where _PayloadValue: Equatable {

      /// Returns whether both views contain equal key-value pairs in the same order.
      /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
      @inlinable
      public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._isIdentical(to: rhs) || lhs.elementsEqual(rhs)
      }
    }

    extension RedBlackTreeKeyValueRangeView: Comparable where _PayloadValue: Comparable {

      /// Returns whether `lhs` lexicographically precedes `rhs`.
      /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
      @inlinable
      public static func < (lhs: Self, rhs: Self) -> Bool {
        !lhs._isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
      }
    }
  #endif

  #if swift(>=5.5)
    extension RedBlackTreeKeyValueRangeView: @unchecked Sendable
    where Element: Sendable {}
  #endif

  // MARK: - Is Identical To

  extension RedBlackTreeKeyValueRangeView {

    /// Returns whether two views reference the same tree and the same range boundaries.
    ///
    /// Identity is stronger than element equality and can be checked without traversing the range.
    ///
    /// - Parameter other: Another view to compare by identity.
    /// - Returns: `true` if both views have identical storage and bounds; otherwise, `false`.
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

  extension RedBlackTreeKeyValueRangeView
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

  extension RedBlackTreeKeyValueRangeView {

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
