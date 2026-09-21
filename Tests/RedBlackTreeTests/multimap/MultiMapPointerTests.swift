import RedBlackTreeCollections
import XCTest

final class MultiMapPointerTests: RedBlackTreeTestCase {

  var members: RedBlackTreeMultiMap<Int, String> = [:]

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
    members = [0: "0", 1: "1", 2: "2", 3: "3", 4: "4"]
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    members = .init()
    try super.tearDownWithError()
  }


  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
