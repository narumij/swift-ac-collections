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

#if swift(>=5.5)
extension ___RedBlackTree.Range: @unchecked Sendable {}
#endif

@inlinable
public func ..< (lhs: ___RedBlackTree.Index, rhs: ___RedBlackTree.Index) -> ___RedBlackTree.Range {
  .init(lhs: lhs, rhs: rhs)
}
