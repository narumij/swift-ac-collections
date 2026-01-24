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

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>

  @inlinable @inline(__always)
  static var nullptr: _NodePtr {
    UnsafeNode.nullptr
  }

  @inlinable
  var __left_: _NodePtr {
    _read { yield pointee.__left_ }
    _modify { yield &pointee.__left_ }
  }

  @inlinable
  var __right_: _NodePtr {
    _read { yield pointee.__right_ }
    _modify { yield &pointee.__right_ }
  }

  @inlinable
  var __parent_: _NodePtr {
    _read { yield pointee.__parent_ }
    _modify { yield &pointee.__parent_ }
  }

  @inlinable
  var __parent_unsafe: _NodePtr {
    _read { yield pointee.__parent_ }
    _modify { yield &pointee.__parent_ }
  }

  @inlinable
  var __set_parent: _NodePtr {
    _read { yield pointee.__parent_ }
    _modify { yield &pointee.__parent_ }
  }

  @inlinable
  var __is_black_: Bool {
    _read { yield pointee.__is_black_ }
    _modify { yield &pointee.__is_black_ }
  }

  @inlinable
  @inline(__always)
  var __left_ref: _NodeRef {
    _ref(to: &pointee.__left_)
  }

  @inlinable
  @inline(__always)
  var __right_ref: _NodeRef {
    _ref(to: &pointee.__right_)
  }
}

//extension UnsafeMutablePointer where Pointee == UnsafeNode {
//  @inlinable @inline(__always)
//  var isGarbaged: Bool { pointee.isGarbaged }
//}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  func __slow_end() -> _NodePtr {
    var __r = self
    while __r.__parent_ != .nullptr {
      __r = __r.__parent_
    }
    return __r
  }
  
  func __slow_begin() -> _NodePtr {
    __tree_min(__slow_end().__left_)
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  @inline(__always)
  var __raw_value_: UnsafeMutableRawPointer {
    UnsafeMutableRawPointer(advanced(by: 1))
  }

  @inlinable
  @inline(__always)
  func __value_<_RawValue>() -> UnsafeMutablePointer<_RawValue> {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: _RawValue.self)
  }

  @inlinable
  @inline(__always)
  package func __value_<_RawValue>(as t: _RawValue.Type) -> UnsafeMutablePointer<_RawValue> {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: _RawValue.self)
  }

  @inlinable
  @inline(__always)
  func __key_ptr<Base: _ScalarRawType>(with t: Base.Type)
    -> UnsafeMutablePointer<Base._Key>
  {
    __value_()
  }

  @inlinable
  @inline(__always)
  func __key_ptr<Base: _PairRawType>(with t: Base.Type)
    -> UnsafeMutablePointer<Base._Key>
  {
    _ref(to: &__value_(as: Base.Pair.self).pointee.key)
  }

  @inlinable
  @inline(__always)
  func __mapped_value_ptr<Base: _PairRawType>(with t: Base.Type)
    -> UnsafeMutablePointer<Base._MappedValue>
  {
    _ref(to: &__value_(as: Base.Pair.self).pointee.value)
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  @inline(__always)
  func _advanced(raw bytes: Int) -> UnsafeMutablePointer {
    UnsafeMutableRawPointer(self)
      .advanced(by: bytes)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  func _advanced(with stride: Int, count: Int) -> UnsafeMutablePointer {
    _advanced(raw: (MemoryLayout<UnsafeNode>.stride + stride) * count)
  }

  @inlinable
  @inline(__always)
  func _advanced<_RawValue>(with t: _RawValue.Type, count: Int) -> UnsafeMutablePointer {
    _advanced(raw: (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_RawValue>.stride) * count)
  }
}

@inlinable @inline(__always)
package func _ref<T>(to a: inout T) -> UnsafeMutablePointer<T> {
  withUnsafeMutablePointer(to: &a) { $0 }
}
