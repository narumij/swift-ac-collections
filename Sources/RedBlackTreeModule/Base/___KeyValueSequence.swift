//
//  ___KeyValueBase.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/24.
//

@usableFromInline
protocol ___KeyValueSequence: ___Base 
where Base: KeyValueComparer & ___RedBlackTreeKeyValueBase {}

extension ___KeyValueSequence {

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

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  func _forEach(_ body: (Base.Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(Base.___element(__tree_[$0]))
    }
  }
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  func _forEach(_ body: (Index, Base.Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(___index($0), Base.___element(__tree_[$0]))
    }
  }
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  public func ___forEach(_ body: (_NodePtr, Base.Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body($0, Base.___element(__tree_[$0]))
    }
  }
}

extension ___KeyValueSequence {

  /// - Complexity: O(*n*)
  @inlinable
  @inline(__always)
  func _sorted() -> [Base.Element] {
    __tree_.___copy_to_array(_start, _end, transform: Base.___element)
  }
}
