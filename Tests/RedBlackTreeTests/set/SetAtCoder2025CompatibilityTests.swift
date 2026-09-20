import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if COMPATIBLE_ATCODER_2025
  final class SetAtCoder2025CompatibilityTests: RedBlackTreeTestCase {
    func testRemoveLast() throws {
      var members: RedBlackTreeSet<Int> = [1, 3, 5, 7, 9]
      XCTAssertEqual(members.removeLast(), 9)
      XCTAssertEqual(members.count, 4)
      XCTAssertEqual(members.removeLast(), 7)
      XCTAssertEqual(members.count, 3)
      XCTAssertEqual(members.removeLast(), 5)
      XCTAssertEqual(members.count, 2)
      XCTAssertEqual(members.removeLast(), 3)
      XCTAssertEqual(members.count, 1)
      XCTAssertEqual(members.removeLast(), 1)
      XCTAssertEqual(members.count, 0)
    }

    func testRemoveWithRange1() throws {
      var members = RedBlackTreeSet(0..<10)
      for i in members.startIndex..<members.endIndex { members.remove(at: i) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithRange2() throws {
      var members = RedBlackTreeSet(0..<10)
      (members.startIndex..<members.endIndex).forEach { members.remove(at: $0) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithRange3() throws {
      var members = RedBlackTreeSet(0..<10)
      for i in (members.startIndex..<members.endIndex).reversed() { members.remove(at: i) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithRange4() throws {
      var members = RedBlackTreeSet(0..<10)
      (members.startIndex..<members.endIndex).reversed().forEach { members.remove(at: $0) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices1() throws {
      var members = RedBlackTreeSet(0..<10)
      for i in members.indices { members.remove(at: i) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices2() throws {
      var members = RedBlackTreeSet(0..<10)
      members.indices.forEach { members.remove(at: $0) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices3() throws {
      var members = RedBlackTreeSet(0..<10)
      for i in members.indices.reversed() { members.remove(at: i) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices4() throws {
      var members = RedBlackTreeSet(0..<10)
      members.indices.reversed().forEach { members.remove(at: $0) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithSubIndices() throws {
      var members = RedBlackTreeSet(0..<10)
      for i in members.elements(in: 2..<8).indices { members.remove(at: i) }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices2() throws {
      var members = RedBlackTreeSet(0..<10)
      members.elements(in: 2..<8).indices.forEach { members.remove(at: $0) }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices3() throws {
      var members = RedBlackTreeSet(0..<10)
      for i in members.elements(in: 2..<8).indices.reversed() { members.remove(at: i) }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices4() throws {
      var members = RedBlackTreeSet(0..<10)
      members.elements(in: 2..<8).indices.reversed().forEach { members.remove(at: $0) }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }
  }
#endif
