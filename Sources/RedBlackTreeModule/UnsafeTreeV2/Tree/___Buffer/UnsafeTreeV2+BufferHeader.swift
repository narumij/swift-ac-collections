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

extension UnsafeTreeV2Buffer {

  @frozen
  public struct Header: _UnsafeNodeRecyclePool {
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
      @usableFromInline var freshBucketCurrent: _BucketPointer?
      @usableFromInline var freshPoolCapacity: Int = 0
      @usableFromInline var freshPoolUsedCount: Int = 0
      @usableFromInline var recycleHead: _NodePtr
      @usableFromInline var freshBucketHead: _BucketPointer?
      @usableFromInline var freshBucketLast: _BucketPointer?
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
    
    @usableFromInline
    var __end_node: _NodePtr? {
      freshBucketHead.map {
        UnsafeMutableRawPointer($0.advanced(by: 1))
          .assumingMemoryBound(to: UnsafeNode.self)
      }
    }

    @inlinable @inline(never)  // ホットじゃないのでinline化から除外したい
    func didUpdateFreshBucketHead() {
      _deallocator?.freshBucketHead = freshBucketHead
    }

    @usableFromInline var _deallocator: _UnsafeNodeFreshPoolDeallocator?

    @inlinable @inline(__always)
    var needsDealloc: Bool {
      _deallocator == nil
    }

    @inlinable @inline(never)
    var deallocator: _UnsafeNodeFreshPoolDeallocator {
      mutating get {
        // TODO: 一度の保証付きの実装にすること
        if _deallocator == nil {
          _deallocator = .init(
            freshBucketHead: freshBucketHead,
            stride: MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride,
            deinitialize: UnsafePair<_Value>.deinitialize,
            nullptr: nullptr)
        }
        return _deallocator!
      }
    }

    #if DEBUG
      @inlinable
      @inline(__always)
      mutating func createDeallocator() {
        _ = deallocator
      }
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
      } else if _deallocator == nil {
        ___flushFreshPool()
      }
      ___flushRecyclePool()
    }
  }
}

#if USE_FRESH_POOL_V1
  extension UnsafeTreeV2Buffer.Header: _UnsafeNodeFreshPool {}
#elseif USE_FRESH_POOL_V2
  extension UnsafeTreeV2Buffer.Header: UnsafeNodeFreshPoolV2 {}
#else
  extension UnsafeTreeV2Buffer.Header: _UnsafeNodeFreshPoolV3 {}
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

extension UnsafeTreeV2Buffer.Header {
  @inlinable
  mutating func tearDown() {
    //#if USE_FRESH_POOL_V1
    #if !USE_FRESH_POOL_V2
      if let _ = _deallocator {
        self._deallocator = nil
        self.freshBucketHead = nil
        self.freshBucketCurrent = nil
        self.freshBucketLast = nil
        self.freshPoolCapacity = 0
        self.freshPoolUsedCount = 0
        #if DEBUG
          self.freshBucketCount = 0
        #endif
      } else {
        ___flushFreshPool()
      }
      count = 0
    #else
      freshPool.dispose()
      freshPool = .init()
      count = 0
    #endif
    ___flushRecyclePool()
  }
}
