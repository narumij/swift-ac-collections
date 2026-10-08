import XCTest

#if DEBUG
    @testable import RedBlackTreeCollections
#else
    import RedBlackTreeCollections
#endif

/// Target-local copy of the Debug lifetime-counter discipline in `RedBlackTreeTestCase`.
///
/// The allocation/node/payload counters are process-global, and XCTest targets can run
/// in the same process, so every case resets them before running and asserts balance
/// and resets them again afterwards. The test-support class is intentionally not shared
/// across targets.
class CppBehaviorReferenceTestCase: XCTestCase {

    override func setUpWithError() throws {
        #if DEBUG
            // The test-only SKIP_DEBUG_LIFETIME_BALANCE_CHECKS trait skips only the
            // balance assertions; counter resets and structural checks always run.
            #if !SKIP_DEBUG_LIFETIME_BALANCE_CHECKS && !SKIP_DEBUG_LIFETIME_SETUP_CHECKS
                XCTAssertEqual(deallocatedCount, 0)
                XCTAssertEqual(nodeDeinitializedCount, 0)
                XCTAssertEqual(payloadDeinitializedCount, 0)
            #endif
            // The empty-tree singleton is never released during a case; initialize it
            // before resetting so it does not unbalance the counters.
            _ = RedBlackTreeSet<Int>()
            allocatedCount = 0
            deallocatedCount = 0
            nodeInitializedCount = 0
            nodeDeinitializedCount = 0
            payloadInitializedCount = 0
            payloadDeinitializedCount = 0
        #endif
    }

    override func tearDownWithError() throws {
        XCTAssertEqual(RedBlackTreeSet<Int>().capacity, 0, "\(name)")
        if RedBlackTreeSet<Int>().capacity != 0 {
            fatalError("singleton bufffer broken")
        }
        #if DEBUG
            XCTAssertNotNil(_emptyTreeStorage.header._tied)
            XCTAssertEqual(_emptyTreeStorage.header.freshPoolActualCapacity, 0)
            XCTAssertEqual(_emptyTreeStorage.header.freshPoolActualCount, 0)

            #if !SKIP_DEBUG_LIFETIME_BALANCE_CHECKS
                XCTAssertEqual(allocatedCount, deallocatedCount, "possible memory leak")
                assert(allocatedCount == deallocatedCount)
                XCTAssertEqual(nodeInitializedCount, nodeDeinitializedCount, "possible memory leak")
                assert(nodeInitializedCount == nodeDeinitializedCount)
                XCTAssertEqual(
                    payloadInitializedCount, payloadDeinitializedCount,
                    "possible memory leak (\(nodeInitializedCount))")
                assert(payloadInitializedCount == payloadDeinitializedCount)
            #endif
            allocatedCount = 0
            deallocatedCount = 0
            nodeInitializedCount = 0
            nodeDeinitializedCount = 0
            payloadInitializedCount = 0
            payloadDeinitializedCount = 0

            assert(UnsafeNode.nullptr.pointee.__left_ == .nullptr)
            assert(UnsafeNode.nullptr.pointee.__right_ == .nullptr)
            assert(UnsafeNode.nullptr.pointee.__parent_ == .nullptr)
            assert(UnsafeNode.nullptr.pointee.__is_black_ == false)
            assert(UnsafeNode.nullptr.pointee.___has_payload_content == false)
            assert(UnsafeNode.nullptr.pointee.___recycle_count == 0)
            assert(UnsafeNode.nullptr.pointee.___tracking_tag == .nullptr)
        #endif
    }
}
