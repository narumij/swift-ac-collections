
@usableFromInline
protocol ___RedBlackTreeNodePoolProtocol: MemberSetProtocol {
  associatedtype Element
  var ___destroy_node: _NodePtr { get nonmutating set }
  var ___destroy_count: Int { get nonmutating set }
  func ___initialize(_ :Element) -> _NodePtr
  func ___element(_ p: _NodePtr, _: Element)
}

extension ___RedBlackTreeNodePoolProtocol {
  /// O(1)
  @inlinable
  @inline(__always)
  internal func ___pushDestroy(_ p: _NodePtr) {
    __left_(p, ___destroy_node)
    __right_(p, p)
    __parent_(p, .nullptr)
    __is_black_(p, false)
    ___destroy_node = p
    ___destroy_count += 1
  }
  /// O(1)
  @inlinable
  @inline(__always)
  internal func ___popDetroy() -> _NodePtr {
    let p = __right_(___destroy_node)
    ___destroy_node = __left_(p)
    ___destroy_count -= 1
    return p
  }
  /// O(1)
  @inlinable
  internal func ___clearDestroy() {
    ___destroy_node = .nullptr
    ___destroy_count = 0
  }
  
#if AC_COLLECTIONS_INTERNAL_CHECKS
  /// O(*k*)
  var ___destroyNodes: [_NodePtr] {
    if ___destroy_node == .nullptr {
      return []
    }
    var nodes: [_NodePtr] = [___destroy_node]
    while let l = nodes.last, __left_(l) != .nullptr {
      nodes.append(__left_(l))
    }
    return nodes
  }
#endif

  @inlinable
  internal func ___recycle(_ k: Element) -> _NodePtr {
    let p = ___popDetroy()
    ___element(p, k)
    return p
  }

  @inlinable
  internal func __construct_node(_ k: Element) -> _NodePtr {
    ___destroy_count > 0 ? ___recycle(k) : ___initialize(k)
  }

  @inlinable
  func destroy(_ p: _NodePtr) {
    ___pushDestroy(p)
  }
}


#if false
extension ___RedBlackTree.___Tree: ___RedBlackTreeNodePoolProtocol {
  @usableFromInline
  var ___destroy_node: _NodePtr {
    get { _header.destroyNode }
    _modify {
      yield &_header.destroyNode
    }
  }
  @usableFromInline
  var ___destroy_count: Int {
    get { _header.destroyCount }
    _modify {
      yield &_header.destroyCount
    }
  }
  @usableFromInline
  func ___initialize(_ k: Element) -> _NodePtr
  {
    assert(capacity - count >= 1)
    let index = _header.initializedCount
    (__node_ptr + index).initialize(to: Node(__value_: k))
    _header.initializedCount += 1
    assert(_header.initializedCount <= _header.capacity)
    return index
  }
}
#endif
