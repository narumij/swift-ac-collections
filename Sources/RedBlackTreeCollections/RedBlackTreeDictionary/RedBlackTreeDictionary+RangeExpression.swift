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

  extension RedBlackTreeDictionary {

    public typealias View = RedBlackTreeKeyValueRangeView<Self>
    public typealias IndexRange = UnsafeIndexV3Range
    public typealias IndexRangeExpression = UnsafeIndexV3RangeExpression
  }

  extension RedBlackTreeDictionary {

    @inlinable
    public func containsSubrange(_ bounds: UnboundedRange) -> Bool {
      return __tree_.isValid(range: ___safe_range)
    }

    @inlinable
    public func containsSubrange(_ bounds: IndexRange) -> Bool {
      let range = __tree_.__purified_safe_(bounds)
      return __tree_.isValid(range: range)
    }

    @inlinable
    public func containsSubrange(_ bounds: IndexRangeExpression) -> Bool {
      let range = __tree_.__purified_safe_(bounds).relative(to: __tree_)
      return __tree_.isValid(range: range)
    }

  }

  extension RedBlackTreeDictionary {

    @inlinable
    public subscript(bounds: UnboundedRange) -> View {
      @inline(__always) get {
        self[_safeRange: ___safe_range]
      }
      @inline(__always) _modify {
        yield &self[_safeRange: ___safe_range]
      }
    }

    @inlinable
    public subscript(bounds: IndexRange) -> View {
      @inline(__always) get {
        let range = __tree_.__purified_safe_(bounds)
        return self[_safeRange: range]
      }
      @inline(__always) _modify {
        let range = __tree_.__purified_safe_(bounds)
        yield &self[_safeRange: range]
      }
    }

    @inlinable
    public subscript(bounds: IndexRangeExpression) -> View {
      @inline(__always) get {
        let range = __tree_.__purified_safe_(bounds).relative(to: __tree_)
        return self[_safeRange: range]
      }
      @inline(__always) _modify {
        let range = __tree_.__purified_safe_(bounds).relative(to: __tree_)
        yield &self[_safeRange: range]
      }
    }
  }

  extension RedBlackTreeDictionary {

    @inlinable
    @discardableResult
    public mutating func erase(_ bounds: UnboundedRange) -> Index {
      __tree_.ensureUnique()
      return erase(_range: ___safe_range)
    }

    @inlinable
    @discardableResult
    public mutating func erase(_ bounds: IndexRange) -> Index {
      __tree_.ensureUnique()
      let range = __tree_.__purified_safe_(bounds)
      return erase(_range: range)
    }

    @inlinable
    @discardableResult
    public mutating func erase(_ bounds: IndexRangeExpression) -> Index {
      __tree_.ensureUnique()
      let range = __tree_.__purified_safe_(bounds).relative(to: __tree_)
      return erase(_range: range)
    }
  }

  extension RedBlackTreeDictionary {

    @inlinable
    public mutating func erase(
      _ bounds: IndexRange, where shouldBeRemoved: (Element) throws -> Bool
    )
      rethrows
    {
      __tree_.ensureUnique()
      let range = __tree_.__purified_safe_(bounds)
      return try erase(_safeRange: range, where: shouldBeRemoved)
    }

    @inlinable
    public mutating func erase(
      _ bounds: IndexRangeExpression, where shouldBeRemoved: (Element) throws -> Bool
    )
      rethrows
    {
      __tree_.ensureUnique()
      let range = __tree_.__purified_safe_(bounds).relative(to: __tree_)
      return try erase(_safeRange: range, where: shouldBeRemoved)
    }
  }

  extension RedBlackTreeDictionary {

    @inlinable
    mutating func erase(_range range: _SafeRange) -> Index {
      assert(__tree_.isUnique())
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
      assert(__tree_.isUnique())
      do {
        _ = try __tree_.___erase_validate_range_if(range) {
          try shouldBeRemoved(Base.__element_($0))
        }
        .get()
      } catch {
        fatalError("\(error)")
      }
    }
  }

  extension RedBlackTreeDictionary {

    @inlinable
    func makeView(range: _NodeRange) -> View {
      View(
        __tree_: __tree_,
        _start: range.lowerBound.uncheckedSeal,
        _end: range.upperBound.uncheckedSeal)
    }

    @inlinable
    func makeView(range: _SafeRange) -> Result<View, SealError> {
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
    subscript(_safeRange range: _SafeRange) -> View {

      @inline(__always) get {
        do {
          return try makeView(range: range).get()
        } catch {
          fatalError("\(error)")
        }
      }

      @inline(__always) _modify {
        do {
          var view = try makeView(range: range).get()
          self = Self() // yield中のCoWキャンセル。考えた人賢い
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
#endif
