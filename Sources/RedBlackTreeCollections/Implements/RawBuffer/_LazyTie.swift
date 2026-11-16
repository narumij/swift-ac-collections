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

// 木の解放を記録するオブジェクト
//
// 解放済みの木への不正なメモリアクセスを予防する
//
@usableFromInline
package final class _LazyTie: ManagedBuffer<Bool, Void> {

  @inlinable
  var isDetached: Bool {
    @inline(__always)
    unsafeAddress {
      UnsafePointer(withUnsafeMutablePointerToHeader { $0 })
    }
    @inline(__always)
    unsafeMutableAddress {
      withUnsafeMutablePointerToHeader { $0 }
    }
  }
}

extension _LazyTie {

  @nonobjc
  @usableFromInline
  internal static func create() -> _LazyTie {
    let storage = _LazyTie.create(minimumCapacity: 0) { managedBuffer in
      return false
    }
    return unsafeDowncast(storage, to: _LazyTie.self)
  }
}

/// The type-punned empty singleton storage instance.
@usableFromInline
nonisolated(unsafe) package let _emptyLazyDetach = _LazyTie.create()

extension _LazyTie {

  @inlinable
  package func release() {
    if self === _emptyLazyDetach {
      return
    }
    isDetached = true
  }
}

/*
 reelase/AtCoder/2025では、インデックス自体にManagerBufferへの参照を持たせていた
 次にManagedBuffer解放時に木のメモリ管理を移動する方式に変わった(_TieWrap)
 その後メモリ管理の移動タイミングに関する工夫がいくつかあり、
 最後に、インデックスの挙動が定まったため、解放済みかどうかだけを確認する方式になった
 */
