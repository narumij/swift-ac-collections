import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class SetPointerTests: XCTestCase {

  var members: RedBlackTreeSet<Int> = []

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    members = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testPointerNext() throws {
    XCTAssertEqual(members.startIndex._pointee, 0)
    XCTAssertEqual(members.startIndex._next()?._pointee, 1)
    XCTAssertEqual(members.startIndex._next()?._next()?._pointee, 2)
    XCTAssertEqual(members.startIndex._next()?._next()?._next()?._pointee, 3)
    XCTAssertEqual(members.startIndex._next()?._next()?._next()?._next()?._pointee, 4)
    XCTAssertNil(members.startIndex._next()?._next()?._next()?._next()?._next()?._pointee)
    XCTAssertEqual(members.startIndex._next()?._next()?._next()?._next()?._next(), members.endIndex)
    XCTAssertNil(members.startIndex._next()?._next()?._next()?._next()?._next()?._next())
    XCTAssertNil(members.endIndex._next())
  }

  func testPointerPrev() throws {
    XCTAssertNil(members.endIndex._pointee)
    XCTAssertEqual(members.endIndex._prev()?._pointee, 4)
    XCTAssertEqual(members.endIndex._prev()?._prev()?._pointee, 3)
    XCTAssertEqual(members.endIndex._prev()?._prev()?._prev()?._pointee, 2)
    XCTAssertEqual(members.endIndex._prev()?._prev()?._prev()?._prev()?._pointee, 1)
    XCTAssertEqual(members.endIndex._prev()?._prev()?._prev()?._prev()?._prev()?._pointee, 0)
    XCTAssertEqual(members.endIndex._prev()?._prev()?._prev()?._prev()?._prev(), members.startIndex)
    XCTAssertNil(members.endIndex._prev()?._prev()?._prev()?._prev()?._prev()?._prev())
    XCTAssertNil(members.startIndex._prev())
  }
  
  func testPointerOffset0() throws {
    XCTAssertEqual((members.startIndex)._pointee, 0)
    XCTAssertEqual(members.startIndex._offset(by: 1)?._pointee, 1)
    XCTAssertEqual(members.startIndex._offset(by: 2)?._pointee, 2)
    XCTAssertEqual(members.startIndex._offset(by: 3)?._pointee, 3)
    XCTAssertEqual(members.startIndex._offset(by: 4)?._pointee, 4)
    XCTAssertNil(members.startIndex._offset(by: 5)?._pointee)
    XCTAssertEqual(members.startIndex._offset(by: 5), members.endIndex)
    XCTAssertNil(members.startIndex._offset(by: 6))
  }

  func testPointerOffset2() throws {
    XCTAssertNil((members.endIndex)._pointee)
    XCTAssertEqual(members.endIndex._offset(by: -1)?._pointee, 4)
    XCTAssertEqual(members.endIndex._offset(by: -2)?._pointee, 3)
    XCTAssertEqual(members.endIndex._offset(by: -3)?._pointee, 2)
    XCTAssertEqual(members.endIndex._offset(by: -4)?._pointee, 1)
    XCTAssertEqual(members.endIndex._offset(by: -5)?._pointee, 0)
    XCTAssertEqual(members.endIndex._offset(by: -5), members.startIndex)
    XCTAssertNil(members.startIndex._offset(by: -6))
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
