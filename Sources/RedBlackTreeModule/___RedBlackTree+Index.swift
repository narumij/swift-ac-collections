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
    enum SimpleIndex
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

extension ___RedBlackTree.SimpleIndex: Comparable {}

extension Optional where Wrapped == ___RedBlackTree.SimpleIndex {
  
  @inlinable
  init(_ ptr: _NodePtr) {
    self = ptr == .nullptr ? .none : .some(___RedBlackTree.SimpleIndex(ptr))
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
extension ___RedBlackTree.SimpleIndex: @unchecked Sendable {}
#endif

extension ___RedBlackTree {
  
  public struct TreeIndex<Base: ValueComparer>: Comparable {

    public typealias Tree = ___RedBlackTree.___Buffer<Base>
    public typealias Index = Self
    
    public static func score(_ rhs: Index) -> Int {
      rhs.pointer != .end ? rhs.pointer : Int.max
    }
    
    public static func < (lhs: Index, rhs: Index) -> Bool {
      
      if lhs.pointer == rhs.pointer {
        return false
      }
      
      guard score(lhs) == score(rhs) else {
        return score(lhs) < score(rhs)
      }
      
      return lhs.tree.distance(__l: lhs.pointer, __r: rhs.pointer) < 0
    }
    
    public static func == (lhs: Index, rhs: Index) -> Bool {
      lhs.pointer == rhs.pointer
    }
    
    @inlinable
    internal init(__tree: Tree, pointer: _NodePtr) {
//      guard pointer != .nullptr else {
//        preconditionFailure("_NodePtr is nullptr")
//      }
      self.tree = __tree
      self.pointer = pointer
    }
    
    @usableFromInline
    let tree: ___RedBlackTree.___Buffer<Base>
    
    @usableFromInline
    let pointer: _NodePtr
    
    var pointee: Base.Element {
      get { tree[pointer] }
      _modify { yield &tree[pointer] }
    }

    public static func nullptr(_ tree: Tree) -> Index {
      .init(__tree: tree, pointer: .nullptr)
    }

    public static func end(_ tree: Tree) -> Index {
      .init(__tree: tree, pointer: tree.__end_node())
    }
    
    public func after() -> Index {
      .init(__tree: tree, pointer: tree.__tree_next(pointer))
    }

    public func before() -> Index {
      .init(__tree: tree, pointer: tree.__tree_prev_iter(pointer))
    }
  }
}

extension ___RedBlackTree {
  
  /// 赤黒木用の半開区間
  ///
  /// 標準のRangeの場合、lowerBoundとupperBoundの比較が行われるが、
  /// この挙動がRedBlackTreeに適さないため、独自のRangeを使用している
  public struct Range {
    @inlinable
    public init(lhs: SimpleIndex, rhs: SimpleIndex) {
      self.lhs = lhs
      self.rhs = rhs
    }
    public var lhs, rhs: Bound
    public typealias Bound = SimpleIndex
  }
}

#if swift(>=5.5)
extension ___RedBlackTree.Range: @unchecked Sendable {}
#endif

@inlinable
public func ..< (lhs: ___RedBlackTree.SimpleIndex, rhs: ___RedBlackTree.SimpleIndex) -> ___RedBlackTree.Range {
  .init(lhs: lhs, rhs: rhs)
}

extension ___RedBlackTree {
  
  /// 赤黒木用の半開区間
  ///
  /// 標準のRangeの場合、lowerBoundとupperBoundの比較が行われるが、
  /// この挙動がRedBlackTreeに適さないため、独自のRangeを使用している
  public struct TreeRange<Base: ValueComparer> {
    public typealias Index = ___RedBlackTree.TreeIndex<Base>
    @inlinable
    public init(lhs: Bound, rhs: Bound) {
      self.lowerBound = lhs
      self.upperBound = rhs
    }
    public var lowerBound, upperBound: Bound
    public typealias Bound = Index
  }
}

#if swift(>=5.5)
extension ___RedBlackTree.TreeRange: @unchecked Sendable {}
#endif

@inlinable
public func ..< <Base: ValueComparer>(lhs: ___RedBlackTree.TreeIndex<Base>, rhs: ___RedBlackTree.TreeIndex<Base>) -> ___RedBlackTree.TreeRange<Base> {
  .init(lhs: lhs, rhs: rhs)
}

