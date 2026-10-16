import RedBlackTreeCollections
// Copyright 2025 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

public struct MemoizePack<each T> {

  public
    typealias RawValue = (repeat each T)

  public
    var rawValue: RawValue

  @inlinable @inline(__always)
  public init(rawValue: (repeat each T)) {
    self.rawValue = (repeat each rawValue)
  }

  @inlinable @inline(__always)
  public init(_ rawValue: repeat each T) {
    self.rawValue = (repeat each rawValue)
  }
}

extension MemoizePack: Equatable where repeat each T: Equatable {

  @inlinable
  public static func == (lhs: MemoizePack<repeat each T>, rhs: MemoizePack<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.rawValue, each rhs.rawValue) {
      if l != r {
        return false
      }
    }
    return true
  }
}

extension MemoizePack: Comparable where repeat each T: Comparable {

  @inlinable
  public static func < (lhs: MemoizePack<repeat each T>, rhs: MemoizePack<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.rawValue, each rhs.rawValue) {
      if l != r {
        return l < r
      }
    }
    return false
  }
}

extension MemoizePack: Hashable where repeat each T: Hashable {

  @inlinable
  public func hash(into hasher: inout Hasher) {
    for l in repeat (each rawValue) {
      hasher.combine(l)
    }
  }
}

extension MemoizePack: Sendable where repeat each T: Sendable { }

import RedBlackTreeCollections

public
  struct ___MemoizeCache<each T, Result>
{}

extension ___MemoizeCache {

  public
    final class Standard where repeat each T: Hashable
  {

    @nonobjc
    @inlinable
    @inline(__always)
    public init() {
      self.storage = .init()
    }

    @usableFromInline
    var storage: [MemoizePack<repeat each T>: Result]

    @usableFromInline
    var _hits: Int = 0

    @usableFromInline
    var _miss: Int = 0

    @nonobjc
    @inlinable
    public subscript(
      key: MemoizePack<repeat each T>,
      fallBacking _fallback: (repeat each T) -> Result
    ) -> Result
    {
      @inline(__always)
      get {
        if let result = storage[key] {
          _hits &+= 1
          return result
        }
        _miss &+= 1
        let r = _fallback(repeat each key.rawValue)
        storage[key] = r
        return r
      }
    }

    @inlinable
    public func clear(keepingCapacity keepCapacity: Bool = false) {
      (_hits, _miss) = (0, 0)
      storage.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable
    public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
      (_hits, _miss, nil, storage.count)
    }
  }
}

extension ___MemoizeCache {

  public
    final class LRU where repeat each T: Comparable
  {
    @nonobjc
    @inlinable
    @inline(__always)
    public init(maxCount: Int) {
      self.storage = .init(maxCount: maxCount)
    }

    @usableFromInline
    var storage: ___LRUMemoizeStorage<MemoizePack<repeat each T>, Result>

    @usableFromInline
    var _hits: Int = 0

    @usableFromInline
    var _miss: Int = 0

    @nonobjc
    @inlinable
    public subscript(
      key: MemoizePack<repeat each T>,
      fallBacking _fallback: (repeat each T) -> Result
    ) -> Result
    {
      @inline(__always)
      get {
        if let result = storage[key] {
          _hits &+= 1
          return result
        }
        _miss &+= 1
        let r = _fallback(repeat each key.rawValue)
        storage[key] = r
        return r
      }
    }

    @inlinable
    public func clear(keepingCapacity keepCapacity: Bool = false) {
      (_hits, _miss) = (0, 0)
      storage.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable
    public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
      (_hits, _miss, storage.maxCount, storage.count)
    }
  }
}

extension ___MemoizeCache {

  public
    final actor StandardActor
  where
    repeat each T: Hashable,
    repeat each T: Sendable,
    Result: Sendable
  {

    @nonobjc
    @inlinable
    @inline(__always)
    public init() {
      self.storage = .init()
    }

    @usableFromInline
    var storage: [MemoizePack<repeat each T>: Result]

    @usableFromInline
    var _hits: Int = 0

    @usableFromInline
    var _miss: Int = 0

    @nonobjc
    @inlinable
    public func value(
      for key: MemoizePack<repeat each T>,
      fallBacking _fallback: (repeat each T) async -> Result
    ) async -> Result {
      if let result = storage[key] {
        _hits &+= 1
        return result
      }
      _miss &+= 1
      let r = await _fallback(repeat each key.rawValue)
      storage[key] = r
      return r
    }

    @inlinable
    public func clear(keepingCapacity keepCapacity: Bool = false) {
      (_hits, _miss) = (0, 0)
      storage.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable
    public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
      (_hits, _miss, nil, storage.count)
    }
  }
}

extension ___MemoizeCache {

  public
    final actor LRUActor
  where
    repeat each T: Comparable,
    repeat each T: Sendable,
    Result: Sendable
  {
    @nonobjc
    @inlinable
    @inline(__always)
    public init(maxCount: Int) {
      self.storage = .init(maxCount: maxCount)
    }

    @usableFromInline
    var storage: ___LRUMemoizeStorage<MemoizePack<repeat each T>, Result>

    @usableFromInline
    var _hits: Int = 0

    @usableFromInline
    var _miss: Int = 0

    @nonobjc
    @inlinable
    public func value(
      for key: MemoizePack<repeat each T>,
      fallBacking _fallback: (repeat each T) async -> Result
    ) async -> Result {
      if let result = storage[key] {
        _hits &+= 1
        return result
      }
      _miss &+= 1
      let r = await _fallback(repeat each key.rawValue)
      storage[key] = r
      return r
    }

    @inlinable
    public func clear(keepingCapacity keepCapacity: Bool = false) {
      (_hits, _miss) = (0, 0)
      storage.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable
    public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
      (_hits, _miss, storage.maxCount, storage.count)
    }
  }
}
