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

@frozen
public struct UnsafeTreeV2Origin: UnsafeTreePointer {
  @usableFromInline let nullptr: _NodePtr
  @usableFromInline var begin_ptr: _NodePtr
  @usableFromInline let end_ptr: _NodePtr
  @inlinable
  init(base: UnsafeMutablePointer<UnsafeTreeV2Origin>, nullptr: _NodePtr, end_ptr: _NodePtr?) {
    self.nullptr = nullptr
    self.end_ptr = end_ptr!
    begin_ptr = end_ptr!
  }
  @inlinable
  mutating func clear() {
    begin_ptr = end_ptr
    begin_ptr.pointee.__left_ = nullptr
    #if DEBUG
      begin_ptr.pointee.__right_ = nullptr
      begin_ptr.pointee.__parent_ = nullptr
    #endif
  }
  @inlinable
  @inline(__always)
  var __root: _NodePtr {
    get { end_ptr.pointee.__left_ }
    set { end_ptr.pointee.__left_ = newValue }
  }
  @inlinable
  @inline(__always)
  internal func __root_ptr() -> _NodeRef {
    withUnsafeMutablePointer(to: &end_ptr.pointee.__left_) { $0 }
  }
}
