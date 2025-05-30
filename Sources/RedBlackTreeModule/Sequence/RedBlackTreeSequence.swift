// Copyright 2024 narumij
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

@usableFromInline
protocol RedBlackTreeSequence: RedBlackTreeSequenceBase, Sequence & Collection & BidirectionalCollection,
ReversableSequence
where
  Tree: BeginNodeProtocol & EndNodeProtocol & ___ForEachProtocol & DistanceProtocol & ___CollectionProtocol & ___IteratorSequcenceProtocol,
  Element == Tree.Element,
  Index: RedBlackTreeIndex,
Index.Tree == Tree
{
  associatedtype Tree
  associatedtype Index
  associatedtype Element
  var _tree: Tree { get }
}

extension RedBlackTreeSequence {

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> ElementIterator<Self.Tree> {
    ElementIterator(tree: _tree, start: _tree.__begin_node, end: _tree.__end_node())
  }
  
  @inlinable
  @inline(__always)
  public __consuming func makeReversedIterator() -> ReversedElementIterator<Self.Tree> {
    ReversedElementIterator(tree: _tree, start: _tree.__begin_node, end: _tree.__end_node())
  }
}

extension RedBlackTreeSequence {
  
  @inlinable
  @inline(__always)
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try _tree.___for_each_(body)
  }
}

extension RedBlackTreeSequence {

  @inlinable
  @inline(__always)
  func ___index(_ rawValue: _NodePtr) -> Index {
    .init(__tree: _tree, rawValue: rawValue)
  }
  
  @inlinable
  @inline(__always)
  func ___index_or_nil(_ p: _NodePtr?) -> Index? {
    p.map { ___index($0) }
  }
}

extension RedBlackTreeSequence {
  
  /// - Complexity: O(*n*)
  @inlinable
  public func sorted() -> [Element] {
    var result = [Element]()
    _tree.___for_each_ { member in
      result.append(member)
    }
    return result
  }
}

extension RedBlackTreeSequence {

  @inlinable
  @inline(__always)
  public var startIndex: Index {
    ___index(_tree.__begin_node)
  }

  @inlinable
  @inline(__always)
  public var endIndex: Index {
    ___index(_tree.__end_node())
  }

  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    _tree.___signed_distance(start.rawValue, end.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    ___index(_tree.___index(after: i.rawValue))
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    _tree.___formIndex(after: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    ___index(_tree.___index(before: i.rawValue))
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    _tree.___formIndex(before: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(_tree.___index(i.rawValue, offsetBy: distance))
  }

  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    _tree.___formIndex(&i.rawValue, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    ___index_or_nil(_tree.___index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue))
  }

  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    _tree.___formIndex(&i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }

  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {
    _read { yield _tree[position.rawValue] }
  }

  @inlinable
  @inline(__always)
  public subscript(position: RawIndex) -> Element {
    _read { yield _tree[position.rawValue] }
  }

#if false
  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    .init(tree: _tree, start: bounds.lowerBound.rawValue, end: bounds.upperBound.rawValue)
  }
  #endif
}

extension RedBlackTreeSequence {

  @inlinable
  @inline(__always)
  public func isValid(index: Index) -> Bool {
    _tree.___is_valid_index(index.rawValue)
  }

  @inlinable
  @inline(__always)
  public func isValid(index: RawIndex) -> Bool {
    _tree.___is_valid_index(index.rawValue)
  }
}

extension RedBlackTreeSequence {
  
  @inlinable
  public func reversed() -> ReversedSequence<Self> {
    .init(base: self)
  }
}

extension RedBlackTreeSequence {
  
  @inlinable
  @inline(__always)
  public var indices: Tree.Indices {
    _tree.makeIndices(start: _tree.__begin_node, end: _tree.__end_node())
  }
}
