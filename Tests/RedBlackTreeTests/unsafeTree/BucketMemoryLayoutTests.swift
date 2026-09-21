#if DEBUG
@testable import RedBlackTreeCollections
import XCTest

final class BucketMemoryLayoutTests: XCTestCase {

    func testBucketComponentsUsePairStride() {
        typealias Payload = SIMD4<Float>

        let pairLayout = MemoryLayout<Payload>._pairLayout
        let bucket = UnsafeMutablePointer<_Bucket>.allocate(capacity: 1)
        bucket.initialize(to: .init(capacity: 2))
        defer {
            bucket.deinitialize(count: 1)
            bucket.deallocate()
        }

        let queue = bucket._queue(isHead: false, payloadLayout: pairLayout)
        let accessor = bucket._accessor(isHead: false, payload: pairLayout)
        let traverser = bucket._counts(
            storage: bucket.secondaryStorage(),
            payload: pairLayout
        )

        XCTAssertEqual(distance(from: queue[0], to: queue[1]), pairLayout.stride)
        XCTAssertEqual(distance(from: accessor[0], to: accessor[1]), pairLayout.stride)
        XCTAssertEqual(distance(from: traverser[0], to: traverser[1]), pairLayout.stride)
    }

    private func distance(
        from first: UnsafeMutablePointer<UnsafeNode>,
        to second: UnsafeMutablePointer<UnsafeNode>
    ) -> Int {
        UnsafeMutableRawPointer(first).distance(to: UnsafeMutableRawPointer(second))
    }
}
#endif
