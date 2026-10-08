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

  // 末尾チェック付きの削除ループ
  //
  // 対応する末尾チェック無しは`__tree`のerase(_:_:)となる
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

  // 末尾チェック付きの削除ループ
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
}

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
