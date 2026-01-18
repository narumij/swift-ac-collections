
@usableFromInline
struct BucketHelper: UnsafeTreePointer {
  
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
  func nextHelper(_value: (stride: Int, alignment: Int)) -> BucketHelper? {
    guard let next = pointer.pointee.next else { return nil }
    return next._helper(isHead: false, _value: _value)
  }
}

extension UnsafeMutablePointer where Pointee == _UnsafeNodeFreshBucket {
  
  @inlinable
  var end_ptr: UnsafeMutablePointer<UnsafeNode> {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: UnsafeNode.self)
  }
  
  @inlinable
  func storage(isHead: Bool) -> UnsafeMutableRawPointer {
    if isHead {
      return UnsafeMutableRawPointer(self.advanced(by: 1))
        .advanced(by: MemoryLayout<UnsafeNode>.stride)
    } else {
      return UnsafeMutableRawPointer(self.advanced(by: 1))
    }
  }
  
  @inlinable
  func pointer(isHead: Bool, valueAlignment: Int) -> UnsafeMutablePointer<UnsafeNode> {
    let headerAlignment = MemoryLayout<UnsafeNode>.alignment
    let elementAlignment = valueAlignment
    if elementAlignment <= headerAlignment {
      return storage(isHead: isHead)
        .assumingMemoryBound(to: UnsafeNode.self)
    }
    return storage(isHead: isHead)
      .advanced(by: MemoryLayout<UnsafeNode>.stride)
      .alignedUp(toMultipleOf: valueAlignment)
      .advanced(by: -MemoryLayout<UnsafeNode>.stride)
      .assumingMemoryBound(to: UnsafeNode.self)
  }
  
  @inlinable
  func _helper(isHead: Bool, _value: (stride: Int, alignment: Int)) -> BucketHelper {
    .init(pointer: self, start: pointer(isHead: isHead, valueAlignment: _value.alignment), stride: MemoryLayout<UnsafeNode>.stride + _value.stride)
  }
  
  @inlinable
  func helper(_value: (stride: Int, alignment: Int)) -> BucketHelper? {
    return _helper(isHead: true, _value: _value)
  }
  
  @inlinable
  func _counts(isHead: Bool, _value: (stride: Int, alignment: Int)) -> BucketIterator {
    .init(pointer: self, start: pointer(isHead: isHead, valueAlignment: _value.alignment), stride: MemoryLayout<UnsafeNode>.stride + _value.stride, limit: pointee.count)
  }
  
  @inlinable
  func _capacities(isHead: Bool, _value: (stride: Int, alignment: Int)) -> BucketIterator {
    .init(pointer: self, start: pointer(isHead: isHead, valueAlignment: _value.alignment), stride: MemoryLayout<UnsafeNode>.stride + _value.stride, limit: pointee.capacity)
  }
}

extension MemoryLayout {
  
  @inlinable
  static var _value: (stride: Int, alignment: Int) { (stride, alignment) }
}

@usableFromInline
struct BucketIterator: UnsafeTreePointer {
  @inlinable
  internal init(pointer: UnsafeMutablePointer<_UnsafeNodeFreshBucket>, start: UnsafeMutablePointer<UnsafeNode>, stride: Int, limit: Int) {
    self.pointer = pointer
    self.start = start
    self.stride = stride
    self.limit = limit
  }
  
  @usableFromInline
  let pointer: UnsafeMutablePointer<_UnsafeNodeFreshBucket>
  
  @usableFromInline
  let start: _NodePtr
  
  @usableFromInline
  let stride: Int
  
  @usableFromInline
  var limit: Int
  
  @usableFromInline
  var count: Int = 0
  
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
    guard count < limit else { return nil }
    let p = self[count]
    count += 1
    return p
  }
  
  @inlinable
  func nextCounts(_value: (stride: Int, alignment: Int)) -> BucketIterator? {
    guard let next = pointer.pointee.next else { return nil }
    return next._counts(isHead: false, _value: _value)
  }
}
