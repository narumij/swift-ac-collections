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

import Foundation

// 単発削除対策型のイテレータ実装
@usableFromInline
protocol RedBlackTreeIteratorNextProtocol: IteratorProtocol {
  associatedtype VC: ValueComparer
  associatedtype _Tree: ___RedBlackTree.___Tree<VC>
  var _tree: _Tree { get }
  var _current: _NodePtr { get set }
  var _next: _NodePtr { get set }
  var _end: _NodePtr { get set }
}

extension RedBlackTreeIteratorNextProtocol {
  @inlinable
  @inline(__always)
  public mutating func _next() -> _NodePtr? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : _tree.__tree_next(_next)
    }
    return _current
  }
}

// 同一値複数削除対策型のイテレータ実装
@usableFromInline
protocol RedBlackTreeIteratorNextProtocol2: IteratorProtocol {
  associatedtype VC: ValueComparer
  associatedtype _Tree: ___RedBlackTree.___Tree<VC>
  var _tree: _Tree { get }
  // 返却予定位置
  var _current: _NodePtr { get set }
  // 単発削除対策で、次の位置
  var _next: _NodePtr { get set }
  // 複数削除対策で、次の位置とは値が異なるさらに先の位置を指すもの
  var _next_next: _NodePtr { get set }
  // 終了位置
  var _end: _NodePtr { get set }
}

extension RedBlackTreeIteratorNextProtocol2 {
  
  @inlinable
  @inline(__always)
  public mutating func _next() -> _NodePtr? {
    guard _current != _end else { return nil }
    defer {
      // カレントをネクスト二つから選ぶ
      _next = _next(_next, _next_next)
      // 返却予定を更新
      _current = _next
      // 次を更新
      _next = _next(_next)
      // 次の予備を更新
      _next_next = _next_next(_next)
    }
    return _current
  }

  @inlinable
  @inline(__always)
  public func _next(_ _next: _NodePtr,_ _next_next: _NodePtr) -> _NodePtr {
    _next != _end && _tree.___is_valid(_next) ? _next : _next_next
  }

  @inlinable
  @inline(__always)
  public func _next(_ _next: _NodePtr) -> _NodePtr {
    _next == _end ? _end : _tree.__tree_next(_next)
  }

  @inlinable
  @inline(__always)
  public func _next_next(_ _next: _NodePtr) -> _NodePtr {
    var _next_next = _next
    // _nextと_next_nextの値が異なるところまで、_next_nextを進める
    while _next_next != _end,
          _tree.___value_equal(
            _tree.__value_(_next),
            _tree.__value_(_next_next))
    {
      _next_next = _tree.__tree_next(_next_next)
    }
    return _next_next
  }
}

extension ___RedBlackTree.___Tree: Sequence {

  @frozen
  public struct Iterator: RedBlackTreeIteratorNextProtocol {

    public typealias Element = Tree.Element

    @inlinable
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self._tree = tree
      self._current = start
      self._end = end
      self._next = start == .end ? .end : tree.__tree_next(start)
    }

    @usableFromInline
    let _tree: Tree

    @usableFromInline
    var _current, _next, _end: _NodePtr

    @inlinable
    @inline(__always)
    public mutating func next() -> Element? {
      _next().map { _tree[$0] }
    }
  }

  @inlinable
  public __consuming func makeIterator() -> Iterator {
    .init(tree: self, start: __begin_node, end: __end_node())
  }
}

extension ___RedBlackTree.___Tree {  // SubSequence不一致でBidirectionalCollectionには適合できない

  public var startIndex: _NodePtr {
    __begin_node
  }

  public var endIndex: _NodePtr {
    __end_node()
  }

  public typealias Index = _NodePtr

  // この実装がないと、迷子になる
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    ___signed_distance(start, end)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    guard i != __end_node(), ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    return __tree_next(i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    i = __tree_next(i)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    guard i != __begin_node, i == __end_node() || ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    return __tree_prev_iter(i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    i = __tree_prev_iter(i)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    guard i == ___end() || ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    var distance = distance
    var i = i
    while distance != 0 {
      if 0 < distance {
        guard i != __end_node() else {
          fatalError(.outOfBounds)
        }
        i = index(after: i)
        distance -= 1
      } else {
        guard i != __begin_node else {
          fatalError(.outOfBounds)
        }
        i = index(before: i)
        distance += 1
      }
    }
    return i
  }

  @inlinable
  @inline(__always)
  internal func formIndex(_ i: inout Index, offsetBy distance: Int) {
    i = index(i, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    guard i == ___end() || ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    var distance = distance
    var i = i
    while distance != 0 {
      if i == limit {
        return nil
      }
      if 0 < distance {
        guard i != __end_node() else {
          fatalError(.outOfBounds)
        }
        i = index(after: i)
        distance -= 1
      } else {
        guard i != __begin_node else {
          fatalError(.outOfBounds)
        }
        i = index(before: i)
        distance += 1
      }
    }
    return i
  }

  @inlinable
  @inline(__always)
  internal func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index) -> Bool
  {
    if let ii = index(i, offsetBy: distance, limitedBy: limit) {
      i = ii
      return true
    }
    return false
  }
}
