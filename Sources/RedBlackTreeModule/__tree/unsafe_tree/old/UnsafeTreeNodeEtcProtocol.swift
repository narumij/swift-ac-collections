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

/// 配列ベースのコードベースにポインタを載せるためのもの
///
/// 段階としては終わっている
@usableFromInline
package protocol UnsafeTreeHandleBase:
  _TreeValueType & _UnsafeNodePtrType & UnsafeTreeNodeProtocol & UnsafeTreeNodeRefProtocol
{
  var header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader> { get }
}

extension UnsafeTreeHandleBase {

  @inlinable
  @inline(__always)
  package var nullptr: _NodePtr { header.pointee.nullptr }

  @inlinable
  @inline(__always)
  package var end: _NodePtr { header.pointee.end_ptr }
}

// MARK: - BeginNodeProtocol

extension UnsafeTreeHandleBase {

  @inlinable
  package var __begin_node_: _NodePtr {

    @inline(__always) get {
      header.pointee.begin_ptr.pointee
    }

    nonmutating set {
      header.pointee.begin_ptr.pointee = newValue
    }
  }
}

// MARK: - EndNodeProtocol

extension UnsafeTreeHandleBase {

  @inlinable
  @inline(__always)
  package var __end_node: _NodePtr {
    header.pointee.end_ptr
  }
}

// MARK: - RootProtocol

extension UnsafeTreeHandleBase {

  #if !DEBUG
    @nonobjc
    @inlinable
    @inline(__always)
    package var __root: _NodePtr {
      header.pointee.root_ptr.pointee
    }
  #else
    @inlinable
    @inline(__always)
    package var __root: _NodePtr {
      get { header.pointee.root_ptr.pointee }
      set { header.pointee.root_ptr.pointee = newValue }
    }
  #endif

  // MARK: - RootPtrProtocol

  @inlinable
  @inline(__always)
  package func __root_ptr() -> _NodeRef {
    header.pointee.root_ptr
  }
}

// MARK: - SizeProtocol

extension UnsafeTreeHandleBase {

  @inlinable
  package var __size_: Int {
    @inline(__always) get {
      header.pointee.count
    }
    nonmutating set {
      /* NOP */
    }
  }
}

// MARK: - AllocatorProtocol

extension UnsafeTreeHandleBase {

  @inlinable
  @inline(__always)
  package func __construct_node(_ k: _Value) -> _NodePtr {
    let p = header.pointee.__construct_raw_node()
    defer { p.__value_().initialize(to: k) }
    return p
  }

  @inlinable
  @inline(__always)
  package func destroy(_ p: _NodePtr) {
    header.pointee.___pushRecycle(p)
  }
}

extension UnsafeTreeHandleBase {

  @inlinable
  @inline(__always)
  package func __value_(_ p: _NodePtr) -> _Value {
    p.__value_().pointee
  }

  @inlinable
  @inline(__always)
  package func ___element(_ p: _NodePtr, _ __v: _Value) {
    p.__value_().pointee = __v
  }
}
