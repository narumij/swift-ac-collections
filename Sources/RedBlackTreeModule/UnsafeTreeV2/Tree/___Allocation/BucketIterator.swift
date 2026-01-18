//
//  BucketIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

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
  func next(memoryLayout: (stride: Int, alignment: Int)) -> BucketIterator? {
    guard let next = pointer.pointee.next else { return nil }
    return next._counts(isHead: false, memoryLayout: memoryLayout)
  }
}

extension UnsafeMutablePointer where Pointee == _UnsafeNodeFreshBucket {
  
  @inlinable
  func _counts(isHead: Bool, memoryLayout: (stride: Int, alignment: Int)) -> BucketIterator {
    .init(pointer: self, start: pointer(isHead: isHead, valueAlignment: memoryLayout.alignment), stride: MemoryLayout<UnsafeNode>.stride + memoryLayout.stride, limit: pointee.count)
  }
  
  @inlinable
  func _capacities(isHead: Bool, memoryLayout: (stride: Int, alignment: Int)) -> BucketIterator {
    .init(pointer: self, start: pointer(isHead: isHead, valueAlignment: memoryLayout.alignment), stride: MemoryLayout<UnsafeNode>.stride + memoryLayout.stride, limit: pointee.capacity)
  }
}
