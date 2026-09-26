//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

extension String {
  
  @usableFromInline
  internal static var garbagedIndex: String {
    "A dangling node reference was used. Consider using a valid range or slice."
  }

  @usableFromInline
  internal static var invalidIndex: String {
    "Attempting to access RedBlackTree elements using an invalid index"
  }

  @usableFromInline
  internal static var outOfBounds: String {
    "Index out of bounds. <RedBlackTree>"
  }

  @usableFromInline
  internal static var outOfRange: String {
    "RedBlackTree index is out of range."
  }
  
  @usableFromInline
  internal static var emptyFirst: String {
    "Can't removeFirst from an empty RedBlackTree"
  }

  @usableFromInline
  internal static var emptyLast: String {
    "Can't removeLast from an empty RedBlackTree"
  }
  
  @usableFromInline
  internal static func duplicateValue<Key>(for key: Key) -> String {
    "Dupricate values for key: '\(key)'"
  }
  
  @usableFromInline
  internal static var alignnment: String {
    "Memory allocation failed due to alignment constraints."
  }
  
  @usableFromInline
  internal static var treeMissmatch: String {
    "RedBlackTree instances do not match."
  }
}
