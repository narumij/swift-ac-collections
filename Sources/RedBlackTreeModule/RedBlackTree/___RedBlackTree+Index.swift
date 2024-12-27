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

extension ___RedBlackTree {

  /// 公開用のインデックス
  ///
  /// nullptrはオプショナルで表現する想定で、nullptrを保持しない
  public
    enum Index
  {
    case node(_NodePtr)
    case end

    @usableFromInline
    init(_ node: _NodePtr) {
      guard node != .nullptr else {
        preconditionFailure("_NodePtr is nullptr")
      }
      self = node == .end ? .end : .node(node)
    }

    @usableFromInline
    var pointer: _NodePtr {
      switch self {
      case .node(let _NodePtr):
        assert(_NodePtr != .nullptr)
        return _NodePtr
      case .end:
        return .end
      }
    }
  }
}

extension ___RedBlackTree.Index: Comparable {}

extension Optional where Wrapped == ___RedBlackTree.Index {
  
  @inlinable
  init(_ ptr: _NodePtr) {
    self = ptr == .nullptr ? .none : .some(___RedBlackTree.Index(ptr))
  }
  
  @usableFromInline
  var pointer: _NodePtr {
    switch self {
    case .none:
      return .nullptr
    case .some(let ptr):
      return ptr.pointer
    }
  }
}

#if swift(>=5.5)
extension ___RedBlackTree.Index: @unchecked Sendable {}
#endif

extension ___RedBlackTree {
  
  /// 赤黒木用の半開区間
  ///
  /// 標準のRangeの場合、lowerBoundとupperBoundの比較が行われるが、
  /// この挙動がRedBlackTreeに適さないため、独自のRangeを使用している
  public struct Range {
    @inlinable
    public init(lhs: Index, rhs: Index) {
      self.lhs = lhs
      self.rhs = rhs
    }
    public var lhs, rhs: Bound
    public typealias Bound = Index
  }
}

@inlinable
public func ..< (lhs: ___RedBlackTree.Index, rhs: ___RedBlackTree.Index) -> ___RedBlackTree.Range {
  .init(lhs: lhs, rhs: rhs)
}

extension ___RedBlackTreeBody {

  @usableFromInline
  typealias ___Index = ___RedBlackTree.Index

  @inlinable @inline(__always)
  func ___index_begin() -> ___Index {
    ___Index(___begin())
  }

  @inlinable @inline(__always)
  func ___index_end() -> ___Index {
    ___Index(___end())
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable @inline(__always)
  func ___index_lower_bound(_ __k: _Key) -> ___Index {
    _read { tree in
      ___Index(tree.__lower_bound(__k, tree.__root(), .end))
    }
  }

  @inlinable @inline(__always)
  func ___index_upper_bound(_ __k: _Key) -> ___Index {
    _read { tree in
      ___Index(tree.__upper_bound(__k, tree.__root(), .end))
    }
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable @inline(__always)
  func ___index_prev(_ i: ___Index) -> ___Index {
    let i = i.pointer
    return _read { tree in
      guard i != tree.__begin_node, i == tree.__end_node() || ___is_valid(i) else {
        fatalError(.invalidIndex)
      }
      return ___Index(tree.__tree_prev_iter(i))
    }
  }

  @inlinable @inline(__always)
  func ___index_next(_ i: ___Index) -> ___Index {
    let i = i.pointer
    return _read { tree in
      guard i != tree.__end_node(), ___is_valid(i) else {
        fatalError(.invalidIndex)
      }
      return ___Index(tree.__tree_next_iter(i))
    }
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable
  func ___index(_ i: ___Index, offsetBy distance: Int, type: String) -> ___Index {
    ___Index(pointer(i.pointer, offsetBy: distance))
  }

  @inlinable
  func ___index(
    _ i: ___Index, offsetBy distance: Int, limitedBy limit: ___Index, type: String
  ) -> ___Index? {
    ___Index?(
      pointer(
        i.pointer, offsetBy: distance, limitedBy: limit.pointer))
  }

  @inlinable
  @inline(__always)
  func pointer(
    _ ptr: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr? = .none) -> _NodePtr {
    guard ptr == ___end() || ___is_valid(ptr) else {
      fatalError(.invalidIndex)
    }
    return distance > 0
      ? pointer(ptr, nextBy: UInt(distance), limitedBy: limit)
      : pointer(ptr, prevBy: UInt(abs(distance)), limitedBy: limit)
  }

  @inlinable
  @inline(__always)
  func pointer(
    _ ptr: _NodePtr, prevBy distance: UInt, limitedBy limit: _NodePtr? = .none) -> _NodePtr {
    _read { tree in
      var ptr = ptr
      var distance = distance
      while distance != 0, ptr != limit {
        // __begin_nodeを越えない
        guard ptr != tree.__begin_node else {
          fatalError(.outOfBounds)
        }
        ptr = tree.__tree_prev_iter(ptr)
        distance -= 1
      }
      guard distance == 0 else {
        return .nullptr
      }
      assert(ptr != .nullptr)
      return ptr
    }
  }

  @inlinable
  @inline(__always)
  func pointer(
    _ ptr: _NodePtr, nextBy distance: UInt, limitedBy limit: _NodePtr? = .none) -> _NodePtr {
    _read { tree in
      var ptr = ptr
      var distance = distance
      while distance != 0, ptr != limit {
        // __end_node()を越えない
        guard ptr != tree.__end_node() else {
          fatalError(.outOfBounds)
        }
        ptr = tree.__tree_next_iter(ptr)
        distance -= 1
      }
      guard distance == 0 else {
        return .nullptr
      }
      assert(ptr != .nullptr)
      return ptr
    }
  }
}

extension ___RedBlackTreeContainerBase {
  
  @inlinable
  public func ___first_index(of member: _Key) -> ___Index? {
    _read { tree in
      var __parent = _NodePtr.nullptr
      let ptr = tree.__ref_(tree.__find_equal(&__parent, member))
      return ___Index?(ptr)
    }
  }
  
  @inlinable
  public func ___first_index(where predicate: (Element) throws -> Bool) rethrows -> ___Index? {
    try _read { tree in
      var result: ___Index?
      try tree.___for_each(__p: tree.__begin_node, __l: tree.__end_node()) { __p, cont in
        if try predicate(___elements[__p]) {
          result = ___Index(__p)
          cont = false
        }
      }
      return result
    }
  }
}

extension ___RedBlackTreeContainerBase {
  
  @inlinable
  public func ___distance(from start: ___Index, to end: ___Index) -> Int {
    _read { tree in
      tree.distance(__l: start.pointer, __r: end.pointer)
    }
  }
}
