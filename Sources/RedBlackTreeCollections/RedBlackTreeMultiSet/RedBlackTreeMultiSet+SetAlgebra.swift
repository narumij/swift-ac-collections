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

/*
  __algorithm/set_union.h
  __algorithm/set_difference.h
  __algorithm/set_intersect.h
  __algorithm/set_symmetric_difference.h
  に準じた動作となっている。
  SwiftのSetAlgebraプロトコルがmulti_setを想定しているか不明なので、プロトコル適合はしていない。
 (swift-collectionsのissuesに対応してないと明言されていた)
*/

extension RedBlackTreeMultiSet {

  @inlinable
  public func union(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    .init(__tree_: __tree_.___meld_multi(other.__tree_))
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  public mutating func formUnion(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___meld_multi(other.__tree_)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public func symmetricDifference(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    .init(__tree_: __tree_.___symmetric_difference(other.__tree_))
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  public mutating func formSymmetricDifference(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___symmetric_difference(other.__tree_)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public func intersection(_ other: RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    .init(__tree_: __tree_.___intersection(other.__tree_))
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  public mutating func formIntersection(_ other: RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___intersection(other.__tree_)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    @inlinable
    public func difference(_ other: __owned RedBlackTreeMultiSet<Element>)
      -> RedBlackTreeMultiSet<Element>
    {
      .init(__tree_: __tree_.___difference(other.__tree_))
    }

    /// - Complexity: O(*n* + *m*)
    @inlinable
    public mutating func formDifference(_ other: __owned RedBlackTreeMultiSet<Element>) {
      __tree_ = __tree_.___difference(other.__tree_)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    @available(*, deprecated, message: "This API is buggy and may behave incorrectly.")
    @inlinable
    public func difference(_ other: __owned RedBlackTreeMultiSet<Element>)
      -> RedBlackTreeMultiSet<Element>
    {
      var result = self
      result.formDifference(other)
      return result
    }

    /// - Complexity: O(*n* + *m*)
    @available(*, deprecated, message: "This API is buggy and may behave incorrectly.")
    @inlinable
    public mutating func formDifference(_ other: __owned RedBlackTreeMultiSet<Element>) {
      __tree_ = __tree_.___difference(other.__tree_)
    }
  }
#endif
