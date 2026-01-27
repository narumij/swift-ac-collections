#if DEBUG
  extension UnsafeTreeV2 {

    package func ___ptr_(_ p: _NodePtr) -> Int {
      p.pointee.___raw_index
    }

    package func __left_(_ p: Int) -> Int {
      __left_(___NodePtr(p)).pointee.___raw_index
    }

    package func __left_(_ p: Int, _ l: Int) {
      __left_(___NodePtr(p), ___NodePtr(l))
    }

    package func __right_(_ p: Int) -> Int {
      __right_(___NodePtr(p)).pointee.___raw_index
    }

    package func __right_(_ p: Int, _ l: Int) {
      __right_(___NodePtr(p), ___NodePtr(l))
    }

    package func __parent_(_ p: Int) -> Int {
      __parent_(___NodePtr(p)).pointee.___raw_index
    }

    package func __parent_(_ p: Int, _ l: Int) {
      __parent_(___NodePtr(p), ___NodePtr(l))
    }

    package func __is_black_(_ p: Int) -> Bool {
      __is_black_(___NodePtr(p))
    }

    package func __is_black_(_ p: Int, _ b: Bool) {
      __is_black_(___NodePtr(p), b)
    }

    package func __value_(_ p: Int) -> _Payload {
      __value_(___NodePtr(p))
    }

    package func ___element(_ p: Int, _ __v: _Payload) {
      ___element(___NodePtr(p), __v)
    }
  }

  extension UnsafeTreeV2 {

    package func destroy(_ p: Int) {
      _buffer.withUnsafeMutablePointerToHeader { header in
        header.pointee.___pushRecycle(_buffer.header[p])
      }
    }
  }

  extension UnsafeMutablePointer where Pointee == UnsafeNode {
    package var index: Int { pointee.___raw_index }
  }

  extension Optional where Wrapped == UnsafeMutablePointer<UnsafeNode> {
    package var index: Int { self?.pointee.___raw_index ?? .nullptr }
  }
#endif

// MARK: -- For assertions

#if DEBUG
  extension UnsafeNode {

    @inlinable
    package func equiv(with tree: UnsafeNode) -> Bool {
      assert(___raw_index == tree.___raw_index)
      assert(__left_.pointee.___raw_index == tree.__left_.pointee.___raw_index)
      assert(__right_.pointee.___raw_index == tree.__right_.pointee.___raw_index)
      assert(__parent_.pointee.___raw_index == tree.__parent_.pointee.___raw_index)
      assert(__is_black_ == tree.__is_black_)
      assert(___needs_deinitialize == tree.___needs_deinitialize)
      guard
        ___raw_index == tree.___raw_index,
        __left_.pointee.___raw_index == tree.__left_.pointee.___raw_index,
        __right_.pointee.___raw_index == tree.__right_.pointee.___raw_index,
        __parent_.pointee.___raw_index == tree.__parent_.pointee.___raw_index,
        __is_black_ == tree.__is_black_,
        ___needs_deinitialize == tree.___needs_deinitialize
      else {
        return false
      }
      return true
    }
  }

  extension UnsafeTreeV2BufferHeader {

    @inlinable
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

      assert(__begin_node_.pointee.___raw_index == tree.__begin_node_.pointee.___raw_index)
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

        __begin_node_.pointee.___raw_index
          == tree.__begin_node_.pointee.___raw_index,

        _buffer.header.equiv(with: tree._buffer.header)

      else {
        return false
      }
      return true
    }
  }

  extension UnsafeNode {

    @inlinable
    package func nullCheck() -> Bool {
      assert(___raw_index == .nullptr)
      assert(__left_ == UnsafeNode.nullptr)
      assert(__right_ == UnsafeNode.nullptr)
      assert(__parent_ == UnsafeNode.nullptr)
      assert(__is_black_ == false)
      assert(___needs_deinitialize == true)
      guard
        ___raw_index == .nullptr,
        __right_ == UnsafeNode.nullptr,
        __right_ == UnsafeNode.nullptr,
        __parent_ == UnsafeNode.nullptr,
        __is_black_ == false,
        // 判定を簡略化するための措置
        ___needs_deinitialize == true
      else {
        return false
      }
      return true
    }

    @inlinable
    package func endCheck() -> Bool {
      assert(___raw_index == .end)
      assert(__right_ == UnsafeNode.nullptr)
      assert(__parent_ == UnsafeNode.nullptr)
      assert(__is_black_ == false)
      guard
        ___raw_index == .end,
        __right_ == UnsafeNode.nullptr,
        __parent_ == UnsafeNode.nullptr,
        __is_black_ == false,
        // 判定を簡略化するための措置
        ___needs_deinitialize == true
      else {
        return false
      }
      return true
    }
  }

  extension UnsafeTreeV2 {

    @inlinable
    package func emptyCheck() -> Bool {
      assert(__tree_invariant(__root))
      assert(count == 0)
      assert(count <= initializedCount)
      assert(count <= capacity)
      assert(initializedCount <= capacity)
      assert(isReadOnly ? count == 0 : true)
      guard
        __tree_invariant(__root),
        end.pointee.__left_ == UnsafeNode.nullptr,
        __begin_node_ == end,
        end.pointee.___needs_deinitialize == true,
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

    @inlinable
    package func check() -> Bool {
      assert(UnsafeNode.nullptr.pointee.nullCheck())
      assert(end.pointee.endCheck())
      assert(count >= 0)
      assert(count <= initializedCount)
      assert(count <= capacity)
      assert(initializedCount <= capacity)
      assert(isReadOnly ? count == 0 : true)
      assert(try! __tree_invariant_checked(__root))
      guard
        UnsafeNode.nullptr.pointee.nullCheck(),
        end.pointee.endCheck(),
        count == 0 ? emptyCheck() : true,
        (try? __tree_invariant_checked(__root)) == true,
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
#else
  extension UnsafeTreeV2 {
    @inlinable
    package func equiv(with tree: UnsafeTreeV2) -> Bool {
      return true
    }
    @inlinable
    package func check() -> Bool {
      return true
    }
  }
#endif

extension RedBlackTreeSet {

  #if USE_FRESH_POOL_V1
    public static var buildInfo: String {
      "USE_FRESH_POOL_V1"
    }
  #elseif USE_FRESH_POOL_V2
    public static var buildInfo: String {
      "USE_FRESH_POOL_V2"
    }
  #else
    public static var buildInfo: String {
      "USE_FRESH_POOL_V3"
    }
  #endif
}
