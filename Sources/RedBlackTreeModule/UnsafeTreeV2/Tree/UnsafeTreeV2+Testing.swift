#if DEBUG
extension UnsafeTreeV2 {

  package func ___NodePtr(_ p: Int) -> _NodePtr {
    switch p {
    case .nullptr:
      return nullptr
    case .end:
      return end
    default:
      return _buffer.header[p]
    }
  }
}

extension UnsafeTreeV2 {

  package func ___ptr_(_ p: _NodePtr) -> Int {
    p.pointee.___node_id_
  }

  package func __left_(_ p: Int) -> Int {
    __left_(___NodePtr(p)).pointee.___node_id_
  }

  package func __left_(_ p: Int,_ l: Int) {
    __left_(___NodePtr(p), ___NodePtr(l))
  }

  package func __right_(_ p: Int) -> Int {
    __right_(___NodePtr(p)).pointee.___node_id_
  }
  
  package func __right_(_ p: Int,_ l: Int) {
    __right_(___NodePtr(p), ___NodePtr(l))
  }

  package func __parent_(_ p: Int) -> Int {
    __parent_(___NodePtr(p)).pointee.___node_id_
  }
  
  package func __parent_(_ p: Int,_ l: Int) {
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
    assert(__begin_node_.pointee.___node_id_ == other.__begin_node_.pointee.___node_id_)
    assert(recycleCount == other.recycleCount)
    guard
      __begin_node_.pointee.___node_id_ == other.__begin_node_.pointee.___node_id_,
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
      _buffer.header.__begin_node_ == end,
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
      _buffer.header.___recycleNodes.count == _buffer.header.recycleCount
    else {
      return false
    }
    return true
  }
}
