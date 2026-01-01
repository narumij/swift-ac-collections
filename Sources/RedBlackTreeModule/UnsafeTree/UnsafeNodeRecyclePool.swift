@usableFromInline
protocol UnsafeNodeRecyclePool
where _NodePtr == UnsafeMutablePointer<UnsafeNode>? {
  associatedtype _Value
  associatedtype _NodePtr
  var destroyNode: _NodePtr { get set }
  var destroyCount: Int { get set }
}

extension UnsafeNodeRecyclePool {
  
  @inlinable
  @inline(__always)
  mutating func ___pushRecycle(_ p: _NodePtr) {
    assert(p != nil)
    assert(destroyNode != p)
    UnsafePair<_Value>.__value_(p)?.deinitialize(count: 1)
    p?.pointee.___needs_deinitialize = false
    p?.pointee.__left_ = destroyNode
    p?.pointee.__right_ = p
    p?.pointee.__parent_ = nil
    destroyNode = p
    destroyCount += 1
  }
  
  @inlinable
  @inline(__always)
  mutating func ___popRecycle() -> _NodePtr {
    assert(destroyCount > 0)
    let p = destroyNode?.pointee.__right_
    destroyNode = p?.pointee.__left_
    destroyCount -= 1
    return p
  }
  
  @inlinable
  @inline(__always)
  mutating func ___clearRecycle() {
    destroyNode = nil
    destroyCount = 0
  }
}
