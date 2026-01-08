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
  ManagedBuffer<UnsafeTreeV2Buffer<_Value>.Header, __tree>
{
  // MARK: - 解放処理
  @inlinable
  @inline(__always)
  deinit {
    withUnsafeMutablePointers { header, tree in
      header.pointee.___flushFreshPool()
      header.pointee.freshPool.dispose()
      tree.deinitialize(count: 1)
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
      return managedBuffer.withUnsafeMutablePointerToElements { tree in
        
        let nullptr = UnsafeNode.nullptr
        // endノード用に初期化する
        tree.initialize(to: __tree(base: tree,nullptr: nullptr))
        // ヘッダーを準備する
        var header = Header(nullptr: nullptr)
        // ノードを確保する
        if nodeCapacity > 0 {
          header.pushFreshBucket(capacity: nodeCapacity)
          assert(header.freshPoolCapacity >= nodeCapacity)
        }
        assert(tree.pointee.end_ptr.pointee.___needs_deinitialize == true)
        // ヘッダを返却して以後はManagerBufferさんがよしなにする
        return header
      }
    }

    assert(nodeCapacity <= storage.header.freshPoolCapacity)
    return unsafeDowncast(storage, to: UnsafeTreeV2Buffer.self)
  }
}

// MARK: -

extension UnsafeTreeV2Buffer {

  @frozen
  public struct Header: UnsafeNodeRecyclePool {
    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
    
    @inlinable
    @inline(__always)
    internal init(nullptr: _NodePtr) {
      self.nullptr = nullptr
    }
    
    @usableFromInline var count: Int = 0
#if !USE_FRESH_POOL_V2
    @usableFromInline var freshBucketCurrent: ReserverHeaderPointer?
    @usableFromInline var freshPoolCapacity: Int = 0
    @usableFromInline var freshPoolUsedCount: Int = 0
#endif

    @usableFromInline var recycleHead: _NodePtr = UnsafeNode.nullptr
    
#if !USE_FRESH_POOL_V2
    @usableFromInline var freshBucketHead: ReserverHeaderPointer?
    @usableFromInline var freshBucketLast: ReserverHeaderPointer?
#if DEBUG
    @usableFromInline var freshBucketCount: Int = 0
#endif
#endif
    @usableFromInline let nullptr: _NodePtr
    
    @usableFromInline var freshPool: FreshPool<_Value> = .init()
    @usableFromInline var _freshPoolCapacity: Int?

    #if AC_COLLECTIONS_INTERNAL_CHECKS
      /// CoWの発火回数を観察するためのプロパティ
      @usableFromInline internal var copyCount: UInt = 0
    #endif
    
    @inlinable
    @inline(__always)
    internal mutating func clear(_end_ptr: _NodePtr) {
      _end_ptr.pointee.__left_ = UnsafeNode.nullptr
      ___cleanFreshPool()
      ___flushRecyclePool()
//      __begin_node_ = _end_ptr
    }
  }
}

#if !USE_FRESH_POOL_V2
extension UnsafeTreeV2Buffer.Header: UnsafeNodeFreshPool { }
#else
extension UnsafeTreeV2Buffer.Header: UnsafeNodeFreshPoolV2 { }
#endif


extension UnsafeTreeV2Buffer.Header {

//  @inlinable
//  @inline(__always)
//  var nullptr: _NodePtr {
//    UnsafeNode.nullptr
//  }

//  @inlinable
//  @inline(__always)
//  public var count: Int {
//    // __sizeへ移行した場合、
//    // 減算のステップ数が増えるので逆効果なため
//    // 計算プロパティ維持の方針
//    freshPoolUsedCount - recycleCount
//  }
}

extension UnsafeTreeV2Buffer.Header {

  @inlinable
  @inline(__always)
  public mutating func __construct_node(_ k: _Value) -> _NodePtr {
    assert(_Value.self != Void.self)
    assert(recycleCount >= 0)
//    let p = recycleCount == 0 ? ___popFresh() : ___popRecycle()
    let p = recycleHead == nullptr ? ___popFresh() : ___popRecycle()
    UnsafeNode.initializeValue(p, to: k)
    assert(p != nil)
    assert(p.pointee.___node_id_ >= 0)
    return p
  }
}

extension UnsafeTreeV2Buffer: CustomStringConvertible {
  public var description: String {
    unsafe withUnsafeMutablePointerToHeader {
      "UnsafeTreeBuffer<\(_Value.self)>\(unsafe $0.pointee)"
    }
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
  }
}

@inlinable
package func tearDown<T>(treeBuffer buffer: UnsafeTreeV2Buffer<T>) {
//  buffer.header.tearDown()
  buffer.withUnsafeMutablePointers { h, e in
    h.pointee.tearDown()
    e.pointee.clear()
//    e.pointee.begin_ptr = e.pointee.end_ptr
//    let e = e.pointee.end_ptr
////    h.pointee.__begin_node_ = e
//    e.pointee.__left_ = UnsafeNode.nullptr
//    e.pointee.__right_ = UnsafeNode.nullptr
//    e.pointee.__parent_ = UnsafeNode.nullptr
//    h.pointee.freshPool = .init()
  }
}
