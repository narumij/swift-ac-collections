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
  extension RedBlackTreeMultiSet {

    /// - Important:
    ///   When an element or its corresponding node is removed, any related index becomes invalid.
    ///   Using an invalid index may result in a runtime error or undefined behavior.
    public typealias Index = RedBlackTreeIndex
  }

  extension RedBlackTreeMultiSet {

    /// Returns whether the given index refers to an accessible element.
    ///
    /// `endIndex` is a valid collection boundary, but it is not an element,
    /// so this method returns `false` for `endIndex`.
    ///
    /// - Parameter index: The index to validate.
    /// - Returns: `true` if `index` identifies an accessible element of this multiset; otherwise, `false`.
    /// - Complexity: O(1)
    @inlinable
    public func isElement(at index: Index) -> Bool {
      __tree_.__purified_(index).accessible.error == nil
    }

    /// Returns whether the given index is this multiset's valid end position.
    ///
    /// An invalid or stale index returns `false`.
    ///
    /// - Parameter index: The index to validate.
    /// - Returns: `true` if `index` is this multiset's `endIndex`; otherwise, `false`.
    /// - Complexity: O(1)
    @inlinable
    public func isEnd(_ index: Index) -> Bool {
      __tree_.__purified_(index).pointer?.___is_end == true
    }
  }

  extension RedBlackTreeMultiSet {
    /// Returns the index of the first element equal to `member`.
    ///
    /// - Parameter member: The element to find.
    /// - Returns: The first matching index, or `nil` if the multiset doesn't contain `member`.
    /// - Complexity: O(log `count`)
    @inlinable
    public func firstIndex(of member: Element) -> Index? {
      ___index_or_nil(__tree_.update { $0.find_first(member) })
    }
  }

  extension RedBlackTreeMultiSet {

    /// The position of the first element in a nonempty multiset.
    ///
    /// - Complexity: O(1)
    @inlinable
    public var startIndex: Index { ___index(_start) }

    /// The multiset's “past the end” position.
    ///
    /// - Complexity: O(1)
    @inlinable
    public var endIndex: Index { ___index(_end) }
  }

  extension RedBlackTreeMultiSet {

    /// Returns the distance between two indices.
    ///
    /// The result is negative when `end` precedes `start`.
    ///
    /// - Parameters:
    ///   - start: A valid index of this multiset.
    ///   - end: Another valid index of this multiset.
    /// - Returns: The number of index steps from `start` to `end`.
    /// - Precondition: Both indices are valid for this multiset.
    /// - Complexity: O(log *n* + *k*)
    @inlinable
    public func distance(from start: Index, to end: Index)
      -> Int
    {
      guard let d = __tree_.distance(from: start, to: end)
      else { fatalError(.invalidIndex) }
      return d
    }
  }

  extension RedBlackTreeMultiSet {

    /// Returns the index of the first element that is not less than the given value.
    ///
    /// `lowerBound(_:)` returns the first position (`Index`) where the value is
    /// greater than or equal to the specified element `member`.
    ///
    /// For example, given a sorted sequence `[1, 3, 5, 7, 9]`:
    /// - `lowerBound(0)` returns the position of the first element `1` (i.e. `startIndex`).
    /// - `lowerBound(3)` returns the position of element `3`.
    /// - `lowerBound(4)` returns the position of element `5` (the first value ≥ `4`).
    /// - `lowerBound(10)` returns `endIndex`.
    ///
    /// - Parameter member: The element to search for using binary search.
    /// - Returns: The first `Index` whose value is greater than or equal to `member`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func lowerBound(_ member: Element) -> Index {
      ___index(__tree_.lower_bound(member))
    }

    /// Returns the index of the first element that is greater than the given value.
    ///
    /// `upperBound(_:)` returns the first position (`Index`) where the value is
    /// strictly greater than the specified element `member`.
    ///
    /// For example, given a sorted sequence `[1, 3, 5, 5, 7, 9]`:
    /// - `upperBound(3)` returns the position of element `5`
    ///   (the first value greater than `3`).
    /// - `upperBound(5)` returns the position of element `7`
    ///   (elements equal to `5` are excluded, so it points just after them).
    /// - `upperBound(9)` returns `endIndex`.
    ///
    /// - Parameter member: The element to search for using binary search.
    /// - Returns: The first `Index` whose value is strictly greater than `member`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func upperBound(_ member: Element) -> Index {
      ___index(__tree_.upper_bound(member))
    }
  }

  extension RedBlackTreeMultiSet {

    /// Returns the index of the first element equal to `member`.
    ///
    /// - Parameter member: The element to find.
    /// - Returns: The first matching index, or `endIndex` if the multiset doesn't contain `member`.
    /// - Complexity: O(log `count`)
    @inlinable
    public func find(_ member: Element) -> Index {
      ___index(__tree_.find(member))
    }
  }

  extension RedBlackTreeMultiSet {

    /// Returns the range of indices containing elements equal to `element`.
    ///
    /// The returned range contains every matching occurrence. If no element is
    /// equal to `element`, the range is empty at the position where it could be inserted.
    ///
    /// - Parameter element: The element whose range to find.
    /// - Returns: A half-open range from `lowerBound(element)` to `upperBound(element)`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func equalRange(_ element: Element) -> RedBlackTreeIndexRange {
      let (lower, upper) = __tree_.__equal_range_multi(element)
      return .init(.init(lowerBound: ___index(lower), upperBound: ___index(upper)))
    }
  }

  extension RedBlackTreeMultiSet {

    /// Returns the position immediately before the given index.
    ///
    /// - Complexity: O(1)
    @inlinable
    public func index(before i: Index) -> Index {
      __tree_.prev_iter(i)
    }

    /// Returns the position immediately after the given index.
    ///
    /// - Complexity: O(1)
    @inlinable
    public func index(after i: Index) -> Index {
      __tree_.next_iter(i)
    }

    /// Returns an index that is the specified distance from the given index.
    ///
    /// - Complexity: O(`distance`)
    @inlinable
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
      __tree_.adv_iter(i, offsetBy: distance)
    }

    /// Returns an index at the specified distance, unless movement would pass `limit`.
    ///
    /// Reaching `limit` exactly succeeds. The method returns `nil` only when the
    /// requested movement would pass the limit in the direction of travel.
    ///
    /// - Complexity: O(`distance`)
    @inlinable
    public func index(
      _ i: Index, offsetBy distance: Int, limitedBy limit: Index
    ) -> Index? {
      __tree_.index_or_nil(i, offsetBy: distance, limitedBy: limit)
    }
  }

  extension RedBlackTreeMultiSet {

    /// Replaces the given index with its predecessor.
    ///
    /// - Complexity: O(1)
    @inlinable
    public func formIndex(before i: inout Index) {
      i = __tree_.prev_iter(i)
    }

    /// Replaces the given index with its successor.
    ///
    /// - Complexity: O(1)
    @inlinable
    public func formIndex(after i: inout Index) {
      i = __tree_.next_iter(i)
    }

    /// Offsets the given index by the specified distance.
    ///
    /// - Complexity: O(*d*)
    @inlinable
    public func formIndex(_ i: inout Index, offsetBy distance: Int) {
      i = __tree_.adv_iter(i, offsetBy: distance)
    }

    /// Offsets the given index unless movement would pass `limit`.
    ///
    /// Reaching `limit` exactly succeeds and returns `true`. If movement would
    /// pass the limit, the index is moved to `limit` and the method returns `false`.
    ///
    /// - Complexity: O(*d*)
    @inlinable
    public func formIndex(
      _ i: inout Index, offsetBy distance: Int, limitedBy limit: Index
    ) -> Bool {

      __tree_.form_index(&i, offsetBy: distance, limitedBy: limit)
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025 && ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
  extension RedBlackTreeMultiSet {

    // CoWでstaleすると破綻するため、ALLOW_CROSS_TREE_INDEXが必要
    // CoW分の生木をずっともってしまうと重いので、!USE_LAZY_DETACH専用にする

    /// Inserts the given element and returns the index of the new occurrence.
    ///
    /// A multiset always inserts another occurrence, even when an equivalent
    /// element is already present. Therefore `inserted` is always `true`, and
    /// `index` refers to the newly inserted occurrence.
    ///
    /// - Complexity: O(log **n**), where **n** is the number of elements.
    @inlinable
    @discardableResult
    public mutating func index(inserting newMember: Element) -> (
      inserted: Bool, index: Index
    ) {
      __tree_.ensureUniqueAndCapacity()
      let __r = __tree_.update { $0.__insert_multi(newMember) }
      return (true, ___index(__r))
    }
  }

  extension RedBlackTreeMultiSet {

    // index(inserting:)で取得したIndexでもりもり消したい場合に過剰にチェックしなくて済むように追加
    // remove(at:)では世代違いをトラップするので、isValidチェックを2回行うことになるので。
    // ただ、オーバーフローで一周した場合への対策はなにもない

    /// Removes the element at the given index if the index is still valid.
    ///
    /// Only the occurrence that `index` refers to is removed. Other equivalent
    /// occurrences remain.
    ///
    /// - Parameter index: An index that was created for this multiset.
    /// - Returns: The index that followed `index` before removal, or `nil` if
    ///   `index` doesn't refer to an accessible element of the multiset.
    /// - Complexity: Amortized O(1)
    /// - SeeAlso: `index(inserting:)`, which returns an index to pass to this method.
    @inlinable
    @discardableResult
    public mutating func erase(exactly index: Index) -> Index? {
      // 空の場合はアクセス可能な要素が存在し得ないため、ensureUnique()による
      // 無駄なコピー(共有される空シングルトンバッファからの退避)を避ける。
      guard __tree_.count > 0 else { return nil }
      __tree_.ensureUnique()
      guard let __p = __tree_.__purified_(index).accessible.pointer else {
        return nil
      }
      let __r = __tree_._unchecked_remove(at: __p).__r
      return ___index(__r)
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025

  extension RedBlackTreeMultiSet {

    @inlinable
    func ___index(_ p: _NodePtr) -> _LazyTiedPtr {
      __tree_.index(p)
    }

    @inlinable
    func ___index_or_nil(_ p: _NodePtr) -> _LazyTiedPtr? {
      __tree_.index_or_nil(p)
    }
  }
#endif
