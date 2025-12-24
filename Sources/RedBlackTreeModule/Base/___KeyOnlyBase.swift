//
//  ___KeyOnlyBase.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/24.
//

@usableFromInline
protocol ___KeyOnlyBase: ___Base {}

extension ___KeyOnlyBase {

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

extension ___KeyOnlyBase {

  @inlinable
  @inline(__always)
  func _forEach(_ body: (_Value) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(__tree_[$0])
    }
  }
}

extension ___KeyOnlyBase {

  @inlinable
  @inline(__always)
  func _forEach(_ body: (Index, _Value) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(___index($0), __tree_[$0])
    }
  }
}

extension ___KeyOnlyBase {

  @inlinable
  @inline(__always)
  public func ___forEach(_ body: (_NodePtr, _Value) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body($0, __tree_[$0])
    }
  }
}

extension ___KeyOnlyBase {

  /// - Complexity: O(*n*)
  @inlinable
  @inline(__always)
  func _sorted() -> [_Value] {
    __tree_.___copy_to_array(_start, _end)
  }
}
