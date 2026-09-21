#if DEBUG
@testable import RedBlackTreeCollections
import XCTest

final class MemoryLayoutConsumerTests: XCTestCase {

    func testMemoryLayoutConsumersUsePairStride() {
        checkMemoryLayoutConsumers(Int8.self)
        checkMemoryLayoutConsumers(Int16.self)
        checkMemoryLayoutConsumers(Int32.self)
        checkMemoryLayoutConsumers(Int64.self)
        checkMemoryLayoutConsumers(SIMD4<Float>.self)
        checkMemoryLayoutConsumers(SIMD4<Int>.self)
    }

    private func checkMemoryLayoutConsumers<Payload>(
        _ payloadType: Payload.Type,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let layout = MemoryLayout<Payload>._memoryLayout
        let allocator = _BucketAllocator(valueType: Payload.self) { _ in }

        let storage = UnsafeMutableRawPointer.allocate(
            byteCount: 1024,
            alignment: layout.alignment
        )
        defer { storage.deallocate() }

        let firstPayload = storage
            .advanced(by: MemoryLayout<UnsafeNode>.stride)
            .alignedUp(toMultipleOf: MemoryLayout<Payload>.alignment)
        let firstNode = firstPayload
            .advanced(by: -MemoryLayout<UnsafeNode>.stride)
            .assumingMemoryBound(to: UnsafeNode.self)
        let secondNode = firstNode._advanced(with: Payload.self, count: 1)
        let expectedStride = UnsafeMutableRawPointer(firstNode).distance(
            to: UnsafeMutableRawPointer(secondNode)
        )

        XCTAssertEqual(
            layout.stride,
            expectedStride,
            "\(Payload.self): type-erased layout stride differs from UnsafeNode",
            file: file,
            line: line
        )
        XCTAssertEqual(
            layout.alignment,
            max(MemoryLayout<UnsafeNode>.alignment, MemoryLayout<Payload>.alignment),
            "\(Payload.self): type-erased layout alignment is wrong",
            file: file,
            line: line
        )
        XCTAssertEqual(allocator.payload.stride, expectedStride, file: file, line: line)
        XCTAssertEqual(allocator._pair.stride, expectedStride, file: file, line: line)

        let bucketStorage = UnsafeMutableRawPointer.allocate(
            byteCount: allocator._allocationSizeNonzero(capacity: 2),
            alignment: layout.alignment
        )
        defer { bucketStorage.deallocate() }

        let bucket = bucketStorage.assumingMemoryBound(to: _Bucket.self)
        bucket.initialize(to: .init(capacity: 2))
        defer { bucket.deinitialize(count: 1) }
        bucket.pointee.count = 2

        let queue = bucket._queue(isHead: false, payloadLayout: layout)
        let accessor = bucket._accessor(isHead: false, payload: layout)
        let traverser = bucket._counts(
            storage: bucket.secondaryStorage(),
            payload: layout
        )

        XCTAssertEqual(queue.stride, expectedStride, file: file, line: line)
        XCTAssertEqual(accessor.stride, expectedStride, file: file, line: line)
        XCTAssertEqual(traverser.stride, expectedStride, file: file, line: line)

        let capacityTraverser = bucket._capacities(
            storage: bucket.secondaryStorage(),
            payload: layout
        )
        XCTAssertEqual(capacityTraverser.stride, expectedStride, file: file, line: line)
    }
}
#endif
