import XCTest

#if DEBUG
@testable import RedBlackTreeModule
#else
import RedBlackTreeModule
#endif

fileprivate extension Optional where Wrapped == Int {
  mutating func hoge() {
    self = .some(1515)
  }
}

final class MultiMapRemoveTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testRemoveKey_() throws {
    var dict = [1:1,2:2,3:3]
    XCTAssertEqual(dict.removeValue(forKey: 0), nil)
    XCTAssertEqual(dict.removeValue(forKey: 1), 1)
    XCTAssertEqual(dict, [2:2,3:3])
  }

  func testRemoveKey() throws {
    var dict = [1:1,2:2,3:3] as RedBlackTreeMultiMap<Int,Int>
    XCTAssertEqual(dict.removeAll(forKey: 0), 0)
    XCTAssertEqual(dict.removeAll(forKey: 1), 1)
    XCTAssertEqual(dict, [2:2,3:3])
    XCTAssertEqual(dict.first?.key, 2)
    XCTAssertEqual(dict.last?.key, 3)
  }

  func testRemove_() throws {
    var dict = [1:1,2:2,3:3]
    let i = dict.firstIndex { (k,v) in k == 1 }!
    XCTAssertEqual(dict.remove(at: i).value, 1)
  }

  func testRemove() throws {
    var dict = [1:1,2:2,3:3] as RedBlackTreeMultiMap<Int,Int>
    let i = dict.firstIndex { (k,v) in k == 1 }!
    XCTAssertEqual(dict.remove(at: i).value, 1)
  }
  
#if DEBUG
  func testRemoveAt() throws {
    var s = [1:1,2:2,3:3,4:4] as RedBlackTreeMultiMap<Int,Int>
    let i = s.firstIndex(of: 2)!
    s.remove(at: RawIndex(i.rawValue))
    XCTAssertEqual(s.map { $0.key }, [1, 3, 4])
  }
#endif

  func testRemoveFirst() throws {
    var members: RedBlackTreeMultiMap<Int,Int> = [1:2, 3:4, 5:6, 7:8, 9:10]
    XCTAssertEqual(members.removeFirst().key, 1)
    XCTAssertEqual(members.removeFirst().key, 3)
    XCTAssertEqual(members.removeFirst().key, 5)
    XCTAssertEqual(members.removeFirst().key, 7)
    XCTAssertEqual(members.removeFirst().key, 9)
  }

  func testRemoveLast() throws {
    var members: RedBlackTreeMultiMap<Int,Int> = [1:2, 3:4, 5:6, 7:8, 9:10]
    XCTAssertEqual(members.removeLast().key, 9)
    XCTAssertEqual(members.removeLast().key, 7)
    XCTAssertEqual(members.removeLast().key, 5)
    XCTAssertEqual(members.removeLast().key, 3)
    XCTAssertEqual(members.removeLast().key, 1)
  }

  func testRemoveAll_() throws {
    var dict = [1:1,2:2,3:3]
    dict.removeAll(keepingCapacity: true)
    XCTAssertTrue(dict.map { $0 }.isEmpty)
    XCTAssertGreaterThanOrEqual(dict.capacity, 3)
    dict.removeAll(keepingCapacity: false)
    XCTAssertTrue(dict.map { $0 }.isEmpty)
    XCTAssertGreaterThanOrEqual(dict.capacity, 0)
    XCTAssertNil(dict.first)
  }

  func testRemoveAll() throws {
    var dict = [1:1,2:2,3:3] as RedBlackTreeMultiMap<Int,Int>
    dict.removeAll(keepingCapacity: true)
    XCTAssertTrue(dict.map { $0 }.isEmpty)
    XCTAssertGreaterThanOrEqual(dict.capacity, 3)
    dict.removeAll(keepingCapacity: false)
    XCTAssertTrue(dict.map { $0 }.isEmpty)
    XCTAssertGreaterThanOrEqual(dict.capacity, 0)
    XCTAssertNil(dict.first)
    XCTAssertNil(dict.last)
  }
  
  func testRemoveWithIndices() throws {
    var members = RedBlackTreeMultiMap(keysWithValues: (0 ..< 10).map { ($0, $0 * 10) })
    for i in members.indices {
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0.key }, [])
  }
  
  func testRemoveWithIndices2() throws {
    var members = RedBlackTreeMultiMap(keysWithValues: (0 ..< 10).map { ($0, $0 * 10) })
    members.indices.forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0.key }, [])
  }
  
  func testRemoveWithIndices3() throws {
    var members = RedBlackTreeMultiMap(keysWithValues: (0 ..< 10).map { ($0, $0 * 10) })
    members.indices.reversed().forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0.key }, [])
  }
  
  func testRemoveWith___Indices() throws {
    var members = RedBlackTreeMultiMap(keysWithValues: (0 ..< 10).map { ($0, $0 * 10) })
    for i in members.rawIndices {
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0.key }, [])
  }
  
  func testRemoveWith___Indices2() throws {
    var members = RedBlackTreeMultiMap(keysWithValues: (0 ..< 10).map { ($0, $0 * 10) })
    members.rawIndices.forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0.key }, [])
  }
  
  func testRemoveWith___Indices3() throws {
    var members = RedBlackTreeMultiMap(keysWithValues: (0 ..< 10).map { ($0, $0 * 10) })
    members.rawIndices.reversed().forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0.key }, [])
  }

#if false
  func testRemoveWithSubIndices() throws {
      var members = RedBlackTreeMultiMap(keysWithValues: (0 ..< 10).map { ($0, $0 * 10) })
    for i in members[2 ..< 8].indices {
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0.key }, [0,1,8,9])
  }

  func testRemoveWithSubIndices2() throws {
    var members = RedBlackTreeMultiMap(keysWithValues: (0 ..< 10).map { ($0, $0 * 10) })
    members[2 ..< 8].indices.forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0.key }, [0,1,8,9])
  }
  
  func testRemoveWithSubIndices4() throws {
    var members = RedBlackTreeMultiMap(keysWithValues: (0 ..< 10).map { ($0, $0 * 10) })
    members[2 ..< 8].indices.reversed().forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0.key }, [0,1,8,9])
  }
#endif

  func testRemoveWithSub___Indices() throws {
      var members = RedBlackTreeMultiMap(keysWithValues: (0 ..< 10).map { ($0, $0 * 10) })
    for i in members[2 ..< 8].rawIndices {
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0.key }, [0,1,8,9])
  }

  func testRemoveWithSub___Indices2() throws {
    var members = RedBlackTreeMultiMap(keysWithValues: (0 ..< 10).map { ($0, $0 * 10) })
    members[2 ..< 8].rawIndices.forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0.key }, [0,1,8,9])
  }
  
  func testRemoveWithSub___Indices4() throws {
    var members = RedBlackTreeMultiMap(keysWithValues: (0 ..< 10).map { ($0, $0 * 10) })
    members[2 ..< 8].rawIndices.reversed().forEach { i in
      members.remove(at: i)
    }
    XCTAssertEqual(members.map { $0.key }, [0,1,8,9])
  }
}

