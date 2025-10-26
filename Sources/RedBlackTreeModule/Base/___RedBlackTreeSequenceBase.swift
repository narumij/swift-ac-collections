// Copyright 2024 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

@usableFromInline
protocol ___RedBlackTreeSequenceBase: ___RedBlackTreeIndexing & ___TreeBase, Collection
where
  Tree == ___Tree<Self>,
  Index == Tree.Index,
  Indices == Tree.Indices,
  _Value == Tree._Value
{
  associatedtype Tree
  associatedtype Index
  associatedtype Indices
  associatedtype _Value
  var __tree_: Tree { get }
  func makeIterator() -> Tree._Values
}

// MARK: -

extension ___RedBlackTreeSequenceBase {

  @inlinable
  @inline(__always)
  __consuming func _makeIterator() -> Tree._Values {
    .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node())
  }

  @inlinable
  @inline(__always)
  func _forEach(_ body: (_Value) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: __tree_.__begin_node_, __l: __tree_.__end_node()) {
      try body(__tree_[$0])
    }
  }
  
  @inlinable
  @inline(__always)
  func _forEach(_ body: (Index, _Value) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: __tree_.__begin_node_, __l: __tree_.__end_node()) {
      try body(___index($0), __tree_[$0])
    }
  }

  @inlinable
  @inline(__always)
  public func ___forEach(_ body: (_NodePtr, _Value) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: __tree_.__begin_node_, __l: __tree_.__end_node()) {
      try body($0, __tree_[$0])
    }
  }
}

extension ___RedBlackTreeSequenceBase {
  
  @inlinable
  @inline(__always)
  var _startIndex: Index {
    ___index(__tree_.__begin_node_)
  }

  @inlinable
  @inline(__always)
  var _endIndex: Index {
    ___index(__tree_.__end_node())
  }

  @inlinable
  @inline(__always)
  func _distance(from start: Index, to end: Index) -> Int {
    __tree_.___distance(from: start.rawValue, to: end.rawValue)
  }
  
  @inlinable
  @inline(__always)
  func _index(after i: Index) -> Index {
    ___index(__tree_.___index(after: i.rawValue))
  }

  @inlinable
  @inline(__always)
  func _formIndex(after i: inout Index) {
    __tree_.___formIndex(after: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  func _index(before i: Index) -> Index {
    ___index(__tree_.___index(before: i.rawValue))
  }

  @inlinable
  @inline(__always)
  func _formIndex(before i: inout Index) {
    __tree_.___formIndex(before: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  func _index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(__tree_.___index(i.rawValue, offsetBy: distance))
  }

  @inlinable
  @inline(__always)
  func _formIndex(_ i: inout Index, offsetBy distance: Int) {
    __tree_.___formIndex(&i.rawValue, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  func _index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    ___index_or_nil(__tree_.___index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue))
  }

  @inlinable
  @inline(__always)
  func _formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    __tree_.___formIndex(&i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }

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

  @inlinable
  @inline(__always)
  func _isValid(index: Index) -> Bool {
    !__tree_.___is_subscript_null(index.rawValue)
  }

  @inlinable
  @inline(__always)
  func _isValid<R: RangeExpression>(
    _ bounds: R
  ) -> Bool where R.Bound == Index {

    let bounds = bounds.relative(to: self)
    return !__tree_.___is_range_null(
      bounds.lowerBound.rawValue,
      bounds.upperBound.rawValue)
  }

  @inlinable
  @inline(__always)
  __consuming func _reversed() -> Tree._Values.Reversed {
    .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node())
  }

  @inlinable
  @inline(__always)
  var _indices: Indices {
    __tree_.makeIndices(start: __tree_.__begin_node_, end: __tree_.__end_node())
  }
  
  @inlinable
  @inline(__always)
  func _elementsEqual<OtherSequence>(
    _ other: OtherSequence, by areEquivalent: (_Value, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try makeIterator().elementsEqual(other, by: areEquivalent)
  }

  @inlinable
  @inline(__always)
  func _lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (_Value, _Value) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, _Value == OtherSequence.Element {
    try makeIterator().lexicographicallyPrecedes(other, by: areInIncreasingOrder)
  }
}

extension ___RedBlackTreeBase {

  @inlinable
  @inline(__always)
  public mutating func ___element(at ptr: _NodePtr) -> _Value? {
    guard !__tree_.___is_subscript_null(ptr) else {
      return nil
    }
    return __tree_[ptr]
  }

  @inlinable
  @inline(__always)
  public __consuming func ___node_positions() -> ___Sequence<Self> {
    .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node())
  }
}
