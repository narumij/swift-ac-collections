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

extension ___RedBlackTreeContainerBase {
  
  public typealias EnumeratedElement = (position: ___Index, element: Element)
}

extension ___RedBlackTreeContainerBase {

  @inlinable
  public func ___enumerated_sequence(from: ___Index, to: ___Index)
    -> ___EnumeratedSequence
  {
    return sequence(state: ___begin(from.pointer, to: to.pointer)) { state in
      guard ___end(state) else { return nil }
      defer { ___next(&state) }
      return (___Index(state.current), ___elements[state.current])
    }
  }

  @inlinable @inline(__always)
  public var ___enumerated_sequence: ___EnumeratedSequence {
    ___enumerated_sequence(from: ___index_begin(), to: ___index_end())
  }

  @inlinable
  public func ___enumerated_sequence__(from: ___Index, to: ___Index)
    -> [EnumeratedElement]
  {
    return _read { tree in
      var result = [EnumeratedElement]()
      tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
        result.append((___Index(__p),___elements[__p]))
      }
      return result
    }
  }

  @inlinable @inline(__always)
  public var ___enumerated_sequence__: [EnumeratedElement] {
    ___enumerated_sequence__(from: ___index_begin(), to: ___index_end())
  }

  @inlinable
  public func ___element_sequence__<T>(from: ___Index, to: ___Index, transform: (Element) throws -> T)
    rethrows -> [T]
  {
    try _read { tree in
      var result = [T]()
      try tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
        result.append(try transform(___elements[__p]))
      }
      return result
    }
  }
  
  @inlinable
  public func ___element_sequence__(from: ___Index, to: ___Index, isIncluded: (Element) throws -> Bool)
    rethrows -> [Element]
  {
    try _read { tree in
      var result = [Element]()
      try tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
        if try isIncluded(___elements[__p]) {
          result.append(___elements[__p])
        }
      }
      return result
    }
  }
  
  @inlinable
  public func ___element_sequence__<T>(from: ___Index, to: ___Index,_ initial: T,_ folding: (T, Element) throws -> T)
    rethrows -> T
  {
    try _read { tree in
      var result = initial
      try tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
        result = try folding(result, ___elements[__p])
      }
      return result
    }
  }
  
  @inlinable
  public func ___element_sequence__<T>(from: ___Index, to: ___Index, into initial: T,_ folding: (inout T, Element) throws -> Void)
    rethrows -> T
  {
    try _read { tree in
      var result = initial
      try tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
        try folding(&result, ___elements[__p])
      }
      return result
    }
  }

  @inlinable
  public func ___element_sequence__(from: ___Index, to: ___Index)
    -> [Element]
  {
    _read { tree in
      var result = [Element]()
      tree.___for_each(__p: from.pointer, __l: to.pointer) { __p, _ in
        result.append(___elements[__p])
      }
      return result
    }
  }

  @inlinable
  public func ___element_sequence__<T>(_ transform: (Element) throws -> T)
    rethrows -> [T]
  {
    try ___element_sequence__(from: ___index_begin(), to: ___index_end(), transform: transform)
  }

  @inlinable @inline(__always)
  public var ___element_sequence__: [Element] {
    ___element_sequence__(from: ___index_begin(), to: ___index_end())
  }
}

// MARK: - UnfoldSequence用の部品

extension ___RedBlackTreeContainerBase {

  public typealias SafeSequenceState = (current: _NodePtr, next: _NodePtr, to: _NodePtr)
  public typealias UnsafeSequenceState = (current: _NodePtr, to: _NodePtr)

  public typealias ___EnumeratedSequence = UnfoldSequence<EnumeratedElement, SafeSequenceState>
  
  @inlinable
  func ___next(_ ptr: _NodePtr, to: _NodePtr) -> _NodePtr {
    ptr == to ? ptr : _read { $0.__tree_next_iter(ptr) }
  }
  
  @inlinable @inline(__always)
  func ___begin(_ from: _NodePtr, to: _NodePtr) -> SafeSequenceState {
    (from, ___next(from, to: to), to)
  }
  
  @inlinable @inline(__always)
  func ___next(_ state: inout SafeSequenceState) {
    state.current = state.next
    state.next = ___next(state.next, to: state.to)
  }
  
  @inlinable @inline(__always)
  func ___end(_ state: SafeSequenceState) -> Bool {
    state.current != state.to
  }
  
  @inlinable @inline(__always)
  func ___begin(_ from: _NodePtr, to: _NodePtr) -> UnsafeSequenceState {
    (from, to)
  }
  
  @inlinable @inline(__always)
  func ___next(_ state: inout UnsafeSequenceState) {
    state.current = ___next(state.current, to: state.to)
  }
  
  @inlinable @inline(__always)
  func ___end(_ state: UnsafeSequenceState) -> Bool {
    state.current != state.to
  }
}
