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

@usableFromInline
package protocol UnsafeTreeHandleBase: UnsafeTreeNodeProtocol & _TreeValue & UnsafeTreePointer,
  UnsafeTreeNodeRefProtocol
{
  var header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader> { get }
//  var origin: UnsafeMutableRawPointer { get }
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
      header.pointee.begin_ptr
    }

    @inline(__always)
    nonmutating set {
      header.pointee.begin_ptr = newValue
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
      end.pointee.__left_
    }
  #else
    @inlinable
    @inline(__always)
    package var __root: _NodePtr {
      get { end.pointee.__left_ }
      set { end.pointee.__left_ = newValue }
    }
  #endif

  // MARK: - RootPtrProtocol

  @inlinable
  @inline(__always)
  package func __root_ptr() -> _NodeRef {
    withUnsafeMutablePointer(to: &header.pointee.end_ptr.pointee.__left_) { $0 }
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
  package func __construct_node<T>(_ k: T) -> _NodePtr {
    header.pointee.__construct_node(k)
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
