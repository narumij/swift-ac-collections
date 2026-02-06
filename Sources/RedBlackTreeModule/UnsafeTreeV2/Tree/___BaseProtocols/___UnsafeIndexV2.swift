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
protocol ___UnsafeIndexV2: UnsafeTreeSealedRangeProtocol & UnsafeIndexProviderProtocol {}

extension ___UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  internal func _distance(from start: Index, to end: Index) -> Int {
    guard
      let d = __tree_.___distance(
        from: __tree_.__sealed_(start),
        to: __tree_.__sealed_(end))
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
    i.sealed = __tree_.___index(after: __tree_.__sealed_(i))
    return i
  }

  @inlinable @inline(__always)
  internal func _formIndex(after i: inout Index) {
    i = _index(after: i)
  }

  @inlinable @inline(__always)
  internal func _index(before i: Index) -> Index {
    var i = i
    i.sealed = __tree_.___index(before: __tree_.__sealed_(i))
    return i
  }

  @inlinable @inline(__always)
  internal func _formIndex(before i: inout Index) {
    i = _index(before: i)
  }

  @inlinable @inline(__always)
  internal func _index(_ i: Index, offsetBy distance: Int) -> Index {
    var i = i
    i.sealed = __tree_.___index(__tree_.__sealed_(i), offsetBy: distance)
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
    let sealed = __tree_.___index(
      __tree_.__sealed_(i), offsetBy: distance, limitedBy: __tree_.__sealed_(limit))
    guard !sealed.isError(.limit) else {
      i = limit
      return false
    }
    guard sealed.isValid else {
      return false
    }
    i.sealed = sealed
    return true
  }
}

extension ___UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  internal func _isValid(index: Index) -> Bool {
    // ___is_endのみを判定するわけじゃないので、お清めお祓いが必要
    __tree_.__sealed_(index).purified.___is_end == false
  }
}

#if COMPATIBLE_ATCODER_2025
  extension ___UnsafeIndexV2 where Self: Collection {

    @inlinable
    @inline(__always)
    internal func _isValid<R: RangeExpression>(
      _ bounds: R
    ) -> Bool where R.Bound == Index {

      let bounds = bounds.relative(to: self)
      if let _ = try? __tree_.__sealed_(bounds.lowerBound).get(),
        let _ = try? __tree_.__sealed_(bounds.upperBound).get()
      {
        return true
      }
      return false
    }
  }
#endif

// TODO: 削除または正式公開の検討
// 初期の名残
extension ___UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___erase(_ ptr: Index) -> Index {
    ___index(__tree_.erase(try! __tree_.__sealed_(ptr).get().pointer).sealed)
  }
}
