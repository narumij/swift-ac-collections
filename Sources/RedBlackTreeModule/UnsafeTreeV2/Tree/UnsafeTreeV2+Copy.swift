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

import Foundation

extension UnsafeTreeV2 {

  /// 木のコピーを作成する
  ///
  /// - Parameters:
  ///   - minimumCapacity: 新しいバッファに確保する最小容量。
  ///     - `nil` の場合はコピー元と同じ容量を使用する。
  ///     - 指定された場合は `max(コピー元の容量, minimumCapacity)` が実際の確保サイズとなる。
  @inlinable
  @inline(__always)
  internal func copy(minimumCapacity: Int? = nil) -> UnsafeTreeV2 {
    assert(check())
    let tree = withMutableHeader { header in
      UnsafeTreeV2._create(
        unsafeBufferObject:
          header.copyBuffer(Base._RawValue.self, minimumCapacity: minimumCapacity))
    }
    assert(count == 0 || initializedCount == tree.initializedCount)
    assert(count == 0 || equiv(with: tree))
    assert(tree.check())
    return tree
  }
}

extension UnsafeTreeV2BufferHeader {

  /// 木のコピーを作成する
  ///
  /// - Parameters:
  ///   - minimumCapacity: 新しいバッファに確保する最小容量。
  ///     - `nil` の場合はコピー元と同じ容量を使用する。
  ///     - 指定された場合は `max(コピー元の容量, minimumCapacity)` が実際の確保サイズとなる。
  @inlinable
  //  @inline(never)
  internal func copy<Base>(minimumCapacity: Int? = nil) -> UnsafeTreeV2<Base> {
    UnsafeTreeV2<Base>._create(
      unsafeBufferObject:
        copyBuffer(Base._RawValue.self, minimumCapacity: minimumCapacity))
  }
  
  /// バッファオブジェクトのコピーを作成する。
  ///
  /// - Parameters:
  ///   - t: 木の要素値型（ヘッダは型消去されているため、引数で受け取る）
  ///   - minimumCapacity: 新しいバッファに確保する最小容量。
  ///     - `nil` の場合はコピー元と同じ容量を使用する。
  ///     - 指定された場合は `max(コピー元の容量, minimumCapacity)` が実際の確保サイズとなる。
  @inlinable
  //  @inline(__always)
  internal func copyBuffer<_RawValue>(_ t: _RawValue.Type, minimumCapacity: Int? = nil)
    -> UnsafeTreeV2Buffer
  {

    // 番号の抜けが発生してるケースがあり、それは再利用プールにノードがいるケース
    // その部分までコピーする必要があり、初期化済み数でのコピーとなる
    let newCapacity = max(minimumCapacity ?? 0, freshPoolUsedCount)

    // 予定サイズの木を作成する
    let _newBuffer =
      UnsafeTreeV2Buffer
      .create(
        _RawValue.self,
        minimumCapacity: newCapacity,
        nullptr: nullptr)

    // freshPool内のfreshBucketは0〜1個となる
    // CoW後の性能維持の為、freshBucket数は1を越えないこと
    // バケット数が1に保たれていると、フォールバックの___raw_indexによるアクセスがO(1)になる
    #if DEBUG
      assert(_newBuffer.header.freshBucketCount <= 1)
    #endif

    _newBuffer.withUnsafeMutablePointerToHeader { newHeader in

      #if AC_COLLECTIONS_INTERNAL_CHECKS
        newHeader.pointee.copyCount += 1
      #endif

      // 空の場合、そのまま返す
      if count == 0 {
        return
      }

      copyHeader(_RawValue.self, to: &newHeader.pointee, nullptr: nullptr)

      assert(freshPoolUsedCount == newHeader.pointee.freshPoolUsedCount)
    }

    return _newBuffer
  }

  /// ヘッダの内容を空のヘッダにコピーする。
  ///
  /// - Parameters:
  ///   - t: 木の要素値型（ヘッダは型消去されているため、引数で受け取る）
  ///   - other: コピー先のヘッダ（あらかじめ容量が確保されている必要がある）
  ///   - nullptr: ヌルポインタ （型情報アクセスのオーバーヘッドを避けるため、呼び出し元のものを再利用する）
  @inlinable
  func copyHeader<_RawValue>(
    _ t: _RawValue.Type,
    to other: inout UnsafeTreeV2BufferHeader,
    nullptr: _NodePtr
  ) {

    // プール経由だとループがあるので、それをキャンセルするために先頭のバケットを直接取り出す
    let bucket = other.freshBucketHead!.accessor(_value: MemoryLayout<_RawValue>._memoryLayout)!

    /// 同一番号の新ノードを取得するメソッド内ユーティリティ
    @inline(__always)
    func __ptr_(_ ptr: _NodePtr) -> _NodePtr {
      let index = ptr.pointee.___raw_index
      return switch index {
      case .nullptr: nullptr
      case .end: other.end_ptr
      default: bucket[index]
      }
    }

    /// ノードを新ノードで再構築するメソッド内ユーティリティ
    @inline(__always)
    func node(_ s: borrowing UnsafeNode) -> UnsafeNode {
      // 値は別途管理
      return .init(
        ___raw_index: s.___raw_index,
        __left_: __ptr_(s.__left_),
        __right_: __ptr_(s.__right_),
        __parent_: __ptr_(s.__parent_),
        __is_black_: s.__is_black_,
        ___needs_deinitialize: s.___needs_deinitialize)
    }

    // 旧ノードを列挙する準備
    var usedNodes = makeUsedNodeIterator() as UsedIterator<_RawValue>

    // ノード番号順に利用歴があるノード全てについて移行作業を行う
    while let s = usedNodes.next(), let d = other.popFresh() {
      // ノードを初期化する
      d.initialize(to: node(s.pointee))
      // 必要な場合、値を初期化する
      if s.pointee.___needs_deinitialize {
        d.__value_().initialize(to: s.__value_().pointee as _RawValue)
      }
    }

    // ルートノードを設定
    other.__root = __ptr_(__root)
    assert(__tree_invariant(other.__root))
    
    // __begin_nodeを初期化
    other.begin_ptr.pointee = __ptr_(begin_ptr.pointee)

    // その他管理情報をコピー
    other.recycleHead = __ptr_(recycleHead)
    other.count = count
    other.freshPoolUsedCount = freshPoolUsedCount

    assert(other.freshPoolUsedCount == freshPoolUsedCount)
    assert(other.count == count)

    assert(other.count <= other.freshPoolCapacity)
    assert(other._tied == nil)
  }
}
