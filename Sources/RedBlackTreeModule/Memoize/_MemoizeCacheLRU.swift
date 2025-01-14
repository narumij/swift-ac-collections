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
public struct _MemoizeCacheLRU<Custom, Value>
where Custom: _KeyCustomProtocol {

  public
    typealias Key = Custom.Parameters

  public
    typealias Value = Value

  public
    typealias KeyValue = _LinkingKeyValueTuple

  public
    typealias Element = KeyValue

  public
    typealias _Key = Key

  public
    typealias _Value = Value

  @usableFromInline
  var _storage: Tree.Storage

  public let maxCount: Int

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
  public init(minimumCapacity: Int = 0, maxCount: Int = Int.max) {
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
        if _tree.count < maxCount {
          // 無条件で更新するとサイズが安定せず、増加してしまう恐れがある
          _ensureCapacity(limit: maxCount)
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

  @inlinable @inline(__always)
  var _tree: Tree { _storage.tree }
  
  @inlinable
  public var count: Int { ___count }
  
  @inlinable
  public var capacity: Int { ___header_capacity }
}

extension _MemoizeCacheLRU {

  /// statistics
  ///
  /// 確保できたcapacity目一杯使う仕様となってます。
  /// このため、currentCountはmaxCountを越える場合があります。
  @inlinable
  public var info: (hits: Int, miss: Int, maxCount: Int?, currentCount: Int) {
    ___info
  }

  @inlinable
  public mutating func clear(keepingCapacity keepCapacity: Bool = false) {
    ___clear(keepingCapacity: keepCapacity)
  }
}

extension _MemoizeCacheLRU: ___LRULinkList {}
extension _MemoizeCacheLRU: ___RedBlackTreeStorageLifetime {}
extension _MemoizeCacheLRU: _MemoizeCacheLRUMiscellaneous {}
extension _MemoizeCacheLRU: CustomKeyValueComparer {}
