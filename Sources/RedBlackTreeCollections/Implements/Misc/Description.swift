//===----------------------------------------------------------------------===//
// Portions adapted from the Swift Collections open source project:
// Sources/InternalCollectionsUtilities/Descriptions.swift
// https://github.com/apple/swift-collections/blob/main/Sources/InternalCollectionsUtilities/Descriptions.swift
//
// Copyright (c) 2022 - 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception.
// See Licenses/swift-collections.txt in the repository root for the full license.
//
// Adapted and modified by narumij for swift-ac-collections, including package
// visibility and dictionary description formatting. Project modifications are
// licensed under Apache License v2.0; see LICENSE in the repository root.
//===----------------------------------------------------------------------===//

@inlinable
package func _arrayDescription<C: Sequence>(
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

@inlinable
package func _dictionaryDescription<Key, Value, C: Sequence>(
  for elements: C
) -> String where C.Element == (key: Key, value: Value) {
//  guard !elements.isEmpty else { return "[:]" }
  var result = ""
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
  if result.isEmpty {
    result = ":"
  }
  return "[" + result + "]"
}
