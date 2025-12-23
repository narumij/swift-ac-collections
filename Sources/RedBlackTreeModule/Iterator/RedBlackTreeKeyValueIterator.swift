//
//  RedBlackTreeKeyValueIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/23.
//

extension RedBlackTreeIterator {

  @frozen
  public struct KeyValues: Sequence, IteratorProtocol
  where Base: KeyValueComparer {

    public typealias Tree = ___Tree<Base>

    @usableFromInline
    let __tree_: Tree

    @usableFromInline
    var _start, _end, _current, _next: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = start
      self._start = start
      self._end = end
      self._next = start == .end ? .end : tree.__tree_next_iter(start)
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> (key: Base._Key, value: Base._MappedValue)? {
      guard _current != _end else { return nil }
      defer {
        _current = _next
        _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
      }
      return (__tree_.__get_value(_current), __tree_.___mapped_value(_current))
    }
  }
}

extension RedBlackTreeIterator.KeyValues where Base: KeyValueComparer {

  #if COMPATIBLE_ATCODER_2025
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func keys() -> RedBlackTreeIterator<Base>.Keys {
      .init(tree: __tree_, start: _start, end: _end)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func values() -> RedBlackTreeIterator<Base>.MappedValues {
      .init(tree: __tree_, start: _start, end: _end)
    }
  #else
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var keys: RedBlackTreeIterator<Base>.Keys {
      .init(tree: __tree_, start: _start, end: _end)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var values: RedBlackTreeIterator<Base>.MappedValues {
      .init(tree: __tree_, start: _start, end: _end)
    }
  #endif
}

extension RedBlackTreeIterator.KeyValues: Equatable
where Base._Key: Equatable, Base._MappedValue: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs, by: ==)
  }
}

extension RedBlackTreeIterator.KeyValues: Comparable
where Base._Key: Comparable, Base._MappedValue: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs, by: <)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIterator.KeyValues: @unchecked Sendable
  where Tree._Value: Sendable {}
#endif

// MARK: - Is Identical To

extension RedBlackTreeIterator.KeyValues: ___RedBlackTreeIsIdenticalTo {}
