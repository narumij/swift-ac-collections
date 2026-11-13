//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

#if ENABLE_EXPERIMENTAL_LRU

@frozen
public struct LRUCache<Key, Value>: ~Copyable
where Key: Comparable {

  public
    typealias _Key = Key

  public
    typealias _MappedValue = Value

  public
    typealias KeyValue = _LinkingPair<_Key, _MappedValue>

  public
    typealias _PayloadValue = KeyValue

  public let maxCount: Int

  @usableFromInline
  let nullptr: _NodePtr

  @usableFromInline
  var _rankHighest: _NodePtr

  @usableFromInline
  var _rankLowest: _NodePtr

  @usableFromInline
  var __tree_: Tree
}

extension LRUCache {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  public init(minimumCapacity: Int = 0, maxCount: Int = Int.max) {
    precondition(maxCount > 0, "maxCount must be positive")
    nullptr = UnsafeNode.nullptr
    __tree_ = ._createWithNewBuffer(minimumCapacity: minimumCapacity, nullptr: nullptr)
    self.maxCount = maxCount
    (_rankHighest, _rankLowest) = (nullptr, nullptr)
  }

  @inlinable
  public subscript(key: _Key) -> Value? {

    @inline(__always) mutating get {

      let __ptr = __tree_.update { $0.find(key) }
      guard !__ptr.___is_end else { return nil }
      ___prepend(___pop(__ptr))
      return Base.__payload_(__ptr).value
    }

    @inline(__always) set {

      guard let newValue else {
        fatalError()
      }

      __tree_.ensureCapacity(limit: maxCount)

      __tree_.update { __tree_ in

        if __tree_.count == maxCount {
          _ = __tree_.erase(___popRankLowest())
        }

        let (__parent, __child) = __tree_.__find_equal(key)

        precondition(__child.pointee == __tree_.nullptr)

        assert(__tree_.count < __tree_.capacity)

        let __h = __tree_.__construct_node(.init(key, __tree_.nullptr, __tree_.nullptr, newValue))
        __tree_.__insert_node_at(__parent, __child, __h)

        ___prepend(__h)
      }
    }
  }
}

extension LRUCache: ___LRULinkList {}

extension LRUCache {

  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    if keepCapacity {
      __tree_.deinitialize()
      (_rankHighest, _rankLowest) = (nullptr, nullptr)
    } else {
      self = .init(maxCount: maxCount)
    }
  }
}

extension LRUCache {

  @inlinable
  public var count: Int { __tree_.count }

  @inlinable
  public var capacity: Int { __tree_.capacity }
}

#endif
