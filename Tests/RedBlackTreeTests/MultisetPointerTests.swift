import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class MultisetPointerTests: XCTestCase {

  var members: RedBlackTreeMultiset<Int> = []

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    members = [0, 0, 1, 2, 2]
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testPointerNext() throws {
    XCTAssertEqual(members.startIndex.pointee, 0)
    XCTAssertEqual(members.startIndex.next?.pointee, 0)
    XCTAssertEqual(members.startIndex.next?.next?.pointee, 1)
    XCTAssertEqual(members.startIndex.next?.next?.next?.pointee, 2)
    XCTAssertEqual(members.startIndex.next?.next?.next?.next?.pointee, 2)
    XCTAssertEqual(members.startIndex.next?.next?.next?.next?.next, members.endIndex)
    XCTAssertNil(members.startIndex.next?.next?.next?.next?.next?.next)
    XCTAssertNil(members.endIndex.next)
  }

  func testPointerPrev() throws {
    XCTAssertNil(members.endIndex.pointee)
    XCTAssertEqual(members.endIndex.prev?.pointee, 2)
    XCTAssertEqual(members.endIndex.prev?.prev?.pointee, 2)
    XCTAssertEqual(members.endIndex.prev?.prev?.prev?.pointee, 1)
    XCTAssertEqual(members.endIndex.prev?.prev?.prev?.prev?.pointee, 0)
    XCTAssertEqual(members.endIndex.prev?.prev?.prev?.prev?.prev?.pointee, 0)
    XCTAssertEqual(members.endIndex.prev?.prev?.prev?.prev?.prev, members.startIndex)
    XCTAssertNil(members.endIndex.prev?.prev?.prev?.prev?.prev?.prev)
    XCTAssertNil(members.startIndex.prev)
  }
  
  func testPointerOffset0() throws {
    XCTAssertEqual((members.startIndex).pointee, 0)
    XCTAssertEqual(members.startIndex.advanced(by: 1)?.pointee, 0)
    XCTAssertEqual(members.startIndex.advanced(by: 2)?.pointee, 1)
    XCTAssertEqual(members.startIndex.advanced(by: 3)?.pointee, 2)
    XCTAssertEqual(members.startIndex.advanced(by: 4)?.pointee, 2)
    XCTAssertNil(members.startIndex.advanced(by: 5)?.pointee)
    XCTAssertEqual(members.startIndex.advanced(by: 5), members.endIndex)
    XCTAssertNil(members.startIndex.advanced(by: 6))
  }

  func testPointerOffset2() throws {
    XCTAssertNil((members.endIndex).pointee)
    XCTAssertEqual(members.endIndex.advanced(by: -1)?.pointee, 2)
    XCTAssertEqual(members.endIndex.advanced(by: -2)?.pointee, 2)
    XCTAssertEqual(members.endIndex.advanced(by: -3)?.pointee, 1)
    XCTAssertEqual(members.endIndex.advanced(by: -4)?.pointee, 0)
    XCTAssertEqual(members.endIndex.advanced(by: -5)?.pointee, 0)
    XCTAssertEqual(members.endIndex.advanced(by: -5), members.startIndex)
    XCTAssertNil(members.startIndex.advanced(by: -6))
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
