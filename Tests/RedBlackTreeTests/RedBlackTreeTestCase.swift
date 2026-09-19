import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

class RedBlackTreeTestCase: XCTestCase {

  override func setUpWithError() throws {
    #if DEBUG
      // DONE: 以下のアサートが止まるケースがあることについて、理由を調査すること
      // 直前にこのクラスを継承してないテストが走り、事後処理がないためだった。
      // assert(deallocatedCount == 0) // アサート(a)
      // assert(payloadDeinitializedCount == 0)
      XCTAssertEqual(deallocatedCount, 0)
      XCTAssertEqual(nodeDeinitializedCount, 0)
      XCTAssertEqual(payloadDeinitializedCount, 0)
      // シングルトンはテストケース期間に開放されず、数があわなくなるので、その調整
      _ = RedBlackTreeSet<Int>()
      allocatedCount = 0
      // アサート(a)時はdeallocatedCount = 0をコメントアウト
      deallocatedCount = 0
      //      XCTAssertEqual(nodeInitializedCount, 0)
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
      // XCTAssertNil(_emptyTreeStorage.header._tied)
      // ホットパス改善のため最初から結束バンド済みにした
      XCTAssertNotNil(_emptyTreeStorage.header._tied)
      XCTAssertEqual(_emptyTreeStorage.header.freshPoolActualCapacity, 0)
      XCTAssertEqual(_emptyTreeStorage.header.freshPoolActualCount, 0)

      XCTAssertEqual(allocatedCount, deallocatedCount, "このチェックに通過しない場合、メモリリークの可能性がある")
      // これで止まるケースは、スコープ外での初期化の影響のケースがあった
      assert(allocatedCount == deallocatedCount)
      XCTAssertEqual(nodeInitializedCount, nodeDeinitializedCount, "このチェックに通過しない場合、メモリリークの可能性がある")
      assert(nodeInitializedCount == nodeDeinitializedCount)
      XCTAssertEqual(
        payloadInitializedCount, payloadDeinitializedCount, "このチェックに通過しない場合、メモリリークの可能性がある (\(nodeInitializedCount))")
//    assert(payloadInitializedCount == payloadDeinitializedCount)
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

class PointerRedBlackTreeTestCase: RedBlackTreeTestCase, _UnsafeNodePtrType {}
