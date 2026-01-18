
@frozen
@usableFromInline
struct BucketQueue: UnsafeTreePointer {
  
  @inlinable
  internal init(pointer: UnsafeMutablePointer<_UnsafeNodeFreshBucket>, start: UnsafeMutablePointer<UnsafeNode>, stride: Int) {
    self.pointer = pointer
    self.start = start
    self.stride = stride
  }
  
  @usableFromInline
  let pointer: UnsafeMutablePointer<_UnsafeNodeFreshBucket>
  @usableFromInline
  let start: _NodePtr
  @usableFromInline
  let stride: Int
  
  @inlinable
  var capacity: Int {
    _read { yield pointer.pointee.capacity }
  }
  
  @inlinable
  var count: Int {
    _read { yield pointer.pointee.count }
    _modify { yield &pointer.pointee.count }
  }
  
  @inlinable
  subscript(index: Int) -> _NodePtr {
    _read {
      yield
      UnsafeMutableRawPointer(start)
        .advanced(by: stride * index)
        .assumingMemoryBound(to: UnsafeNode.self)
    }
  }
  
  @inlinable
  mutating func pop() -> _NodePtr? {
    guard count < capacity else { return nil }
    let p = self[count]
    count += 1
    return p
  }
  
  @inlinable
  func next(_value: (stride: Int, alignment: Int)) -> BucketQueue? {
    guard let next = pointer.pointee.next else { return nil }
    return next._queue(isHead: false, memoryLayout: _value)
  }
}



extension UnsafeMutablePointer where Pointee == _UnsafeNodeFreshBucket {
  
  @inlinable
  func _queue(isHead: Bool, memoryLayout: (stride: Int, alignment: Int)) -> BucketQueue {
    .init(pointer: self, start: pointer(isHead: isHead, valueAlignment: memoryLayout.alignment), stride: MemoryLayout<UnsafeNode>.stride + memoryLayout.stride)
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



