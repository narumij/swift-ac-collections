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

extension RedBlackTreeMultiMap {

  /// releaseビルドでは無効化されています(?)
  @inlinable
  package func ___tree_invariant() -> Bool {
    #if SIZECHECK
      // 並行してサイズもチェックする。その分遅い
      __tree_.count == __tree_.___signed_distance(__tree_.__begin_node_, __tree_.end)
        && __tree_.__tree_invariant(__tree_.__root)
    #else
      __tree_.__tree_invariant(__tree_.__root)
    #endif
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  package func ___is_garbaged(_ index: Index) -> Bool {
    switch __tree_.__purified_(index).purified {
    case .failure:
      return true
    default:
      return false
    }
  }
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeMultiMap {

    package var _copyCount: UInt {
      get { __tree_.copyCount }
      set { __tree_.copyCount = newValue }
    }
  }
#endif

extension RedBlackTreeMultiMap {

  package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
    .init(_start: _sealed_start, _end: _sealed_end)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(1)
    @inlinable
    public subscript(_result position: Index) -> Result<Element, SealError> {
      __tree_.__purified_(position)
        .map { $0.pointer.__value_().pointee }
    }
  }
#endif
