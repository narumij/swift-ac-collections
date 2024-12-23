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

@usableFromInline
protocol ___RedBlackTreeUpdate {
  associatedtype VC: ValueComparer
  mutating func _update<R>(_ body: (___UnsafeMutatingHandle<VC>) throws -> R) rethrows -> R
}

extension ___RedBlackTreeUpdate {

  @inlinable
  mutating func __insert_node_at(
    _ __parent: _NodePtr,
    _ __child: _NodeRef,
    _ __new_node: _NodePtr
  ) {
    _update { tree in
      tree.__insert_node_at(__parent, __child, __new_node) }
  }

  @inlinable
  mutating func __remove_node_pointer(_ __ptr: _NodePtr) -> _NodePtr {
    _update { tree in
      tree.__remove_node_pointer(__ptr) }
  }  
}

@usableFromInline
protocol ___RedBlackTreeEraseSubrangeProtocol: ___RedBlackTreeContainer, StorageProtocol, ___RedBlackTreeUpdate {
  
}

extension ___RedBlackTreeEraseSubrangeProtocol {
  
  @inlinable
  @discardableResult
  mutating func ___erase___(_ l: _NodePtr,_ r: _NodePtr) -> _NodePtr {
    var destroyed = [_NodePtr]()
    func ___destroy(_ p: _NodePtr) {
      destroyed.append(p)
    }
    defer {
      destroyed.forEach {
        destroy($0)
      }
    }
    return _update { tree in
      tree.erase(___destroy: ___destroy, l, r)
    }
  }
  
  @inlinable
  @discardableResult
  mutating func ___remove___(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != .end else {
      return .end
    }
    guard ___nodes[from].isValid, to == .end || ___nodes[to].isValid else {
      fatalError("Attempting to access RedBlackTreeSet elements using an invalid index")
    }
    return ___erase___(from, to)
  }
}

