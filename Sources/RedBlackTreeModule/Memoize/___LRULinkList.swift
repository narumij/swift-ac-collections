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

extension KeyValueComparer {
  public typealias _LinkingKeyValueTuple = (key: _Key, prev: _NodePtr, next: _NodePtr, value: _Value)
}

extension KeyValueComparer where Element == _LinkingKeyValueTuple {

  @inlinable @inline(__always)
  public static func __key(_ element: Element) -> _Key { element.key }

  @inlinable @inline(__always)
  static func __value(_ element: Element) -> _Value { element.value }
}

@usableFromInline
protocol ___LRULinkList: ___RedBlackTreeBase, KeyValueComparer
where Element == _LinkingKeyValueTuple {
  associatedtype Value
  var _tree_: Tree { get }
  var _rankHighest: _NodePtr { get set }
  var _rankLowest: _NodePtr { get set }
  var _hits: Int { get set }
  var _miss: Int { get set }
  var maxCount: Int { get }
  var count: Int { get }
}

extension ___LRULinkList {
  
  @inlinable
  mutating func ___prepend(_ __p: _NodePtr) {
    if _rankHighest == .nullptr {
      _tree_[__p].next = .nullptr
      _tree_[__p].prev = .nullptr
      _rankLowest = __p
      _rankHighest = __p
    } else {
      _tree_[_rankHighest].prev = __p
      _tree_[__p].next = _rankHighest
      _tree_[__p].prev = .nullptr
      _rankHighest = __p
    }
  }

  @inlinable
  mutating func ___pop(_ __p: _NodePtr) -> _NodePtr {

    assert(
      __p == _rankHighest || _tree_[__p].next != .nullptr || _tree_[__p].prev != .nullptr,
      "did not contain \(__p) ptr.")

    defer {
      let prev = _tree_[__p].prev
      let next = _tree_[__p].next
      if prev != .nullptr {
        _tree_[prev].next = next
      } else {
        _rankHighest = next
      }
      if next != .nullptr {
        _tree_[next].prev = prev
      } else {
        _rankLowest = prev
      }
    }

    return __p
  }

  @inlinable
  mutating func ___popRankLowest() -> _NodePtr {

    defer {
      if _rankLowest != .nullptr {
        _rankLowest = _tree_[_rankLowest].prev
      }
      if _rankLowest != .nullptr {
        _tree_[_rankLowest].next = .nullptr
      } else {
        _rankHighest = .nullptr
      }
    }

    return _rankLowest
  }
}

