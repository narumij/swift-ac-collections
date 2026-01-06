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
public final class UnsafeTreeV2Buffer<_Value>:
  ManagedBuffer<UnsafeTreeV2Buffer<_Value>.Header, UnsafeNode>
{
  // MARK: - 解放処理
  @inlinable
  @inline(__always)
  deinit {
    withUnsafeMutablePointers { header, end in
      header.pointee.___flushFreshPool()
      end.deinitialize(count: 1)
    }
  }
}

// MARK: - 生成

extension UnsafeTreeV2Buffer {

  @nonobjc
  @inlinable
  @inline(__always)
  internal static func create(
    minimumCapacity nodeCapacity: Int
  ) -> UnsafeTreeV2Buffer {

    // end nodeしか用意しないので要素数は常に1
    
    let storage = UnsafeTreeV2Buffer.create(minimumCapacity: 1) { managedBuffer in
      return managedBuffer.withUnsafeMutablePointerToElements { _end_ptr in
        
        // endノード用に初期化する
        _end_ptr.initialize(to: UnsafeNode(___node_id_: .end))
        // ヘッダーを準備する
        var header = Header(_end_ptr: _end_ptr)
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
    return unsafeDowncast(storage, to: UnsafeTreeV2Buffer.self)
  }
}

// MARK: -

extension UnsafeTreeV2Buffer {

  @frozen
  public struct Header: UnsafeNodeFreshPool, UnsafeNodeRecyclePool {
    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
    @inlinable
    @inline(__always)
    internal init(_end_ptr: _NodePtr) {
      self.__begin_node_ = _end_ptr
      self.destroyNode = UnsafeNode.nullptr
    }
    
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
      _end_ptr.pointee.__left_ = UnsafeNode.nullptr
      ___cleanFreshPool()
      ___flushRecyclePool()
      __begin_node_ = _end_ptr
      initializedCount = 0
    }
  }
}

extension UnsafeTreeV2Buffer.Header {

  @inlinable
  @inline(__always)
  public var count: Int {
    // TODO: _size_に移行する（性能を観察しながら）
    initializedCount - destroyCount
  }
}

extension UnsafeTreeV2Buffer.Header {

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
    p.initialize(to: UnsafeNode(___node_id_: initializedCount))
    UnsafeNode.initializeValue(p, to: k)
    assert(p.pointee.___node_id_ >= 0)
    initializedCount += 1
    return p
  }
}

extension UnsafeTreeV2Buffer.Header {
  
  @inlinable
  @inline(__always)
  var isVoid: Bool {
    _Value.self == Void.self
  }
}

extension UnsafeTreeV2Buffer: CustomStringConvertible {
  public var description: String {
    unsafe withUnsafeMutablePointerToHeader { "UnsafeTreeBuffer<\(_Value.self)>\(unsafe $0.pointee)" }
  }
}

/// The type-punned empty singleton storage instance.
@usableFromInline
nonisolated(unsafe) package let _emptyTreeStorage = UnsafeTreeV2Buffer<Void>.create(
  minimumCapacity: 0)

// TODO: このシングルトンを破壊するテストコードを撲滅し根治すること

#if DEBUG
#endif

extension UnsafeTreeV2Buffer.Header {
  @inlinable
  mutating func tearDown() {
    ___flushFreshPool()
    ___flushRecyclePool()
    initializedCount = 0
  }
}

@inlinable
package func tearDown<T>(treeBuffer buffer: UnsafeTreeV2Buffer<T>) {
  buffer.header.tearDown()
  buffer.withUnsafeMutablePointers { h, e in
    h.pointee.__begin_node_ = e
    e.pointee.__left_ = UnsafeNode.nullptr
    e.pointee.__right_ = UnsafeNode.nullptr
    e.pointee.__parent_ = UnsafeNode.nullptr
  }
}
