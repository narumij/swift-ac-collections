//
//  RedBlackTreeSequence.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/29.
//

@usableFromInline
protocol RedBlackTreeSequence: RedBlackTreeRawIndexIteratable, Sequence & Collection & BidirectionalCollection, RandomAccessCollection
where
  Tree: BeginNodeProtocol & EndNodeProtocol & ForEachProtocol & DistanceProtocol & CollectionableProtocol,
  Element == Tree.Element,
  Index: RedBlackTreeIndex, Index.Tree == Tree
{
  associatedtype Tree
  associatedtype Index
  associatedtype Element
  var _tree: Tree { get }
}

#if true
//@usableFromInline
//protocol RedBlackTreeSequence: RedBlackTreeRawIndexIteratable, Sequence & Collection & BidirectionalCollection
//where Tree: BeginNodeProtocol & EndNodeProtocol & ForEachProtocol & ___CountProtocol & DistanceProtocol & CollectionableProtocol,
//      Tree.Element == Element,
//      Index: RedBlackTreeIndex, Index.Tree == Tree
//{
//  associatedtype Tree
//  associatedtype Index
//  var _tree: Tree { get }
//}

extension RedBlackTreeSequence {
  
//  public typealias Indices = Range<Index>

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try _tree.___for_each_(body)
  }

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> ElementIterator<Self> {
    ElementIterator(tree: _tree, start: _tree.__begin_node, end: _tree.__end_node())
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

#if false
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
  public var count: Int {
    _tree.count
  }
#endif

  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    _tree.___signed_distance(start.rawValue, end.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    ___index(_tree.index(after: i.rawValue))
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    _tree.formIndex(after: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    ___index(_tree.index(before: i.rawValue))
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    _tree.formIndex(before: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(_tree.index(i.rawValue, offsetBy: distance))
  }

  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    _tree.formIndex(&i.rawValue, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    ___index_or_nil(_tree.index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue))
  }

  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    _tree.formIndex(&i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }

#if false
  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {
    return _tree[position.rawValue]
  }

  @inlinable
  @inline(__always)
  public subscript(position: RawIndex) -> Element {
    return _tree[position.rawValue]
  }

  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    .init(tree: _tree, start: bounds.lowerBound.rawValue, end: bounds.upperBound.rawValue)
  }
  #endif
}
#endif
