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
  protocol KeyCustomProtocol
{
  associatedtype Key
  static func value_comp(_ a: Key, _ b: Key) -> Bool
}

public
protocol MemoizationCacheProtocol: KeyCustomProtocol {
  associatedtype Result
}

extension MemoizationCacheProtocol {
  public typealias Cache = MemoizeCacheBase<Self, Result>
}

/// メモ化用途向け
///
/// CustomKeyProtocolで比較方法を供給することで、
/// Comparableプロトコル未適合の型を使うことができる
///
/// 辞書としての機能は削いである
@frozen
public struct MemoizeCacheBase<CustomKey, Value>
where CustomKey: KeyCustomProtocol {

  public
    typealias Key = CustomKey.Key

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

  @usableFromInline
  let maximumCapacity: Int
  
  @usableFromInline
  var oldestNode: _NodePtr
}

extension MemoizeCacheBase {

  public init(minimumCapacity: Int = 0, maximumCapacity: Int? = nil) {
    _storage = .create(withCapacity: minimumCapacity)
    self.maximumCapacity = maximumCapacity ?? Int.max
    self.oldestNode = 0
  }

  public subscript(key: Key) -> Value? {
    get { ___value_for(key)?.value }
    set {
      if let newValue {
        if _tree.count < maximumCapacity {
          // 無条件で更新するとサイズが安定せず、増加してしまう恐れがある
          _ensureCapacity(to: _tree.count + 1, limit: maximumCapacity)
        }
        if _tree.count == maximumCapacity {
          ___remove(at: oldestNode)
          oldestNode += 1
          oldestNode %= maximumCapacity
        }
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
}

extension MemoizeCacheBase: ___RedBlackTreeBase {}
extension MemoizeCacheBase: ___RedBlackTreeStorageLifetime {}
extension MemoizeCacheBase: KeyValueComparer {

  @inlinable
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    CustomKey.value_comp(a, b)
  }
}
