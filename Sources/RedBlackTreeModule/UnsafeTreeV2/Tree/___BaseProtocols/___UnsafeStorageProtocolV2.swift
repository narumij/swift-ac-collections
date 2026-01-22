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
protocol ___UnsafeStorageProtocolV2: ___Root & _ValueType
where
  Base: ___TreeBase,
  Tree == UnsafeTreeV2<Base>,
  _Value == Tree._Value,
  _NodePtr == Tree._NodePtr
{
  associatedtype _NodePtr
  var __tree_: Tree { get set }
}

extension ___UnsafeStorageProtocolV2 {

  @inlinable
  @inline(__always)
  internal var _start: _NodePtr {
    __tree_.__begin_node_
  }

  @inlinable
  @inline(__always)
  internal var _end: _NodePtr {
    __tree_.__end_node
  }

  @inlinable
  @inline(__always)
  internal var ___count: Int {
    __tree_.count
  }

  @inlinable
  @inline(__always)
  internal var ___capacity: Int {
    __tree_.capacity
  }
}

// MARK: - Remove

extension ___UnsafeStorageProtocolV2 {

  @inlinable
  @inline(__always)
  @discardableResult
  internal mutating func ___remove_first() -> _Value? {
    guard !__tree_.___is_empty else {
      return nil
    }
    let e = __tree_[__tree_.__begin_node_]
    _ = __tree_.erase(__tree_.__begin_node_)
    return e
  }

  @inlinable
  @inline(__always)
  @discardableResult
  internal mutating func ___remove(at ptr: _NodePtr) -> _Value? {
    guard !__tree_.___is_subscript_null(ptr) else {
      return nil
    }
    let e = __tree_[ptr]
    _ = __tree_.erase(ptr)
    return e
  }

  @inlinable
  @inline(__always)
  @discardableResult
  internal mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard !__tree_.___is_end(from) else {
      return __tree_.end
    }
    __tree_.___ensureValid(begin: from, end: to)
    return __tree_.erase(from, to)
  }
}
