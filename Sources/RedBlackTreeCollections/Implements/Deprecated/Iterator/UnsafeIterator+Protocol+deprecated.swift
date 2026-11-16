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
  public protocol UnsafeIteratorProtocol: _UnsafeNodePtrType, IteratorProtocol {
    init(_start: _SealedPtr, _end: _SealedPtr)
    var _sealed_start: _SealedPtr { get }
    var _sealed_end: _SealedPtr { get }
  }

  public protocol UnsafeAssosiatedIterator: _UnsafeNodePtrType, IteratorProtocol {
    associatedtype Base: ___TreeBase
    associatedtype Source: IteratorProtocol & Sequence
    init(_ t: Base.Type, _start: _SealedPtr, _end: _SealedPtr)
    var _source: Source { get }
    var _sealed_start: _SealedPtr { get }
    var _sealed_end: _SealedPtr { get }
  }
#endif
