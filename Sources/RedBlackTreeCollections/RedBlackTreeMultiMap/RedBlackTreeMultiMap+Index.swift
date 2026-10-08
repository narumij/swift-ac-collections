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
  extension RedBlackTreeMultiMap {

    /// - Important:
    ///   When an element or its corresponding node is removed, any related index becomes invalid.
    ///   Using an invalid index may result in a runtime error or undefined behavior.
    public typealias Index = RedBlackTreeIndex
  }


  extension RedBlackTreeMultiMap {

    @inlinable
    func ___index(_ p: _NodePtr) -> _LazyTiedPtr {
      __tree_.index(p)
    }

    @inlinable
    func ___index_or_nil(_ p: _NodePtr) -> _LazyTiedPtr? {
      __tree_.index_or_nil(p)
    }
  }

  extension RedBlackTreeMultiMap {

    /// Returns the index of the first element with the given key.
    ///
    /// - Parameter key: The key to find.
    /// - Returns: The first matching index, or `nil` if the multimap doesn't contain `key`.
    /// - Complexity: O(log `count`)
    @inlinable
    public func firstIndex(of key: Key) -> Index? {
      ___index_or_nil(__tree_.update { $0.find_first(key) })
    }
  }

  extension RedBlackTreeMultiMap {

    /// The position of the first element in a nonempty multimap.
    ///
    /// - Complexity: O(1)
    @inlinable
    public var startIndex: Index { ___index(_start) }

    /// The multimap's “past the end” position.
    ///
    /// - Complexity: O(1)
    @inlinable
    public var endIndex: Index { ___index(_end) }
  }

  extension RedBlackTreeMultiMap {

    /// Returns the distance between two indices.
    ///
    /// The result is negative when `end` precedes `start`.
    ///
    /// - Parameters:
    ///   - start: A valid index of this multimap.
    ///   - end: Another valid index of this multimap.
    /// - Returns: The number of index steps from `start` to `end`.
    /// - Precondition: Both indices are valid for this multimap.
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

  extension RedBlackTreeMultiMap {

    /// Returns the index of the first element whose key is not less than the given key.
    ///
    /// `lowerBound(_:)` returns the first position (`Index`) whose element has a key
    /// greater than or equal to the specified `key`.
    /// If multiple elements share the same key, it points to the **first (earliest inserted)**
    /// element among them.
    ///
    /// For example, given a key-sorted sequence `[1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]`:
    /// - `lowerBound(0)` returns the position of the first element `(1, "b")` (i.e. `startIndex`).
    /// - `lowerBound(1)` returns the position of the first element with key `1`, `(1, "b")`.
    /// - `lowerBound(2)` returns the position of `(3, "a")` (the first key ≥ `2`).
    /// - `lowerBound(5)` returns the position of `(5, "e")`.
    /// - `lowerBound(10)` returns `endIndex`.
    ///
    /// - Parameter key: The key to search for using binary search.
    /// - Returns: The first `Index` whose element’s key is greater than or equal to `key`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func lowerBound(_ key: Key) -> Index {
      ___index(__tree_.lower_bound(key))
    }

    /// Returns the index of the first element whose key is greater than the given key.
    ///
    /// `upperBound(_:)` returns the first position (`Index`) whose element has a key
    /// strictly greater than the specified `key`.
    /// If multiple elements share the same key, it points to the position **just after
    /// the last element with that key**.
    ///
    /// For example, given a key-sorted sequence `[1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]`:
    /// - `upperBound(1)` returns the position of `(3, "a")`
    ///   (elements equal to key `1` are excluded, so it points just after them).
    /// - `upperBound(3)` returns the position of `(4, "c")`.
    /// - `upperBound(5)` returns `endIndex`.
    ///
    /// - Parameter key: The key to search for using binary search.
    /// - Returns: The first `Index` whose element’s key is strictly greater than `key`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func upperBound(_ key: Key) -> Index {
      ___index(__tree_.upper_bound(key))
    }
  }

  extension RedBlackTreeMultiMap {

    /// Returns the index of the first element with the given key.
    ///
    /// - Parameter key: The key to find.
    /// - Returns: The first matching index, or `endIndex` if the multimap doesn't contain `key`.
    /// - Complexity: O(log `count`)
    @inlinable
    public func find(_ key: Key) -> Index {
      ___index(__tree_.find(key))
    }
  }

  extension RedBlackTreeMultiMap {

    /// Returns the range of indices containing elements with the given key.
    ///
    /// The returned range contains every key-value pair whose key is equal to
    /// `key`. If the key isn't present, the range is empty at the position where
    /// it could be inserted.
    ///
    /// - Parameter key: The key whose range to find.
    /// - Returns: A half-open range from `lowerBound(key)` to `upperBound(key)`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func equalRange(_ key: Key) -> RedBlackTreeIndexRange {
      let (lower, upper) = __tree_.__equal_range_multi(key)
      return .init(.init(lowerBound: ___index(lower), upperBound: ___index(upper)))
    }
  }

  extension RedBlackTreeMultiMap {

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

  extension RedBlackTreeMultiMap {

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

// MARK: -

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// Returns whether the given index refers to an accessible element.
    ///
    /// `endIndex` is a valid collection boundary, but it is not an element,
    /// so this method returns `false` for `endIndex`.
    ///
    /// - Parameter index: The index to validate.
    /// - Returns: `true` if `index` identifies an accessible element of this multimap; otherwise, `false`.
    /// - Complexity: O(1)
    @inlinable
    public func isElement(at index: Index) -> Bool {
      __tree_.__purified_(index).accessible.error == nil
    }

    /// Returns whether the given index is this multimap's valid end position.
    ///
    /// An invalid or stale index returns `false`.
    ///
    /// - Parameter index: The index to validate.
    /// - Returns: `true` if `index` is this multimap's `endIndex`; otherwise, `false`.
    /// - Complexity: O(1)
    @inlinable
    public func isEnd(_ index: Index) -> Bool {
      __tree_.__purified_(index).pointer?.___is_end == true
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025 && ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
  extension RedBlackTreeMultiMap {
    
    // SetAlgebra都合でinsertの戻りが変えられない。
    // Linuxのスケジューラの様な使い方をするには欠かせないので、追加
    // CoWでstaleすると破綻するため、ALLOW_CROSS_TREE_INDEXが必要
    // CoW分の生木をずっともってしまうと重いので、!USE_LAZY_DETACH専用にする

    /// Returns the index of the given element, inserting it if necessary.
    ///
    /// If the element is inserted, `inserted` is `true` and `index` refers to
    /// the newly inserted element. If an equivalent element is already present,
    /// `inserted` is `false` and `index` refers to the existing element.
    ///
    /// - Complexity: O(log **n**), where **n** is the number of elements.
    @inlinable
    @discardableResult
    public mutating func index(inserting newMember: Element) -> (
      inserted: Bool, index: Index
    ) {
      __tree_.ensureUniqueAndCapacity()
      let __r = __tree_.update { $0.__insert_multi(Base.__payload_(newMember)) }
      return (true, ___index(__r))
    }
  }

  extension RedBlackTreeMultiMap {

    // index(inserting:)で取得したIndexでもりもり消したい場合に過剰にチェックしなくて済むように追加
    // remove(at:)では世代違いをトラップするので、isValidチェックを2回行うことになるので。
    // ただ、オーバーフローで一周した場合への対策はなにもない

    /// Removes the key-value pair at the given index if the index is still valid.
    ///
    /// - Parameter index: An index that was created for this multimap.
    /// - Returns: The index that followed `index` before removal, or `nil` if
    ///   `index` doesn't refer to an accessible key-value pair of the multimap.
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
