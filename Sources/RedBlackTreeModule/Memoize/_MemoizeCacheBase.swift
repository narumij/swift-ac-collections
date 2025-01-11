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

public
  protocol _KeyCustomProtocol
{
  associatedtype Parameter
  static func value_comp(_ a: Parameter, _ b: Parameter) -> Bool
}

public
  protocol _MemoizationProtocol: _KeyCustomProtocol
{
  associatedtype Return
}

extension _MemoizationProtocol {
  public typealias Base = _MemoizeCacheBase<Self, Return>
  public typealias LRU = _MemoizeCacheLRU<Self, Return>
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
    typealias Key = Custom.Parameter

  public
    typealias Value = Value

  public
    typealias KeyValue = (key: Key, value: Value)

  public
    typealias Element = KeyValue

  public
    typealias _Key = Key

  public
    typealias _Value = Value

  @usableFromInline
  var _storage: Tree.Storage
}

extension _MemoizeCacheBase {

  public init(minimumCapacity: Int = 0) {
    _storage = .create(withCapacity: minimumCapacity)
  }

  public subscript(key: Key) -> Value? {
    get { ___value_for(key)?.value }
    set {
      if let newValue {
        _ensureCapacity(to: _tree.count + 1)
        _ = _tree.__insert_unique((key, newValue))
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
}

extension _MemoizeCacheBase: ___RedBlackTreeBase {}
extension _MemoizeCacheBase: ___RedBlackTreeStorageLifetime {}
extension _MemoizeCacheBase: KeyValueComparer {

  @inlinable
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    Custom.value_comp(a, b)
  }
}

extension _MemoizeCacheBase {

  @inlinable
  mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    ___removeAll(keepingCapacity: keepCapacity)
  }
}
