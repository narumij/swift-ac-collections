// Copyright 2024-2025 narumij
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
protocol ___IndexProvider: ___Base {}

extension ___IndexProvider {

  @inlinable
  @inline(__always)
  func ___index(_ p: _NodePtr) -> Index {
    __tree_.makeIndex(rawValue: p)
  }

  @inlinable
  @inline(__always)
  func ___index_or_nil(_ p: _NodePtr) -> Index? {
    p == .nullptr ? nil : ___index(p)
  }

  @inlinable
  @inline(__always)
  func ___index_or_nil(_ p: _NodePtr?) -> Index? {
    p.map { ___index($0) }
  }

  @inlinable
  @inline(__always)
  var _startIndex: Index {
    ___index(_start)
  }

  @inlinable
  @inline(__always)
  var _endIndex: Index {
    ___index(_end)
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
}

extension ___IndexProvider {

  @inlinable
  @inline(__always)
  func ___first_index(where predicate: (_Value) throws -> Bool) rethrows -> Index? {
    var result: Index?
    try __tree_.___for_each(__p: _start, __l: _end) { __p, cont in
      if try predicate(__tree_[__p]) {
        result = ___index(__p)
        cont = false
      }
    }
    return result
  }
}

extension ___IndexProvider {

  @inlinable
  @inline(__always)
  public func ___first(where predicate: (_Value) throws -> Bool) rethrows -> _Value? {
    var result: _Value?
    try __tree_.___for_each(__p: _start, __l: _end) { __p, cont in
      if try predicate(__tree_[__p]) {
        result = __tree_[__p]
        cont = false
      }
    }
    return result
  }
}

//extension ___IndexProvider {
//
//  @inlinable
//  @inline(__always)
//  func _forEach(_ body: (Index, _Value) throws -> Void) rethrows {
//    try __tree_.___for_each_(__p: _start, __l: _end) {
//      try body(___index($0), __tree_[$0])
//    }
//  }
//}

//extension ___IndexProvider where Base: KeyValueComparer & ___RedBlackTreeKeyValueBase {
//
//  @inlinable
//  @inline(__always)
//  func _forEach(_ body: (Index, Base.Element) throws -> Void) rethrows {
//    try __tree_.___for_each_(__p: _start, __l: _end) {
//      try body(___index($0), Base.___element(__tree_[$0]))
//    }
//  }
//}

extension ___IndexProvider {

  @inlinable
  @inline(__always)
  func _isValid(index: Index) -> Bool {
    !__tree_.___is_subscript_null(index.rawValue)
  }
}

extension ___IndexProvider where Self: Collection {

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
}

extension ___IndexProvider where Base: CompareUniqueTrait {

  ///（重複なし）
  @inlinable
  @inline(__always)
  func ___equal_range(_ k: Tree._Key) -> (lower: _NodePtr, upper: _NodePtr) {
    __tree_.__equal_range_unique(k)
  }

  @inlinable
  @inline(__always)
  func ___index_equal_range(_ k: Tree._Key) -> (lower: Index, upper: Index) {
    let (lo, hi) = __tree_.__equal_range_unique(k)
    return (___index(lo), ___index(hi))
  }
}

extension ___IndexProvider where Base: CompareMultiTrait {

  /// （重複あり）
  @inlinable
  @inline(__always)
  func ___equal_range(_ k: Tree._Key) -> (lower: _NodePtr, upper: _NodePtr) {
    __tree_.__equal_range_multi(k)
  }

  @inlinable
  @inline(__always)
  func ___index_equal_range(_ k: Tree._Key) -> (lower: Index, upper: Index) {
    let (lo, hi) = __tree_.__equal_range_multi(k)
    return (___index(lo), ___index(hi))
  }
}

extension ___IndexProvider {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___erase(_ ptr: _NodePtr) -> _NodePtr {
    __tree_.erase(ptr)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___erase(_ ptr: Index) -> Index {
    ___index(__tree_.erase(ptr.rawValue))
  }
}
