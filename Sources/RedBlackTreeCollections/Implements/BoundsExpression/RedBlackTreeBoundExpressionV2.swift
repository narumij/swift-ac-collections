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

/// An internal DSL that represents an element position.
///
/// It is evaluated when each API is used, replaced with the corresponding element, and then the operation is performed.
/// How “past-the-end” and failures are handled depends on the API.
///
/// ---
///
/// ## Cases
///
/// - `start` : The first element
/// - `last` : The last element
/// - `end` : The past-the-end element
/// - `lowerBound(_:)` : The first element that is not less than the given value
/// - `upperBound(_:)` : The first element that is greater than the given value
/// - `find(_:)` : The element equal to the given value
/// - `advanced(_:offset:limit:)` : The element advanced by `offset` from a base position
/// - `before(_:)` : The previous element
/// - `after(_:)` : The next element
@frozen
public struct RedBlackTreeBoundExpressionV2<_Key> {

  @inlinable
  init(_internal: Internal) {
    self._internal = _internal
  }

  @usableFromInline
  var _internal: Internal
}

extension RedBlackTreeBoundExpressionV2 {

  @usableFromInline
  struct Internal {

    @usableFromInline
    var first: Op

    // 2個目以降だけを保持する。
    // 1要素式では空Arrayなのでヒープ確保なし。
    @usableFromInline
    var rest: [Op]

    @inlinable
    init(_ first: Op) {
      self.first = first
      self.rest = []
    }

    @inlinable
    var count: Int {
      1 + rest.count
    }

    @inlinable
    subscript(_ index: Int) -> Op {
      _read {
        if index == 0 {
          yield first
        } else {
          yield rest[index - 1]
        }
      }
    }

    @inlinable
    mutating func append(_ op: Op) {
      rest.append(op)
    }
  }

  @usableFromInline
  enum Op {
    case index(UnsafeIndexV3)
    case start
    case last
    case end
    case lowerBound(_Key)
    case upperBound(_Key)
    case find(_Key)
    indirect case advanced(offset: Int, limit: Internal? = nil)
    case before
    case after
    case lessThan(_Key)
    case greaterThan(_Key)
    case lessThanOrEqual(_Key)
    case greaterThanOrEqual(_Key)
    #if DEBUG
      case debug(SealError)
    #endif
  }
}
extension RedBlackTreeBoundExpressionV2 {

  /// Represents the first element.
  ///
  /// If no such element exists, it is substituted with the past-the-end element.
  ///
  /// - Complexity: O(1)
  ///   (when evaluated)
  @inlinable
  public static var start: Self {
    .init(_internal: .init(.start))
  }

  /// Represents the last element.
  ///
  /// If no such element exists, it is substituted with the past-the-end element.
  ///
  /// - Complexity: O(log `count`)
  ///   (when evaluated)
  @inlinable
  public static var last: Self {
    .init(_internal: .init(.last))
  }

  /// Represents the past-the-end element.
  ///
  /// - Complexity: O(1)
  ///   (when evaluated)
  @inlinable
  public static var end: Self {
    .init(_internal: .init(.end))
  }

  /// Represents the first element that is not less than the given value.
  ///
  /// If no such element exists, it is substituted with the past-the-end element.
  ///
  /// - Complexity: O(log `count`)
  ///   (when evaluated)
  @inlinable
  public static func lowerBound(_ k: _Key) -> Self {
    .init(_internal: .init(.lowerBound(k)))
  }

  /// Represents the first element that is greater than the given value.
  ///
  /// If no such element exists, it is substituted with the past-the-end element.
  ///
  /// - Complexity: O(log `count`)
  ///   (when evaluated)
  @inlinable
  public static func upperBound(_ k: _Key) -> Self {
    .init(_internal: .init(.upperBound(k)))
  }

  /// Represents the element equal to the given value.
  ///
  /// If no such element exists, it is substituted with the past-the-end element.
  ///
  /// - Complexity: O(log `count`)
  ///   (when evaluated)
  @inlinable
  public static func find(_ k: _Key) -> Self {
    .init(_internal: .init(.find(k)))
  }

  /// Represents the greatest element that is less than the given value.
  @inlinable
  public static func lessThan(_ k: _Key) -> Self {
    .init(_internal: .init(.lessThan(k)))
  }

  /// Represents the smallest element that is greater than the given value.
  @inlinable
  public static func greaterThan(_ k: _Key) -> Self {
    .init(_internal: .init(.greaterThan(k)))
  }

  /// Represents the greatest element that is less than or equal to the given value.
  @inlinable
  public static func lessThanOrEqual(_ k: _Key) -> Self {
    .init(_internal: .init(.lessThanOrEqual(k)))
  }

  /// Represents the smallest element that is greater than or equal to the given value.
  @inlinable
  public static func greaterThanOrEqual(_ k: _Key) -> Self {
    .init(_internal: .init(.greaterThanOrEqual(k)))
  }

  @inlinable
  public static func index(_ p: UnsafeIndexV3) -> Self {
    .init(_internal: .init(.index(p)))
  }

  #if DEBUG
    @inlinable
    public static func index(_ p: _LazyTieWrappedPtr) -> Self {
      .init(_internal: .init(.index((try? p.get()) ?? .nullptr)))
    }

    @inlinable
    public static func debug(_ e: SealError) -> Self {
      .init(_internal: .init(.debug(e)))
    }
  #endif
}

extension RedBlackTreeBoundExpressionV2 {

  /// Returns the previous element.
  ///
  /// Fails if it goes past the start or past-the-end.
  ///
  /// - Complexity: O(1)
  ///   (when evaluated)
  @inlinable
  public var before: Self {
    var result = self
    result._internal.append(.before)
    return result
  }

  /// Returns the next element.
  ///
  /// Fails if it goes past the start or past-the-end.
  ///
  /// - Complexity: O(1)
  ///   (when evaluated)
  @inlinable
  public var after: Self {
    var result = self
    result._internal.append(.after)
    return result
  }

  /// Returns the element advanced by `offset`.
  ///
  /// Fails if it goes past the start or past-the-end.
  ///
  /// - Complexity: O(`offset`)
  ///   (when evaluated)
  @inlinable
  public func advanced(by offset: Int, limit: Self? = nil) -> Self {
    var result = self
    result._internal.append(.advanced(offset: offset, limit: limit?._internal))
    return result
  }
}
