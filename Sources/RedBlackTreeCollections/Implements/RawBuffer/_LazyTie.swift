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

// そもそもバッファの寿命園著自体がもう不要な気がした
// -> 変な使い方しない限りオーバーヘッドに差が無いので、実験はしたが採用しなかった

// 従来の結束バンドは、IndexやIteratorを作るたびにバッファの準備が始まっていて、必ず生成コストが生じていた
// 行儀良く使う場合、寿命保証も解放遅延も必要ないので無駄なコストになっていた
// これを生成コストが軽量な代理オブジェクトを挟み、寿命保証を本体解放まで遅延することで、生成コストを抑制する方式
// 行儀悪く使う場合のコストは増すが、そういう使い方は主たるユースケースではないので、気にしないことにした

@usableFromInline
package final class _LazyTie: ManagedBuffer<_TiedRawBuffer?, Void> {

  @inlinable
  var buffer: _TiedRawBuffer? {
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
      return nil
    }
    return unsafeDowncast(storage, to: _LazyTie.self)
  }
}

/// The type-punned empty singleton storage instance.
@usableFromInline
nonisolated(unsafe) package let _emptyLazyDetach = _LazyTie.create()
