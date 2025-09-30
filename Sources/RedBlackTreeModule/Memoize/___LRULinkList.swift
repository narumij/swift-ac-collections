// Copyright 2025 narumij
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

public struct _LinkingPair<Key,Value> {
  @inlinable
  @inline(__always)
  public init(_ key: Key,_ prev: _NodePtr,_ next: _NodePtr,_ value: Value) {
    self.key = key
    self.prev = prev
    self.next = next
    self.value = value
  }
  public var key: Key
  public var prev: _NodePtr
  public var next: _NodePtr
  public var value: Value
}

extension KeyValueComparer where _Value == _LinkingPair<_Key,_MappedValue> {

  @inlinable @inline(__always)
  public static func __key(_ element: _Value) -> _Key { element.key }

  @inlinable @inline(__always)
  public static func __value(_ element: _Value) -> _MappedValue { element.value }
}

@usableFromInline
protocol ___LRULinkList: ___RedBlackTreeBase, KeyValueComparer
where _Value == _LinkingPair<_Key,_MappedValue> {
  associatedtype Value
  var __tree_: Tree { get }
  var _rankHighest: _NodePtr { get set }
  var _rankLowest: _NodePtr { get set }
}

extension ___LRULinkList {

  @inlinable
  @inline(__always)
  mutating func ___prepend(_ __p: _NodePtr) {
    if _rankHighest == .nullptr {
      __tree_[__p].next = .nullptr
      __tree_[__p].prev = .nullptr
      _rankLowest = __p
      _rankHighest = __p
    } else {
      __tree_[_rankHighest].prev = __p
      __tree_[__p].next = _rankHighest
      __tree_[__p].prev = .nullptr
      _rankHighest = __p
    }
  }

  @inlinable
  @inline(__always)
  mutating func ___pop(_ __p: _NodePtr) -> _NodePtr {

    assert(
      __p == _rankHighest || __tree_[__p].next != .nullptr || __tree_[__p].prev != .nullptr,
      "did not contain \(__p) ptr.")

    defer {
      let prev = __tree_[__p].prev
      let next = __tree_[__p].next
      if prev != .nullptr {
        __tree_[prev].next = next
      } else {
        _rankHighest = next
      }
      if next != .nullptr {
        __tree_[next].prev = prev
      } else {
        _rankLowest = prev
      }
    }

    return __p
  }

  @inlinable
  @inline(__always)
  mutating func ___popRankLowest() -> _NodePtr {

    defer {
      if _rankLowest != .nullptr {
        _rankLowest = __tree_[_rankLowest].prev
      }
      if _rankLowest != .nullptr {
        __tree_[_rankLowest].next = .nullptr
      } else {
        _rankHighest = .nullptr
      }
    }

    return _rankLowest
  }
}
