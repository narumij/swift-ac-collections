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

// TODO: 削除検討
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
}

extension ___Common {

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

  /// releaseビルドでは無効化されています(?)
  @inlinable
  @inline(__always)
  public func ___tree_invariant() -> Bool {
    #if !WITHOUT_SIZECHECK
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
  func _isIdentical(to other: Self) -> Bool {
    __tree_.isIdentical(to: other.__tree_) && _start == other._start && _end == other._end
  }
}

// TODO: 削除検討
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
  @inline(__always)
  public func ___node_positions() -> ___SafePointers<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}
