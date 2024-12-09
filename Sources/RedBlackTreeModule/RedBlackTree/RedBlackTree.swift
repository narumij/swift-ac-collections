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
// Copyright © [年] The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

public enum RedBlackTree {}

extension RedBlackTree {

  public
    protocol Iteratee
  {
    associatedtype Element
    func iteratorNext(ptr: _NodePtr) -> _NodePtr
    func iteratorValue(ptr: _NodePtr) -> Element
  }

  public
    struct Iterator<Iteratee: RedBlackTree.Iteratee>: IteratorProtocol
  {
    @inlinable
    init(container: Iteratee, ptr: _NodePtr) {
      self.container = container
      self.ptr = ptr
    }
    @usableFromInline
    let container: Iteratee
    @usableFromInline
    var ptr: _NodePtr
    @inlinable
    public mutating func next() -> Iteratee.Element? {
      defer { if ptr != .end { ptr = container.iteratorNext(ptr: ptr) } }
      return ptr == .end ? nil : container.iteratorValue(ptr: ptr)
    }
  }
}

extension RedBlackTreeSetContainer {

  public func iteratorNext(ptr: _NodePtr) -> _NodePtr {
    _read { $0.__tree_next_iter(ptr) }
  }

  public func iteratorValue(ptr: _NodePtr) -> Element {
    values[ptr]
  }
}
