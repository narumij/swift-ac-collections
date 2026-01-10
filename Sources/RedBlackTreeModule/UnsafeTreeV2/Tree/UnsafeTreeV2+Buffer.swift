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
  ManagedBuffer<UnsafeTreeV2Buffer<_Value>.Header, UnsafeTreeV2Origin>
{
  // MARK: - 解放処理
  @inlinable
  @inline(__always)
  deinit {
    withUnsafeMutablePointers { header, tree in
      header.pointee.___deinitFreshPool()
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
    minimumCapacity nodeCapacity: Int,
    nullptr: UnsafeMutablePointer<UnsafeNode>
  ) -> UnsafeTreeV2Buffer {

    // end nodeしか用意しないので要素数は常に1

    let storage = UnsafeTreeV2Buffer.create(minimumCapacity: 1) { managedBuffer in
      return managedBuffer.withUnsafeMutablePointerToElements { tree in

        // endノード用に初期化する
        tree.initialize(to: UnsafeTreeV2Origin(base: tree, nullptr: nullptr))
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
      self.recycleHead = nullptr
    }

    //#if USE_FRESH_POOL_V1
    #if !USE_FRESH_POOL_V2
      @usableFromInline let nullptr: _NodePtr
      @usableFromInline var freshBucketCurrent: ReserverHeaderPointer?
      @usableFromInline var freshPoolCapacity: Int = 0
      @usableFromInline var freshPoolUsedCount: Int = 0
      @usableFromInline var recycleHead: _NodePtr
      @usableFromInline var freshBucketHead: ReserverHeaderPointer?
      @usableFromInline var freshBucketLast: ReserverHeaderPointer?
      @usableFromInline var count: Int = 0
      #if DEBUG
        @usableFromInline var freshBucketCount: Int = 0
      #endif
    #else
      @usableFromInline var recycleHead: _NodePtr
      @usableFromInline let nullptr: _NodePtr
      @usableFromInline var freshPool: FreshPool<_Value> = .init()
      @usableFromInline var count: Int = 0
    #endif

    #if AC_COLLECTIONS_INTERNAL_CHECKS
      /// CoWの発火回数を観察するためのプロパティ
      @usableFromInline internal var copyCount: UInt = 0
    #endif

    @inlinable
    @inline(__always)
    internal mutating func clear(keepingCapacity keepCapacity: Bool = false) {
      if keepCapacity {
        ___cleanFreshPool()
      } else {
        ___flushFreshPool()
      }
      ___flushRecyclePool()
    }
  }
}

//#if USE_FRESH_POOL_V1
#if !USE_FRESH_POOL_V2
  extension UnsafeTreeV2Buffer.Header: UnsafeNodeFreshPool {}
#else
  extension UnsafeTreeV2Buffer.Header: UnsafeNodeFreshPoolV2 {}
#endif

extension UnsafeTreeV2Buffer.Header {

  @inlinable
  @inline(__always)
  public mutating func __construct_node(_ k: _Value) -> _NodePtr {
    #if DEBUG
      assert(recycleCount >= 0)
    #endif
    let p = recycleHead.pointerIndex == .nullptr ? ___popFresh() : ___popRecycle()
    UnsafeNode.initializeValue(p, to: k)
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
  minimumCapacity: 0, nullptr: UnsafeNode.nullptr)

// TODO: このシングルトンを破壊するテストコードを撲滅し根治すること

extension UnsafeTreeV2Buffer.Header {
  @inlinable
  mutating func tearDown() {
    //#if USE_FRESH_POOL_V1
    #if !USE_FRESH_POOL_V2
      ___flushFreshPool()
      count = 0
    #else
      freshPool.dispose()
      freshPool = .init()
      count = 0
    #endif
    ___flushRecyclePool()
  }
}

@inlinable
package func tearDown<T>(treeBuffer buffer: UnsafeTreeV2Buffer<T>) {
  buffer.withUnsafeMutablePointers { h, e in
    h.pointee.tearDown()
    e.pointee.clear()
  }
}
