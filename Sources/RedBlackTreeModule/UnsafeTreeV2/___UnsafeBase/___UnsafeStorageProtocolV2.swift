
@usableFromInline
protocol ___UnsafeStorageProtocolV2: ___Root
where
  Base: ___TreeBase,
  Tree == UnsafeTreeV2<Base>,
  _Value == Tree._Value,
  _NodePtr == Tree._NodePtr
{
  associatedtype _Value
  associatedtype _NodePtr
  var __tree_: Tree { get set }
}

extension ___UnsafeStorageProtocolV2 {
  
  @inlinable
  @inline(__always)
  internal var _start: _NodePtr {
    __tree_.__begin_node_
  }

  @inlinable
  @inline(__always)
  internal var _end: _NodePtr {
    __tree_.__end_node
  }

  @inlinable
  @inline(__always)
  internal var ___count: Int {
    __tree_.count
  }

  @inlinable
  @inline(__always)
  internal var ___capacity: Int {
    __tree_.capacity
  }
}

// MARK: - Remove

extension ___UnsafeStorageProtocolV2 {

  @inlinable
  @inline(__always)
  @discardableResult
  internal mutating func ___remove(at ptr: _NodePtr) -> _Value? {
    guard !__tree_.___is_subscript_null(ptr) else {
      return nil
    }
    let e = __tree_[ptr]
    _ = __tree_.erase(ptr)
    return e
  }

  @inlinable
  @inline(__always)
  @discardableResult
  internal mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard !__tree_.___is_end(from) else {
      return __tree_.end
    }
    __tree_.___ensureValid(begin: from, end: to)
    return __tree_.erase(from, to)
  }
}

extension ___UnsafeStorageProtocolV2 {

  @inlinable
  @inline(__always)
  internal mutating func ___removeAll(keepingCapacity keepCapacity: Bool = false) {

    if keepCapacity {
      __tree_.__eraseAll()
    } else {
//      _storage = .create(withCapacity: 0)
      fatalError()
    }
  }
}

