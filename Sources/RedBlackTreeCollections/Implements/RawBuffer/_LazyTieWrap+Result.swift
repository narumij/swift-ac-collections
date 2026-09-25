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

/// 外部に出す場合、あるいは木が常に一致するとは限らない場合に使うポインタ
///
/// `_LazyDetachPointer`は、`_SealedPtr`に解放時メモリ延長を付与したもの
///
/// `_TieWrappedPtr`は`_SealedPtr`にメモリ寿命を付与したもの
///
/// `_NodePtr`は内部用の最速
///
/// `_SealedPtr`は外部での変更リスクがある場合に使う
///
public typealias _LazyTieWrappedPtr = Result<_LazyTieWrap<_NodePtrSealing>, SealError>

extension Result where Success == _LazyTieWrap<_NodePtrSealing>, Failure == SealError {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.success(let lhs), .success(let rhs)):
      return lhs == rhs
    case (.failure(let lhs), .failure(let rhs)):
      return lhs == rhs
    default:
      return false
    }
  }

  @inlinable
  public static func != (lhs: Self, rhs: Self) -> Bool {
    !(lhs == rhs)
  }
}

extension Result where Success == _LazyTieWrap<_NodePtrSealing>, Failure == SealError {

  @inlinable
  @inline(__always)
  static func unchecked(_ _p: _NodePtr, end_ptr: _NodePtr, lazyDetach: _LazyTie) -> Self {
    .success(.init(rawValue: .init(_p: _p), lazyDetach: lazyDetach))
  }

  /// ポインタを利用する際に用いる
  #if USE_LAZY_DETACH
    @inlinable
    package var purified: Result { flatMap { $0.purified } }
  #else
    @inlinable
    package var purified: Result {
      flatMap { $0.lazyDetach.isDetached ? .failure(.detached) : $0.purified }
    }
  #endif

  @usableFromInline
  package var isValid: Bool {
    switch purified {
    case .success: true
    default: false
    }
  }

  @inlinable
  package var sealed: _SealedPtr {
    map(\.rawValue)
  }
  
  @inlinable
  package var safe: _SafePtr {
    map(\.rawValue.pointer)
  }
}

#if DEBUG
  extension Result where Success == _LazyTieWrap<_NodePtrSealing>, Failure == SealError {

    package static func unsafe<Base: ___TreeBase>(tree: UnsafeTreeV2<Base>, rawTag: _TrackingTag)
      -> Self
    {
      if rawTag == .nullptr {
        return .failure(.null)
      }

      return tree.__retrieve_(rawTag)
        .flatMap(\.uncheckedSeal)
        .flatMap { $0.band(tree) }
    }
  }
#endif

#if DEBUG
  // TODO: ContainerのIndexがComparable必須で確定した場合、_LazyTiedPtrをIndexとすることを検討すること
  extension Result: @retroactive Comparable
  where Success: Comparable, Failure: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.failure(let l), .failure(let r)):
        return l < r
      case (.failure, .success):
        return true
      case (.success, .failure):
        return false
      case (.success(let l), .success(let r)):
        return l < r
      }
    }
  }
#endif
