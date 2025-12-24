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

// コレクションの内部実装

@usableFromInline
protocol ___RedBlackTreeValueBase___:
  ___BaseSequence & ___IndexProvider & ___Common & ___StorageProvider & ___KeyOnlySequence & ___CopyOnWrite
{}

@usableFromInline
protocol ___RedBlackTreeKeyValueBase___:
  ___BaseSequence & ___IndexProvider & ___Common & ___StorageProvider & ___KeyValueSequence & ___CopyOnWrite
{}

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
