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
protocol ___RedBlackTreeUpdateBase {
  associatedtype VC: ValueComparer
  mutating func _update<R>(_ body: (___UnsafeMutatingHandle<VC>) throws -> R) rethrows -> R
}

extension ___RedBlackTreeUpdateBase {

  @inlinable
  mutating func __insert_node_at(
    _ __parent: _NodePtr,
    _ __child: _NodeRef,
    _ __new_node: _NodePtr
  ) {
    _update { tree in
      tree.__insert_node_at(__parent, __child, __new_node)
    }
  }
}

@usableFromInline
protocol ___RedBlackTreeUpdate: ___RedBlackTreeUpdateBase, StorageProtocol { }

extension ___RedBlackTreeUpdate {
  
  @inlinable
  @inline(__always)
  mutating func _update<R>(_ body: (___UnsafeMutatingHandle<VC>, (_NodePtr) -> Void) throws -> R)
  rethrows -> R
  {
    var destroyed = [_NodePtr]()
    func ___destroy(_ p: _NodePtr) {
      destroyed.append(p)
    }
    defer {
      destroyed.forEach {
        destroy($0)
      }
    }
    return try _update { tree in
      try body(tree, ___destroy)
    }
  }
  
  @inlinable
  mutating func ___erase_multi(_ __k: VC._Key) -> Int {
    _update { tree, ___destroy in
      var __p = tree.__equal_range_multi(__k)
      var __r = 0
      while __p.0 != __p.1 {
        defer { __r += 1 }
        __p.0 = tree.erase(___destroy, __p.0)
      }
      return __r
    }
  }

  @inlinable
  mutating func ___erase_unique(_ __k: VC._Key) -> Bool {
    _update { tree, ___destroy in
      let __i = tree.find(__k)
      if __i == tree.end() {
        return false
      }
      _ = tree.erase(___destroy, __i)
      return true
    }
  }

  @inlinable
  @discardableResult
  mutating func ___erase(_ r: _NodePtr) -> _NodePtr {
    _update { tree, ___destroy in
      tree.erase(___destroy, r)
    }
  }

  @inlinable
  @discardableResult
  mutating func ___erase(_ l: _NodePtr, _ r: _NodePtr) -> _NodePtr {
    _update { tree, ___destroy in
      tree.erase(___destroy, l, r)
    }
  }
  
  @inlinable
  mutating func
  ___erase(_ l: _NodePtr,_ r: _NodePtr, forEach action: (VC.Element) throws -> Void) rethrows
  {
    try _update { tree, ___destroy in
      try tree.___erase(___destroy, l, r, action)
    }
  }

  @inlinable
  mutating func
  ___erase<Result>(_ l: _NodePtr, _ r: _NodePtr, into initialResult: Result, _ updateAccumulatingResult: (inout Result, VC.Element) throws -> ()) rethrows -> Result
  {
    try _update { tree, ___destroy in
      try tree.___erase(___destroy, l, r,into: initialResult, updateAccumulatingResult)
    }
  }
  
  @inlinable
  mutating func
  ___erase<Result>(_ l: _NodePtr, _ r: _NodePtr,_ initialResult: Result, _ nextPartialResult: (Result, VC.Element) throws -> Result) rethrows -> Result {
    try _update { tree, ___destroy in
      try tree.___erase(___destroy, l, r, initialResult, nextPartialResult)
    }
  }
}

@usableFromInline
protocol ___RedBlackTreeRemove: ___RedBlackTreeContainer, ___RedBlackTreeUpdate {}

extension ___RedBlackTreeRemove {

  @inlinable
  @discardableResult
  mutating func ___remove(at ptr: _NodePtr) -> Element? {
    guard
      // 下二つのコメントアウトと等価
      0 <= ptr,
      // ptr != .nullptr,
      // ptr != .end,
      ___nodes[ptr].isValid
    else {
      return nil
    }
    let e = ___values[ptr]
    _ = ___erase(ptr)
    return e
  }

  @inlinable
  @discardableResult
  mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != .end else {
      return .end
    }
    guard ___nodes[from].isValid, to == .end || ___nodes[to].isValid else {
      fatalError(.invalidIndex)
    }
    return ___erase(from, to)
  }

  @inlinable
  mutating func ___remove(from: _NodePtr, to: _NodePtr, forEach action: (VC.Element) throws -> ()) rethrows {
    guard from != .end else {
      return
    }
    guard ___nodes[from].isValid, to == .end || ___nodes[to].isValid else {
      fatalError(.invalidIndex)
    }
    return try ___erase(from, to, forEach: action)
  }

  @inlinable
  mutating func ___remove<Result>(from: _NodePtr, to: _NodePtr, into initialResult: Result, _ updateAccumulatingResult: (inout Result, VC.Element) throws -> ()) rethrows -> Result {
    guard from != .end else {
      return initialResult
    }
    guard ___nodes[from].isValid, to == .end || ___nodes[to].isValid else {
      fatalError(.invalidIndex)
    }
    return try ___erase(from, to, into: initialResult, updateAccumulatingResult)
  }
  
  @inlinable
  mutating func ___remove<Result>(from: _NodePtr, to: _NodePtr,_ initialResult: Result, _ nextPartialResult: (Result, VC.Element) throws -> Result) rethrows -> Result {
    guard from != .end else {
      return initialResult
    }
    guard ___nodes[from].isValid, to == .end || ___nodes[to].isValid else {
      fatalError(.invalidIndex)
    }
    return try ___erase(from, to, initialResult, nextPartialResult)
  }
  
  @inlinable
  public mutating func ___remove(from: ___RedBlackTree.Index, to: ___RedBlackTree.Index, forEach action: (VC.Element) throws -> ()) rethrows {
    try ___remove(from: from.pointer, to: to.pointer, forEach: action)
  }

  @inlinable
  public mutating func ___remove<Result>(from: ___RedBlackTree.Index, to: ___RedBlackTree.Index, into initialResult: Result, _ updateAccumulatingResult: (inout Result, VC.Element) throws -> ()) rethrows -> Result {
    try ___remove(from: from.pointer, to: to.pointer, into: initialResult, updateAccumulatingResult)
  }

  @inlinable
  public mutating func ___remove<Result>(from: ___RedBlackTree.Index, to: ___RedBlackTree.Index,_  initialResult: Result, _ nextPartialResult: (Result, VC.Element) throws -> Result) rethrows -> Result {
    try ___remove(from: from.pointer, to: to.pointer, initialResult, nextPartialResult)
  }
}
