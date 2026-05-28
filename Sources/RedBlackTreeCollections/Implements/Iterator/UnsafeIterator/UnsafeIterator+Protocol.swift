//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

public protocol ObverseIterator: IteratorProtocol
where Element == ReversedIterator.Element {
  associatedtype ReversedIterator: IteratorProtocol
  func reversed() -> ReversedIterator
}

extension ObverseIterator {
  public typealias Reversed = ReversedIterator
}

public protocol ReverseIterator: IteratorProtocol {}

#if !COMPATIBLE_ATCODER_2025
  public protocol UnsafeIteratorProtocol: _UnsafeNodePtrType, IteratorProtocol {
    init(_start: _NodePtr, _end: _NodePtr)
  }

  public protocol UnsafeAssosiatedIterator: _UnsafeNodePtrType, IteratorProtocol
  where Source.Element == _NodePtr {
    associatedtype Base: ___TreeBase
    associatedtype Source: IteratorProtocol & UnsafeIteratorProtocol
    init(source: Source)
  }
#endif
