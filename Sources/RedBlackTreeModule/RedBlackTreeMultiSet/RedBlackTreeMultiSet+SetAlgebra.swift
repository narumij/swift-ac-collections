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

/*
  __algorithm/set_union.h
  __algorithm/set_difference.h
  __algorithm/set_intersect.h
  __algorithm/set_symmetric_difference.h
  に準じた動作となっている。
  SwiftのSetAlgebraプロトコルがmulti_setを想定しているか不明なので、プロトコル適合はしていない。
*/

extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  public func union(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.formUnion(other)
    return result
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  //  @inline(__always)
  public mutating func formUnion(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___meld_multi(other.__tree_)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  public func symmetricDifference(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.formSymmetricDifference(other)
    return result
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  //  @inline(__always)
  public mutating func formSymmetricDifference(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___symmetric_difference(other.__tree_)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  public func intersection(_ other: RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.formIntersection(other)
    return result
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  //  @inline(__always)
  public mutating func formIntersection(_ other: RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___intersection(other.__tree_)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    @inlinable
    @inline(__always)
    public func difference(_ other: __owned RedBlackTreeMultiSet<Element>)
      -> RedBlackTreeMultiSet<Element>
    {
      var result = self
      result.formDifference(other)
      return result
    }

    /// - Complexity: O(*n* + *m*)
    @inlinable
    //  @inline(__always)
    public mutating func formDifference(_ other: __owned RedBlackTreeMultiSet<Element>) {
      __tree_ = __tree_.___difference(other.__tree_)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    @available(*, deprecated, message: "This API is buggy and may behave incorrectly.")
    @inlinable
    @inline(__always)
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
    //  @inline(__always)
    public mutating func formDifference(_ other: __owned RedBlackTreeMultiSet<Element>) {
      __tree_ = __tree_.___difference(other.__tree_)
    }
  }
#endif
