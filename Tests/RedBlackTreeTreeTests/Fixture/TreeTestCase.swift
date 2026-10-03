import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

/// 原木テスト専用のXCTest基底クラス。
///
/// `RedBlackTreeTests`ターゲットの`RedBlackTreeTestCase`から、原木が必要とする
/// allocation・lifetime・singleton nodeの検査だけを独立させている。専用ターゲットが
/// 公開4型向けのテスト支援コードへ依存しないよう、意図的に小さく重複させている。
class TreeTestCase: XCTestCase {

  override func setUpWithError() throws {
    #if DEBUG
      // SKIP_DEBUG_LIFETIME_BALANCE_CHECKS(テスト専用trait)は釣り合い検査だけを省略する。
      // counterのresetと構造検査は常に行う。
      #if !SKIP_DEBUG_LIFETIME_BALANCE_CHECKS && !SKIP_DEBUG_LIFETIME_SETUP_CHECKS
        XCTAssertEqual(deallocatedCount, 0)
        XCTAssertEqual(nodeDeinitializedCount, 0)
        XCTAssertEqual(payloadDeinitializedCount, 0)
      #endif

      // Singleton storageの初期化による計数を、各テストの観測対象から除外する。
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
    XCTAssertEqual(RedBlackTreeSet<Int>().capacity, 0, name)
    if RedBlackTreeSet<Int>().capacity != 0 {
      fatalError("singleton buffer broken")
    }

    #if DEBUG
      XCTAssertNotNil(_emptyTreeStorage.header._tied)
      XCTAssertEqual(_emptyTreeStorage.header.freshPoolActualCapacity, 0)
      XCTAssertEqual(_emptyTreeStorage.header.freshPoolActualCount, 0)

      #if !SKIP_DEBUG_LIFETIME_BALANCE_CHECKS
        XCTAssertEqual(allocatedCount, deallocatedCount, "このチェックに通過しない場合、メモリリークの可能性がある")
        assert(allocatedCount == deallocatedCount)
        XCTAssertEqual(nodeInitializedCount, nodeDeinitializedCount, "このチェックに通過しない場合、メモリリークの可能性がある")
        assert(nodeInitializedCount == nodeDeinitializedCount)
        XCTAssertEqual(
          payloadInitializedCount,
          payloadDeinitializedCount,
          "このチェックに通過しない場合、メモリリークの可能性がある (\(nodeInitializedCount))")
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
