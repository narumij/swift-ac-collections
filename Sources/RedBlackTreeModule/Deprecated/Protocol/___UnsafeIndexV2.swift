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
protocol ___UnsafeIndexV2:
  UnsafeTreeSealedRangeProtocol
    & UnsafeIndexProviderProtocol
    & _KeyBride
{}

extension ___UnsafeIndexV2 {

  @inlinable @inline(__always)
  internal func _distance(from start: Index, to end: Index) -> Int {
    guard
      let d = __tree_.___distance(
        from: __tree_.__purified_(start),
        to: __tree_.__purified_(end))
    else {
      fatalError(.invalidIndex)
    }
    return d
  }
}

extension ___UnsafeIndexV2 {

  @inlinable @inline(__always)
  internal var _startIndex: Index {
    ___index(_sealed_start)
  }

  @inlinable @inline(__always)
  internal var _endIndex: Index {
    ___index(_sealed_end)
  }

  @inlinable @inline(__always)
  internal func _index(after i: Index) -> Index {
    var i = i
    i.sealed = __tree_.___index(after: __tree_.__purified_(i))
    return i
  }

  @inlinable @inline(__always)
  internal func _formIndex(after i: inout Index) {
    i = _index(after: i)
  }

  @inlinable @inline(__always)
  internal func _index(before i: Index) -> Index {
    var i = i
    i.sealed = __tree_.___index(before: __tree_.__purified_(i))
    return i
  }

  @inlinable @inline(__always)
  internal func _formIndex(before i: inout Index) {
    i = _index(before: i)
  }

  @inlinable @inline(__always)
  internal func _index(_ i: Index, offsetBy distance: Int) -> Index {
    var i = i
    i.sealed = __tree_.___index(__tree_.__purified_(i), offsetBy: distance)
    return i
  }

  @inlinable @inline(__always)
  internal func _formIndex(_ i: inout Index, offsetBy distance: Int) {
    i = _index(i, offsetBy: distance)
  }

  @inlinable @inline(__always)
  internal func _index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Index?
  {
    var i = i
    let result = _formIndex(&i, offsetBy: distance, limitedBy: limit)
    return result ? i : nil
  }

  @inlinable @inline(__always)
  internal func _formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    guard let ___i = __tree_.__purified_(i).pointer
    else { return false }

    let __l = __tree_.__purified_(limit).map(\.pointer)

    return ___form_index(___i, offsetBy: distance, limitedBy: __l) {
      i.sealed = $0.flatMap { $0.sealed }
    }
  }
}

extension ___UnsafeIndexV2 {

  @inlinable @inline(__always)
  internal func _isValid(index: Index) -> Bool {
    __tree_.__purified_(index).exists
  }
}

#if COMPATIBLE_ATCODER_2025
  extension ___UnsafeIndexV2 where Self: Collection {

    @inlinable @inline(__always)
    internal func _isValid<R: RangeExpression>(
      _ bounds: R
    ) -> Bool where R.Bound == Index {

      let bounds = bounds.relative(to: self)
      if let _ = try? __tree_.__purified_(bounds.lowerBound).get(),
        let _ = try? __tree_.__purified_(bounds.upperBound).get()
      {
        return true
      }
      return false
    }
  }
#endif

// 初期の名残
extension ___UnsafeIndexV2 {

  @discardableResult
  @inlinable @inline(__always)
  public mutating func ___erase(_ ptr: Index) -> Index {
    ___index(__tree_.erase(__tree_.__purified_(ptr).pointer!).sealed)
  }
}

extension ___UnsafeIndexV2 {

  @inlinable @inline(__always)
  internal func ___index_lower_bound(_ __k: _Key) -> Index {
    ___index(__tree_.lower_bound(__k).sealed)
  }

  @inlinable @inline(__always)
  internal func ___index_upper_bound(_ __k: _Key) -> Index {
    ___index(__tree_.upper_bound(__k).sealed)
  }
}

extension ___UnsafeIndexV2 {

  @inlinable @inline(__always)
  internal func ___first_index(of member: _Key) -> Index? {
    let ptr = __tree_.__find_equal(member).__child.__ptr_
    return ___index_or_nil(ptr.sealed)
  }
}
