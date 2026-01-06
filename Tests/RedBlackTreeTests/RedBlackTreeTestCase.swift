import XCTest
#if DEBUG
@testable import RedBlackTreeModule
#else
import RedBlackTreeModule
#endif

class RedBlackTreeTestCase: XCTestCase {

  override func setUpWithError() throws {
    RedBlackTreeModule.tearDown(treeBuffer: _emptyTreeStorage)
  }
  
  override func tearDownWithError() throws {
#if DEBUG
    // TODO: シングルトン破壊の原因を潰すこと
    // assert(_emptyTreeStorage.header.freshPoolCapacity == 0)
#endif
    RedBlackTreeModule.tearDown(treeBuffer: _emptyTreeStorage)
  }
}
