//
//  ElementCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/28.
//

public
struct ElementCollection<Base: RedBlackTreeCollectionable>: Sequence {
  
  @usableFromInline
  let _tree: Base.Tree

  @usableFromInline
  var _start, _end: _NodePtr

  @inlinable
  @inline(__always)
  internal init(tree: Base.Tree) where Base.Tree: BeginNodeProtocol & EndNodeProtocol {
    self.init(
      tree: tree,
      start: tree.__begin_node,
      end: tree.__end_node())
  }

  @inlinable
  @inline(__always)
  internal init(tree: Base.Tree, start: _NodePtr, end: _NodePtr) {
    _tree = tree
    _start = start
    _end = end
  }

  @inlinable
  public func makeIterator() -> ElementIterator<Base> {
    .init(tree: _tree, start: _start, end: _end)
  }
  
  @inlinable
  @inline(__always)
  internal func forEach(_ body: (Base.Tree.Element) throws -> Void) rethrows {
    var __p = _start
    while __p != _end {
      let __c = __p
      __p = _tree.__tree_next(__p)
      try body(_tree[__c])
    }
  }
}

extension ElementCollection: Collection {
  
  @inlinable
  public subscript(position: Index) -> Base.Tree.Element {
    @inline(__always)
    _read { yield _tree[position.rawValue] }
  }
  
  public var startIndex: Index {
    Base.index(tree: _tree, rawValue: _start)
  }
  
  public var endIndex: Index {
    Base.index(tree: _tree, rawValue: _end)
  }
  
  public typealias Index = Base.Index
}

extension ElementCollection {
  
  @inlinable
  public subscript(position: RawIndex) -> Element {
    @inline(__always)
    _read { yield _tree[position.rawValue] }
  }
}

extension ElementCollection {
  
  public typealias SubSequence = Self
  
  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    .init(tree: _tree, start: bounds.lowerBound.rawValue, end: bounds.upperBound.rawValue)
  }
}

extension ElementCollection: BidirectionalCollection {
  
  @inlinable @inline(__always)
  public var count: Int {
    _tree.distance(from: _start, to: _end)
  }

  // この実装がないと、迷子になる
  @inlinable @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    _tree.distance(from: start.rawValue, to: end.rawValue)
  }

  @inlinable @inline(__always)
  public func index(before i: Index) -> Index {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    Base.index(tree: _tree, rawValue: _tree.index(before: i.rawValue))
  }
  
  @inlinable @inline(__always)
  public func index(after i: Index) -> Index {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    Base.index(tree: _tree, rawValue: _tree.index(after: i.rawValue))
  }
}

extension ElementCollection {

  public typealias Indices = Range<Base.Index>

  @inlinable
  @inline(__always)
  public var indices: Indices {
    startIndex..<endIndex
  }
}
