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
  typealias Internal = [Op]

  @usableFromInline
  enum Op {
    case pointer(_SafePtr)
    case start
    case last
    case end
    case lowerBound(_Key)
    case upperBound(_Key)
    case find(_Key)
    case advanced(offset: Int, limit: Internal? = nil)
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

  @inlinable
  public static var start: Self {
    .init(_internal: [.start])
  }

  @inlinable
  public static var last: Self {
    .init(_internal: [.last])
  }

  @inlinable
  public static var end: Self {
    .init(_internal: [.end])
  }

  @inlinable
  public static func lowerBound(_ k: _Key) -> Self {
    .init(_internal: [.lowerBound(k)])
  }

  @inlinable
  public static func upperBound(_ k: _Key) -> Self {
    .init(_internal: [.upperBound(k)])
  }

  @inlinable
  public static func find(_ k: _Key) -> Self {
    .init(_internal: [.find(k)])
  }

  @inlinable
  public static func lessThan(_ k: _Key) -> Self {
    .init(_internal: [.lessThan(k)])
  }

  @inlinable
  public static func greaterThan(_ k: _Key) -> Self {
    .init(_internal: [.greaterThan(k)])
  }

  @inlinable
  public static func lessThanOrEqual(_ k: _Key) -> Self {
    .init(_internal: [.lessThanOrEqual(k)])
  }

  @inlinable
  public static func greaterThanOrEqual(_ k: _Key) -> Self {
    .init(_internal: [.greaterThanOrEqual(k)])
  }

  #if DEBUG
    @inlinable
    public static func debug(_ e: SealError) -> Self {
      .init(_internal: [.debug(e)])
    }
  #endif
}

extension RedBlackTreeBoundExpressionV2 {

  @inlinable
  public var before: Self {
    var result = self
    result._internal.append(.before)
    return result
  }

  @inlinable
  public var after: Self {
    var result = self
    result._internal.append(.after)
    return result
  }

  @inlinable
  public func advanced(by offset: Int, limit: Self? = nil) -> Self {
    var result = self
    result._internal.append(.advanced(offset: offset, limit: limit?._internal))
    return result
  }
}
