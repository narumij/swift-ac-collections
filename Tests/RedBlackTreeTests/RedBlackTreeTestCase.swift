import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

class RedBlackTreeTestCase: XCTestCase {

  override func setUpWithError() throws {
    #if DEBUG
      // DONE: 以下のアサートが止まるケースがあることについて、理由を調査すること
      // 直前にこのクラスを継承してないテストが走り、事後処理がないためだった。
      // assert(deallocatedCount == 0) // アサート(a)
      XCTAssertEqual(deallocatedCount, 0)
      // シングルトンはテストケース期間に開放されず、数があわなくなるので、その調整
      let dummy = RedBlackTreeSet<Int>()
      allocatedCount = 0
      // アサート(a)時はdeallocatedCount = 0をコメントアウト
      deallocatedCount = 0
    #endif
  }

  override func tearDownWithError() throws {
    XCTAssertEqual(RedBlackTreeSet<Int>().capacity, 0, "\(name)")
    if RedBlackTreeSet<Int>().capacity != 0 {
      fatalError("singleton bufffer broken")
    }
    #if DEBUG
      XCTAssertNil(_emptyTreeStorage.header._tied)
      XCTAssertEqual(_emptyTreeStorage.header.freshPoolActualCapacity, 0)
      XCTAssertEqual(_emptyTreeStorage.header.freshPoolActualCount, 0)

      XCTAssertEqual(allocatedCount, deallocatedCount)
      // これで止まるケースは、スコープ外での初期化の影響のケースがあった
       assert(allocatedCount == deallocatedCount)
      allocatedCount = 0
      deallocatedCount = 0
    #endif
  }
}

class PointerRedBlackTreeTestCase: RedBlackTreeTestCase, _UnsafeNodePtrType {}
