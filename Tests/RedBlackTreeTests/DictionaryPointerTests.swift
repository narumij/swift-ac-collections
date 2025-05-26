import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class DictionaryPointerTests: XCTestCase {

  var members: RedBlackTreeDictionary<Int, String> = [:]

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    members = [0: "0", 1: "1", 2: "2", 3: "3", 4: "4"]
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testPointer2() throws {
    if let it = members.startIndex.next {
      XCTAssertTrue(it.isValid)
      XCTAssertEqual(it.pointee?.key, 1)
      XCTAssertNotNil(it.previous)
      XCTAssertNotNil(it.next)
      members.remove(at: it)
      XCTAssertFalse(it.isValid)
      XCTAssertTrue(it.isPhantom)
      XCTAssertNil(it.pointee)
      XCTAssertEqual(it.previous?.pointee?.key, 0)
      XCTAssertEqual(it.next?.pointee?.key, 2)
    }
  }

  func testPointerNext() throws {
    XCTAssertEqual(members.startIndex.pointee?.key, 0)
    XCTAssertEqual(members.startIndex.next?.pointee?.key, 1)
    XCTAssertEqual(members.startIndex.next?.next?.pointee?.key, 2)
    XCTAssertEqual(members.startIndex.next?.next?.next?.pointee?.key, 3)
    XCTAssertEqual(members.startIndex.next?.next?.next?.next?.pointee?.key, 4)
    XCTAssertNil(members.startIndex.next?.next?.next?.next?.next?.pointee)
    XCTAssertEqual(members.startIndex.next?.next?.next?.next?.next, members.endIndex)
    XCTAssertNil(members.startIndex.next?.next?.next?.next?.next?.next)
    XCTAssertNil(members.endIndex.next)
  }

  func testPointerPrev() throws {
    XCTAssertNil(members.endIndex.pointee)
    XCTAssertEqual(members.endIndex.previous?.pointee?.key, 4)
    XCTAssertEqual(members.endIndex.previous?.previous?.pointee?.key, 3)
    XCTAssertEqual(members.endIndex.previous?.previous?.previous?.pointee?.key, 2)
    XCTAssertEqual(members.endIndex.previous?.previous?.previous?.previous?.pointee?.key, 1)
    XCTAssertEqual(members.endIndex.previous?.previous?.previous?.previous?.previous?.pointee?.key, 0)
    XCTAssertEqual(members.endIndex.previous?.previous?.previous?.previous?.previous, members.startIndex)
    XCTAssertNil(members.endIndex.previous?.previous?.previous?.previous?.previous?.previous)
    XCTAssertNil(members.startIndex.previous)
  }
  
  func testPointerOffset0() throws {
    XCTAssertEqual((members.startIndex).pointee?.key, 0)
    XCTAssertEqual(members.startIndex.advanced(by: 1).pointee?.key, 1)
    XCTAssertEqual(members.startIndex.advanced(by: 2).pointee?.key, 2)
    XCTAssertEqual(members.startIndex.advanced(by: 3).pointee?.key, 3)
    XCTAssertEqual(members.startIndex.advanced(by: 4).pointee?.key, 4)
    XCTAssertNil(members.startIndex.advanced(by: 5).pointee)
    XCTAssertEqual(members.startIndex.advanced(by: 5), members.endIndex)
    XCTAssertTrue(members.startIndex.advanced(by: 6).isOver)
    XCTAssertNil(members.startIndex.advanced(by: 6).pointee)
  }

  func testPointerOffset2() throws {
    XCTAssertNil((members.endIndex).pointee)
    XCTAssertEqual(members.endIndex.advanced(by: -1).pointee?.key, 4)
    XCTAssertEqual(members.endIndex.advanced(by: -2).pointee?.key, 3)
    XCTAssertEqual(members.endIndex.advanced(by: -3).pointee?.key, 2)
    XCTAssertEqual(members.endIndex.advanced(by: -4).pointee?.key, 1)
    XCTAssertEqual(members.endIndex.advanced(by: -5).pointee?.key, 0)
    XCTAssertEqual(members.endIndex.advanced(by: -5), members.startIndex)
    XCTAssertTrue(members.startIndex.advanced(by: -6).isUnder)
    XCTAssertNil(members.startIndex.advanced(by: -6).pointee)
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
