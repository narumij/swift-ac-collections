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

@usableFromInline
protocol ___RedBlackTreeRemove: ___RedBlackTreeContainer, ___RedBlackTreeErase {}

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
    let e = ___elements[ptr]
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
