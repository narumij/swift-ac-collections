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

extension RedBlackTree {

  public
    enum Index
  {
    case node(_NodePtr)
    case end
    @usableFromInline
    init(_ node: _NodePtr) {
      self = node == .end ? .end : .node(node)
    }
    @usableFromInline
    var pointer: _NodePtr {
      switch self {
      case .node(let _NodePtr):
        return _NodePtr
      case .end:
        return .end
      }
    }
  }
}

extension Optional where Wrapped == RedBlackTree.Index {
  @inlinable
  init(_ ptr: _NodePtr) {
    switch ptr {
    case .nullptr:
      self = .none
    case .end:
      self = .some(.end)
    default:
      self = .some(.node(ptr))
    }
  }
}

extension RedBlackTree.Index: Comparable {}

extension RedBlackTree.Index: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self = .end
  }
}
