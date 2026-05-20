#if DEBUG
  extension UnsafeTreeV2 {

    package func ___ptr_(_ p: _NodePtr) -> Int {
      p.pointee.___tracking_tag
    }

    package func __left_(_ p: Int) -> Int {
      try! __retrieve_(p).get().pointee.__left_.trackingTag
    }

    package func __left_(_ p: Int, _ l: Int) {
      try! __retrieve_(p).get().pointee.__left_ = try! __retrieve_(l).get()
    }

    package func __right_(_ p: Int) -> Int {
      try! __retrieve_(p).get().pointee.__right_.trackingTag
    }

    package func __right_(_ p: Int, _ l: Int) {
      try! __retrieve_(p).get().pointee.__right_ = try! __retrieve_(l).get()
    }

    package func __parent_(_ p: Int) -> Int {
      try! __retrieve_(p).get().pointee.__parent_.trackingTag
    }

    package func __parent_(_ p: Int, _ l: Int) {
      try! __retrieve_(p).get().pointee.__parent_ = try! __retrieve_(l).get()
    }

    package func __is_black_(_ p: Int) -> Bool {
      try! __retrieve_(p).get().pointee.__is_black_
    }

    package func __is_black_(_ p: Int, _ b: Bool) {
      try! __retrieve_(p).get().pointee.__is_black_ = b
    }

    package func __value_(_ p: Int) -> _PayloadValue {
      __value_(try! __retrieve_(p).get())
    }

    package func ___element(_ p: Int, _ __v: _PayloadValue) {
      //      ___element(try! __retrieve_(p).get(), __v)
      try! __retrieve_(p).get().__value_().pointee = __v
    }
  }

  extension UnsafeTreeV2 {

    package func destroy(_ p: Int) {
      _buffer.withUnsafeMutablePointerToHeader { header in
        header.pointee.___pushRecycle(_buffer.header[p])
      }
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
      assert(count == 0)
      assert(count <= initializedCount)
      assert(count <= capacity)
      assert(initializedCount <= capacity)
      assert(isReadOnly ? count == 0 : true)
      guard
        __tree_invariant(__root),
        end.pointee.__left_ == UnsafeNode.nullptr,
        __begin_node_ == end,
        end.pointee.___has_payload_content == true,
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
      assert(count >= 0)
      assert(count <= initializedCount)
      assert(count <= capacity)
      assert(initializedCount <= capacity)
      assert(isReadOnly ? count == 0 : true)
      assert(__tree_invariant(__root))
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
#else
  //  extension UnsafeTreeV2 {
  //    @inlinable
  //    package func equiv(with tree: UnsafeTreeV2) -> Bool {
  //      return true
  //    }
  //    @inlinable
  //    package func check() -> Bool {
  //      return true
  //    }
  //  }
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
