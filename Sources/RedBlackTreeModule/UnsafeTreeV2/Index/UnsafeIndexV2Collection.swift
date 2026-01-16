//
//  UnsafeIndexCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/13.
//

// TODO: 仕様及び設計について再検討すること
// プロトコル適合問題だけに対処して止まっている気がする
// そもそも使いやすくすること自体が不可能かもしれない

// TODO: 再度チューニングすること
// 荒く書いた段階なのでいろいろ手抜きがある

public
  struct UnsafeIndexV2Collection<Base: ___TreeBase & ___TreeIndex>:
    UnsafeTreeProtocol, UnsafeImmutableIndexingProtocol
{
  @usableFromInline
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    __tree_ = .init(__tree_: tree)
    _start = start
    _end = end
    poolLifespan = tree.poolLifespan
  }

  @usableFromInline
  internal init(
    __tree_: ImmutableTree,
    start: _NodePtr,
    end: _NodePtr,
    poolLifespan: PoolLifespan
  ) {

    self.__tree_ = __tree_
    self._start = start
    self._end = end
    self.poolLifespan = poolLifespan
  }

  // TODO: Intに変更する検討
  // 計算量が問題
  public typealias Index = UnsafeIndexV2<Base>

  @usableFromInline
  internal let __tree_: ImmutableTree

  @usableFromInline
  internal var _start, _end: _NodePtr

  @usableFromInline
  internal var poolLifespan: PoolLifespan

  public typealias Element = Index
}

#if false
  // TODO: 標準実装だとdistanceが重かった記憶。追加すること
  // TODO: あとで仕上げる
  extension UnsafeIndexV2Collection {

    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public func distance(from start: Index, to end: Index) -> Int {
      __tree_.___distance(from: start.rawValue, to: end.rawValue)
    }
  }
#endif

extension UnsafeIndexV2Collection: Sequence, Collection, BidirectionalCollection {

  public var startIndex: Index { ___index(_start) }
  public var endIndex: Index { ___index(_end) }

  public func makeIterator() -> Iterator {
    .init(
      __tree_: __tree_,
      start: _start,
      end: _end,
      poolLifespan: poolLifespan)
  }

  @inlinable
  @inline(__always)
  public func reversed() -> Reversed {
    .init(
      __tree_: __tree_,
      start: _start,
      end: _end,
      poolLifespan: poolLifespan)
  }

  public func index(after i: Index) -> Index {
    i.advanced(by: 1)
  }

  public func index(before i: Index) -> Index {
    i.advanced(by: -1)
  }

  public subscript(position: Index) -> Index {
    position
  }

  #if COMPATIBLE_ATCODER_2025
    public subscript(bounds: Range<Index>) -> UnsafeIndexV2Collection {
      .init(
        __tree_: __tree_,
        start: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue,
        poolLifespan: bounds.lowerBound.poolLifespan)
    }
  #else
    @inlinable
    @inline(__always)
    public subscript<R>(bounds: R) -> SubSequence where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)
      return .init(
        tree: __tree_,
        start: __tree_.rawValue(bounds.lowerBound),
        end: __tree_.rawValue(bounds.upperBound))
    }
  #endif
}

extension UnsafeIndexV2Collection {

  public struct Iterator: IteratorProtocol, UnsafeTreeProtocol, UnsafeImmutableIndexingProtocol {

    @usableFromInline
    internal init(
      __tree_: ImmutableTree,
      start: _NodePtr,
      end: _NodePtr,
      poolLifespan: PoolLifespan
    ) {

      self.__tree_ = __tree_
      self._current = start
      self._next = __tree_.__tree_next(start)
      self._end = end
      self.poolLifespan = poolLifespan
    }

    @usableFromInline
    internal let __tree_: ImmutableTree

    @usableFromInline
    internal var _current, _next, _end: _NodePtr

    @usableFromInline
    internal var poolLifespan: PoolLifespan

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

extension UnsafeIndexV2Collection {

  public struct Reversed: IteratorProtocol, Sequence, UnsafeImmutableIndexingProtocol {

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = .init(__tree_: tree)
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._begin = __tree_.__begin_node_
      self.poolLifespan = tree.poolLifespan
    }

    @usableFromInline
    internal init(
      __tree_: ImmutableTree,
      start: _NodePtr,
      end: _NodePtr,
      poolLifespan: PoolLifespan
    ) {

      self.__tree_ = __tree_
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._begin = __tree_.__begin_node_
      self.poolLifespan = poolLifespan
    }

    @usableFromInline
    internal let __tree_: ImmutableTree

    @usableFromInline
    internal var _current, _next, _start, _begin: _NodePtr

    @usableFromInline
    internal var poolLifespan: PoolLifespan

    public mutating func next() -> Index? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : __tree_.nullptr
      return ___index(_current)
    }
  }
}

#if swift(>=5.5)
  extension UnsafeIndexV2Collection: @unchecked Sendable {}
#endif

// MARK: - Is Identical To

extension UnsafeIndexV2Collection: ___UnsafeImmutableIsIdenticalToV2 {}
