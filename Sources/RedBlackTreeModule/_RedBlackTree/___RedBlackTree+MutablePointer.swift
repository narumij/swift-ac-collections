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

extension ___RedBlackTree.___Tree {
  
  @frozen
  public struct MutablePointer {

    @usableFromInline
    let _storage: Storage

    // MARK: -

    @inlinable
    @inline(__always)
    internal init(_storage: Tree.Storage) {
      self._storage = _storage
      ___next()
    }
    
    @inlinable
    var _tree: Tree {
      get { _storage.tree }
      _modify { yield &_storage.tree }
    }

    @inlinable
    public var pointee: Element {
      get { _tree[_tree.__tree_max(_tree.__root())] }
      set {
        Tree.ensureUniqueAndCapacity(tree: &_tree, minimumCapacity: _tree.count + 1)
        _tree.___emplace_last(newValue)
      }
    }
    
    @inlinable
    public mutating func ___next() { }
  }
}

