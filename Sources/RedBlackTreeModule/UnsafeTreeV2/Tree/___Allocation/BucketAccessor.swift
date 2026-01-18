//
//  BucketAccessor.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

@frozen
@usableFromInline
struct BucketAccessor: UnsafeTreePointer {
  
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
  subscript(index: Int) -> _NodePtr {
    _read {
      yield
      UnsafeMutableRawPointer(start)
        .advanced(by: stride * index)
        .assumingMemoryBound(to: UnsafeNode.self)
    }
  }
  
  @inlinable
  func next(_value: (stride: Int, alignment: Int)) -> BucketAccessor? {
    guard let next = pointer.pointee.next else { return nil }
    return next._accessor(isHead: false, _value: _value)
  }
}

extension UnsafeMutablePointer where Pointee == _UnsafeNodeFreshBucket {
  
  @inlinable
  func _accessor(isHead: Bool, _value: (stride: Int, alignment: Int)) -> BucketAccessor {
    .init(pointer: self, start: pointer(isHead: isHead, valueAlignment: _value.alignment), stride: MemoryLayout<UnsafeNode>.stride + _value.stride)
  }
  
  @inlinable
  func accessor(_value: (stride: Int, alignment: Int)) -> BucketAccessor? {
    _accessor(isHead: true, _value: _value)
  }
}

