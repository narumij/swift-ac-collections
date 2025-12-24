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

// コレクション実装の基点
public protocol ___RedBlackTree___ {
  associatedtype Base
  associatedtype Tree
  associatedtype Element
}

public protocol ___RedBlackTreeKeyValue___: ___RedBlackTree___ {
  associatedtype _Key
  associatedtype _MappedValue
}

// コレクションの内部実装
@usableFromInline
protocol ___RedBlackTreeBase:
  ___RedBlackTree___ & ___StorageProvider & ___IndexProvider & ___Common & ___Sequence
{}

// MARK: - Index

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  func ___contains(_ __k: _Key) -> Bool {
    __tree_.__count_unique(__k) != 0
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  func ___min() -> _Value? {
    __tree_.__root() == .nullptr ? nil : __tree_[__tree_.__tree_min(__tree_.__root())]
  }

  @inlinable
  @inline(__always)
  func ___max() -> _Value? {
    __tree_.__root() == .nullptr ? nil : __tree_[__tree_.__tree_max(__tree_.__root())]
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  public func ___lower_bound(_ __k: _Key) -> _NodePtr {
    __tree_.lower_bound(__k)
  }

  @inlinable
  @inline(__always)
  public func ___upper_bound(_ __k: _Key) -> _NodePtr {
    __tree_.upper_bound(__k)
  }

  @inlinable
  @inline(__always)
  func ___index_lower_bound(_ __k: _Key) -> Index {
    ___index(___lower_bound(__k))
  }

  @inlinable
  @inline(__always)
  func ___index_upper_bound(_ __k: _Key) -> Index {
    ___index(___upper_bound(__k))
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  func ___first_index(of member: _Key) -> Index? {
    let ptr = __tree_.__ptr_(__tree_.__find_equal(member).__child)
    return ___index_or_nil(ptr)
  }
}

// MARK: - Etc

// from https://github.com/apple/swift-collections/blob/main/Sources/InternalCollectionsUtilities/Descriptions.swift
@inlinable
package func _arrayDescription<C: Collection>(
  for elements: C
) -> String {
  var result = "["
  var first = true
  for item in elements {
    if first {
      first = false
    } else {
      result += ", "
    }
    debugPrint(item, terminator: "", to: &result)
  }
  result += "]"
  return result
}

// from https://github.com/apple/swift-collections/blob/main/Sources/InternalCollectionsUtilities/Descriptions.swift
@inlinable
package func _dictionaryDescription<Key, Value, C: Collection>(
  for elements: C
) -> String where C.Element == (key: Key, value: Value) {
  guard !elements.isEmpty else { return "[:]" }
  var result = "["
  var first = true
  for (key, value) in elements {
    if first {
      first = false
    } else {
      result += ", "
    }
    debugPrint(key, terminator: "", to: &result)
    result += ": "
    debugPrint(value, terminator: "", to: &result)
  }
  result += "]"
  return result
}

@inlinable
package func _dictionaryDescription<Key, Value, C: Collection>(
  for elements: C
) -> String where C.Element == RedBlackTreePair<Key, Value> {
  guard !elements.isEmpty else { return "[:]" }
  var result = "["
  var first = true
  for kv in elements {
    let (key, value) = (kv.key, kv.value)
    if first {
      first = false
    } else {
      result += ", "
    }
    debugPrint(key, terminator: "", to: &result)
    result += ": "
    debugPrint(value, terminator: "", to: &result)
  }
  result += "]"
  return result
}
