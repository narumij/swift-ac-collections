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

// TODO: ContainerのIndexがComparable必須で確定した場合、_LazyTiedPtrをIndexとすることを検討すること
public typealias _LazyTiedPtr = _LazyTieWrap<_NodePtrSealing>

extension _LazyTieWrap: Equatable where RawValue: Equatable {

  @inlinable
  public static func == (lhs: _LazyTieWrap<RawValue>, rhs: _LazyTieWrap<RawValue>) -> Bool {
    lhs.rawValue == rhs.rawValue && lhs.lazyDetach === rhs.lazyDetach
  }
}

#if DEBUG
  extension _LazyTieWrap: Comparable where RawValue: Comparable {

    // swift-collections 1.7.0でContainerのIndexにComparable要求がある
    // 平衡木だから比較がO(log n)で済むけれど、雑な木や普通のリンクリストだと無理なんじゃないかと
    //
    // 値の利用まで考慮すると、unique系ではO(1)比較が可能。mult系では最悪O(log n)となる。
    //
    @inlinable
    public static func < (lhs: _LazyTieWrap<RawValue>, rhs: _LazyTieWrap<RawValue>) -> Bool {
      if lhs.lazyDetach !== rhs.lazyDetach {
        return lhs.lazyDetach < rhs.lazyDetach
      }
      return lhs.rawValue < rhs.rawValue
    }
  }
#endif

extension _LazyTieWrap: Hashable where RawValue: Hashable {

  @inlinable
  public func hash(into hasher: inout Hasher) {
    rawValue.hash(into: &hasher)
  }
}

extension _LazyTieWrap where RawValue == _NodePtrSealing {

  @inlinable
  package var purified: Result<Self, SealError> {
    rawValue.isUnsealed ? .failure(.unsealed) : .success(self)
  }
}

#if DEBUG
  extension _NodePtrSealing {

    @inlinable
    package func band<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _LazyTieWrappedPtr {
      .success(.init(rawValue: self, lazyDetach: __tree_.lazyDetach))
    }
  }

  extension _NodePtrSealing {

    @inlinable
    package func band<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _LazyTiedPtr {
      .init(rawValue: self, lazyDetach: __tree_.lazyDetach)
    }
  }
#endif
