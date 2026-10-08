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

#if COMPATIBLE_ATCODER_2025
@_documentation(visibility: internal)
public protocol ObverseIterator: IteratorProtocol
where Element == ReversedIterator.Element {
  associatedtype ReversedIterator: IteratorProtocol
  func reversed() -> ReversedIterator
}

extension ObverseIterator {
  public typealias Reversed = ReversedIterator
}

@_documentation(visibility: internal)
public protocol ReverseIterator: IteratorProtocol {}
#endif

#if !COMPATIBLE_ATCODER_2025
  @_documentation(visibility: internal)
  public protocol UnsafeAssosiatedIterator: _UnsafeNodePtrType, IteratorProtocol
  where Source.Element == _NodePtr {
    associatedtype Base: ___TreeBase
    associatedtype Source: IteratorProtocol
    init(source: Source)
  }
#endif
