import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if COMPATIBLE_ATCODER_2025
  final class DictionaryAtCoder2025CompatibilityTests: RedBlackTreeTestCase {
    func testRemove() throws {
      var dict = [1: 1, 2: 2, 3: 3] as RedBlackTreeDictionary<Int, Int>
      let i = dict.firstIndex { key, _ in key == 1 }!
      XCTAssertEqual(dict.remove(at: i).value, 1)
    }

    func testRemoveWithIndices() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      for i in members.indices { members.remove(at: i) }
      XCTAssertEqual(members.map { $0.key }, [])
    }

    func testRemoveWithIndices2() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      members.indices.forEach { members.remove(at: $0) }
      XCTAssertEqual(members.map { $0.key }, [])
    }

    func testRemoveWithIndices3() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      for i in members.indices.reversed() { members.remove(at: i) }
      XCTAssertEqual(members.map { $0.key }, [])
    }

    func testRemoveWithIndices4() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      members.indices.reversed().forEach { members.remove(at: $0) }
      XCTAssertEqual(members.map { $0.key }, [])
    }
  }
#endif
