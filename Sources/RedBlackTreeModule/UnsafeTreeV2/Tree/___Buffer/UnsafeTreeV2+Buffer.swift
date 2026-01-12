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
      if header.pointee.needsDeallocate {
        header.pointee.___deallocateFreshPool()
      }
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
      // ヘッダを返却して以後はManagerBufferさんがよしなにする
      return Header(nullptr: nullptr)
    }

    storage.withUnsafeMutablePointers { header, tree in
      // ノード数を確保
      if nodeCapacity > 0 {
        header.pointee.pushFreshBucket(capacity: nodeCapacity)
        assert(header.pointee.freshPoolCapacity >= nodeCapacity)
      }
      // originを初期化
      tree.initialize(to: UnsafeTreeV2Origin(base: tree, nullptr: nullptr))
      assert(tree.pointee.end_ptr.pointee.___needs_deinitialize == true)
    }

    assert(nodeCapacity <= storage.header.freshPoolCapacity)
    return unsafeDowncast(storage, to: UnsafeTreeV2Buffer.self)
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

@inlinable
package func tearDown<T>(treeBuffer buffer: UnsafeTreeV2Buffer<T>) {
  buffer.withUnsafeMutablePointers { h, e in
    h.pointee.tearDown()
    e.pointee.clear()
  }
}
