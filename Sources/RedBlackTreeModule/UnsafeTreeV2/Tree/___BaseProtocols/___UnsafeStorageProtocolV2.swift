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
protocol ___UnsafeStorageProtocolV2: ___Root & _PayloadValueType
where
  Base: ___TreeBase,
  Tree == UnsafeTreeV2<Base>,
  _PayloadValue == Tree._PayloadValue,
  _NodePtr == Tree._NodePtr
{
  associatedtype _NodePtr
  var __tree_: Tree { get set }
}

extension ___UnsafeStorageProtocolV2 {

  @inlinable
  @inline(__always)
  package var _start: _NodePtr {
    __tree_.__begin_node_
  }

  @inlinable
  @inline(__always)
  package var _end: _NodePtr {
    __tree_.__end_node
  }

  @inlinable
  @inline(__always)
  package var ___count: Int {
    __tree_.count
  }

  @inlinable
  @inline(__always)
  package var ___capacity: Int {
    __tree_.capacity
  }
}

// MARK: - Remove

extension ___UnsafeStorageProtocolV2 {

  @inlinable
  @inline(__always)
  @discardableResult
  package mutating func ___remove_first() -> (__r: _NodePtr, payload: _PayloadValue)? {
    guard _start != _end else { return nil }
    let ___e = __tree_[_start]
    let __r = __tree_.erase(_start)
    return (__r, ___e)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  package mutating func ___remove_last() -> (__r: _NodePtr, payload: _PayloadValue)? {
    guard _start != _end else { return nil }
    let ___l = __tree_prev_iter(_end)
    let ___e = __tree_[___l]
    let __r = __tree_.erase(___l)
    return (__r, ___e)
  }
}

extension ___UnsafeStorageProtocolV2 {

  @inlinable
  @inline(__always)
  @discardableResult
  package mutating func ___remove(at ptr: _NodePtr) -> (__r: _NodePtr, payload: _PayloadValue)? {
    guard !ptr.___is_subscript_null else { return nil }
    let ___e = __tree_[ptr]
    let __r = __tree_.erase(ptr)
    return (__r, ___e)
  }
}

extension ___UnsafeStorageProtocolV2 {

  @inlinable
  @inline(__always)
  @discardableResult
  package mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != _end else { return __tree_.end }
    __tree_.___ensureValid(begin: from, end: to)
    guard __tree_.isValidRawRange(lower: from, upper: to) else {
      fatalError(.invalidIndex)
    }
    return __tree_.erase(from, to)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  package mutating func ___unchecked_remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != _end else { return __tree_.end }
    return __tree_.___checking_erase(from, to)
  }

  @inlinable
  package mutating func ___remove(_ rawRange: UnsafeTreeRangeExpression) -> _NodePtr {
    let (lower, upper) = rawRange.relative(to: __tree_)
    return ___remove(from: lower, to: upper)
  }

  @inlinable
  package mutating func ___unchecked_remove(_ rawRange: UnsafeTreeRangeExpression) -> _NodePtr {
    let (lower, upper) = rawRange.relative(to: __tree_)
    return ___unchecked_remove(from: lower, to: upper)
  }
}
