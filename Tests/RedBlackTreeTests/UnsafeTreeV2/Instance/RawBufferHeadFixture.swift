//
//  RawBufferHeadFixture.swift
//  swift-ac-collections
//

#if DEBUG
  @testable import RedBlackTreeCollections
  import XCTest

  /// `_BucketAllocator`/`_Bucket`/`_BucketAccessor`を直接操作し、headバケツの
  /// 実際のメモリ配置を測定するFixture。生木(`UnsafeTreeV2`/`RedBlackTreeSet`)を
  /// 経由しない。参照計算側は共有`RedBlackTreeFixture/UnsafeNodeReferenceFixture.swift`を参照。
  struct RawBufferHeadFixture<Payload> {

    let allocator: _BucketAllocator
    let storage: UnsafeMutableRawPointer
    let header: UnsafeMutablePointer<_Bucket>
    let accessor: _BucketAccessor

    init(capacity: Int) {
      precondition(capacity > 0)
      allocator = _BucketAllocator(valueType: Payload.self) { _ in }
      let byteSize = allocator._headAllocationSize(capacity: capacity)
      storage = UnsafeMutableRawPointer.allocate(
        byteCount: byteSize,
        alignment: allocator.pairLayout.alignment)
      header = storage.assumingMemoryBound(to: _Bucket.self)
      let start = header.start(
        storage: header.primaryStorage(),
        payloadOrPairAlignment: MemoryLayout<Payload>.alignment)
      accessor = _BucketAccessor(
        header: header, startNode: start, pairStride: allocator.pairLayout.stride)
    }

    func node(at index: Int) -> UnsafeMutablePointer<UnsafeNode> {
      accessor[index]
    }

    func payload(at index: Int) -> UnsafeMutablePointer<Payload> {
      accessor[index].__value_(as: Payload.self)
    }

    var pairStride: Int {
      allocator.pairLayout.stride
    }

    func deallocate() {
      storage.deallocate()
    }
  }
#endif
