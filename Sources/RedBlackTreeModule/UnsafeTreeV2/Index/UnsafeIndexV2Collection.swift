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
  public typealias Element = Index
  public typealias SubSequence = Self
  public typealias Iterator = UnsafeIterator.IndexObverse<Base>
  public typealias Reversed = UnsafeIterator.IndexReverse<Base>

  @usableFromInline
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    __tree_ = .init(__tree_: tree)
    _start = start
    _end = end
    tied = tree.tied
  }

  @usableFromInline
  internal init(
    __tree_: ImmutableTree,
    start: _NodePtr,
    end: _NodePtr,
    tie: _TiedRawBuffer
  ) {

    self.__tree_ = __tree_
    self._start = start
    self._end = end
    self.tied = tie
  }

  // TODO: Intに変更する検討
  // 計算量が問題
  public typealias Index = UnsafeIndexV2<Base>

  @usableFromInline
  internal let __tree_: ImmutableTree

  @usableFromInline
  internal var _start, _end: _NodePtr

  @usableFromInline
  internal var tied: _TiedRawBuffer
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
      tie: tied)
  }

  public func reversed() -> Reversed {
    .init(
      __tree_: __tree_,
      start: _start,
      end: _end,
      tie: tied)
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

  public subscript(bounds: Range<Index>) -> UnsafeIndexV2Collection {
    .init(
      __tree_: __tree_,
      start: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue,
      tie: bounds.lowerBound.tied)
  }

  #if !COMPATIBLE_ATCODER_2025
    public subscript(bounds: UnsafeIndexV2RangeExpression<Base>) -> UnsafeIndexV2Collection {
      let (lower, upper) = bounds.rawValue.pair(
        _begin: __tree_.__begin_node_,
        _end: __tree_.__end_node)
      return .init(__tree_: __tree_, start: lower, end: upper, tie: tied)
    }
  #endif
}

#if swift(>=5.5)
  extension UnsafeIndexV2Collection: @unchecked Sendable {}
#endif

// MARK: - Is Identical To

extension UnsafeIndexV2Collection: ___UnsafeImmutableIsIdenticalToV2 {}
