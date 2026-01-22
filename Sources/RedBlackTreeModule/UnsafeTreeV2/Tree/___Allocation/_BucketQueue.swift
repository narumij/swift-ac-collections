@frozen
@usableFromInline
struct _BucketQueue {

  @usableFromInline
  internal init(
    pointer: UnsafeMutablePointer<_Bucket>,
    start: UnsafeMutablePointer<UnsafeNode>,
    stride: Int
  ) {
    self.pointer = pointer
    self.start = start
    self.stride = stride
  }

  let pointer: UnsafeMutablePointer<_Bucket>
  let start: UnsafeMutablePointer<UnsafeNode>
  let stride: Int

  subscript(index: Int) -> UnsafeMutablePointer<UnsafeNode> {
    UnsafeMutableRawPointer(start)
      .advanced(by: stride * index)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @usableFromInline
  mutating func pop() -> UnsafeMutablePointer<UnsafeNode>? {
    guard pointer.count < pointer.capacity else { return nil }
    let p = self[pointer.count]
    pointer.pointee.count += 1
    return p
  }

  @usableFromInline
  func next(memoryLayout: _MemoryLayout) -> _BucketQueue? {
    guard let next = pointer.pointee.next else { return nil }
    return next._queue(isHead: false, memoryLayout: memoryLayout)
  }
}

extension UnsafeMutablePointer where Pointee == _Bucket {

  @inlinable
  @inline(__always)
  func _queue(isHead: Bool, memoryLayout: _MemoryLayout) -> _BucketQueue {
    .init(
      pointer: self, start: start(isHead: isHead, valueAlignment: memoryLayout.alignment),
      stride: MemoryLayout<UnsafeNode>.stride + memoryLayout.stride)
  }

  @inlinable
  func queue(memoryLayout: _MemoryLayout) -> _BucketQueue? {
    return _queue(isHead: true, memoryLayout: memoryLayout)
  }
}

extension MemoryLayout {

  @inlinable
  static var _memoryLayout: _MemoryLayout { .init(stride: stride, alignment: alignment) }
}
