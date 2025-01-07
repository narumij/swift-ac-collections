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
  protocol CustomKeyProtocol
{
  associatedtype Key
  static func value_comp(_ a: Key, _ b: Key) -> Bool
}

/// メモ化用途向け
///
/// CustomKeyProtocolで比較方法を供給することで、
/// Comparableプロトコル未適合の型を使うことができる
///
/// 辞書としての機能は削いである
@frozen
public struct ___RedBlackTreeMapBase<CustomKey, Value>
where CustomKey: CustomKeyProtocol {

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
}

extension ___RedBlackTreeMapBase {

  public init(minimumCapacity: Int = 0, maximumCapacity: Int = Int.max) {
    _storage = .create(withCapacity: minimumCapacity)
    self.maximumCapacity = maximumCapacity
  }

  public subscript(key: Key) -> Value? {
    get { ___value_for(key)?.value }
    set {
      if let newValue, _tree.count < maximumCapacity {
        _ensureUniqueAndCapacity(
          minimumCapacity: _tree.count + 1,
          maximumCapacity: maximumCapacity)
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

extension ___RedBlackTreeMapBase: ___RedBlackTreeBase {}
extension ___RedBlackTreeMapBase: ___RedBlackTreeStorageLifetime {}
extension ___RedBlackTreeMapBase: KeyValueComparer {

  @inlinable
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    CustomKey.value_comp(a, b)
  }
}

extension ___RedBlackTreeStorageLifetime {
  @inlinable
  @inline(__always)
  mutating func _ensureUniqueAndCapacity(minimumCapacity: Int, maximumCapacity: Int) {
    #if !DISABLE_COPY_ON_WRITE
      let shouldExpand = _storage.capacity < minimumCapacity
      if shouldExpand || !_isKnownUniquelyReferenced_LV1() {
        _storage = _storage.copy(
          newCapacity:
            min(
              maximumCapacity,
              Tree._growCapacity(
                tree: &_storage.tree, to: minimumCapacity, linearly: false)))
      }
      assert(_storage.capacity >= minimumCapacity)
      assert(_storage.tree.header.initializedCount <= _storage.capacity)
    #endif
  }
}
