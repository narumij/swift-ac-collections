@frozen
@usableFromInline
struct BucketQueue: _UnsafeNodePtrType {

  @usableFromInline
  internal init(
    pointer: UnsafeMutablePointer<_UnsafeNodeFreshBucket>,
    start: UnsafeMutablePointer<UnsafeNode>,
    stride: Int
  ) {
    self.pointer = pointer
    self.start = start
    self.stride = stride
    self.capacity = pointer.pointee.capacity
  }

  let pointer: UnsafeMutablePointer<_UnsafeNodeFreshBucket>
  let start: _NodePtr
  let stride: Int
  let capacity: Int

  var count: Int {
    get { pointer.pointee.count }
    _modify { yield &pointer.pointee.count }
  }

  subscript(index: Int) -> _NodePtr {
    UnsafeMutableRawPointer(start)
      .advanced(by: stride * index)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @usableFromInline
  mutating func pop() -> _NodePtr? {
    guard count < capacity else { return nil }
    let p = self[count]
    count += 1
    return p
  }

  @usableFromInline
  func next(_value: (stride: Int, alignment: Int)) -> BucketQueue? {
    guard let next = pointer.pointee.next else { return nil }
    return next._queue(isHead: false, memoryLayout: _value)
  }
}

extension UnsafeMutablePointer where Pointee == _UnsafeNodeFreshBucket {

  @inlinable
  @inline(__always)
  func _queue(isHead: Bool, memoryLayout: (stride: Int, alignment: Int)) -> BucketQueue {
    .init(
      pointer: self, start: pointer(isHead: isHead, valueAlignment: memoryLayout.alignment),
      stride: MemoryLayout<UnsafeNode>.stride + memoryLayout.stride)
  }

  @inlinable
  func queue(memoryLayout: (stride: Int, alignment: Int)) -> BucketQueue? {
    return _queue(isHead: true, memoryLayout: memoryLayout)
  }
}

extension MemoryLayout {

  @inlinable
  static var _value: (stride: Int, alignment: Int) { (stride, alignment) }
}
