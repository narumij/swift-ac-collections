//
//  ___Common.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/24.
//

@usableFromInline
protocol ___Common: ___Base {}

extension ___Common {

  @inlinable
  @inline(__always)
  var ___is_empty: Bool {
    __tree_.___is_empty
  }

  @inlinable
  @inline(__always)
  var ___first: _Value? {
    ___is_empty ? nil : __tree_[_start]
  }

  @inlinable
  @inline(__always)
  var ___last: _Value? {
    ___is_empty ? nil : __tree_[__tree_.__tree_prev_iter(_end)]
  }
}

extension ___Common {

  @inlinable
  @inline(__always)
  func ___prev(_ i: _NodePtr) -> _NodePtr {
    __tree_.__tree_prev_iter(i)
  }

  @inlinable
  @inline(__always)
  func ___next(_ i: _NodePtr) -> _NodePtr {
    __tree_.__tree_next_iter(i)
  }

  @inlinable
  @inline(__always)
  func ___advanced(_ i: _NodePtr, by distance: Int) -> _NodePtr {
    __tree_.___tree_adv_iter(i, by: distance)
  }

  @inlinable
  @inline(__always)
  func _distance(from start: Index, to end: Index) -> Int {
    __tree_.___distance(from: start.rawValue, to: end.rawValue)
  }
}

extension ___Common {

  @inlinable
  @inline(__always)
  func ___is_valid(_ index: _NodePtr) -> Bool {
    !__tree_.___is_subscript_null(index)
  }

  @inlinable
  @inline(__always)
  func ___is_valid_range(_ p: _NodePtr, _ l: _NodePtr) -> Bool {
    !__tree_.___is_range_null(p, l)
  }
}

extension ___Common {

  @inlinable
  @inline(__always)
  public var ___key_comp: (_Key, _Key) -> Bool {
    __tree_.value_comp
  }

  @inlinable
  @inline(__always)
  public var ___value_comp: (_Value, _Value) -> Bool {
    { __tree_.value_comp(Base.__key($0), Base.__key($1)) }
  }
}

extension ___Common {

  @inlinable
  @inline(__always)
  public func ___is_garbaged(_ index: _NodePtr) -> Bool {
    __tree_.___is_garbaged(index)
  }
}

extension ___Common {

  /// releaseビルドでは無効化されています
  @inlinable
  @inline(__always)
  public func ___tree_invariant() -> Bool {
    #if true
      // 並行してサイズもチェックする。その分遅い
      __tree_.count == __tree_.___signed_distance(__tree_.__begin_node_, .end)
        && __tree_.__tree_invariant(__tree_.__root())
    #else
      __tree_.__tree_invariant(__tree_.__root())
    #endif
  }
}

extension ___Common {

  @inlinable
  @inline(__always)
  public func _isIdentical(to other: Self) -> Bool {
    __tree_.isIdentical(to: other.__tree_) && _start == other._start && _end == other._end
  }
}

extension ___Common {

  @inlinable
  @inline(__always)
  public func ___start() -> _NodePtr { _start }

  @inlinable
  @inline(__always)
  public func ___end() -> _NodePtr { _end }
}

extension ___Common {
  @inlinable
  @inline(__always)
  var _indices: Indices {
    __tree_.makeIndices(start: _start, end: _end)
  }
}

extension ___Common {

  @inlinable
  subscript(_checked position: Index) -> _Value {
    @inline(__always) _read {
      __tree_.___ensureValid(subscript: position.rawValue)
      yield __tree_[position.rawValue]
    }
  }

  @inlinable
  subscript(_unchecked position: Index) -> _Value {
    @inline(__always) _read {
      yield __tree_[position.rawValue]
    }
  }
}

extension ___Common {

  @inlinable
  @inline(__always)
  func _elementsEqual<OtherSequence>(
    _ other: OtherSequence, by areEquivalent: (_Value, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try __tree_.elementsEqual(_start, _end, other, by: areEquivalent)
  }

  @inlinable
  @inline(__always)
  func _lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (_Value, _Value) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, _Value == OtherSequence.Element {
    try __tree_.lexicographicallyPrecedes(_start, _end, other, by: areInIncreasingOrder)
  }
}

extension ___Common {

  @inlinable
  @inline(__always)
  public func ___node_positions() -> ___SafePointers<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___Common {

  @inlinable
  @inline(__always)
  public mutating func ___element(at ptr: _NodePtr) -> _Value? {
    guard !__tree_.___is_subscript_null(ptr) else {
      return nil
    }
    return __tree_[ptr]
  }
}
