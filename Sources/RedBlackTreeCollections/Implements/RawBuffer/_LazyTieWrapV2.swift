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

// （遅延）結束バンド
@frozen
public struct _LazyTieWrapV2 {
  
  @usableFromInline
  package typealias RawValue = _NodePtrSealing

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

public typealias _LazyTiedPtrV2 = _LazyTieWrapV2

extension _LazyTieWrapV2: Equatable {

  @inlinable
  public static func == (lhs: _LazyTieWrapV2, rhs: _LazyTieWrapV2) -> Bool {
    lhs.rawValue == rhs.rawValue && lhs.lazyDetach === rhs.lazyDetach
  }
}

extension _LazyTieWrapV2: Hashable {

  @inlinable
  public func hash(into hasher: inout Hasher) { rawValue.hash(into: &hasher) }
}

extension _LazyTieWrapV2 {

  @inlinable
  package var purified: Result<Self, SealError> {
    rawValue.isUnsealed ? .failure(.unsealed) : .success(self)
  }
}

extension _LazyTieWrapV2 {

  @usableFromInline
  package typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  static func unchecked(
    _ _p: _NodePtr,
    end_ptr: _NodePtr,
    lazyDetach: _LazyTie
  ) -> Self { .init(rawValue: .init(_p: _p), lazyDetach: lazyDetach) }

  @inlinable
  package var sealed: _SealedPtr { rawValue.purified }

  @usableFromInline
  package var isValid: Bool {
    switch purified {
    case .success: true
    default: false
    }
  }

  @inlinable
  package var tag: _SealedTag {
    rawValue.trackingTag == .nullptr ? .failure(.null) : rawValue.tag
  }
}

#if DEBUG
extension _NodePtrSealing {

  @inlinable
  package func band<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _LazyTiedPtrV2 {
    .init(rawValue: self, lazyDetach: __tree_.lazyDetach)
  }
}
#endif

#if DEBUG
extension _LazyTieWrapV2 {
  @usableFromInline
  static var nullptr: Self {
    .init(rawValue: .init(unsafe: .nullptr), lazyDetach: _emptyLazyDetach)
  }
}
#endif

extension _LazyTieWrapV2 {
  
  @inlinable
  var isBlessed: Bool {
    rawValue.pointer.pointee.___has_payload_content
  }
}
