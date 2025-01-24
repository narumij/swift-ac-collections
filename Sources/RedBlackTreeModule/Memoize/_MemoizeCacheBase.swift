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

import Foundation

public
  protocol _ComparableMemoizationCacheProtocol: _MemoizationCacheProtocol, _KeyCustomProtocol
{}

extension _ComparableMemoizationCacheProtocol {
  public typealias Base = _MemoizeCacheBase<Self, Return>
  public typealias LRU = _MemoizeCacheLRU<Self, Return>
  public typealias CoW = _MemoizeCacheCoW<Self, Return>
}

/// メモ化用途向け
///
/// CustomKeyProtocolで比較方法を供給することで、
/// Comparableプロトコル未適合の型を使うことができる
///
/// 辞書としての機能は削いである
@frozen
public struct _MemoizeCacheBase<Custom, Value>
where Custom: _KeyCustomProtocol {

  public
    typealias Key = Custom.Parameters

  public
    typealias Value = Value

  public
    typealias Element = _KeyValueTuple

  public
    typealias _Key = Key

  public
    typealias _Value = Value

  @usableFromInline
  var _storage: Tree.Storage

  @usableFromInline
  var _hits: Int

  @usableFromInline
  var _miss: Int
}

extension _MemoizeCacheBase {

  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int = 0) {
    _storage = .create(withCapacity: minimumCapacity)
    (_hits, _miss) = (0, 0)
  }

  @inlinable
  public subscript(key: Key) -> Value? {
    @inline(__always)
    mutating get {
      if let v = ___value_for(key)?.value {
        _hits &+= 1
        return v
      } else {
        _miss &+= 1
        return nil
      }
    }
    @inline(__always)
    set {
      if let newValue {
        _ensureCapacity()
        _ = _tree.__insert_unique((key, newValue))
      }
    }
  }

  @inlinable var _tree: Tree
  {
    @inline(__always) get { _storage.tree }
    @inline(__always) _modify { yield &_storage.tree }
  }

  @inlinable
  public var count: Int { ___count }

  @inlinable
  public var capacity: Int { ___capacity }
}

extension _MemoizeCacheBase {

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

extension _MemoizeCacheBase: ___RedBlackTreeBase {}
extension _MemoizeCacheBase: ___RedBlackTreeStorageLifetime {}
extension _MemoizeCacheBase: _MemoizeCacheMiscellaneous {}
extension _MemoizeCacheBase: CustomKeyValueComparer {}
