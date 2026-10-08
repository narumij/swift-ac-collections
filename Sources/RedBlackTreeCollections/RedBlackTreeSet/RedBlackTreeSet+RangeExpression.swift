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

// MARK: -

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// A mutable view over a contiguous range of this set.
    public typealias View = RedBlackTreeKeyOnlyRangeView<Self>
  }

  extension RedBlackTreeSet {

    /// A concrete half-open range of red-black-tree indices.
    public typealias IndexRange = RedBlackTreeIndexRange
    /// A range expression whose bounds are resolved against a red-black tree.
    public typealias IndexRangeExpression = RedBlackTreeIndexRangeExpression
  }

  extension RedBlackTreeSet {

    /// Returns whether the whole collection forms a valid subrange.
    ///
    /// - Parameter bounds: The unbounded range expression (`...`).
    /// - Returns: `true` when this set's complete index range is valid.
    @inlinable
    public func containsSubrange(_ bounds: UnboundedRange) -> Bool {
      return __tree_.isValid(range: ___safe_range)
    }

    /// Returns whether `bounds` identifies a valid subrange of this set.
    ///
    /// - Parameter bounds: The concrete index range to validate.
    /// - Returns: `true` if both bounds belong to this set and are in ascending order; otherwise, `false`.
    @inlinable
    public func containsSubrange(_ bounds: IndexRange) -> Bool {
      let range = __tree_.__purified_safe_(bounds)
      return __tree_.isValid(range: range)
    }

    /// Returns whether `bounds` resolves to a valid subrange of this set.
    ///
    /// - Parameter bounds: The range expression to resolve and validate.
    /// - Returns: `true` if the resolved bounds belong to this set and are in ascending order; otherwise, `false`.
    @inlinable
    public func containsSubrange(_ bounds: IndexRangeExpression) -> Bool {
      let range: _SafeRange = __tree_.__purified_safe_(bounds).relative(to: __tree_)
      return __tree_.isValid(range: range)
    }

  }

  extension RedBlackTreeSet {

    /// Accesses a view spanning the whole set.
    ///
    /// - Parameter bounds: The unbounded range expression (`...`).
    @inlinable
    public subscript(bounds: UnboundedRange) -> View {
      @inline(__always) get {
        self[_validate: ___safe_range]
      }
      @inline(__always) _modify {
        yield &self[_validate: ___safe_range]
      }
    }

    /// Accesses a view over the specified concrete index range.
    ///
    /// An invalid or reversed range produces an empty view.
    ///
    /// - Parameter bounds: The concrete index range to access.
    @inlinable
    public subscript(bounds: IndexRange) -> View {
      @inline(__always) get {
        let range = __tree_.__purified_safe_(bounds)
        return self[_validate: range]
      }
      @inline(__always) _modify {
        let range = __tree_.__purified_safe_(bounds)
        yield &self[_validate: range]
      }
    }

    /// Accesses a view over the specified range expression.
    ///
    /// An expression that resolves to an invalid or reversed range produces an empty view.
    ///
    /// - Parameter bounds: The range expression to resolve and access.
    @inlinable
    public subscript(bounds: IndexRangeExpression) -> View {
      @inline(__always) get {
        let range = __tree_.__purified_safe_(bounds).relative(to: __tree_)
        return self[_validate: range]
      }
      @inline(__always) _modify {
        let range = __tree_.__purified_safe_(bounds).relative(to: __tree_)
        yield &self[_validate: range]
      }
    }
  }

  extension RedBlackTreeSet {

    /// Removes every element from the set.
    ///
    /// - Parameter bounds: The unbounded range expression (`...`).
    /// - Returns: The resulting `endIndex`.
    @inlinable
    @discardableResult
    public mutating func erase(_ bounds: UnboundedRange) -> Index {
      // 空の場合は削除対象が存在し得ないため、ensureUnique()による無駄なコピー(共有される
      // 空シングルトンバッファからの退避)を避ける。範囲の検査は続けて行う。
      if __tree_.count > 0 { __tree_.ensureUnique() }
      return erase(_range: ___safe_range)
    }

    /// Removes the elements in the specified concrete index range.
    ///
    /// - Parameter bounds: A valid range of this set.
    /// - Returns: The index immediately following the removed elements.
    /// - Precondition: `bounds` is a valid, ascending subrange of this set.
    @inlinable
    @discardableResult
    public mutating func erase(_ bounds: IndexRange) -> Index {
      // 空の場合は削除対象が存在し得ないため、ensureUnique()による無駄なコピー(共有される
      // 空シングルトンバッファからの退避)を避ける。範囲の検査は続けて行う。
      if __tree_.count > 0 { __tree_.ensureUnique() }
      let range = __tree_.__purified_safe_(bounds)
      return erase(_range: range)
    }

    /// Removes the elements selected by the specified range expression.
    ///
    /// - Parameter bounds: A range expression that resolves to a valid subrange of this set.
    /// - Returns: The index immediately following the removed elements.
    /// - Precondition: The resolved range is a valid, ascending subrange of this set.
    @inlinable
    @discardableResult
    public mutating func erase(_ bounds: IndexRangeExpression) -> Index {
      // 空の場合は削除対象が存在し得ないため、ensureUnique()による無駄なコピー(共有される
      // 空シングルトンバッファからの退避)を避ける。範囲の検査は続けて行う。
      if __tree_.count > 0 { __tree_.ensureUnique() }
      let range = __tree_.__purified_safe_(bounds).relative(to: __tree_)
      return erase(_range: range)
    }
  }

  extension RedBlackTreeSet {

    /// Removes elements in `bounds` that satisfy `shouldBeRemoved`.
    ///
    /// - Parameters:
    ///   - bounds: A valid range of this set.
    ///   - shouldBeRemoved: A predicate that returns `true` for each element to remove.
    /// - Precondition: `bounds` is a valid, ascending subrange of this set.
    @inlinable
    public mutating func erase(
      _ bounds: IndexRange, where shouldBeRemoved: (Element) throws -> Bool
    )
      rethrows
    {
      // 空の場合は削除対象が存在し得ないため、ensureUnique()による無駄なコピー(共有される
      // 空シングルトンバッファからの退避)を避ける。範囲の検査は続けて行う。
      if __tree_.count > 0 { __tree_.ensureUnique() }
      let range = __tree_.__purified_safe_(bounds)
      return try erase(_safeRange: range, where: shouldBeRemoved)
    }

    /// Removes elements in the resolved range that satisfy `shouldBeRemoved`.
    ///
    /// - Parameters:
    ///   - bounds: A range expression that resolves to a valid subrange of this set.
    ///   - shouldBeRemoved: A predicate that returns `true` for each element to remove.
    /// - Precondition: The resolved range is a valid, ascending subrange of this set.
    @inlinable
    public mutating func erase(
      _ bounds: IndexRangeExpression, where shouldBeRemoved: (Element) throws -> Bool
    )
      rethrows
    {
      // 空の場合は削除対象が存在し得ないため、ensureUnique()による無駄なコピー(共有される
      // 空シングルトンバッファからの退避)を避ける。範囲の検査は続けて行う。
      if __tree_.count > 0 { __tree_.ensureUnique() }
      let range = __tree_.__purified_safe_(bounds).relative(to: __tree_)
      return try erase(_safeRange: range, where: shouldBeRemoved)
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    mutating func erase(_range range: _SafeRange) -> Index {
      assert(__tree_.count == 0 || __tree_.isUnique())
      do {
        return try __tree_.___erase_validate_range(range).get()
      } catch {
        fatalError("\(error)")
      }
    }

    @inlinable
    mutating func erase(
      _safeRange range: _SafeRange,
      where shouldBeRemoved: (Element) throws -> Bool
    )
      rethrows
    {
      assert(__tree_.count == 0 || __tree_.isUnique())
      do {
        _ = try __tree_.___erase_validate_range_if(range, shouldBeRemoved).get()
      } catch {
        fatalError("\(error)")
      }
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    func makeView(range: _NodeRange) -> View {
      View(
        __tree_: __tree_,
        _start: range.lowerBound.uncheckedSeal,
        _end: range.upperBound.uncheckedSeal)
    }

    @inlinable
    func makeViewWithValidate(range: _SafeRange) -> Result<View, SealError> {
      range
        .flatMap(__tree_.validated(range:))
        .map(makeView(range:))
    }
    
    @inlinable
    func makeViewWithSanitize(range: _SafeRange) -> Result<View, SealError> {
      __tree_.sanitize(range)
        .map(makeView(range:))
    }

    @inlinable
    subscript(_validate range: _SafeRange) -> View {

      @inline(__always) get {
        do {
          return try makeViewWithValidate(range: range).get()
        } catch {
          fatalError("\(error)")
        }
      }

      @inline(__always) _modify {
        do {
          var view = try makeViewWithValidate(range: range).get()
          self = Self()  // yield中のCoWキャンセル。考えた人賢い
          defer { self = Self(__tree_: view.__tree_) }
          yield &view
        } catch {
          fatalError("\(error)")
        }
      }
    }
    
    @inlinable
    subscript(_sanitize range: _SafeRange) -> View {

      @inline(__always) get {
        do {
          return try makeViewWithSanitize(range: range).get()
        } catch {
          fatalError("\(error)")
        }
      }

      @inline(__always) _modify {
        do {
          var view = try makeViewWithSanitize(range: range).get()
          self = Self()  // yield中のCoWキャンセル。考えた人賢い
          defer { self = Self(__tree_: view.__tree_) }
          yield &view
        } catch {
          fatalError("\(error)")
        }
      }
    }
  }

  extension RedBlackTreeSet {

    /// Returns the range of indices containing `element`.
    ///
    /// A set contains at most one matching element. If `element` isn't present,
    /// the returned range is empty at the position where it could be inserted.
    ///
    /// - Parameter element: The element whose range to find.
    /// - Returns: A half-open range from `lowerBound(element)` to `upperBound(element)`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func equalRange(_ element: Element) -> RedBlackTreeIndexRange {
      let (lower, upper) = __tree_.__equal_range_unique(element)
      return .init(.init(lowerBound: ___index(lower), upperBound: ___index(upper)))
    }
  }
#endif
