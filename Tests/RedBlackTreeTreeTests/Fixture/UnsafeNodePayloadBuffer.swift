#if DEBUG
@testable import RedBlackTreeCollections

extension _UnsafeNodePtrType where Self: ~Copyable, Self: _PayloadValueType {
  
  public typealias _PayloadBuffer = UnsafeMutableBufferPointer<_PayloadValue>

  @inlinable
  static func __payload_buffer(_ p: _NodePtr) -> _PayloadBuffer {
    .init(start: __payload_ptr(p), count: 1)
  }
  @inlinable
  static func __payload_buffer(_ p: _NodeRef) -> _PayloadBuffer {
    .init(start: __payload_ptr(p), count: 1)
  }
}
#endif
