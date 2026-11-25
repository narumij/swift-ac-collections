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

#if !COMPATIBLE_ATCODER_2025 && ENABLE_EXPERIMENTAL_LRU
// 素朴で速いほうを選ぶので、Sendableにはしない
// 並列対応が必要なら、Actorにでも放り込んでくれたらいい

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

  @usableFromInline
  let linkList: UnsafeMutablePointer<LinkList>

  @usableFromInline
  var __tree_: Tree
}

extension LRUCache {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  public init(minimumCapacity: Int = 0, maxCount: Int = Int.max) {
    precondition(maxCount > 0, "maxCount must be positive")
    __tree_ = ._createWithNewBuffer(minimumCapacity: minimumCapacity, nullptr: .nullptr)
    linkList = .allocate(capacity: 1)
    linkList.initialize(to: .init(maxCount: maxCount))
  }

  @inlinable
  package var maxCount: Int { linkList.pointee.maxCount }

  @inlinable
  public subscript(key: _Key) -> Value? {

    @inline(__always) mutating get {

      return update {
        let __ptr = $0.find(key)
        guard !__ptr.___is_end else { return nil }
        $1.prepend($1.pop(__ptr))
        return Base.__payload_(__ptr).value
      }
    }

    @inline(__always) set {

      guard let newValue else {
        fatalError()
      }

      __tree_.ensureCapacity(limit: maxCount)
      
      update { __tree_, linkList in

        if __tree_.count == linkList.maxCount {
          _ = __tree_.erase(linkList.popRankLowest())
        }
        
        let (__parent, __child) = __tree_.__find_equal(key)

        precondition(__child.pointee == __tree_.nullptr)

        assert(__tree_.count < __tree_.capacity)

        let __h = __tree_.__construct_node(.init(key, __tree_.nullptr, __tree_.nullptr, newValue))
        __tree_.__insert_node_at(__parent, __child, __h)

        linkList.prepend(__h)
      }
    }
  }
}

extension LRUCache: LinkPairValueTrait & IntThreeWayComparator {
  @usableFromInline typealias Base = ___LRULinkListBase<_Key, _MappedValue>
  @usableFromInline typealias Tree = UnsafeTreeV2<Base>
  @usableFromInline typealias LinkList = _LinkList<Key, Value>
}

extension LRUCache {

  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    if keepCapacity {
      __tree_.deinitialize()
      linkList.pointee.reset()
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

extension LRUCache {

  @usableFromInline
  typealias _LRUHandle = ___LRUHandle<_Key, Base._MappedValue>

  @inlinable
  internal mutating func update<R>(_ body: (inout _LRUHandle, inout LinkList) throws -> R) rethrows -> R {
    try __tree_._buffer.withUnsafeMutablePointers { header, _ in
      var handle = _LRUHandle(header: header)
      return try body(&handle, &linkList.pointee)
    }
  }
}

#endif
