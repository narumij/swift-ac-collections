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

public typealias _TieWrappedPtr = Result<_TieWrap<_NodePtrSealing>, SealError>

public typealias UnsafeIndexV3 = _TieWrappedPtr

extension Result where Success == _TieWrap<_NodePtrSealing>, Failure == SealError {

  /// ポインタを利用する際に用いる
  @inlinable @inline(__always)
  var purified: Result { flatMap { $0.purified } }

  @inlinable
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

extension Result where Success == _TieWrap<_NodePtrSealing>, Failure == SealError {

  @usableFromInline
  package var value: _TrackingTag? { try? map(\.rawValue.tag.value).get() }
}

#if DEBUG
  extension Result where Success == _TieWrap<_NodePtrSealing>, Failure == SealError {

    internal static func unsafe<Base: ___TreeBase>(tree: UnsafeTreeV2<Base>, rawTag: _TrackingTag)
      -> Self
    {
      if rawTag == .nullptr {
        return .failure(.null)
      }
      return tree[__retrieve_: rawTag].flatMap(\.sealed).flatMap { $0.band(tree.tied) }
    }
  }
#endif
