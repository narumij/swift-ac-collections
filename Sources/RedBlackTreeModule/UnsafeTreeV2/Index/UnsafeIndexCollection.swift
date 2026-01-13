//
//  UnsafeIndexCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/13.
//

public
  struct UnsafeIndexCollection<Base: ___TreeBase & ___TreeIndex>: UnsafeTreePointer
{
  @usableFromInline
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    __tree_ = .init(__tree_: tree)
    _start = start
    _end = end
    deallocator = tree.deallocator
  }

  @usableFromInline
  internal init(
    __tree_: ImmutableTree,
    start: _NodePtr,
    end: _NodePtr,
    deallocator: Deallocator
  ) {

    self.__tree_ = __tree_
    self._start = start
    self._end = end
    self.deallocator = deallocator
  }

  public typealias Tree = UnsafeTreeV2<Base>
  public typealias _NodePtr = Tree._NodePtr

  @usableFromInline
  typealias ImmutableTree = UnsafeImmutableTree<Base>
  @usableFromInline
  typealias Deallocator = _UnsafeNodeFreshPoolDeallocator

  public typealias Index = UnsafeIndexV2<Base>

  @usableFromInline
  internal let __tree_: ImmutableTree

  @usableFromInline
  internal var _start, _end: _NodePtr

  @usableFromInline
  internal var deallocator: Deallocator

  public typealias Element = Index
}

extension UnsafeIndexCollection {

  @inlinable
  @inline(__always)
  internal func ___index(_ p: _NodePtr) -> Index {
    .init(
      __tree_: __tree_,
      rawValue: p,
      deallocator: deallocator)
  }
}

extension UnsafeIndexCollection: Sequence, Collection {

  public var startIndex: Index { ___index(_start) }
  public var endIndex: Index { ___index(_end) }

  public func makeIterator() -> Iterator {
    .init(
      __tree_: __tree_,
      start: _start,
      end: _end,
      deallocator: deallocator)
  }

  @inlinable
  @inline(__always)
  public func reversed() -> Reversed {
    .init(
      __tree_: __tree_,
      start: _start,
      end: _end,
      deallocator: deallocator)
  }

  public func index(after i: Index) -> Index {
    i.advanced(by: 1)
  }

  public subscript(position: Index) -> Index {
    position
  }

  public subscript(bounds: Range<Index>) -> UnsafeIndexCollection {
    .init(
      __tree_: __tree_,
      start: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue,
      deallocator: bounds.lowerBound.deallocator)
  }
}

extension UnsafeIndexCollection {

  public struct Iterator: IteratorProtocol {

    @usableFromInline
    internal init(
      __tree_: ImmutableTree,
      start: _NodePtr,
      end: _NodePtr,
      deallocator: Deallocator
    ) {

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

extension UnsafeIndexCollection {

  public struct Reversed: IteratorProtocol, Sequence {

    @usableFromInline
    internal init(
      __tree_: ImmutableTree,
      start: _NodePtr,
      end: _NodePtr,
      deallocator: Deallocator
    ) {

      self.__tree_ = __tree_
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._begin = __tree_.__begin_node_
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
    internal var _current, _next, _start, _begin: _NodePtr

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
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : __tree_.nullptr
      return ___index(_current)
    }
  }
}
