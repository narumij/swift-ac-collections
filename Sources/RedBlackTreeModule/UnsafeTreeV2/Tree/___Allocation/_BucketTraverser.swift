//
//  BucketIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

@usableFromInline
struct _BucketTraverser: _UnsafeNodePtrType {
  
  @inlinable
  internal init(pointer: UnsafeMutablePointer<_UnsafeNodeFreshBucket>, start: UnsafeMutablePointer<UnsafeNode>, stride: Int, count: Int) {
    self.pointer = pointer
    self.start = start
    self.stride = stride
    self.count = count
  }
  
  @usableFromInline
  let pointer: UnsafeMutablePointer<_UnsafeNodeFreshBucket>
  
  @usableFromInline
  let start: _NodePtr
  
  @usableFromInline
  let stride: Int
  
  @usableFromInline
  var count: Int
  
  @usableFromInline
  var it: Int = 0
  
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
    guard it < count else { return nil }
    let p = self[it]
    it += 1
    return p
  }
  
  @inlinable
  func nextCounts(memoryLayout: _MemoryLayout) -> _BucketTraverser? {
    guard let next = pointer.pointee.next else { return nil }
    return next._counts(isHead: false, memoryLayout: memoryLayout)
  }
}

extension UnsafeMutablePointer where Pointee == _UnsafeNodeFreshBucket {
  
  @inlinable
  func _counts(isHead: Bool, memoryLayout: _MemoryLayout) -> _BucketTraverser {
    .init(pointer: self, start: start(isHead: isHead, valueAlignment: memoryLayout.alignment), stride: MemoryLayout<UnsafeNode>.stride + memoryLayout.stride, count: pointee.count)
  }
  
  @inlinable
  func _capacities(isHead: Bool, memoryLayout: _MemoryLayout) -> _BucketTraverser {
    .init(pointer: self, start: start(isHead: isHead, valueAlignment: memoryLayout.alignment), stride: MemoryLayout<UnsafeNode>.stride + memoryLayout.stride, count: pointee.capacity)
  }
}
