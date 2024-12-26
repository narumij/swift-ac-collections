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
protocol ___RedBlackTreeErase: ___RedBlackTreeUpdate, StorageProtocol { }

extension ___RedBlackTreeErase {
  
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

