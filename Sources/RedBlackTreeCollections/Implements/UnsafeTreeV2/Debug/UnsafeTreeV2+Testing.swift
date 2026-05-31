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

#if DEBUG
  extension UnsafeTreeV2 {

    @inlinable
    func makeUsedNodeIterator() -> _FreshPoolUsedIterator<_PayloadValue> {
      return _buffer.header.makeUsedNodeIterator()
    }
  }
#endif

// MARK: -- For assertions

#if DEBUG
  extension UnsafeTreeV2BufferHeader {

    package func equiv(with other: UnsafeTreeV2BufferHeader) -> Bool {
      // freshPoolCapacityは等価判定不可
      assert(freshPoolUsedCount == other.freshPoolUsedCount)
      assert(recycleCount == other.recycleCount)
      assert(freshPoolActualCount == other.freshPoolActualCount)
      assert(___recycleNodes == other.___recycleNodes)
      guard
        freshPoolUsedCount == other.freshPoolUsedCount,
        freshPoolActualCount == other.freshPoolActualCount,
        recycleCount == other.recycleCount,
        ___recycleNodes == other.___recycleNodes
      else {
        return false
      }
      return true
    }
  }

  extension UnsafeTreeV2 {

    @usableFromInline
    package func equiv(with tree: UnsafeTreeV2) -> Bool {
      // isReadOnlyは等価判定不可
      assert(__end_node.pointee.equiv(with: tree.__end_node.pointee))
      //      assert(
      //        makeFreshPoolIterator()
      //          .elementsEqual(
      //            tree.makeFreshPoolIterator(),
      //            by: {
      //              assert($0.pointee.equiv(with: $1.pointee))
      //              return $0.pointee.equiv(with: $1.pointee)
      //            }))

      assert(__begin_node_.pointee.___tracking_tag == tree.__begin_node_.pointee.___tracking_tag)
      assert(_buffer.header.equiv(with: tree._buffer.header))
      guard

        __end_node.pointee
          .equiv(with: tree.__end_node.pointee),

        makeUsedNodeIterator()
          .elementsEqual(
            tree.makeUsedNodeIterator(),
            by: {
              $0.pointee.equiv(with: $1.pointee)
            }),

        __begin_node_.pointee.___tracking_tag
          == tree.__begin_node_.pointee.___tracking_tag,

        _buffer.header.equiv(with: tree._buffer.header)

      else {
        return false
      }
      return true
    }
  }
#endif

#if DEBUG
  extension UnsafeTreeV2 {

    package func emptyCheck() -> Bool {
      assert(__tree_invariant(__root))
      assert(end.pointee.__left_ == UnsafeNode.nullptr)
      assert(__begin_node_ == end)
      assert(end.pointee.___has_payload_content == false)
      assert(count == 0)
      assert(count <= initializedCount)
      assert(count <= capacity)
      assert(initializedCount <= capacity)
      assert(isReadOnly ? count == 0 : true)
      guard
        __tree_invariant(__root),
        end.pointee.__left_ == UnsafeNode.nullptr,
        __begin_node_ == end,
        end.pointee.___has_payload_content == false,
        count == 0,
        count <= initializedCount,
        count <= capacity,
        initializedCount <= capacity,
        isReadOnly ? count == 0 : true
      else {
        return false
      }
      return true
    }

    @usableFromInline
    package func check() -> Bool {
      assert(UnsafeNode.nullptr.pointee.nullCheck())
      assert(end.pointee.endCheck())
      assert(count == 0 ? emptyCheck() : true)
      assert(__tree_invariant(__root))
      assert(count >= 0)
      assert(count <= initializedCount)
      assert(count <= capacity)
      assert(initializedCount <= capacity)
      assert(isReadOnly ? count == 0 : true)
      guard
        UnsafeNode.nullptr.pointee.nullCheck(),
        end.pointee.endCheck(),
        count == 0 ? emptyCheck() : true,
        __tree_invariant(__root),
        count >= 0,
        count <= initializedCount,
        count <= capacity,
        initializedCount <= capacity,
        isReadOnly ? count == 0 : true,
        true
        //      _buffer.header.___recycleNodes.count == _buffer.header.recycleCount,
        //      (makeFreshBucketIterator() + []).first == _buffer.header.freshBucketHead,
        //      _buffer.header.freshBucketCurrent.map({
        //        makeFreshBucketIterator().contains($0)
        //      }) ?? true,
        //      (makeFreshBucketIterator() + []).last == _buffer.header.freshBucketLast
      else {
        return false
      }
      return true
    }
  }
#endif

@usableFromInline
func __equiv<Base>(_ lhs: UnsafeTreeV2<Base>, _ rhs: UnsafeTreeV2<Base>) -> Bool {
  #if DEBUG
    return lhs.equiv(with: rhs)
  #else
    fatalError()
  #endif
}

@usableFromInline
func __check<Base>(_ tree: UnsafeTreeV2<Base>) -> Bool {
  #if DEBUG
    return tree.check()
  #else
    fatalError()
  #endif
}
