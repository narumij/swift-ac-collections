// Copyright 2025 narumij
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

import Foundation

/// メモ化用途向け、LRU (least recently used) cache 動作
/// https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_Recently_Used_(LRU)
///
/// InlineMemoize動作用。CoWがないので注意
@frozen
public struct ___LRUMemoizeStorage<Parameters, Value>
where Parameters: Comparable {

  public
    typealias Key = Parameters

  public
    typealias Value = Value

  public
    typealias KeyValue = _LinkingPair<_Key, _MappedValue>

  public
    typealias _Value = KeyValue

  public
    typealias _Key = Key

  public
    typealias _MappedValue = Value

  @usableFromInline
  var _storage: Tree.Storage

  public let maxCount: Int

  @usableFromInline
  var _rankHighest: _NodePtr

  @usableFromInline
  var _rankLowest: _NodePtr
}

extension ___LRUMemoizeStorage {

  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int = 0, maxCount: Int = Int.max) {
    _storage = .create(withCapacity: minimumCapacity)
    self.maxCount = maxCount
    (_rankHighest, _rankLowest) = (.nullptr, .nullptr)
  }

  @inlinable
  public subscript(key: Key) -> Value? {
    @inline(__always)
    mutating get {
      let __ptr = __tree_.find(key)
      if ___is_null_or_end(__ptr) {
        return nil
      }
      ___prepend(___pop(__ptr))
      return __tree_[__ptr].value
    }
    @inline(__always)
    set {
      if let newValue {
        if __tree_.count < maxCount {
          // 無条件で更新するとサイズが安定せず、増加してしまう恐れがある
          _ensureCapacity(limit: maxCount)
        }
        if __tree_.count == maxCount {
          _ = __tree_.erase(___popRankLowest())
        }
        let (__parent, __child) = __tree_.__find_equal(key)
        if __tree_.__ptr_(__child) == .nullptr {
          let __h = __tree_.__construct_node(.init(key, .nullptr, .nullptr, newValue))
          __tree_.__insert_node_at(__parent, __child, __h)
          ___prepend(__h)
        }
      }
    }
  }
}

extension ___LRUMemoizeStorage: HasDefaultThreeWayComparator {}

extension ___LRUMemoizeStorage: ___LRULinkList {

  @inlinable
  var __tree_: Tree {
    @inline(__always) _read {
      yield _storage.tree
    }
  }
}

extension ___LRUMemoizeStorage: ___RedBlackTreeCopyOnWrite {}
extension ___LRUMemoizeStorage: CompareUniqueTrait {}
extension ___LRUMemoizeStorage: KeyValueComparer {

  @inlinable
  @inline(__always)
  public static func ___mapped_value(_ element: _Value) -> _MappedValue {
    element.value
  }

  @inlinable
  @inline(__always)
  public static func ___with_mapped_value<T>(
    _ element: inout _Value, _ f: (inout _MappedValue) throws -> T
  ) rethrows -> T {
    try f(&element.value)
  }
}

extension ___LRUMemoizeStorage {

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

extension ___LRUMemoizeStorage {

  @inlinable
  public var count: Int { __tree_.count }

  @inlinable
  public var capacity: Int { __tree_.___capacity }

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    public var _copyCount: UInt {
      _storage.tree.copyCount
    }
  #endif
}
