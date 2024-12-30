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
@frozen
public struct ___RedBlackTreeMemoizeBase<CustomKey, Value>
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

  public init() {
    tree = .create(withCapacity: 0)
  }

  public subscript(key: Key) -> Value? {
    get { ___value_for(key)?.value }
    set {
      if let newValue {
        _ = tree.__insert_unique((key, newValue))
      } else {
        _ = tree.___erase_unique(key)
      }
    }
  }

  @usableFromInline
  var tree: Tree
  
  @usableFromInline
  var lifeStorage: Tree.LifeStorage = .init()

  public var count: Int { tree.size }
  public var isEmpty: Bool { count == 0 }
}

extension ___RedBlackTreeMemoizeBase: ___RedBlackTreeBase {}
extension ___RedBlackTreeMemoizeBase: KeyValueComparer {

  @inlinable
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    CustomKey.value_comp(a, b)
  }
}
