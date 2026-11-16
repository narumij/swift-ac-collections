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

#if BENCHMARK
  extension UnsafeIterator {

    @frozen
    public struct _Indices<Base>:
      _UnsafeNodePtrType,
      IteratorProtocol,
      Sequence
    where Base: ___TreeBase {
      public typealias Tree = UnsafeTreeV2<Base>

      @usableFromInline
      var tree: Tree

      @inlinable
      init(start: _NodePtr, end: _NodePtr, tree: Tree) {
        self.source = .init(nullptr: tree.nullptr, _start: start, _end: end)
        self.tree = tree
      }

      @usableFromInline
      var source: _Obverse4

      @inlinable
      public mutating func next() -> UnsafeIndexV3? {
        source.next().map { tree.index($0) }
      }
    }
  }
#endif
