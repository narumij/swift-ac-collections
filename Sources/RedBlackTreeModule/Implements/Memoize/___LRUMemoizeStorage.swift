//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

import Foundation

/// メモ化用途向け、LRU (least recently used) cache 動作
/// https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_Recently_Used_(LRU)
///
/// InlineMemoize動作用。CoWがないので注意
@frozen
public struct ___LRUMemoizeStorage<Parameters, Value>
where Parameters: Comparable {

  public
    typealias _Key = Parameters

  public
    typealias _MappedValue = Value

  public
    typealias KeyValue = _LinkingPair<_Key, _MappedValue>

  public
    typealias _PayloadValue = KeyValue

  public let maxCount: Int

  @usableFromInline
  var _rankHighest: _NodePtr

  @usableFromInline
  var _rankLowest: _NodePtr

  @usableFromInline
  var __tree_: Tree
}

extension ___LRUMemoizeStorage {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int = 0, maxCount: Int = Int.max) {
    // enxureUniqueをしないため、シングルトンインスタンスを避けている
    __tree_ = ._createWithNewBuffer(minimumCapacity: minimumCapacity, nullptr: UnsafeNode.nullptr)
    self.maxCount = maxCount
    // これら二つはコピーでケアされない
    // インデックス時代はそれでこまらなかった
    // コピーが発生する前提の場合、別途ケアをする必要がある
    (_rankHighest, _rankLowest) = (__tree_.nullptr, __tree_.nullptr)
  }

  @inlinable
  public subscript(key: _Key) -> Value? {

    @inline(__always) mutating get {
      
      let __ptr = __tree_.update { $0.find(key) }
      
      guard !__ptr.___is_null_or_end else {
        return nil
      }
      
      ___prepend(___pop(__ptr))
            
      return __tree_[_unsafe_raw: __ptr].value
    }

    @inline(__always) set {
      
      guard let newValue else {
        fatalError()
      }

      if __tree_.capacity < maxCount {
        // 無条件で更新するとサイズが安定せず、増加してしまう恐れがある
        __tree_.ensureCapacity(limit: maxCount)
      }
      
      let __h = __tree_.update { __tree_ in
        
        if __tree_.count == maxCount {
          _ = __tree_.erase(___popRankLowest())
        }

        assert(__tree_.count < __tree_.capacity)
        
        let (__parent, __child) = __tree_.__find_equal(key)
        
        guard __child.pointee == __tree_.nullptr else {
          fatalError()
        }
        
        let __h = __tree_.__construct_node(.init(key, __tree_.nullptr, __tree_.nullptr, newValue))
        __tree_.__insert_node_at(__parent, __child, __h)
        
        return __h
      }
      
      ___prepend(__h)
    }
  }
}

extension ___LRUMemoizeStorage: ___LRULinkList {}

extension ___LRUMemoizeStorage {

  @inlinable
  @inline(__always)
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    if keepCapacity {
      __tree_.deinitialize()
    } else {
      self = .init()
    }
  }
}

extension ___LRUMemoizeStorage {

  @inlinable
  public var count: Int { __tree_.count }

  @inlinable
  public var capacity: Int { __tree_.capacity }
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension ___LRUMemoizeStorage {

    package var _copyCount: UInt {
      get { __tree_.copyCount }
      set { __tree_.copyCount = newValue }
    }
  }
#endif
