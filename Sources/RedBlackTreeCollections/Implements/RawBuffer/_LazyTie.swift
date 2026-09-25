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

// ↑ 直前の1行が何を書いてるのかよくわからない

// _LazyTieはもともとIndexの生成を軽くする工夫の一つとして生まれた
// コンテナ本体の解放時まで生バッファのバインドを遅延し、その後バッファの寿命を保証する
// インデックスで生バッファを触る必要がある互換版とことなり、現行版では生バッファのバインドは不要になっている
// ポインタの有効性を検証する必要は引き続き残っていて、その判定に用いる事もできる
// 実際には、_LazyTie同士の同値比較で本体木の判定が可能で、その時点でcross tree判定となり、
// そこまでの判定は必要なかったので、ManagedBuffer<Bool, Void>ではなく、ManagedBuffer<Void, Void>でも足りる
// allow cross treeの場合、生バッファ寿命延長は必須なので、軽量_LazyTieは使えない

// 異なる木同士のインデックスは非互換
// コピーされた場合のインデックスは非互換
// CoW発生時のインデックス互換はなるべく保証したい

#if USE_LAZY_DETACH
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
#else
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
#endif

extension _LazyTie {

  @inlinable
  package static func < (lhs: _LazyTie, rhs: _LazyTie) -> Bool {
    ObjectIdentifier(lhs) < ObjectIdentifier(rhs)
  }
}

extension _LazyTie {

  @nonobjc
  @usableFromInline
  internal static func create() -> _LazyTie {
    #if USE_LAZY_DETACH
      let storage = _LazyTie.create(minimumCapacity: 0) { managedBuffer in
        return nil
      }
    #else
      let storage = _LazyTie.create(minimumCapacity: 0) { managedBuffer in
        return false
      }
    #endif
    return unsafeDowncast(storage, to: _LazyTie.self)
  }
}

/// The type-punned empty singleton storage instance.
@usableFromInline
nonisolated(unsafe) package let _emptyLazyDetach = _LazyTie.create()

// MARK: -

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
