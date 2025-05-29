import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

#if true
final class SetPointerTests: XCTestCase {

  var members: RedBlackTreeSet<Int> = []

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    members = [0, 1, 2, 3, 4]
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testPointer() throws {
    XCTAssertTrue(members.startIndex.isStart)
    XCTAssertFalse(members.endIndex.isStart)
    XCTAssertFalse(members.startIndex.isEnd)
    XCTAssertTrue(members.endIndex.isEnd)
  }

  func testPointer2() throws {
    if let it = members.startIndex.next {
      XCTAssertTrue(it.___isValid)
      XCTAssertEqual(it.pointee, 1)
      XCTAssertNotNil(it.previous)
      XCTAssertNotNil(it.next)
      members.remove(at: it)
      XCTAssertFalse(it.___isValid)
      XCTAssertTrue(it.isPhantom)
      XCTAssertNil(it.pointee)
      XCTAssertNil(it.previous)
      XCTAssertNil(it.next)
    }
  }

  func testPointerNext() throws {
    XCTAssertEqual(members.startIndex.pointee, 0)
    XCTAssertEqual(members.startIndex.next?.pointee, 1)
    XCTAssertEqual(members.startIndex.next?.next?.pointee, 2)
    XCTAssertEqual(members.startIndex.next?.next?.next?.pointee, 3)
    XCTAssertEqual(members.startIndex.next?.next?.next?.next?.pointee, 4)
    XCTAssertNil(members.startIndex.next?.next?.next?.next?.next?.pointee)
    XCTAssertEqual(members.startIndex.next?.next?.next?.next?.next, members.endIndex)
    XCTAssertNil(members.startIndex.next?.next?.next?.next?.next?.next)
    XCTAssertNil(members.endIndex.next)
  }

  func testPointerPrev() throws {
    XCTAssertNil(members.endIndex.pointee)
    XCTAssertEqual(members.endIndex.previous?.pointee, 4)
    XCTAssertEqual(members.endIndex.previous?.previous?.pointee, 3)
    XCTAssertEqual(members.endIndex.previous?.previous?.previous?.pointee, 2)
    XCTAssertEqual(members.endIndex.previous?.previous?.previous?.previous?.pointee, 1)
    XCTAssertEqual(members.endIndex.previous?.previous?.previous?.previous?.previous?.pointee, 0)
    XCTAssertEqual(
      members.endIndex.previous?.previous?.previous?.previous?.previous, members.startIndex)
    XCTAssertNil(members.endIndex.previous?.previous?.previous?.previous?.previous?.previous)
    XCTAssertNil(members.startIndex.previous)
  }

  func testPointerOffset0() throws {
    XCTAssertEqual((members.startIndex).pointee, 0)
    XCTAssertEqual(members.startIndex.advanced(by: 1).pointee, 1)
    XCTAssertEqual(members.startIndex.advanced(by: 2).pointee, 2)
    XCTAssertEqual(members.startIndex.advanced(by: 3).pointee, 3)
    XCTAssertEqual(members.startIndex.advanced(by: 4).pointee, 4)
    XCTAssertNil(members.startIndex.advanced(by: 5).pointee)
    XCTAssertEqual(members.startIndex.advanced(by: 5), members.endIndex)
    XCTAssertTrue(members.startIndex.advanced(by: 6).isOver)
    XCTAssertNil(members.startIndex.advanced(by: 6).pointee)
  }

  func testPointerOffset2() throws {
    XCTAssertNil((members.endIndex).pointee)
    XCTAssertEqual(members.endIndex.advanced(by: -1).pointee, 4)
    XCTAssertEqual(members.endIndex.advanced(by: -2).pointee, 3)
    XCTAssertEqual(members.endIndex.advanced(by: -3).pointee, 2)
    XCTAssertEqual(members.endIndex.advanced(by: -4).pointee, 1)
    XCTAssertEqual(members.endIndex.advanced(by: -5).pointee, 0)
    XCTAssertEqual(members.endIndex.advanced(by: -5), members.startIndex)
    XCTAssertTrue(members.startIndex.advanced(by: -6).isUnder)
    XCTAssertNil(members.startIndex.advanced(by: -6).pointee)
  }

  func testGhostBehavior1() throws {
    let indices = members.indices.map { $0 }
    members.remove(at: indices[2])
    XCTAssertFalse(indices[2].___isValid)
    XCTAssertLessThan(indices[0].advanced(by: -2), indices[2])
    XCTAssertLessThan(indices[0].advanced(by: -1), indices[2])
    XCTAssertTrue(indices[0] < indices[2])
    XCTAssertLessThan(indices[1], indices[2])
    XCTAssertEqual(indices[2], indices[2])
    XCTAssertGreaterThan(indices[3], indices[2])
    XCTAssertGreaterThan(indices[4], indices[2])
    XCTAssertGreaterThan(indices[4].advanced(by: 1), indices[2])
    XCTAssertGreaterThan(indices[4].advanced(by: 2), indices[2])
  }

  func testGhostBehavior2() throws {
    let indices = members.indices.map { $0 }
    members.remove(at: indices[0])
    XCTAssertFalse(indices[0].___isValid)
    XCTAssertLessThan(indices[0].advanced(by: -2), indices[0])
    XCTAssertLessThan(indices[0].advanced(by: -1), indices[0])
    XCTAssertEqual(indices[0], indices[0])
    XCTAssertGreaterThan(indices[1], indices[0])
    XCTAssertGreaterThan(indices[2], indices[0])
    XCTAssertGreaterThan(indices[3], indices[0])
    XCTAssertGreaterThan(indices[4], indices[0])
    XCTAssertGreaterThan(indices[4].advanced(by: 1), indices[0])
    XCTAssertGreaterThan(indices[4].advanced(by: 2), indices[0])
  }

  func testGhostBehavior3() throws {
    let indices = members.indices.map { $0 }
    members.remove(at: indices[4])
    XCTAssertFalse(indices[4].___isValid)
    XCTAssertLessThan(indices[0].advanced(by: -2), indices[4])
    XCTAssertLessThan(indices[0].advanced(by: -1), indices[4])
    XCTAssertLessThan(indices[0], indices[4])
    XCTAssertLessThan(indices[1], indices[4])
    XCTAssertLessThan(indices[2], indices[4])
    XCTAssertLessThan(indices[3], indices[4])
    XCTAssertEqual(indices[4], indices[4])
    XCTAssertGreaterThan(indices[4].advanced(by: 1), indices[4])
    XCTAssertEqual(indices[4].advanced(by: 1), members.endIndex)
    XCTAssertGreaterThan(indices[4].advanced(by: 2), indices[4])
  }

  func testGhostBehavior4() throws {
    let indices = members.indices.map { $0 }
    XCTAssertLessThanOrEqual(indices[0], members.endIndex)
    XCTAssertGreaterThanOrEqual(members.endIndex, indices[0])
    members.remove(at: indices[0])
    XCTAssertLessThanOrEqual(indices[0], members.endIndex)
    XCTAssertLessThanOrEqual(indices[0], indices[1])
    XCTAssertLessThanOrEqual(indices[1], members.endIndex)
    XCTAssertGreaterThanOrEqual(members.endIndex, indices[0])
    XCTAssertGreaterThanOrEqual(indices[1], indices[0])
    XCTAssertGreaterThanOrEqual(members.endIndex, indices[1])
    members.remove(at: indices[1])
    XCTAssertLessThanOrEqual(indices[0], members.endIndex)
    XCTAssertLessThanOrEqual(indices[0], indices[2])
    XCTAssertLessThanOrEqual(indices[2], members.endIndex)
    XCTAssertGreaterThanOrEqual(members.endIndex, indices[0])
    XCTAssertGreaterThanOrEqual(indices[2], indices[0])
    XCTAssertGreaterThanOrEqual(members.endIndex, indices[2])
    members.remove(at: indices[2])
    XCTAssertLessThanOrEqual(indices[0], members.endIndex)
    XCTAssertLessThanOrEqual(indices[0], indices[3])
    XCTAssertLessThanOrEqual(indices[3], members.endIndex)
    XCTAssertGreaterThanOrEqual(members.endIndex, indices[0])
    XCTAssertGreaterThanOrEqual(indices[3], indices[0])
    XCTAssertGreaterThanOrEqual(members.endIndex, indices[3])
    members.remove(at: indices[3])
    XCTAssertLessThanOrEqual(indices[0], members.endIndex)
    XCTAssertLessThanOrEqual(indices[0], indices[4])
    XCTAssertLessThanOrEqual(indices[4], members.endIndex)
    XCTAssertGreaterThanOrEqual(members.endIndex, indices[0])
    XCTAssertGreaterThanOrEqual(indices[4], indices[0])
    XCTAssertGreaterThanOrEqual(members.endIndex, indices[4])
    members.remove(at: indices[4])
  }

  #if DEBUG
    func testGhostBehavior5() throws {
      let indices = members.indices.map { $0 }
      let end = members.endIndex
      end.phantomMark()
      XCTAssertTrue(indices[0] < end)
      XCTAssertFalse(end < indices[0])
    }
  #endif

  func testGhostBehavior6_0() throws {
    let indices = members.indices.map { $0 }
    let index0 = indices[0]
    members.remove(at: indices[0])
    members.remove(at: indices[1])
    XCTAssertTrue(index0 < indices[2])
    XCTAssertFalse(indices[2] < index0)
    XCTAssertTrue(index0 < indices[3])
    XCTAssertFalse(indices[3] < index0)
    XCTAssertTrue(index0 < indices[4])
    XCTAssertFalse(indices[4] < index0)
    XCTAssertFalse(members.endIndex < index0)
    XCTAssertTrue(index0 < members.endIndex)
  }

  func testGhostBehavior6_1() throws {
    let indices = members.indices.map { $0 }
    let index1 = indices[1]
    members.remove(at: indices[1])
    members.remove(at: indices[2])
    XCTAssertFalse(index1 < indices[0])
    XCTAssertTrue(indices[0] < index1)
    XCTAssertTrue(index1 < indices[3])
    XCTAssertFalse(indices[3] < index1)
    XCTAssertTrue(index1 < indices[4])
    XCTAssertFalse(indices[4] < index1)
    XCTAssertFalse(members.endIndex < index1)
    XCTAssertTrue(index1 < members.endIndex)
  }

  func testGhostBehavior6_3() throws {
    let indices = members.indices.map { $0 }
    let index3 = indices[3]
    members.remove(at: indices[3])
    members.remove(at: indices[2])
    XCTAssertTrue(indices[0] < index3)
    XCTAssertFalse(index3 < indices[0])
    XCTAssertTrue(indices[1] < index3)
    XCTAssertFalse(index3 < indices[1])
    XCTAssertFalse(indices[4] < index3)
    XCTAssertTrue(index3 < indices[4])
    XCTAssertFalse(members.endIndex < index3)
    XCTAssertTrue(index3 < members.endIndex)
  }

  #if DEBUG
    func testGhostBehavior8() throws {
      let indices = members.indices.map { $0 }
      let under = indices[0].advanced(by: -1)
      under.phantomMark()
      members.remove(at: indices[0])
      members.remove(at: indices[1])
      XCTAssertLessThan(under, indices[2])
      XCTAssertFalse(indices[2] < under)
    }

    func testGhostBehavior9() throws {
      let indices = members.indices.map { $0 }
      let end = members.endIndex
      end.phantomMark()
      members.remove(at: indices[4])
      XCTAssertLessThan(indices[0], end)
      XCTAssertFalse(end < indices[0])
    }

    func testGhostBehavior10() throws {
      let indices = members.indices.map { $0 }
      let over = members.endIndex.advanced(by: -1)
      over.phantomMark()
      members.remove(at: indices[4])
      XCTAssertLessThan(indices[0], over)
      XCTAssertFalse(over < indices[0])
    }
  #endif

  func testValidBehavior1() throws {
    let indices = members.indices.map { $0 }
    for i in indices.indices {
      members.remove(at: indices[i])
      for j in indices.startIndex..<i {
        XCTAssertFalse(indices[j].___isValid)
      }
      for j in i.advanced(by: 1)..<indices.endIndex {
        XCTAssertTrue(indices[j].___isValid)
      }
    }
  }

  func testValidBehavior2() throws {
    let indices = members.indices.map { $0 }
    for i in indices.indices.reversed() {
      members.remove(at: indices[i])
      for j in indices.startIndex..<i {
        XCTAssertTrue(indices[j].___isValid)
      }
      for j in i.advanced(by: 1)..<indices.endIndex {
        XCTAssertFalse(indices[j].___isValid)
      }
    }
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
#endif
