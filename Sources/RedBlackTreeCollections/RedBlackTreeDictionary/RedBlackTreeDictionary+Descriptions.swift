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

// MARK: - CustomStringConvertible

extension RedBlackTreeDictionary: CustomStringConvertible {

  /// A string that represents the contents of the set.
  @inlinable
  public var description: String {
    _dictionaryDescription(for: self)
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeDictionary: CustomDebugStringConvertible {

  /// A string that represents the contents of the set, suitable for debugging.
  public var debugDescription: String {
    description
  }
}
