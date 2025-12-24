//
//  ___KeyValueBase.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/12/24.
//

@usableFromInline
protocol ___KeyValueSequence: ___Base
where
  Base: KeyValueComparer,
  _Value == RedBlackTreePair<_Key, _MappedValue>,
  Element == (key: _Key, value: _MappedValue)
{
  associatedtype _MappedValue
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  static func ___element(_ __value: _Value) -> Element {
    (__value.key, __value.value)
  }
  
  @inlinable
  @inline(__always)
  public static func ___tree_value(_ __element: Element) -> _Value {
    RedBlackTreePair(__element.key, __element.value)
  }
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  func ___element(_ __value: _Value) -> Element {
    Self.___element(__value)
  }
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  func ___value_for(_ __k: _Key) -> _Value? {
    let __ptr = __tree_.find(__k)
    return ___is_null_or_end(__ptr) ? nil : __tree_[__ptr]
  }
}

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
  func _forEach(_ body: (Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(Self.___element(__tree_[$0]))
    }
  }
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  func _forEach(_ body: (Index, Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(___index($0), Self.___element(__tree_[$0]))
    }
  }
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  public func ___forEach(_ body: (_NodePtr, Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body($0, Self.___element(__tree_[$0]))
    }
  }
}

extension ___KeyValueSequence {

  /// - Complexity: O(*n*)
  @inlinable
  @inline(__always)
  func _sorted() -> [Element] {
    __tree_.___copy_to_array(_start, _end, transform: Self.___element)
  }
}
