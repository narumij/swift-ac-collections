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
/// - `find(_:)` : An element equal to the given value
/// - `first(_:)` : The first element in traversal order equal to the given value
/// - `advanced(by:limit:)` : A position offset from the preceding position, with an optional limit
/// - `before` : The previous position
/// - `after` : The next position
@frozen
public struct RedBlackTreeBoundExpression<Key> {

  @inlinable
  init(_internal: Internal) {
    self._internal = _internal
  }

  @usableFromInline
  var _internal: Internal
}

extension RedBlackTreeBoundExpression {

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
  public static func lowerBound(_ k: Key) -> Self {
    .init(_internal: .init(.lowerBound(k)))
  }

  /// Represents the first element that is greater than the given value.
  ///
  /// If no such element exists, it is substituted with the past-the-end element.
  ///
  /// - Complexity: O(log `count`)
  ///   (when evaluated)
  @inlinable
  public static func upperBound(_ k: Key) -> Self {
    .init(_internal: .init(.upperBound(k)))
  }

  /// Represents the element equal to the given value.
  ///
  /// If no such element exists, it is substituted with the past-the-end element.
  ///
  /// - Complexity: O(log `count`)
  ///   (when evaluated)
  @inlinable
  public static func find(_ k: Key) -> Self {
    .init(_internal: .init(.find(k)))
  }

  /// Represents the first element in traversal order whose key equals the given value.
  ///
  /// If no such element exists, it is substituted with the past-the-end element.
  /// In multi collections, this selects the beginning of the equal-key group.
  ///
  /// - Complexity: O(log `count`) when evaluated.
  @inlinable
  public static func first(_ k: Key) -> Self {
    .init(_internal: .init(.first(k)))
  }

  #if DEBUG
    @inlinable
    package static func index(_ p: UnsafeIndexV3) -> Self {
      .init(_internal: .init(.index(p)))
    }

    @inlinable
    package static func debug(_ e: SealError) -> Self {
      .init(_internal: .init(.debug(e)))
    }
  #endif
}

extension RedBlackTreeBoundExpression {

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

// MARK: -

extension RedBlackTreeBoundExpression {

  @usableFromInline
  struct Internal {

    @usableFromInline
    var body: (Op?, Op?, Op?)

    @usableFromInline
    var rest: ContiguousArray<Op>?

    @inlinable
    @inline(__always)
    init(_ first: Op) {
      self.body = (first,nil,nil)
      count = 1
    }

    @usableFromInline
    var count: Int
    
    @inlinable
    @inline(__always)
    var single: Op? { count == 1 ? body.0 : nil }

    @inlinable
    subscript(_ index: Int) -> Op {
      @inline(__always)
      get {
        switch index {
        case 0:
          body.0!
        case 1:
          body.1!
        case 2:
          body.2!
        default:
          rest![index - 3]
        }
      }
    }

    @inlinable
    @inline(__always)
    mutating func append(_ op: Op) {
      switch count {
      case 1:
        body.1 = op
      case 2:
        body.2 = op
      default:
        if rest == nil {
          rest = [op]
        } else {
          rest?.append(op)
        }
      }
      count &+= 1
    }
  }

  @usableFromInline
  enum Op {
    case start
    case last
    case end
    case lowerBound(Key)
    case upperBound(Key)
    case find(Key)
    case first(Key)
    indirect case advanced(offset: Int, limit: Internal? = nil)
    case before
    case after
    #if DEBUG
      // 性能問題が発生したので、デバッグ便利ケース落ち
      case index(UnsafeIndexV3)
      case debug(SealError)
    #endif
  }
}

extension RedBlackTreeBoundExpression.Internal {

  @inlinable
  func evaluate<Base>(_ __tree_: UnsafeTreeV2<Base>)
    -> _SafePtr
  where
    Base: ___TreeBase,
    Base._Key == Key
  {
    if let op = single {
      switch op {
      case .first(let key):
        return __tree_.find_first(key).unchecked
      case .find(let key):
        return __tree_.find(key).unchecked
      case .lowerBound(let key):
        return __tree_.lower_bound(key).unchecked
      case .upperBound(let key):
        return __tree_.upper_bound(key).unchecked
      case .start:
        return __tree_.__begin_node_.unchecked
      case .end:
        return __tree_.__end_node.unchecked
      default:
        break
      }
    }

    return evaluateSlow(__tree_)
  }
  
  @inlinable
  func evaluateSlow<Base>(_ __tree_: UnsafeTreeV2<Base>)
    -> _SafePtr
  where
    Base: ___TreeBase,
    Base._Key == Key
  {
    var ptr = _SafePtr.failure(.null)

    func apply(_ op: RedBlackTreeBoundExpression<Base._Key>.Op) -> _SafePtr? {
      switch op {

      case .start:
        ptr = __tree_.__begin_node_.unchecked

      case .last:
        ptr = __tree_.__begin_node_ == __tree_.__end_node
        ? __tree_.__end_node.unchecked
        : __tree_.___tree_prev_iter(__tree_.__end_node)

      case .end:
        ptr = __tree_.__end_node.unchecked

      case .lowerBound(let __v):
        ptr = __tree_.lower_bound(__v).unchecked

      case .upperBound(let __v):
        ptr = __tree_.upper_bound(__v).unchecked

      case .find(let __v):
        ptr = __tree_.find(__v).unchecked

      case .first(let __v):
        ptr = __tree_.find_first(__v).unchecked

      case .advanced(let offset, let limit):
        switch limit {
        case .none:
          ptr = ptr.flatMap {
            __tree_.___tree_adv_iter($0, offset)
          }

        case .some(let __l):
          ptr = __l.evaluate(__tree_).flatMap { limit in
            let result = ptr.flatMap {
              __tree_.___tree_adv_iter($0, offset, .success(limit))
            }
            return switch result {
            case .failure(.limit): .success(limit)
            default: result
            }
          }
        }

      case .before:
        ptr = ptr.flatMap {
          __tree_.___tree_adv_iter($0, -1)
        }

      case .after:
        ptr = ptr.flatMap {
          __tree_.___tree_adv_iter($0, 1)
        }

      #if DEBUG
        case .index(let i):
        switch __tree_.__purified_(i) {
          case .success(let s):
            ptr = s.pointer.unchecked
          case .failure:
            ptr = .failure(.null)
          }

        case .debug(let e):
          return .failure(e)
      #endif
      }
      return nil
    }
    
    switch count {
    case 1:
      if let failure = apply(body.0!) { return failure }
    case 2:
      if let failure = apply(body.0!) { return failure }
      if let failure = apply(body.1!) { return failure }
    case 3:
      if let failure = apply(body.0!) { return failure }
      if let failure = apply(body.1!) { return failure }
      if let failure = apply(body.2!) { return failure }
    default:
      for i in 0..<count {
        if let failure = apply(self[i]) { return failure }
      }
    }

    return ptr
  }
}
