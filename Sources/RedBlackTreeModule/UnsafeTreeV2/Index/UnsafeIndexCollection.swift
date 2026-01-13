//
//  UnsafeIndexCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/13.
//

public
  struct UnsafeIndexCollection<Base: ___TreeBase & ___TreeIndex>: UnsafeTreePointer
{

  internal init(tree: UnsafeTreeV2<Base>, start: _NodePtr, end: _NodePtr) {

    self.startIndex = .init(tree: tree, rawValue: start)
    self.endIndex = .init(tree: tree, rawValue: end)
    self.deallocator = tree.deallocator
  }

  internal init(
    startIndex: Index,
    endIndex: Index,
    deallocator: Deallocator
  ) {

    self.startIndex = startIndex
    self.endIndex = endIndex
    self.deallocator = deallocator
  }

  public typealias Index = UnsafeIndexV2<Base>

  @usableFromInline
  typealias Deallocator = _UnsafeNodeFreshPoolDeallocator

  public var startIndex: Index
  public var endIndex: Index

  @usableFromInline
  internal var deallocator: Deallocator

  public typealias Element = Index
}

extension UnsafeIndexCollection {

  @inlinable
  @inline(__always)
  internal func ___index(_ p: _NodePtr) -> Index {
    .init(
      __tree_: endIndex.__tree_,
      rawValue: p,
      deallocator: endIndex.deallocator)
  }

  public struct Iterator: IteratorProtocol {
    
    internal init(__tree_: ImmutableTree,
                  start: _NodePtr,
                  end: _NodePtr,
                  deallocator: Deallocator) {
      
      self.__tree_ = __tree_
      self._current = start
      self._next = __tree_.__tree_next(start)
      self._end = end
      self.deallocator = deallocator
    }
    
    public typealias Tree = UnsafeTreeV2<Base>
    public typealias _NodePtr = Tree._NodePtr

    @usableFromInline
    typealias ImmutableTree = UnsafeImmutableTree<Base>
    @usableFromInline
    typealias Deallocator = _UnsafeNodeFreshPoolDeallocator

    @usableFromInline
    internal let __tree_: ImmutableTree

    @usableFromInline
    internal var _current, _next, _end: _NodePtr

    @usableFromInline
    internal var deallocator: Deallocator

    @inlinable
    internal func ___index(_ p: _NodePtr) -> Index {
      .init(
        __tree_: __tree_,
        rawValue: p,
        deallocator: deallocator)
    }

    public mutating func next() -> Index? {
      guard _current != _end else { return nil }
      defer {
        _current = _next
        _next = _next == _end ? _end : __tree_.__tree_next(_next)
      }
      return ___index(_current)
    }
  }
}

extension UnsafeIndexCollection: Sequence, Collection {

  public func makeIterator() -> Iterator {
    .init(__tree_: startIndex.__tree_,
          start: startIndex.rawValue,
          end: endIndex.rawValue,
          deallocator: startIndex.deallocator)
  }

  public func index(after i: Index) -> Index {
    i.advanced(by: 1)
  }

  public subscript(position: Index) -> Index {
    position
  }

  public subscript(bounds: Range<Index>) -> UnsafeIndexCollection {
    .init(
      startIndex: bounds.lowerBound,
      endIndex: bounds.upperBound,
      deallocator: deallocator)
  }
}
