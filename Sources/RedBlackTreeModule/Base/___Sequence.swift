//
//  ___Sequence.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/24.
//

@usableFromInline
protocol ___Sequence: ___RedBlackTree___
where
  Base: ___TreeBase & ___TreeIndex,
  Tree == ___Tree<Base>,
  Index == Tree.Index,
  Indices == Tree.Indices,
  _Value == Tree._Value
{
  associatedtype Index
  associatedtype Indices
  associatedtype _Value
  var __tree_: Tree { get }
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}

//extension ___Sequence where Base: ScalarValueComparer {
extension ___Sequence {

  @inlinable
  @inline(__always)
  func _makeIterator() -> Tree._Values {
    .init(tree: __tree_, start: _start, end: _end)
  }

  @inlinable
  @inline(__always)
  func _reversed() -> Tree._Values.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___Sequence where Base: KeyValueComparer {

  @inlinable
  @inline(__always)
  func _makeIterator() -> Tree._KeyValues {
    .init(tree: __tree_, start: _start, end: _end)
  }

  @inlinable
  @inline(__always)
  func _reversed() -> Tree._KeyValues.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___Sequence {
  @inlinable
  @inline(__always)
  var _indices: Indices {
    __tree_.makeIndices(start: _start, end: _end)
  }
}

extension ___Sequence {

  @inlinable
  @inline(__always)
  func _forEach(_ body: (_Value) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(__tree_[$0])
    }
  }
}

extension ___Sequence {

  @inlinable
  @inline(__always)
  public func ___forEach(_ body: (_NodePtr, _Value) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body($0, __tree_[$0])
    }
  }
}

extension ___Sequence where Base: KeyValueComparer & ___RedBlackTreeKeyValueBase {

  @inlinable
  @inline(__always)
  func _forEach(_ body: (Base.Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(Base.___element(__tree_[$0]))
    }
  }
}

extension ___Sequence {

  @inlinable
  @inline(__always)
  public func ___node_positions() -> ___SafePointers<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___Sequence {
  
  @inlinable
  @inline(__always)
  public mutating func ___element(at ptr: _NodePtr) -> _Value? {
    guard !__tree_.___is_subscript_null(ptr) else {
      return nil
    }
    return __tree_[ptr]
  }
}

extension ___Sequence {
  
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

extension ___Sequence {

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
