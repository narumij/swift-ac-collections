// Copyright 2024-2026 narumij
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
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

@usableFromInline
protocol ___UnsafeIndexV2: UnsafeTreeRangeProtocol & ___UnsafeIndexBaseV2 & _PayloadValueBride {}

extension ___UnsafeIndexV2 {
  
  @inlinable
  @inline(__always)
  internal func _distance(from start: Index, to end: Index) -> Int {
    __tree_.___distance(
      from: try! __tree_._remap_to_safe_(start).get().pointer,
      to: try! __tree_._remap_to_safe_(end).get().pointer)
  }
}

extension ___UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  internal var _startIndex: Index {
    ___index(_start)
  }

  @inlinable
  @inline(__always)
  internal var _endIndex: Index {
    ___index(_end)
  }

  @inlinable
  @inline(__always)
  internal func _index(after i: Index) -> Index {
    ___index(__tree_.___index(after: try! __tree_._remap_to_safe_(i).get().pointer))
  }

  @inlinable
  @inline(__always)
  internal func _formIndex(after i: inout Index) {
    __tree_.___formIndex(after: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  internal func _index(before i: Index) -> Index {
    ___index(__tree_.___index(before: try! __tree_._remap_to_safe_(i).get().pointer))
  }

  @inlinable
  @inline(__always)
  internal func _formIndex(before i: inout Index) {
    __tree_.___formIndex(before: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  internal func _index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(__tree_.___index(try! __tree_._remap_to_safe_(i).get().pointer, offsetBy: distance))
  }

  @inlinable
  @inline(__always)
  internal func _formIndex(_ i: inout Index, offsetBy distance: Int) {
    __tree_.___formIndex(&i.rawValue, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  internal func _index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    ___index_or_nil(
      __tree_.___index(try! __tree_._remap_to_safe_(i).get().pointer, offsetBy: distance, limitedBy: try! __tree_._remap_to_safe_(limit).get().pointer))
  }

  @inlinable
  @inline(__always)
  internal func _formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    __tree_.___formIndex(&i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }
}

extension ___UnsafeIndexV2 {
  
  @inlinable
  @inline(__always)
  internal func ___first_index(where predicate: (_PayloadValue) throws -> Bool) rethrows -> Index? {
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

extension ___UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  internal func _isValid(index: Index) -> Bool {
    __tree_._remap_to_safe_(index).___is_end == false
  }
}

//extension ___UnsafeIndexV2 where Self: Sequence {
//
//  @inlinable
//  @inline(__always)
//  internal func _isValid(
//    _ rawRange: UnsafeTreeRangeExpression
//  ) -> Bool {
//
//    let (l, u) = rawRange._relative(to: __tree_)
//    return l.isValid && u.isValid
//  }
//}

#if COMPATIBLE_ATCODER_2025
  extension ___UnsafeIndexV2 where Self: Collection {

    @inlinable
    @inline(__always)
    internal func _isValid<R: RangeExpression>(
      _ bounds: R
    ) -> Bool where R.Bound == Index {

      let bounds = bounds.relative(to: self)
      if
        let _ = try? __tree_._remap_to_safe_(bounds.lowerBound).get(),
        let _ = try? __tree_._remap_to_safe_(bounds.upperBound).get() {
        return true
      }
      return false
    }
  }
#endif

extension ___UnsafeIndexV2 where Base: CompareUniqueTrait {

  ///（重複なし）
  @inlinable
  @inline(__always)
  internal func ___equal_range(_ k: Tree._Key) -> (lower: _NodePtr, upper: _NodePtr) {
    __tree_.__equal_range_unique(k)
  }

  @inlinable
  @inline(__always)
  internal func ___index_equal_range(_ k: Tree._Key) -> (lower: Index, upper: Index) {
    let (lo, hi) = ___equal_range(k)
    return (___index(lo), ___index(hi))
  }
}

extension ___UnsafeIndexV2 where Base: CompareMultiTrait {

  /// （重複あり）
  @inlinable
  @inline(__always)
  internal func ___equal_range(_ k: Tree._Key) -> (lower: _NodePtr, upper: _NodePtr) {
    __tree_.__equal_range_multi(k)
  }

  @inlinable
  @inline(__always)
  internal func ___index_equal_range(_ k: Tree._Key) -> (lower: Index, upper: Index) {
    let (lo, hi) = ___equal_range(k)
    return (___index(lo), ___index(hi))
  }
}

// TODO: 削除または正式公開の検討
// 初期の名残
extension ___UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___erase(_ ptr: Index) -> Index {
    ___index(__tree_.erase(try! __tree_._remap_to_safe_(ptr).get().pointer))
  }
}

//extension ___UnsafeIndexV2 where Self: ___UnsafeIndicesBaseV2 {
//
//  @inlinable
//  @inline(__always)
//  internal var _indices: Indices {
//    .init(start: _start, end: _end, tie: __tree_.tied)
//  }
//}

