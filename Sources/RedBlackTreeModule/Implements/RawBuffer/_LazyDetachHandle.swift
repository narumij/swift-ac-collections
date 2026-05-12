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

@frozen
public struct _LazyDetachHandle<RawValue> {

  @usableFromInline
  package let rawValue: RawValue

  @usableFromInline
  package let tied: _LazyDetach

  @inlinable @inline(__always)
  package init(rawValue: RawValue, tie: _LazyDetach) {
    self.rawValue = rawValue
    self.tied = tie
  }
}

extension _LazyDetachHandle {
  public func map<U>(_ transform: (RawValue) throws -> U) rethrows -> _LazyDetachHandle<U> {
    .init(rawValue: try transform(rawValue), tie: tied)
  }
}

extension _LazyDetachHandle: Equatable where RawValue: Equatable {

  @inlinable
  public static func == (lhs: _LazyDetachHandle<RawValue>, rhs: _LazyDetachHandle<RawValue>) -> Bool {
    lhs.rawValue == rhs.rawValue && lhs.tied === rhs.tied
  }
}

extension _LazyDetachHandle where RawValue == _NodePtrSealing {

  @inlinable @inline(__always)
  package var purified: Result<Self, SealError> {
    rawValue.isUnsealed ? .failure(.unsealed) : .success(self)
  }
}

extension _NodePtrSealing {

  @inlinable
  package func band(_ tie: _LazyDetach) -> _LazyDetachPointer {
    isUnsealed ? .failure(.unsealed) : .success(.init(rawValue: self, tie: tie))
  }
}

extension Result where Success == _NodePtrSealing, Failure == SealError {

  @inlinable
  package func band(_ tie: _LazyDetach) -> _LazyDetachPointer {
    flatMap { $0.band(tie) }
  }
}

extension Result where Success == _LazyDetachHandle<_NodePtrSealing>, Failure == SealError {

  @inlinable
  package var tied: _LazyDetach? {
    try? map(\.tied).get()
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
public typealias _LazyDetachPointer = Result<_LazyDetachHandle<_NodePtrSealing>, SealError>

extension Result where Success == _LazyDetachHandle<_NodePtrSealing>, Failure == SealError {

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

  @inlinable @inline(__always)
  package var sealed: _SealedPtr {
    map(\.rawValue)
  }
}

extension Result where Success == _LazyDetachHandle<_NodePtrSealing>, Failure == SealError {

  @inlinable
  package var value: _TrackingTag {
    (try? map(\.rawValue.pointer.trackingTag).get()) ?? .nullptr
  }
}

#if DEBUG
  extension Result where Success == _LazyDetachHandle<_NodePtrSealing>, Failure == SealError {

    package static func unsafe<Base: ___TreeBase>(tree: UnsafeTreeV2<Base>, rawTag: _TrackingTag)
      -> Self
    {
      if rawTag == .nullptr {
        return .failure(.null)
      }

      return tree.__retrieve_(rawTag)
        .flatMap(\.sealed)
        .flatMap { $0.band(tree.lazyDetach) }
    }
  }
#endif
