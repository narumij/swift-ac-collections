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

// 外部に出す場合、あるいは木が常に一致するとは限らない場合に使うポインタ
//
// `_LazyDetachPointer`は、`_SealedPtr`に解放時メモリ延長を付与したもの
//
// `_TieWrappedPtr`は`_SealedPtr`にメモリ寿命を付与したもの
//
// `_NodePtr`は内部用の最速
//
// `_SealedPtr`は外部での変更リスクがある場合に使う
//
public typealias _LazyTieWrappedPtr = Result<_LazyTieWrap<_NodePtrSealing>, SealError>

extension Result where Success == _LazyTieWrap<_NodePtrSealing>, Failure == SealError {

  @inlinable
  @inline(__always)
  static func unchecked(_ _p: _NodePtr, end_ptr: _NodePtr, lazyDetach: _LazyTie) -> Self {
    .success(.init(rawValue: .init(_p: _p), lazyDetach: lazyDetach))
  }
}

#if DEBUG
  extension _LazyTieWrap where RawValue == _NodePtrSealing {
    
    package static func unsafe<Base: ___TreeBase>(tree: UnsafeTreeV2<Base>, rawTag: _TrackingTag)
      -> Self
    {
      if rawTag == .nullptr {
        return .nullptr
      }

      return (try? tree.__retrieve_(rawTag)
        .flatMap(\.uncheckedSeal)
        .flatMap { $0.band(tree) }
        .get())
      ?? .nullptr
    }
  }
#endif
