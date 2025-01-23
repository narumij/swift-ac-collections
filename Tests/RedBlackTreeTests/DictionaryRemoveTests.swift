import XCTest

#if DEBUG
@testable import RedBlackTreeModule
#else
import RedBlackTreeModule
#endif

#if true
fileprivate extension Optional where Wrapped == Int {
  mutating func hoge() {
    self = .some(1515)
  }
}

final class DictionaryRemoveTests: XCTestCase {

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
    var dict = [1:1,2:2,3:3] as RedBlackTreeDictionary<Int,Int>
    XCTAssertEqual(dict.removeValue(forKey: 0), nil)
    XCTAssertEqual(dict.removeValue(forKey: 1), 1)
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
    var dict = [1:1,2:2,3:3] as RedBlackTreeDictionary<Int,Int>
    let i = dict.firstIndex { (k,v) in k == 1 }!
    XCTAssertEqual(dict.remove(at: i).value, 1)
  }

  func testRemoveFirst() throws {
    var members: RedBlackTreeDictionary<Int,Int> = [1:2, 3:4, 5:6, 7:8, 9:10]
    XCTAssertEqual(members.removeFirst().key, 1)
    XCTAssertEqual(members.removeFirst().key, 3)
    XCTAssertEqual(members.removeFirst().key, 5)
    XCTAssertEqual(members.removeFirst().key, 7)
    XCTAssertEqual(members.removeFirst().key, 9)
  }

  func testRemoveLast() throws {
    var members: RedBlackTreeDictionary<Int,Int> = [1:2, 3:4, 5:6, 7:8, 9:10]
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
    var dict = [1:1,2:2,3:3] as RedBlackTreeDictionary<Int,Int>
    dict.removeAll(keepingCapacity: true)
    XCTAssertTrue(dict.map { $0 }.isEmpty)
    XCTAssertGreaterThanOrEqual(dict.capacity, 3)
    dict.removeAll(keepingCapacity: false)
    XCTAssertTrue(dict.map { $0 }.isEmpty)
    XCTAssertGreaterThanOrEqual(dict.capacity, 0)
    XCTAssertNil(dict.first)
    XCTAssertNil(dict.last)
  }
}
#endif
