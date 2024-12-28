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

public enum ___RedBlackTree {}

@usableFromInline
protocol ___RedBlackTreeBody {
  associatedtype Element
  var ___header: ___RedBlackTree.___Header { get set }
  var ___nodes: [___RedBlackTree.___Node] { get set }
  var ___elements: [Element] { get set }
}

extension ___RedBlackTreeBody {

  @inlinable @inline(__always)
  public var ___count: Int {
    ___header.size
  }

  @inlinable @inline(__always)
  public var ___isEmpty: Bool {
    ___header.size == 0
  }

  @inlinable @inline(__always)
  public var ___capacity: Int {
    Swift.min(___elements.capacity, ___nodes.capacity)
  }

  @inlinable @inline(__always)
  public func ___begin() -> _NodePtr {
    ___header.__begin_node
  }

  @inlinable @inline(__always)
  public func ___end() -> _NodePtr {
    .end
  }
}

//@usableFromInline
//protocol ___RedBlackTreeContainerBase: ___RedBlackTreeAllocatorBase, ___RedBlackTreeContainerRead, EndProtocol, ValueComparer {}


extension String {

  @usableFromInline
  static var invalidIndex = "Attempting to access RedBlackTree elements using an invalid index"

  @usableFromInline
  static var outOfBounds = "RedBlackTree index is out of Bound."
  
  @usableFromInline
  static var emptyFirst = "Can't removeFirst from an empty RedBlackTree"
  
  @usableFromInline
  static var emptyLast = "Can't removeLast from an empty RedBlackTree"
}
