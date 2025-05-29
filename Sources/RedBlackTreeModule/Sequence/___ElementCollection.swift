//
//  ElementCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/28.
//

struct ___ElementCollection<Base: RedBlackTreeCollectionable>: Sequence {
  
  @usableFromInline
  let _tree: Base.Tree

  @usableFromInline
  var _start, _end: _NodePtr

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

extension ___ElementCollection: Collection {
  
  @inlinable
  public subscript(position: Index) -> Base.Tree.Element {
    @inline(__always)
    _read { yield _tree[position.rawValue] }
  }
  
  public var startIndex: Index {
    .init(__tree: _tree, rawValue: _start)
  }
  
  public var endIndex: Index {
    .init(__tree: _tree, rawValue: _end)
  }
  
  public typealias Index = Base.Index
}

extension ___ElementCollection {
  
  @inlinable
  public subscript(position: RawIndex) -> Element {
    @inline(__always)
    _read { yield _tree[position.rawValue] }
  }
}

extension ___ElementCollection {
  
  public typealias SubSequence = Self
  
  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    .init(tree: _tree,
          start: bounds.lowerBound.rawValue,
          end: bounds.upperBound.rawValue)
  }
}

extension ___ElementCollection: BidirectionalCollection {
  
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
    .init(__tree: _tree, rawValue: _tree.index(before: i.rawValue))
  }
  
  @inlinable @inline(__always)
  public func index(after i: Index) -> Index {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    .init(__tree: _tree, rawValue: _tree.index(after: i.rawValue))
  }
  
#if false
  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    _tree.index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
      .map { Base.index(tree: _tree, rawValue: $0) }
  }
#endif
  
#if false
  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    if let ii = index(i, offsetBy: distance, limitedBy: limit) {
      i = ii
      return true
    }
    return false
  }
#endif
}

extension ___ElementCollection {

  public typealias Indices = Range<Base.Index>

  @inlinable
  @inline(__always)
  public var indices: Indices {
    startIndex..<endIndex
  }
}

extension ___ElementCollection {
  
  @inlinable
  @inline(__always)
  internal func ___is_valid_index(index i: _NodePtr) -> Bool {
    guard i != .nullptr, _tree.___is_valid(i) else {
      return false
    }
    return _tree.___ptr_closed_range_contains(_start, _end, i)
  }
}
