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

// 性能変化の反応が過敏なので、慎重さが必要っぽい。

// 単発削除対策型のイテレータ実装
@usableFromInline
protocol RedBlackTreeIteratorNextProtocol: IteratorProtocol {
  associatedtype _Tree: MemberProtocol
  var _tree: _Tree { get }
  var _current: _NodePtr { get set }
  var _next: _NodePtr { get set }
  var _end: _NodePtr { get set }
}

extension RedBlackTreeIteratorNextProtocol {
  
  @inlinable
  @inline(__always)
  internal mutating func _next() -> _NodePtr? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : _tree.__tree_next(_next)
    }
    return _current
  }

  @inlinable
  @inline(__always)
  internal func _re_initialize(_ start: _NodePtr) -> (next: _NodePtr, nextnext: _NodePtr) {
    (start == .end ? .end : _tree.__tree_next(start), _end)
  }
}

#if false
  // 同一値一括削除対策型のイテレータ実装
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

  extension ValueProtocol {
    @inlinable
    @inline(__always)
    func ___value_equal(_ a: _Key, _ b: _Key) -> Bool {
      !value_comp(a, b) && !value_comp(b, a)
    }
  }

  extension RedBlackTreeIteratorNextProtocol2 {

    // 性能低下する予想だったが、キャッシュの効きがいいのか、手元計測ではむしろ速い
    @inlinable
    @inline(__always)
    internal mutating func _next() -> _NodePtr? {
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
    internal func _next(_ _next: _NodePtr, _ _next_next: _NodePtr) -> _NodePtr {
      _next != _end && _tree.___is_valid(_next) ? _next : _next_next
    }

    @inlinable
    @inline(__always)
    internal func _next(_ _next: _NodePtr) -> _NodePtr {
      _next == _end ? _end : _tree.__tree_next(_next)
    }

    @inlinable
    @inline(__always)
    internal func _next_next(_ _next: _NodePtr) -> _NodePtr {
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

    @inlinable
    @inline(__always)
    internal func _re_initialize(_ start: _NodePtr) -> (next: _NodePtr, nextnext: _NodePtr) {
      let next = _next(start)
      let nextnext = _next_next(start)
      return (next, nextnext)
    }
  }
#endif

extension ___RedBlackTree.___Tree: Sequence {

  @frozen
  public struct Iterator: RedBlackTreeIteratorNextProtocol {

    public typealias Element = Tree.Element

    @inlinable
    @inline(__always)
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

#if false
  @usableFromInline
  var startIndex: _NodePtr {
    __begin_node
  }

  @usableFromInline
  var endIndex: _NodePtr {
    __end_node()
  }
#endif

  // この実装がないと、迷子になる
  @inlinable
  internal func ___distance(from start: _NodePtr, to end: _NodePtr) -> Int {
    guard start == __end_node() || ___is_valid(start),
      end == __end_node() || ___is_valid(end)
    else {
      fatalError(.invalidIndex)
    }
    return ___signed_distance(start, end)
  }

  @inlinable
  @inline(__always)
  internal func index(after i: _NodePtr) -> _NodePtr {
    guard i != __end_node(), ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    return __tree_next(i)
  }

  @inlinable
  @inline(__always)
  internal func formIndex(after i: inout _NodePtr) {
    guard i != __end_node(), ___is_valid(i) else { fatalError(.invalidIndex) }
    i = __tree_next(i)
  }

  @inlinable
  @inline(__always)
  internal func index(before i: _NodePtr) -> _NodePtr {
    guard i != __begin_node, i == __end_node() || ___is_valid(i) else {
      fatalError(.invalidIndex)
    }
    return __tree_prev_iter(i)
  }

  @inlinable
  @inline(__always)
  internal func formIndex(before i: inout _NodePtr) {
    guard i == __end_node() || ___is_valid(i) else { fatalError(.invalidIndex) }
    i = __tree_prev_iter(i)
  }

  @inlinable
  @inline(__always)
  internal func index(_ i: _NodePtr, offsetBy distance: Int) -> _NodePtr {
    guard i == ___end() || ___is_valid(i) else { fatalError(.invalidIndex) }
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
  internal func formIndex(_ i: inout _NodePtr, offsetBy distance: Int) {
    guard i == __end_node() || ___is_valid(i) else { fatalError(.invalidIndex) }
    i = index(i, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  internal func index(_ i: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr) -> _NodePtr? {
    guard i == ___end() || ___is_valid(i) else { fatalError(.invalidIndex) }
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
  internal func formIndex(_ i: inout _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr) -> Bool
  {
    guard i == __end_node() || ___is_valid(i) else { fatalError(.invalidIndex) }
    if let ii = index(i, offsetBy: distance, limitedBy: limit) {
      i = ii
      return true
    }
    return false
  }
}
