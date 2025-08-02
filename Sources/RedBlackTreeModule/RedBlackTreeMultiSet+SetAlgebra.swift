//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

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
    _storage = .init(tree: __tree_.___meld_multi(other.__tree_))
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
    _storage = .init(tree: __tree_.___symmetric_difference(other.__tree_))
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
    _storage = .init(tree: __tree_.___intersection(other.__tree_))
  }
}

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
    _storage = .init(tree: __tree_.___difference(other.__tree_))
  }
}
