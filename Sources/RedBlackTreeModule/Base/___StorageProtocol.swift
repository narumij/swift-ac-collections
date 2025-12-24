// Copyright 2024-2025 narumij
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
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

@usableFromInline
protocol ___StorageProtocol: ___Root
where
  Base: ___TreeBase,
  Storage == ___Storage<Base>,
  Tree == ___Tree<Base>,
  _Value == Tree._Value
{
  associatedtype Storage
  associatedtype _Value
  var _storage: Storage { get set }
}

extension ___StorageProtocol {

  @inlinable
  var __tree_: Tree {
    @inline(__always) _read {
      yield _storage.tree
    }
  }

  @inlinable
  @inline(__always)
  var _start: _NodePtr {
    __tree_.__begin_node_
  }

  @inlinable
  @inline(__always)
  var _end: _NodePtr {
    __tree_.__end_node()
  }

  @inlinable
  @inline(__always)
  var ___count: Int {
    __tree_.count
  }

  @inlinable
  @inline(__always)
  var ___capacity: Int {
    __tree_.___capacity
  }
}

// MARK: - Remove

extension ___StorageProtocol {
  
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___remove(at ptr: _NodePtr) -> _Value? {
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
  public mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard !__tree_.___is_end(from) else {
      return .end
    }
    __tree_.___ensureValid(begin: from, end: to)
    return __tree_.erase(from, to)
  }
}

// TODO: 削除検討
// ABCの何かの問題に特化で速くできないか模索した名残だと思う
// カバレッジもないし利用してもいなさそう
extension ___StorageProtocol {

  @inlinable
  @inline(__always)
  public mutating func ___remove(
    from: _NodePtr, to: _NodePtr, forEach action: (_Value) throws -> Void
  )
    rethrows
  {
    guard !__tree_.___is_end(from) else {
      return
    }
    __tree_.___ensureValid(begin: from, end: to)
    return try __tree_.___erase(from, to, action)
  }

  @inlinable
  @inline(__always)
  public mutating func ___remove<Result>(
    from: _NodePtr, to: _NodePtr,
    into initialResult: Result,
    _ updateAccumulatingResult: (inout Result, _Value) throws -> Void
  ) rethrows -> Result {
    guard !__tree_.___is_end(from) else {
      return initialResult
    }
    __tree_.___ensureValid(begin: from, end: to)
    return try __tree_.___erase(from, to, into: initialResult, updateAccumulatingResult)
  }

  @inlinable
  @inline(__always)
  public mutating func ___remove<Result>(
    from: _NodePtr, to: _NodePtr,
    _ initialResult: Result,
    _ nextPartialResult: (Result, _Value) throws -> Result
  ) rethrows -> Result {
    guard !__tree_.___is_end(from) else {
      return initialResult
    }
    __tree_.___ensureValid(begin: from, end: to)
    return try __tree_.___erase(from, to, initialResult, nextPartialResult)
  }
}

extension ___StorageProtocol {

  @inlinable
  @inline(__always)
  mutating func ___removeAll(keepingCapacity keepCapacity: Bool = false) {

    if keepCapacity {
      __tree_.__eraseAll()
    } else {
      _storage = .create(withCapacity: 0)
    }
  }
}

extension ___StorageProtocol {

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    public var _copyCount: UInt {
      get { _storage.tree.copyCount }
      set { _storage.tree.copyCount = newValue }
    }
  #endif
}
