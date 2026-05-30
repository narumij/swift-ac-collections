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

/// （遅延）結束バンド
@frozen
public struct _LazyTieWrap<RawValue> {

  @usableFromInline
  package let rawValue: RawValue
  
  @usableFromInline
  package let lazyDetach: _LazyTie

  @inlinable
  package init(rawValue: RawValue, lazyDetach: _LazyTie) {
    self.rawValue = rawValue
    self.lazyDetach = lazyDetach
  }
}

extension _LazyTieWrap: Equatable where RawValue: Equatable {

  @inlinable
  public static func == (lhs: _LazyTieWrap<RawValue>, rhs: _LazyTieWrap<RawValue>) -> Bool
  {
    lhs.rawValue == rhs.rawValue && lhs.lazyDetach === rhs.lazyDetach
  }
}

extension _LazyTieWrap where RawValue == _NodePtrSealing {

  @inlinable
  package var purified: Result<Self, SealError> {
    rawValue.isUnsealed ? .failure(.unsealed) : .success(self)
  }
}

extension _NodePtrSealing {

  // 某バンドオマージュ

  @inlinable
  package func band<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _LazyTieWrappedPtr {
    isUnsealed ? .failure(.unsealed) : .success(.init(rawValue: self, lazyDetach: __tree_.lazyDetach))
  }
}

extension Result where Success == _NodePtrSealing, Failure == SealError {

  // 某バンドオマージュ
  @inlinable
  package func band<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _LazyTieWrappedPtr {
    flatMap { $0.band(__tree_) }
  }
}

extension Result where Success == _LazyTieWrap<_NodePtrSealing>, Failure == SealError {

  @inlinable
  package var lazyDetach: _LazyTie? {
    try? map(\.lazyDetach).get()
  }

  @inlinable
  func __isSameLazyDetach(_ rhs: _LazyTie?) -> Bool {
    switch self {
    case .success(let handle):
      handle.lazyDetach === rhs
    case .failure:
      false
    }
  }
}

// MARK: -

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
  @inline(__always)
  static func unchecked(_ _p: _NodePtr, end_ptr: _NodePtr, lazyDetach: _LazyTie) -> Self {
    .success(.init(rawValue: .init(_p: _p), lazyDetach: lazyDetach))
  }
  
  /// ポインタを利用する際に用いる
  @inlinable
  package var purified: Result { flatMap { $0.purified } }

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
}

extension Result where Success == _LazyTieWrap<_NodePtrSealing>, Failure == SealError {

  @inlinable
  package var value: _TrackingTag {
    (try? map(\.rawValue.pointer.trackingTag).get()) ?? .nullptr
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
