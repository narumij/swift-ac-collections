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

@usableFromInline
protocol _RecyclePool: _UnsafeNodePtrType {
  var recycleHead: _NodePtr { get set }
  var count: Int { get set }
  var freshPoolUsedCount: Int { get set }
  var nullptr: _NodePtr { get }
  var freshBucketAllocator: _BucketAllocator { get }
}

extension _RecyclePool {

  @inlinable
  mutating func ___pushRecycle(_ p: _NodePtr) {
    assert(p.pointee.___tracking_tag > .end)
    assert(recycleHead != p)
    count -= 1
    #if DEBUG
      p.pointee.___recycle_count += 1
    #endif
    freshBucketAllocator.deinitialize(p.advanced(by: 1))
    #if GRAPHVIZ_DEBUG
      p.pointee.__right_ = nullptr
      p.pointee.__parent_ = nullptr
    #endif
    p.pointee.___needs_deinitialize = false
    p.pointee.__left_ = recycleHead
    recycleHead = p
  }

  @usableFromInline
  mutating func ___popRecycle() -> _NodePtr {
    let p = recycleHead
    recycleHead = p.pointee.__left_
    count += 1
    p.pointee.___needs_deinitialize = true
    return p
  }

  @usableFromInline
  mutating func ___flushRecyclePool() {
    recycleHead = nullptr
    count = 0  // これは不適切な気がする
  }
}

#if DEBUG || GRAPHVIZ_DEBUG
  extension _RecyclePool {
    
    @usableFromInline
    var recycleCount: Int {
      freshPoolUsedCount - count
    }

    @usableFromInline
    internal var ___recycleNodes: [Int] {
      var nodes: [Int] = []
      var last = recycleHead
      while last != nullptr {
        nodes.append(last.pointee.___tracking_tag)
        last = last.pointee.__left_
      }
      return nodes
    }
  }
#endif
