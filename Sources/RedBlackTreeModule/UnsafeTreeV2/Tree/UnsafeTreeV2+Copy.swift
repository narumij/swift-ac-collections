// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func copy(minimumCapacity: Int? = nil) -> UnsafeTreeV2 {
    #if false
      // 番号の抜けが発生してるケースがあり、それは再利用プールにノードがいるケース
      // その部分までコピーする必要があり、初期化済み数でのコピーとなる
      let initializedCount = initializedCount

      assert(check())
      let newCapacity = max(minimumCapacity ?? 0, initializedCount)

      // 予定サイズの木を作成する
      let tree = UnsafeTreeV2.___create(minimumCapacity: newCapacity, nullptr: nullptr)

      // freshPool内のfreshBucketは0〜1個となる
      // CoW後の性能維持の為、freshBucket数は1を越えないこと
      // バケット数が1に保たれていると、フォールバックの___raw_indexによるアクセスがO(1)になる
      #if DEBUG
        assert(tree._buffer.header.freshBucketCount <= 1)
      #endif

      #if AC_COLLECTIONS_INTERNAL_CHECKS
        tree.withMutableHeader { $0.copyCount += 1 }
      #endif

      // 空の場合、そのまま返す
      if count == 0 {
        return tree
      }

      let header = _buffer.header

      tree.withMutableHeader { newHeader in
        header._copy(Base.self, to: &newHeader, nullptr: nullptr)
      }

      assert(equiv(with: tree))
      assert(tree.check())

      return tree
    #else
      assert(check())
      let tree = withMutableHeader { header in
        UnsafeTreeV2.create(
          unsafeBufferObject:
            header.copyBuffer(Base.self, minimumCapacity: minimumCapacity))
      }
      assert(count == 0 || initializedCount == tree.initializedCount)
      assert(count == 0 || equiv(with: tree))
      assert(tree.check())
      return tree
    #endif
  }
}

extension UnsafeTreeV2BufferHeader {

  @inlinable
  @inline(__always)
  internal func copyBuffer<Base>(_ t: Base.Type, minimumCapacity: Int? = nil) -> UnsafeTreeV2Buffer
  where Base: ___TreeBase {

    // 番号の抜けが発生してるケースがあり、それは再利用プールにノードがいるケース
    // その部分までコピーする必要があり、初期化済み数でのコピーとなる
    let newCapacity = max(minimumCapacity ?? 0, freshPoolUsedCount)

    // 予定サイズの木を作成する
    let _newBuffer =
      UnsafeTreeV2Buffer
      .create(
        Base._Value.self,
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

      _copy(Base.self, to: &newHeader.pointee, nullptr: nullptr)

      assert(freshPoolUsedCount == newHeader.pointee.freshPoolUsedCount)
    }

    return _newBuffer
  }

  @usableFromInline
  func _copy<Base>(
    _ t: Base.Type, to other: inout UnsafeTreeV2BufferHeader,
    nullptr: UnsafeMutablePointer<UnsafeNode>
  )
  where Base: ___TreeBase {

    typealias _Value = Base._Value
    typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    // プール経由だとループがあるので、それをキャンセルするために先頭のバケットを直接取り出す
    let bucket = other.freshBucketHead!.accessor(_value: MemoryLayout<_Value>._memoryLayout)!

    /// 同一番号の新ノードを取得する内部ユーティリティ
    @inline(__always)
    func __ptr_(_ ptr: _NodePtr) -> _NodePtr {
      let index = ptr.pointee.___raw_index
      return switch index {
      case .nullptr: nullptr
      case .end: other.end_ptr
      default: bucket[index]
      }
    }

    /// ノードを新ノードで再構築する内部ユーティリティ
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
    var nodes = makeFreshPoolIterator() as PopIterator<_Value>

    // ノード番号順に利用歴があるノード全てについて移行作業を行う
    while let s = nodes.next(), let d = other.popFresh() {
      // ノードを初期化する
      d.initialize(to: node(s.pointee))
      // 必要な場合、値を初期化する
      if s.pointee.___needs_deinitialize {
        d.__value_().initialize(to: s.__value_().pointee as _Value)
      }
    }

    // ルートノードを設定
    other.__root = __ptr_(__root)

    // __begin_nodeを初期化
    other.begin_ptr = __ptr_(begin_ptr)

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
