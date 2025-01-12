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

/// メモ化用途向け、LRU (least recently used) cache 動作
/// https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_Recently_Used_(LRU)
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

  public let maxCount: Int?

  @usableFromInline
  var _rankHighest: _NodePtr

  @usableFromInline
  var _rankLowest: _NodePtr

  @usableFromInline
  var _hits: Int

  @usableFromInline
  var _miss: Int
}

extension _MemoizeCacheLRU {

  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int = 0, maxCount: Int? = nil) {
    _storage = .create(withCapacity: minimumCapacity)
    self.maxCount = maxCount
    (_rankHighest, _rankLowest) = (.nullptr, .nullptr)
    (_hits, _miss) = (0, 0)
  }

  @inlinable
  public subscript(key: Key) -> Value? {
    @inline(__always)
    mutating get {
      let __ptr = _tree.find(key)
      if ___is_null_or_end(__ptr) {
        _miss &+= 1
        return nil
      }
      _hits &+= 1
      ___prepend(___pop(__ptr))
      return _tree[__ptr].value
    }
    @inline(__always)
    set {
      if let newValue {
        if let maxCount, _tree.count < maxCount {
          // 無条件で更新するとサイズが安定せず、増加してしまう恐れがある
          _ensureCapacity(to: _tree.count + 1, limit: maxCount)
        } else if maxCount == nil {
          _ensureCapacity(to: _tree.count + 1)
        }
        if _tree.count == maxCount {
          ___remove(at: ___popRankLowest())
        }
        var __parent = _NodePtr.nullptr
        let __child = _tree.__find_equal(&__parent, key)
        if _tree.__ref_(__child) == .nullptr {
          let __h = _tree.__construct_node((key, .nullptr, .nullptr, newValue))
          _tree.__insert_node_at(__parent, __child, __h)
          ___prepend(__h)
        }
      }
    }
  }

  @inlinable var _tree: Tree
  {
    @inline(__always) get { _storage.tree }
    @inline(__always) _modify { yield &_storage.tree }
  }

  @inlinable public var count: Int { ___count }
  @inlinable public var capacity: Int { ___header_capacity }
}

extension _MemoizeCacheLRU {

  /// statistics
  ///
  /// 確保できたcapacity目一杯使う仕様となってます。
  /// このため、currentCountはmaxCountを越える場合があります。
  @inlinable
  public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
    (_hits, _miss, maxCount, count)
  }

  @inlinable
  public mutating func clear(keepingCapacity keepCapacity: Bool = false) {
    (_hits, _miss) = (0, 0)
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

extension _MemoizeCacheLRU: ___RedBlackTreeBase {
  @inlinable @inline(__always)
  public static func __key(_ element: Element) -> Key {
    element.key
  }
}
extension _MemoizeCacheLRU: ___RedBlackTreeStorageLifetime {}
extension _MemoizeCacheLRU: CustomComparer {}
extension _MemoizeCacheLRU {

  @inlinable
  mutating func ___prepend(_ __p: _NodePtr) {
    if _rankHighest == .nullptr {
      _tree[__p].next = .nullptr
      _tree[__p].prev = .nullptr
      _rankLowest = __p
      _rankHighest = __p
    } else {
      _tree[_rankHighest].prev = __p
      _tree[__p].next = _rankHighest
      _tree[__p].prev = .nullptr
      _rankHighest = __p
    }
  }

  @inlinable
  mutating func ___pop(_ __p: _NodePtr) -> _NodePtr {

    assert(
      __p == _rankHighest || _tree[__p].next != .nullptr || _tree[__p].prev != .nullptr,
      "did not contain \(__p) ptr.")

    defer {
      let prev = _tree[__p].prev
      let next = _tree[__p].next
      if prev != .nullptr {
        _tree[prev].next = next
      } else {
        _rankHighest = next
      }
      if next != .nullptr {
        _tree[next].prev = prev
      } else {
        _rankLowest = prev
      }
    }

    return __p
  }

  @inlinable
  mutating func ___popRankLowest() -> _NodePtr {

    defer {
      if _rankLowest != .nullptr {
        _rankLowest = _tree[_rankLowest].prev
      }
      if _rankLowest != .nullptr {
        _tree[_rankLowest].next = .nullptr
      } else {
        _rankHighest = .nullptr
      }
    }

    return _rankLowest
  }
}
