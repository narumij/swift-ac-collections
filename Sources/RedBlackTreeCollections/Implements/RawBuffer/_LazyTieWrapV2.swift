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
  public typealias RawValue = _NodePtrSealing

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

// TODO: ContainerのIndexがComparable必須で確定した場合、_LazyTiedPtrをIndexとすることを検討すること
public typealias _LazyTiedPtrV2 = _LazyTieWrapV2

extension _LazyTieWrapV2: Equatable {

  @inlinable
  public static func == (lhs: _LazyTieWrapV2, rhs: _LazyTieWrapV2) -> Bool {
    lhs.rawValue == rhs.rawValue && lhs.lazyDetach === rhs.lazyDetach
  }
}

#if DEBUG
extension _LazyTieWrapV2: Comparable {

  // swift-collections 1.7.0でContainerのIndexにComparable要求がある
  // 平衡木だから比較がO(log n)で済むけれど、雑な木や普通のリンクリストだと無理なんじゃないかと
  //
  // 値の利用まで考慮すると、unique系ではO(1)比較が可能。mult系では最悪O(log n)となる。
  //
  @inlinable
  public static func < (lhs: _LazyTieWrapV2, rhs: _LazyTieWrapV2) -> Bool {
    if lhs.lazyDetach !== rhs.lazyDetach {
      return lhs.lazyDetach < rhs.lazyDetach
    }
    #if !USE_LAZY_DETACH
      // 通常構成ではIndexがノードの寿命を延長しない。
      // 同じ発行元の比較で生ポインタをたどる前に、寿命を確認する。
      precondition(!lhs.lazyDetach.isDetached, .invalidIndex)
    #endif
    return lhs.rawValue < rhs.rawValue
  }
}
#endif

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

  #if USE_RECYCLE_COUNT_OVERWRAP
  @inlinable
  func __isSameLazyDetach(_ rhs: _LazyTie?) -> Bool { lazyDetach === rhs }
  #else
  // TODO: 名前変更の検討
  // 実際にはそのポインタの直接利用可否となっている
  @inlinable
  func __isSameLazyDetach(_ rhs: _LazyTie?) -> Bool {
    lazyDetach === rhs && rawValue.pointer.pointee.___recycle_count < .max
  }
  #endif

  // treeを経由しない封印のみの判定。発行元基準での有効性確認としてテストが使う
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
