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

// TODO: テスト整備後internalにする
@_fixed_layout
public final class UnsafeTreeBuffer<_Value>:
  ManagedBuffer<UnsafeTreeBuffer<_Value>.Header, UnsafeNode>
{
  // MARK: - 解放処理
  @inlinable
  @inline(__always)
  deinit {
    withUnsafeMutablePointers { header, end in
      header.pointee.___disposeFreshPool()
      end.deinitialize(count: 1)
    }
  }
}

// MARK: - 生成

extension UnsafeTreeBuffer {

  @nonobjc
  @inlinable
  @inline(__always)
  internal static func create(
    minimumCapacity nodeCapacity: Int
  ) -> UnsafeTreeBuffer {

    // elementsはendにしか用いないのでManagerdBufferの要素数は常に1
    
    let storage = UnsafeTreeBuffer.create(minimumCapacity: 1) { managedBuffer in
      return managedBuffer.withUnsafeMutablePointerToElements { _end_ptr in
        
        let _nullptr = ___slow_shared_unsafe_null_pointer
        
        // endノード用に初期化する
        _end_ptr.initialize(
          to: UnsafeNode(___node_id_: .end, _nullpotr: _nullptr))
        // ヘッダーを準備する
        var header = Header(_nullptr: _nullptr, _end_ptr: _end_ptr)
        // ノードを確保する
        if nodeCapacity > 0 {
          header.pushFreshBucket(capacity: nodeCapacity)
        }
        assert(_end_ptr.pointee.___needs_deinitialize == true)
        // ヘッダを返却して以後はManagerBufferさんがよしなにする
        return header
      }
    }

    assert(nodeCapacity == storage.header.freshPoolCapacity)
    return unsafeDowncast(storage, to: UnsafeTreeBuffer.self)
  }
}

// MARK: -

extension UnsafeTreeBuffer {

  @frozen
  public struct Header: UnsafeNodeFreshPool, UnsafeNodeRecyclePool {
    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
    @inlinable
    @inline(__always)
    internal init(_nullptr: _NodePtr, _end_ptr: _NodePtr) {
      self._nullptr = _nullptr
      self.__begin_node_ = _end_ptr
      self.destroyNode = _nullptr
    }
    public var _nullptr: UnsafeMutablePointer<UnsafeNode>
    public var __begin_node_: UnsafeMutablePointer<UnsafeNode>
    @usableFromInline var initializedCount: Int = 0
    @usableFromInline var destroyNode: _NodePtr
    @usableFromInline var destroyCount: Int = 0
    @usableFromInline var freshBucketHead: ReserverHeaderPointer?
    @usableFromInline var freshBucketCurrent: ReserverHeaderPointer?
    @usableFromInline var freshBucketLast: ReserverHeaderPointer?
    @usableFromInline var freshBucketCount: Int = 0
    @usableFromInline var freshPoolCapacity: Int = 0
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      /// CoWの発火回数を観察するためのプロパティ
      @usableFromInline internal var copyCount: UInt = 0
    #endif
    // TODO: removeAll(keepingCapacity:)対応
    @inlinable
    @inline(__always)
    internal mutating func clear(_end_ptr: _NodePtr) {
      assert(_Value.self != Void.self)

      ___clearFresh()
      ___clearRecycle()
      __begin_node_ = _end_ptr
      initializedCount = 0
    }
  }
}

extension UnsafeTreeBuffer.Header {

  @inlinable
  @inline(__always)
  public var count: Int {
    initializedCount - destroyCount
  }
}

extension UnsafeTreeBuffer.Header {

  @inlinable
  @inline(__always)
  public mutating func __construct_node(_ k: _Value) -> _NodePtr {
    assert(_Value.self != Void.self)
    
    if destroyCount > 0 {
      let p = ___popRecycle()
      UnsafeNode.initializeValue(p, to: k)
      p.pointee.___needs_deinitialize = true
      return p
    }
    assert(initializedCount < freshPoolCapacity)
    let p = ___node_alloc()
    assert(p != nil)
    assert(p.pointee.___node_id_ == -2)
    // ナンバリングとノード初期化の責務は移動できる(freshPoolUsedCountは使えない）
    //    p?.initialize(to: UnsafeNode(___node_id_: initializedCount))
    p.initialize(
      to: UnsafeNode(
        ___node_id_: initializedCount, __left_: _nullptr, __right_: _nullptr, __parent_: _nullptr))
    UnsafeNode.initializeValue(p, to: k)
    assert(p.pointee.___node_id_ >= 0)
    initializedCount += 1
    return p
  }
}

extension UnsafeTreeBuffer.Header {
  
  @inlinable
  @inline(__always)
  var isVoid: Bool {
    _Value.self == Void.self
  }
}

extension UnsafeTreeBuffer: CustomStringConvertible {
  public var description: String {
    unsafe withUnsafeMutablePointerToHeader { "UnsafeTreeBuffer<\(_Value.self)>\(unsafe $0.pointee)" }
  }
}

/// The type-punned empty singleton storage instance.
@usableFromInline
nonisolated(unsafe) internal let _emptyTreeStorage = UnsafeTreeBuffer<Void>.create(
  minimumCapacity: 0)

