
#if DEBUG
  extension UnsafeTreeV2 {

    package func ___ptr_(_ p: _NodePtr) -> Int {
      p.pointee.___node_id_
    }

    package func __left_(_ p: Int) -> Int {
      __left_(___NodePtr(p)).pointee.___node_id_
    }

    package func __left_(_ p: Int, _ l: Int) {
      __left_(___NodePtr(p), ___NodePtr(l))
    }

    package func __right_(_ p: Int) -> Int {
      __right_(___NodePtr(p)).pointee.___node_id_
    }

    package func __right_(_ p: Int, _ l: Int) {
      __right_(___NodePtr(p), ___NodePtr(l))
    }

    package func __parent_(_ p: Int) -> Int {
      __parent_(___NodePtr(p)).pointee.___node_id_
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

    package func __value_(_ p: Int) -> _Value {
      __value_(___NodePtr(p))
    }

    package func ___element(_ p: Int, _ __v: _Value) {
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
    package var index: Int { pointee.___node_id_ }
  }

  extension Optional where Wrapped == UnsafeMutablePointer<UnsafeNode> {
    package var index: Int { self?.pointee.___node_id_ ?? .nullptr }
  }
#endif

// MARK: -- For assertions

#if DEBUG
  extension UnsafeNode {

    @inlinable
    package func equiv(with tree: UnsafeNode) -> Bool {
      assert(___node_id_ == tree.___node_id_)
      assert(__left_.pointee.___node_id_ == tree.__left_.pointee.___node_id_)
      assert(__right_.pointee.___node_id_ == tree.__right_.pointee.___node_id_)
      assert(__parent_.pointee.___node_id_ == tree.__parent_.pointee.___node_id_)
      assert(__is_black_ == tree.__is_black_)
      assert(___needs_deinitialize == tree.___needs_deinitialize)
      guard
        ___node_id_ == tree.___node_id_,
        __left_.pointee.___node_id_ == tree.__left_.pointee.___node_id_,
        __right_.pointee.___node_id_ == tree.__right_.pointee.___node_id_,
        __parent_.pointee.___node_id_ == tree.__parent_.pointee.___node_id_,
        __is_black_ == tree.__is_black_,
        ___needs_deinitialize == tree.___needs_deinitialize
      else {
        return false
      }
      return true
    }
  }

  extension UnsafeTreeV2Buffer.Header {

    @inlinable
    package func equiv(with other: UnsafeTreeV2Buffer.Header) -> Bool {
      // freshPoolCapacityは等価判定不可
      assert(recycleCount == other.recycleCount)
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

    @inlinable
    package func equiv(with tree: UnsafeTreeV2) -> Bool {
      // isReadOnlyは等価判定不可
      assert(__end_node.pointee.equiv(with: tree.__end_node.pointee))
      assert(
        makeFreshPoolIterator()
          .elementsEqual(
            tree.makeFreshPoolIterator(),
            by: {
              assert($0.pointee.equiv(with: $1.pointee))
              return $0.pointee.equiv(with: $1.pointee)
            }))

      assert(__begin_node_.pointee.___node_id_ == tree.__begin_node_.pointee.___node_id_)
      assert(_buffer.header.equiv(with: tree._buffer.header))
      guard

        __end_node.pointee
          .equiv(with: tree.__end_node.pointee),

        makeFreshPoolIterator()
          .elementsEqual(
            tree.makeFreshPoolIterator(),
            by: {
              $0.pointee.equiv(with: $1.pointee)
            }),

        __begin_node_.pointee.___node_id_
          == tree.__begin_node_.pointee.___node_id_,

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
      assert(___node_id_ == .nullptr)
      assert(__left_ == UnsafeNode.nullptr)
      assert(__right_ == UnsafeNode.nullptr)
      assert(__parent_ == UnsafeNode.nullptr)
      assert(__is_black_ == false)
      assert(___needs_deinitialize == true)
      guard
        ___node_id_ == .nullptr,
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
      assert(___node_id_ == .end)
      assert(__right_ == UnsafeNode.nullptr)
      assert(__parent_ == UnsafeNode.nullptr)
      assert(__is_black_ == false)
      guard
        ___node_id_ == .end,
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
      assert(try! ___tree_invariant(__root))
      guard
        UnsafeNode.nullptr.pointee.nullCheck(),
        end.pointee.endCheck(),
        count == 0 ? emptyCheck() : true,
        (try? ___tree_invariant(__root)) == true,
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

extension UnsafeTreeV2 {

  enum UnsafeTreeError: Swift.Error {
    case message(String)
  }

  /// Determines if the subtree rooted at `__x` is a proper red black subtree.  If
  ///    `__x` is a proper subtree, returns the black height (null counts as 1).  If
  ///    `__x` is an improper subtree, returns 0.
  @usableFromInline
  internal func
    ___tree_sub_invariant(_ __x: _NodePtr) throws -> UInt
  {
    if __x == nullptr {
      return 1
    }
    // parent consistency checked by caller
    // check __x->__left_ consistency
    if __left_(__x) != nullptr && __parent_(__left_(__x)) != __x {
      throw UnsafeTreeError.message(
        """
        parent consistency checked by caller
        check __x->__left_ consistency
        """)
    }
    // check __x->__right_ consistency
    if __right_(__x) != nullptr && __parent_(__right_(__x)) != __x {
      throw UnsafeTreeError.message(
        """
        check __x->__right_ consistency
        """)
    }
    // check __x->__left_ != __x->__right_ unless both are nullptr
    if __left_(__x) == __right_(__x) && __left_(__x) != nullptr {
      throw UnsafeTreeError.message(
        """
        check __x->__left_ != __x->__right_ unless both are nullptr
        """)
    }
    // If this is red, neither child can be red
    if !__is_black_(__x) {
      if __left_(__x) != nullptr && !__is_black_(__left_(__x)) {
        throw UnsafeTreeError.message(
          """
          If this is red, neither child can be red
          """)
      }
      if __right_(__x) != nullptr && !__is_black_(__right_(__x)) {
        throw UnsafeTreeError.message(
          """
          If this is red, neither child can be red
          """)
      }
    }
    let __h = try ___tree_sub_invariant(__left_(__x))
    if __h == 0 {
      throw UnsafeTreeError.message(
        """
        invalid left subtree
        """)
    }  // invalid left subtree
    if try __h != ___tree_sub_invariant(__right_(__x)) {
      throw UnsafeTreeError.message(
        """
        invalid or different height right subtree
        """)
    }  // invalid or different height right subtree
    return __h + (__is_black_(__x) ? 1 : 0)  // return black height of this node
  }

  /// Determines if the red black tree rooted at `__root` is a proper red black tree.
  ///    `__root` == nullptr is a proper tree.  Returns true if `__root` is a proper
  ///    red black tree, else returns false.
  @usableFromInline
  internal func
    ___tree_invariant(_ __root: _NodePtr) throws -> Bool
  {
    if __root == nullptr {
      return true
    }
    // check __x->__parent_ consistency
    if __parent_(__root) == nullptr {
      throw UnsafeTreeError.message("check __x->__parent_ consistency")
    }
    if !__tree_is_left_child(__root) {
      throw UnsafeTreeError.message("check left child of __root")
    }
    // root must be black
    if !__is_black_(__root) {
      throw UnsafeTreeError.message("root must be black")
    }
    // do normal node checks
    return try ___tree_sub_invariant(__root) != 0
  }
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
    "not both, maybe pool v1"
  }
#endif
}
