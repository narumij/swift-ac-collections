//
//  ElementCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/29.
//

@usableFromInline
protocol ElementCollection:
  RedBlackTreeRawIndexIteratable & Sequence & Collection & BidirectionalCollection
where
  Tree == Base.Tree,
  Index == Base.Index,
  Indices == Range<Index>,
  Element == Tree.Element,
  Iterator == ElementIterator<Base>,
  SubSequence == Self
{
  associatedtype Base: RedBlackTreeCollectionable
  var _tree: Base.Tree { get }
  var _start: _NodePtr { get set }
  var _end: _NodePtr { get set }
  init(tree: Base.Tree, start: _NodePtr, end: _NodePtr)
}

extension ElementCollection {

  @inlinable
  public func makeIterator() -> ElementIterator<Base> {
    .init(tree: _tree, start: _start, end: _end)
  }
}

extension ElementCollection {

  @inlinable @inline(__always)
  public var count: Int {
    _tree.distance(from: _start, to: _end)
  }
}

extension ElementCollection {

  @inlinable
  @inline(__always)
  internal func forEach(_ body: (Element) throws -> Void) rethrows {
    var __p = _start
    while __p != _end {
      let __c = __p
      __p = _tree.__tree_next(__p)
      try body(_tree[__c])
    }
  }
}

extension ElementCollection {

  //  public typealias Index = Index

  @inlinable
  func index(rawValue: _NodePtr) -> Index {
    .init(__tree: _tree, rawValue: rawValue)
  }
}

extension ElementCollection {

  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {

    _read {
      guard _tree.___ptr_less_than_or_equal(_start, position.rawValue),
        _tree.___ptr_less_than(position.rawValue, _end)
      else {
        fatalError(.outOfRange)
      }
      yield _tree[position.rawValue]
    }
  }
}

extension ElementCollection {

  @inlinable
  @inline(__always)
  public var indices: Indices {
    startIndex..<endIndex
  }
}

extension ElementCollection {

  public var startIndex: Index {
    index(rawValue: _start)
  }

  public var endIndex: Index {
    index(rawValue: _end)
  }
}

extension ElementCollection {

  @inlinable
  public subscript(position: RawIndex) -> Element {
    @inline(__always)
    _read { yield _tree[position.rawValue] }
  }
}

extension ElementCollection {

  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Index>) -> SubSequence {
    guard _tree.___ptr_less_than_or_equal(_start, bounds.lowerBound.rawValue),
      _tree.___ptr_less_than_or_equal(bounds.upperBound.rawValue, _end)
    else {
      fatalError(.outOfRange)
    }
    return .init(
      tree: _tree,
      start: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue)
  }
}

extension ElementCollection {

  // この実装がないと、迷子になる?
  @inlinable @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    _tree.distance(from: start.rawValue, to: end.rawValue)
  }
}

extension ElementCollection {

  @inlinable @inline(__always)
  public func index(before i: Index) -> Index {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    index(rawValue: _tree.index(before: i.rawValue))
  }

  @inlinable @inline(__always)
  public func index(after i: Index) -> Index {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    index(rawValue: _tree.index(after: i.rawValue))
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    _tree.index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
      .map { index(rawValue: $0) }
  }
}

extension ElementCollection {

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    _tree.formIndex(after: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    // 標準のArrayが単純に減算することにならい、範囲チェックをしない
    _tree.formIndex(before: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    _tree.formIndex(&i.rawValue, offsetBy: distance)
  }

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
}

extension ElementCollection {

  /// RawIndexは赤黒木ノードへの軽量なポインタとなっていて、rawIndicesはRawIndexのシーケンスを返します。
  /// 削除時のインデックス無効対策がイテレータに施してあり、削除操作に利用することができます。
  @inlinable
  @inline(__always)
  public var rawIndices: RawIndexSequence<Self> {
    RawIndexSequence(
      tree: _tree,
      start: _start,
      end: _end)
  }
}

extension ElementCollection {

  @inlinable @inline(__always)
  public var rawIndexedElements: RawIndexedSequence<Self> {
    RawIndexedSequence(
      tree: _tree,
      start: _start,
      end: _end)
  }

  @available(*, deprecated, renamed: "rawIndexedElements")
  @inlinable @inline(__always)
  public func enumerated() -> RawIndexedSequence<Self> {
    rawIndexedElements
  }
}

extension ElementCollection {

  @inlinable
  @inline(__always)
  func ___is_valid_index(index i: _NodePtr) -> Bool {
    guard i != .nullptr, _tree.___is_valid(i) else {
      return false
    }
    return _tree.___ptr_closed_range_contains(_start, _end, i)
  }

  @inlinable
  @inline(__always)
  public func isValid(index i: Index) -> Bool {
    ___is_valid_index(index: i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func isValid(index i: RawIndex) -> Bool {
    ___is_valid_index(index: i.rawValue)
  }
}
