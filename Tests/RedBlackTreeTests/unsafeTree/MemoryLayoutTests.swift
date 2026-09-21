#if DEBUG
@testable import RedBlackTreeCollections
import XCTest

final class MemoryLayoutTests: XCTestCase {

    func testNodeAndPayloadMemoryLayout() {
        checkMemoryLayout(Int8.self)
        checkMemoryLayout(Int16.self)
        checkMemoryLayout(Int32.self)
        checkMemoryLayout(Int64.self)
        checkMemoryLayout(SIMD4<Float>.self)
        checkMemoryLayout(SIMD4<Int>.self)
    }

    func testBucketComponentsUsePairStride() {
        typealias Payload = SIMD4<Float>

        let payloadLayout = MemoryLayout<Payload>._memoryLayout
        let pairLayout = _MemoryLayout(UnsafeNode.self, Payload.self)
        let bucket = UnsafeMutablePointer<_Bucket>.allocate(capacity: 1)
        bucket.initialize(to: .init(capacity: 2))
        defer {
            bucket.deinitialize(count: 1)
            bucket.deallocate()
        }

        let queue = bucket._queue(isHead: false, payloadLayout: payloadLayout)
        let accessor = bucket._accessor(isHead: false, payload: payloadLayout)
        let traverser = bucket._counts(
            storage: bucket.secondaryStorage(),
            payload: payloadLayout
        )

        XCTAssertEqual(distance(from: queue[0], to: queue[1]), pairLayout.stride)
        XCTAssertEqual(distance(from: accessor[0], to: accessor[1]), pairLayout.stride)
        XCTAssertEqual(distance(from: traverser[0], to: traverser[1]), pairLayout.stride)
    }

    private func checkMemoryLayout<Payload>(
        _ payloadType: Payload.Type,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let layout = _MemoryLayout(UnsafeNode.self, Payload.self)
        let nodeStride = MemoryLayout<UnsafeNode>.stride
        let pairSize = nodeStride + MemoryLayout<Payload>.stride

        let storage = UnsafeMutableRawPointer.allocate(
            byteCount: layout.stride * 2 + layout.alignment,
            alignment: layout.alignment
        )
        defer { storage.deallocate() }

        let firstPayload = storage
            .advanced(by: nodeStride)
            .alignedUp(toMultipleOf: MemoryLayout<Payload>.alignment)
        let firstNode = firstPayload
            .advanced(by: -nodeStride)
            .assumingMemoryBound(to: UnsafeNode.self)
        let secondNode = UnsafeMutableRawPointer(firstNode)
            .advanced(by: layout.stride)
            .assumingMemoryBound(to: UnsafeNode.self)

        XCTAssertEqual(
            layout.alignment,
            max(MemoryLayout<UnsafeNode>.alignment, MemoryLayout<Payload>.alignment),
            "\(Payload.self): layout alignment is wrong",
            file: file,
            line: line
        )
        XCTAssertGreaterThanOrEqual(layout.stride, pairSize, file: file, line: line)
        XCTAssertLessThan(
            layout.stride - pairSize,
            layout.alignment,
            "\(Payload.self): layout stride contains excessive padding",
            file: file,
            line: line
        )
        XCTAssertEqual(
            layout.stride % layout.alignment,
            0,
            "\(Payload.self): layout stride is not aligned",
            file: file,
            line: line
        )
        XCTAssertEqual(
            Int(bitPattern: secondNode) % MemoryLayout<UnsafeNode>.alignment,
            0,
            "\(Payload.self): second node is not aligned",
            file: file,
            line: line
        )
        XCTAssertEqual(
            Int(bitPattern: secondNode.__value_(as: Payload.self))
                % MemoryLayout<Payload>.alignment,
            0,
            "\(Payload.self): second payload is not aligned",
            file: file,
            line: line
        )
        XCTAssertEqual(
            UnsafeMutableRawPointer(secondNode.__value_(as: Payload.self)),
            UnsafeMutableRawPointer(secondNode).advanced(by: nodeStride),
            "\(Payload.self): payload offset is wrong",
            file: file,
            line: line
        )
    }

    private func distance(
        from first: UnsafeMutablePointer<UnsafeNode>,
        to second: UnsafeMutablePointer<UnsafeNode>
    ) -> Int {
        UnsafeMutableRawPointer(first).distance(to: UnsafeMutableRawPointer(second))
    }
}
#endif
