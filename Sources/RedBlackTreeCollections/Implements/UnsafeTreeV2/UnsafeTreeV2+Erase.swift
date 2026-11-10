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

extension UnsafeTreeV2 {

  @inlinable
  mutating func ___erase_with_many_care(_ __p: _NodePtr) -> _NodePtr {
    var __p = __p
    let __e = __end_node
    ensureUnique()
    if __e != __end_node {
      __p = __simple_retrieve(__p)
    }
    return erase(__p)
  }
}

#if COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2 {

    @inlinable
    @discardableResult
    func ___erase_range(_ __first: _NodePtr, _ __last: _NodePtr) -> _NodePtr {

      var __first = __first
      while __first != __last {
        guard __first.___has_payload_content else {
          fatalError(.outOfBounds)  // エラー種別がしっくりこない
        }
        __first = erase(__first)
      }
      return __last
    }
  }
#endif

// MARK: -

extension UnsafeTreeV2 {

  @inlinable
  @discardableResult
  func ___erase_range(_ __first: _NodePtr, _ __last: _NodePtr) -> _SafePtr {

    var __first = __first
    while __first != __last {
      guard __first.___has_payload_content else {
        return .failure(.other)
      }
      __first = erase(__first)
    }
    return .success(__last)
  }

  @inlinable
  @discardableResult
  func ___erase_range_if(
    _ __first: _SafePtr,
    _ __last: _SafePtr,
    _ shouldBeRemoved: (_PayloadValue) throws -> Bool
  ) rethrows -> _SafePtr {

    var __first = __first
    while __first != __last {
      guard __first.___has_payload_content else {
        return .failure(.other)
      }
      if try shouldBeRemoved(__value_(__first.pointer!)) {
        __first = erase(__first.accessible.pointer!).unchecked
      } else {
        __first = ___tree_next_iter(__first.accessible.pointer!)
      }
    }
    return __last
  }

  @inlinable
  @discardableResult
  func ___erase_view_range_if(
    _ __first: inout _SafePtr,
    _ __last: _SafePtr,
    _ shouldBeRemoved: (_PayloadValue) throws -> Bool
  ) rethrows -> _SafePtr {
    var current = __first
    while current != __last {
      guard current.___has_payload_content else {
        return .failure(.other)
      }
      if try shouldBeRemoved(__value_(current.pointer!)) {
        let next = erase(current.accessible.pointer!).unchecked
        if current == __first { __first = next }
        current = next
      } else {
        current = ___tree_next_iter(current.accessible.pointer!)
      }
    }
    return __last
  }

}

extension UnsafeTreeV2 {

  @inlinable
  @discardableResult
  mutating func ___erase_view_range_if_with_many_care(
    _ __first: inout _SafePtr,
    _ __last: inout _SafePtr,
    _ shouldBeRemoved: (_PayloadValue) throws -> Bool
  ) rethrows -> _SafePtr {

    var current = __first
    while current != __last {
      guard current.___has_payload_content else {
        return .failure(.other)
      }
      if try shouldBeRemoved(__value_(current.pointer!)) {
        break
      }
      current = ___tree_next_iter(current.accessible.pointer!)
    }
    guard current != __last else {
      return __last
    }
    let __e = __end_node
    ensureUnique()
    if __e != __end_node {
      __first = __simple_retrieve(__first.pointer!).unchecked
      __last = __simple_retrieve(__last.pointer!).unchecked
      current = __simple_retrieve(current.pointer!).unchecked
    }
    let next = erase(current.accessible.pointer!).unchecked
    if current == __first {
      __first = next
      return try ___erase_view_range_if(&__first, __last, shouldBeRemoved)
    }
    return try ___erase_range_if(next, __last, shouldBeRemoved)
  }
}

extension UnsafeTreeV2 where Base: _BaseNode_PtrCompInterface {

  @inlinable
  mutating func ___erase_range_with_many_care(_range range: _SafeRange) throws -> _NodePtr {
      var __r = try range.get()
      if __r.isEmpty {
        return __r.upperBound
      }
      let __e = __end_node
      if count > 0 {
        ensureUnique()
      }
      if __e != __end_node {
        __r = __simple_retrieve(__r)
      }
      guard isValid(range: __r) else {
        throw SealError.unknown
      }
      assert(count == 0 || isUnique())
      return try ___erase_range(__r.lowerBound, __r.upperBound).get()
  }
  
  @inlinable
  mutating func ___erase_sanitize_range_with_many_care(_range range: _SafeRange) -> _NodePtr? {
    guard var __r = try? sanitize(range).get() else {
      return nil
    }
    if __r.isEmpty {
      return __r.upperBound
    }
    let __e = __end_node
    if count > 0 {
      ensureUnique()
    }
    if __e != __end_node {
      __r = __simple_retrieve(__r)
    }
    assert(count == 0 || isUnique())
    return try? ___erase_range(__r.lowerBound, __r.upperBound).get()
  }

  @inlinable
  @discardableResult
  mutating func ___erase_range_if_with_many_care(
    _ __first: _SafePtr,
    _ __last: _SafePtr,
    _ shouldBeRemoved: (_PayloadValue) throws -> Bool
  ) rethrows -> _SafePtr {

    var __first = __first
    var __last = __last
    while __first != __last {
      guard __first.___has_payload_content else {
        return .failure(.other)
      }
      if try shouldBeRemoved(__value_(__first.pointer!)) {
        break
      }
      __first = ___tree_next_iter(__first.accessible.pointer!)
    }
    guard __first != __last else {
      return __last
    }
    let __e = __end_node
    ensureUnique()
    if __e != __end_node {
      __first = __simple_retrieve(__first.pointer!).unchecked
      __last = __simple_retrieve(__last.pointer!).unchecked
    }
    __first = erase(__first.accessible.pointer!).unchecked
    // 2個目以降の削除は短縮処理で行う
    return try ___erase_range_if(__first, __last, shouldBeRemoved)
  }

  @inlinable
  @discardableResult
  mutating func ___erase_validate_range_if_with_many_care(
    _ range: _SafeRange,
    _ shouldBeRemoved: (_PayloadValue) throws -> Bool
  ) rethrows -> _SafePtr {

    try range
      .flatMap(validated(range:))
      .flatMapThrowing { range in
        try ___erase_range_if_with_many_care(
          range.lowerBound.unchecked, range.upperBound.unchecked, shouldBeRemoved)
      }
  }

  @inlinable
  @discardableResult
  mutating func ___erase_sanitize_range_if_with_many_care(
    _ range: _SafeRange,
    _ shouldBeRemoved: (_PayloadValue) throws -> Bool
  ) rethrows -> _SafePtr {

    try sanitize(range)
      .flatMapThrowing { range in
        try ___erase_range_if_with_many_care(
          range.lowerBound.unchecked, range.upperBound.unchecked, shouldBeRemoved)
      }
  }
}

#if false && COMPATIBLE_ATCODER_2025 // falseで構わないが、取り急ぎなので念のため
extension UnsafeTreeV2 where Base: _BaseNode_PtrCompInterface {

  @inlinable
  func ___erase_validate_range(_ range: _SafeRange) -> Result<UnsafeIndexV3, SealError> {
    range
      .flatMap(validated(range:))
      .flatMap {
        $0.fold(___erase_range)
      }
      .map(index)
  }
  
  @inlinable
  func ___erase_sanitize_range(_ range: _SafeRange) -> Result<UnsafeIndexV3, SealError> {
    sanitize(range)
      .flatMap {
        $0.fold(___erase_range)
      }
      .map(index)
  }

  @inlinable
  func ___erase_validate_range_if(
    _ range: _SafeRange,
    _ shouldBeRemoved: (_PayloadValue) throws -> Bool
  ) rethrows -> Result<UnsafeIndexV3, SealError> {

    try range
      .flatMap(validated(range:))
      .flatMapThrowing { range in
        try range.fold { first, last in
          try ___erase_range_if(first.unchecked, last.unchecked, shouldBeRemoved)
        }
      }
      .map(index)
  }
  
  @inlinable
  func ___erase_sanitize_range_if(
    _ range: _SafeRange,
    _ shouldBeRemoved: (_PayloadValue) throws -> Bool
  ) rethrows -> Result<UnsafeIndexV3, SealError> {

    try sanitize(range)
      .flatMapThrowing { range in
        try range.fold { first, last in
          try ___erase_range_if(first.unchecked, last.unchecked, shouldBeRemoved)
        }
      }
      .map(index)
  }
}
#endif

// TODO: 以下を別ファイルに切り出す
extension Result {

  @inlinable
  func flatMapThrowing<T>(
    _ transform: (Success) throws -> Result<T, Failure>
  ) rethrows -> Result<T, Failure> {
    switch self {
    case .success(let value):
      return try transform(value)
    case .failure(let error):
      return .failure(error)
    }
  }
}
