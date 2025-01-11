// Copyright 2024 narumij
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

/// メモ化用途向け
///
/// CustomKeyProtocolで比較方法を供給することで、
/// Comparableプロトコル未適合の型を使うことができる
///
/// 辞書としての機能は削いである
@frozen
public struct _MemoizeCacheLRU<Custom, Value>
where Custom: _KeyCustomProtocol {

  public
    typealias Key = Custom.Parameter

  public
    typealias Value = Value

  public
  typealias KeyValue = (key: Key, prev: _NodePtr, next: _NodePtr, value: Value)

  public
    typealias Element = KeyValue

  public
    typealias _Key = Key

  public
    typealias _Value = Value

  @usableFromInline
  var _storage: Tree.Storage

  @usableFromInline
  let maximumCapacity: Int

  @usableFromInline
  var lru_start: _NodePtr
  
  @usableFromInline
  var lru_end: _NodePtr
}

extension _MemoizeCacheLRU {

  public init(minimumCapacity: Int = 0, maximumCapacity: Int? = nil) {
    _storage = .create(withCapacity: minimumCapacity)
    self.maximumCapacity = maximumCapacity ?? Int.max
    (lru_start, lru_end) = (.nullptr, .nullptr)
  }

  public subscript(key: Key) -> Value? {
    mutating get {
      let __ptr = _tree.find(key)
      if ___is_null_or_end(__ptr) { return nil }
      ___prepend(___pop(__ptr))
      return _tree[__ptr].value
    }
    set {
      if let newValue {
        if _tree.count < maximumCapacity {
          // 無条件で更新するとサイズが安定せず、増加してしまう恐れがある
          _ensureCapacity(to: _tree.count + 1, limit: maximumCapacity)
        }
        if _tree.count == maximumCapacity {
          ___remove(at: ___popLast())
        }
        var __parent = _NodePtr.nullptr
        let __child = _tree.__find_equal(&__parent, key)
        if _tree.__ref_(__child) == .nullptr {
          let __h = _tree.__construct_node((key, -1, -1, newValue))
          _tree.__insert_node_at(__parent, __child, __h)
          ___prepend(___pop(__h))
        } else {
          ___prepend(___pop(_tree.__ref_(__child)))
        }
      }
    }
  }

  @usableFromInline
  var _tree: Tree
  {
    get { _storage.tree }
    _modify { yield &_storage.tree }
  }
  
  public var count: Int { ___count }
  public var capacity: Int { ___header_capacity }
  public
  mutating func clear() {
    _storage = .create(withCapacity: 0)
  }
}

extension _MemoizeCacheLRU: ___RedBlackTreeBase {}
extension _MemoizeCacheLRU: ___RedBlackTreeStorageLifetime {}
extension _MemoizeCacheLRU {

  public static func __key(_ element: KeyValue) -> Key {
    element.key
  }
  
  @inlinable
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    Custom.value_comp(a, b)
  }
}

extension _MemoizeCacheLRU {

  @inlinable
  mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

extension _MemoizeCacheLRU {
  
  @inlinable
  mutating func ___prepend(_ __p: _NodePtr) {
    if lru_start == .nullptr {
      _tree[__p].next = .nullptr
      _tree[__p].prev = .nullptr
      lru_end = __p
      lru_start = __p
    }
    else {
      _tree[lru_start].prev = __p
      _tree[__p].next = lru_start
      _tree[__p].prev = .nullptr
      lru_start = __p
    }
  }
  
  @inlinable
  mutating func ___pop(_ __p: _NodePtr) -> _NodePtr {
    if _tree[__p].prev == .nullptr, _tree[__p].next == .nullptr, lru_start != __p {
      return __p
    }
    defer {
      let prev = _tree[__p].prev
      let next = _tree[__p].next
      if prev != .nullptr {
        _tree[prev].next = next
      } else {
        lru_start = next
      }
      if next != .nullptr {
        _tree[next].prev = prev
      } else {
        lru_end = prev
      }
    }
    return __p
  }
  
  @inlinable
  mutating func ___popLast() -> _NodePtr {
    if lru_end == .nullptr {
      return .nullptr
    }
    defer {
      lru_end = _tree[lru_end].prev
      if lru_end != .nullptr {
        _tree[lru_end].next = .nullptr
      } else {
        lru_start = .nullptr
      }
    }
    return lru_end
  }
}
