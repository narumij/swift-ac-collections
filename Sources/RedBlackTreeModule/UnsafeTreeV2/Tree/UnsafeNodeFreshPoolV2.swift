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

/*
 V2は、ベンチではV1には速度が今一歩及ばない。
 及ばない理由はアロケーションが多いから。
 そのアロケーションで新規ノード作成がO(1)になり挿入時やCoW時の安定性が増す。
 このため、どちらか決めずにしばらく併存でいく。
 */

// NOTE: 性能過敏なので修正する場合は必ず計測しながら行うこと
@usableFromInline
protocol UnsafeNodeFreshPoolV2: _TreeValue where _NodePtr == UnsafeMutablePointer<UnsafeNode> {

  associatedtype _NodePtr
  var freshPool: FreshPool<_Value> { get set }
  var count: Int { get set }
  var nullptr: _NodePtr { get }
}

extension UnsafeNodeFreshPoolV2 {
  
  @inlinable
  var freshPoolCapacity: Int {
    @inline(__always)
    get { freshPool.capacity }
    set { fatalError() }
  }

  @inlinable
  var freshPoolUsedCount: Int {
    @inline(__always)
    get { freshPool.used }
    set {
      #if DEBUG
        freshPool.used = newValue
      #endif
    }
  }

  @usableFromInline
  var freshPoolActualCount: Int {
    freshPool.used
  }

  #if DEBUG
    @usableFromInline
    var freshBucketCount: Int { -1 }
  #endif

  @inlinable
  @inline(__always)
  subscript(___node_id_: Int) -> _NodePtr {
    return freshPool[___node_id_]
  }

  @inlinable
  @inline(__always)
  mutating func pushFreshBucket(capacity: Int) {
    assert(capacity > 0)
    freshPool.reserveCapacity(minimumCapacity: freshPool.capacity + capacity)
  }

  @inlinable
  @inline(__always)
  mutating func popFresh() -> _NodePtr? {
    freshPool._popFresh(nullptr: nullptr)
  }

  @inlinable
  @inline(__always)
  mutating func ___popFresh() -> _NodePtr {
    let p = freshPool._popFresh(nullptr: nullptr)
    count += 1
    return p
  }

  @inlinable
  @inline(__always)
  mutating func ___deinitFreshPool() {
    freshPool.dispose()
  }

  @inlinable
  @inline(__always)
  mutating func ___flushFreshPool() {
    freshPool.clear()
  }
  
  @inlinable
  @inline(__always)
  mutating func ___cleanFreshPool() {
    freshPool.clear()
  }
}

extension UnsafeNodeFreshPoolV2 {

  @inlinable
  @inline(__always)
  func makeFreshPoolIterator() -> UnsafeNodeFreshPoolV2Iterator<_Value> {
    freshPool.makeFreshPoolIterator()
  }
}
