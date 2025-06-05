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

extension ___Tree {

  @usableFromInline
  typealias Storage = ___Storage<VC>

  @frozen
  @usableFromInline
  struct ___MutableIterator {

    @usableFromInline
    let _storage: Storage

    // __tree_max()を削るとO(1)動作となることが分かったので、
    // 一旦それ以外の動作について削っている。

    @usableFromInline
    var __parent: _NodePtr

    @usableFromInline
    var __child: _NodeRef

    // MARK: -

    @inlinable
    @inline(__always)
    init(_storage: ___Storage<VC>) {
      self._storage = _storage
      (__parent, __child) = _storage.tree.___max_ref()
    }

    @inlinable
    var _tree: Tree {
      @inline(__always) get {
        _storage.tree
      }
      @inline(__always) _modify {
        yield &_storage.tree
      }
    }

    @inlinable
    var pointee: Element {
      @inline(__always) get {
        _tree[_tree.__tree_max(_tree.__root())]
      }
      @inline(__always) set {
        Tree.ensureUniqueAndCapacity(tree: &_tree)
        (__parent, __child) = _tree.___emplace_hint_right(__parent, __child, newValue)
        assert(_tree.__tree_invariant(_tree.__root()))
      }
    }

    @inlinable
    mutating func ___next() {
      // 未実装
    }

    @inlinable
    mutating func ___prev() {
      // 未実装
    }
  }
}
