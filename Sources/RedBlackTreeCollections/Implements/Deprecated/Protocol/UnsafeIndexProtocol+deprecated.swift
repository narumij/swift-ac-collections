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
  public protocol UnsafeIndicesBinding: UnsafeTreeBindingV2
  where Indices == UnsafeTreeV2<Base>.Indices, Base: ___TreeIndex {
    associatedtype Indices
  }

  // Indexが何であるかをしり、その生成には何が必要で、どう生成するのかを知っている
  @usableFromInline
  protocol UnsafeIndexProtocol_tie: _UnsafeNodePtrType
  where Index == UnsafeIndexV2<Base> {
    associatedtype Base: ___TreeBase & ___TreeIndex
    associatedtype Index
    var tied: _TiedRawBuffer { get }
  }

  extension UnsafeIndexProtocol_tie {

    @inlinable
    package func ___index(_ p: _SealedPtr) -> Index {
      Index(sealed: p, tie: tied)
    }
  }

  @usableFromInline
  protocol UnsafeIndexProtocol_tree: UnsafeIndexBindingV2 & UnsafeTreeHostV2 {
    func ___index(_ p: _SealedPtr) -> Index
  }

  extension UnsafeIndexProtocol_tree {

    @inlinable
    internal func ___index(_ p: _SealedPtr) -> Index {
      Index(sealed: p, tie: __tree_.tied)
    }
  }

  @usableFromInline
  protocol UnsafeIndicesProtoocl: UnsafeTreeSealedRangeBaseInterfaceV2 & UnsafeIndicesBinding {}

  extension UnsafeIndicesProtoocl {

    @inlinable
    internal var _indices: Indices {
      .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
    }
  }

  extension UnsafeIndexProviderProtocolV2 {

    @inlinable
    internal func ___index_or_nil(_ p: _SealedPtr) -> Index? {
      !p.isValid ? nil : ___index(p)
    }

    @inlinable
    internal func ___index_or_nil(_ p: _SealedPtr?) -> Index? {
      p.flatMap { ___index_or_nil($0) }
    }
  }
#endif
