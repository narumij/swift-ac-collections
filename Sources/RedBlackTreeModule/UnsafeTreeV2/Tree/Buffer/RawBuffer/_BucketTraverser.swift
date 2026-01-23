//
//  BucketIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

@frozen
@usableFromInline
struct _BucketTraverser: _UnsafeNodePtrType {

  @usableFromInline
  internal init(
    pointer: UnsafeMutablePointer<_Bucket>,
    start: UnsafeMutablePointer<UnsafeNode>,
    stride: Int,
    count: Int
  ) {
    self.pointer = pointer
    self.start = start
    self.stride = stride
    self.count = count
  }

  let pointer: UnsafeMutablePointer<_Bucket>
  let start: _NodePtr
  let stride: Int
  var count: Int
  var it: Int = 0

  subscript(index: Int) -> _NodePtr {
    _read {
      yield
      UnsafeMutableRawPointer(start)
        .advanced(by: stride * index)
        .assumingMemoryBound(to: UnsafeNode.self)
    }
  }

  @usableFromInline
  mutating func pop() -> _NodePtr? {
    guard it < count else { return nil }
    let p = self[it]
    it += 1
    return p
  }

  @usableFromInline
  func nextCounts(memoryLayout: _MemoryLayout) -> _BucketTraverser? {
    guard let next = pointer.pointee.next else { return nil }
    return next._counts(isHead: false, memoryLayout: memoryLayout)
  }
}

extension UnsafeMutablePointer where Pointee == _Bucket {

  @usableFromInline
  func _counts(isHead: Bool, memoryLayout: _MemoryLayout) -> _BucketTraverser {
    .init(
      pointer: self,
      start: start(isHead: isHead, valueAlignment: memoryLayout.alignment),
      stride: MemoryLayout<UnsafeNode>.stride + memoryLayout.stride,
      count: pointee.count)
  }

  @usableFromInline
  func _capacities(isHead: Bool, memoryLayout: _MemoryLayout) -> _BucketTraverser {
    .init(
      pointer: self,
      start: start(isHead: isHead, valueAlignment: memoryLayout.alignment),
      stride: MemoryLayout<UnsafeNode>.stride + memoryLayout.stride,
      count: pointee.capacity)
  }
}
