#if DEBUG
@testable import RedBlackTreeModule
#else
import RedBlackTreeModule
#endif
import XCTest

class RedBlackTreeTestCase: XCTestCase {

  override func setUpWithError() throws {}

  override func tearDownWithError() throws {
    XCTAssertEqual(RedBlackTreeSet<Int>().capacity, 0, "\(name)")
    if RedBlackTreeSet<Int>().capacity != 0 {
      fatalError("singleton bufffer broken")
    }
#if DEBUG
    XCTAssertNil(_emptyTreeStorage.header._deallocator)
#endif
  }
}

class PointerRedBlackTreeTestCase: RedBlackTreeTestCase, _UnsafeNodePtrType {}
