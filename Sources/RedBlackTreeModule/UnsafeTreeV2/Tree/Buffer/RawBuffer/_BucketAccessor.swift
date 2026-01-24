//
//  BucketAccessor.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

@frozen
@usableFromInline
package struct _BucketAccessor: _UnsafeNodePtrType {

  @usableFromInline
  package init(
    pointer: UnsafeMutablePointer<_Bucket>,
    start: UnsafeMutablePointer<UnsafeNode>,
    stride: Int
  ) {
    self.pointer = pointer
    self.start = start
    self.stride = stride
  }

  let pointer: UnsafeMutablePointer<_Bucket>
  let start: _NodePtr
  let stride: Int

  @usableFromInline
  var capacity: Int {
    _read { yield pointer.pointee.capacity }
  }

  @usableFromInline
  package subscript(index: Int) -> _NodePtr {
    _read {
      yield
      UnsafeMutableRawPointer(start)
        .advanced(by: stride * index)
        .assumingMemoryBound(to: UnsafeNode.self)
    }
  }

  @usableFromInline
  func next(_value: _MemoryLayout) -> _BucketAccessor? {
    guard let next = pointer.pointee.next else { return nil }
    return next._accessor(isHead: false, _value: _value)
  }
}

extension UnsafeMutablePointer where Pointee == _Bucket {

  @inlinable
  @inline(__always)
  func _accessor(isHead: Bool, _value: _MemoryLayout) -> _BucketAccessor {
    .init(
      pointer: self, start: start(isHead: isHead, valueAlignment: _value.alignment),
      stride: MemoryLayout<UnsafeNode>.stride + _value.stride)
  }

  @inlinable
  func accessor(_value: _MemoryLayout) -> _BucketAccessor? {
    _accessor(isHead: true, _value: _value)
  }
}
