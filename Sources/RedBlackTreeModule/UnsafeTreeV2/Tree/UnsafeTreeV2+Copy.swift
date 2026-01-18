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

//  @inlinable
//  @inline(__always)
  @usableFromInline
  internal func copy(minimumCapacity: Int? = nil) -> UnsafeTreeV2 {

    // 番号の抜けが発生してるケースがあり、それは再利用プールにノードがいるケース
    // その部分までコピーする必要があり、初期化済み数でのコピーとなる
    let initializedCount = initializedCount

    assert(check())
    let newCapacity = max(minimumCapacity ?? 0, initializedCount)

    // 予定サイズの木を作成する
    let tree = UnsafeTreeV2.___create(minimumCapacity: newCapacity, nullptr: nullptr)

    // freshPool内のfreshBucketは0〜1個となる
    // CoW後の性能維持の為、freshBucket数は1を越えないこと
    // バケット数が1に保たれていると、フォールバックの___node_idによるアクセスがO(1)になる
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

      // プール経由だとループがあるので、それをキャンセルするために先頭のバケットを直接取り出す
      let bucket = newHeader.freshBucketHead!.accessor(_value: MemoryLayout<_Value>._value)!

      /// 同一番号の新ノードを取得する内部ユーティリティ
      @inline(__always)
      func __ptr_(_ ptr: _NodePtr) -> _NodePtr {
        let index = ptr.pointee.___node_id_
        return switch index {
        case .nullptr: nullptr
        case .end: newHeader.end_ptr
        default: bucket[index]
        }
      }

      /// ノードを新ノードで再構築する内部ユーティリティ
      @inline(__always)
      func node(_ s: borrowing UnsafeNode) -> UnsafeNode {
        // 値は別途管理
        return .init(
          ___node_id_: s.___node_id_,
          __left_: __ptr_(s.__left_),
          __right_: __ptr_(s.__right_),
          __parent_: __ptr_(s.__parent_),
          __is_black_: s.__is_black_,
          ___needs_deinitialize: s.___needs_deinitialize)
      }

      // 旧ノードを列挙する準備
      var nodes = header.makeFreshPoolIterator() as UnsafeTreeV2<Base>.Header.Iterator<_Value>

      // ノード番号順に利用歴があるノード全てについて移行作業を行う
      while let s = nodes.next(), let d = newHeader.popFresh() {
        // ノードを初期化する
        d.initialize(to: node(s.pointee))
        // 必要な場合、値を初期化する
        if s.pointee.___needs_deinitialize {
//          UnsafeNode.initializeValue(d, to: UnsafeNode.value(s) as _Value)
          d.__value_(as: _Value.self).initialize(to: s.__value_().pointee)
        }
      }

      // ルートノードを設定
      newHeader.__root = __ptr_(header.__root)

      // __begin_nodeを初期化
      newHeader.begin_ptr = __ptr_(header.begin_ptr)

      // その他管理情報をコピー
      newHeader.recycleHead = __ptr_(header.recycleHead)
      newHeader.count = header.count
      newHeader.freshPoolUsedCount = header.freshPoolUsedCount

      assert(newHeader.count <= newHeader.freshPoolCapacity)
      assert(newHeader._deallocator == nil)
    }

    assert(equiv(with: tree))
    assert(tree.check())

    return tree
  }
}
