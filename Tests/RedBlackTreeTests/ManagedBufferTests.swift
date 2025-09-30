import XCTest

#if DEBUG
@testable import RedBlackTreeModule

final class ManagedBufferTests: XCTestCase {

  enum VC: ScalarValueComparer & CompareUniqueTrait {
    typealias _Key = Int
    typealias Element = Int
  }

  func testCreateZero() async throws {
    let storage = ___Tree<VC>.create(minimumCapacity: 0)
    XCTAssertEqual(storage.capacity, 0)
    XCTAssertEqual(storage.count, 0)
    XCTAssertEqual(storage.__root(), .nullptr)
    XCTAssertEqual(storage.__begin_node, .end)
  }

  func testCreate() async throws {
    let storage = ___Tree<VC>.create(minimumCapacity: 4)
    XCTAssertEqual(storage.capacity, 4)
    XCTAssertEqual(storage.count, 0)
    XCTAssertEqual(storage.__root(), .nullptr)
    XCTAssertEqual(storage.__begin_node, .end)
  }

  func testConstruct() async throws {
    let storage = ___Tree<VC>.create(minimumCapacity: 4)
    let ptr = storage.__construct_node(100)
    XCTAssertEqual(storage.__value_(ptr), 100)
    storage.___element(ptr, 20)
    XCTAssertEqual(storage.__value_(ptr), 20)
    storage.___element(ptr, 50)
    XCTAssertEqual(storage.__value_(ptr), 50)
  }

  func testDestroy0() async throws {
    let storage = ___Tree<VC>.create(minimumCapacity: 4)
    let ptr = storage.__construct_node(100)
    XCTAssertEqual(storage.__value_(ptr), 100)
    storage.destroy(ptr)
    XCTAssertEqual(storage.__value_(ptr), 100)
  }
  
  func testDestroyStack() async throws {
#if AC_COLLECTIONS_INTERNAL_CHECKS
    let storage = ___Tree<VC>.create(minimumCapacity: 4)
    storage.header.initializedCount = 4
    XCTAssertEqual(storage.header.destroyNode, .nullptr)
    XCTAssertEqual(storage.___destroyNodes, [])
    XCTAssertEqual(storage.header.destroyCount, 0)
    storage.___pushDestroy(0)
    XCTAssertEqual(storage.header.destroyNode, 0)
    XCTAssertEqual(storage.__left_(0), .nullptr)
    XCTAssertEqual(storage.___destroyNodes, [0])
    XCTAssertEqual(storage.header.destroyCount, 1)
    storage.___pushDestroy(1)
    XCTAssertEqual(storage.___destroyNodes, [1,0])
    XCTAssertEqual(storage.header.destroyCount, 2)
    storage.___pushDestroy(2)
    XCTAssertEqual(storage.___destroyNodes, [2,1,0])
    XCTAssertEqual(storage.header.destroyCount, 3)
    storage.___pushDestroy(3)
    XCTAssertEqual(storage.___destroyNodes, [3,2,1,0])
    XCTAssertEqual(storage.header.destroyCount, 4)
    XCTAssertEqual(storage.___popDetroy(), 3)
    XCTAssertEqual(storage.___destroyNodes, [2,1,0])
    XCTAssertEqual(storage.header.destroyCount, 3)
    XCTAssertEqual(storage.___popDetroy(), 2)
    XCTAssertEqual(storage.___destroyNodes, [1,0])
    XCTAssertEqual(storage.header.destroyCount, 2)
    XCTAssertEqual(storage.___popDetroy(), 1)
    XCTAssertEqual(storage.___destroyNodes, [0])
    XCTAssertEqual(storage.header.destroyCount, 1)
    XCTAssertEqual(storage.___popDetroy(), 0)
    XCTAssertEqual(storage.___destroyNodes, [])
    XCTAssertEqual(storage.header.destroyCount, 0)
#endif
  }

  func testConstructDestroy() async throws {
#if AC_COLLECTIONS_INTERNAL_CHECKS
    let storage = ___Tree<VC>.create(minimumCapacity: 4)
    do {
      let p = storage.__construct_node(-1)
      XCTAssertEqual(storage.count, 1)
      XCTAssertEqual(p, 0)
      storage.destroy(p)
      XCTAssertEqual(storage.count, 0)
      XCTAssertEqual(storage.header.destroyNode, 0)
      XCTAssertEqual(storage.___destroyNodes, [0])
      XCTAssertEqual(storage.header.destroyCount, 1)
      XCTAssertEqual(storage.__left_(0), .nullptr)
    }
    do {
      let p = storage.__construct_node(-1)
      XCTAssertEqual(storage.count, 1)
      XCTAssertEqual(p, 0)
      do {
        let p = storage.__construct_node(-1)
        XCTAssertEqual(storage.count, 2)
        XCTAssertEqual(p, 1)
        storage.destroy(p)
        XCTAssertEqual(storage.count, 1)
        XCTAssertEqual(storage.header.destroyNode, 1)
        XCTAssertEqual(storage.___destroyNodes, [1])
        XCTAssertEqual(storage.header.destroyCount, 1)
      }
      storage.destroy(p)
      XCTAssertEqual(storage.count, 0)
      XCTAssertEqual(storage.header.destroyNode, 0)
      XCTAssertEqual(storage.___destroyNodes, [0,1])
      XCTAssertEqual(storage.header.destroyCount, 2)
      XCTAssertEqual(storage.__left_(1), .nullptr)
    }
    do {
      let p = storage.__construct_node(-1)
      XCTAssertEqual(storage.count, 1)
      XCTAssertEqual(p, 0)
      do {
        let p = storage.__construct_node(-1)
        XCTAssertEqual(storage.count, 2)
        XCTAssertEqual(p, 1)
        do {
          let p = storage.__construct_node(-1)
          XCTAssertEqual(storage.count, 3)
          XCTAssertEqual(p, 2)
          storage.destroy(p)
          XCTAssertEqual(storage.count, 2)
          XCTAssertEqual(storage.header.destroyNode, 2)
          XCTAssertEqual(storage.___destroyNodes, [2])
          XCTAssertEqual(storage.header.destroyCount, 1)
          XCTAssertEqual(storage.__left_(2), .nullptr)
        }
        storage.destroy(p)
        XCTAssertEqual(storage.count, 1)
        XCTAssertEqual(storage.header.destroyNode, 1)
        XCTAssertEqual(storage.___destroyNodes, [1,2])
        XCTAssertEqual(storage.header.destroyCount, 2)
        XCTAssertEqual(storage.__left_(2), .nullptr)
      }
      storage.destroy(p)
      XCTAssertEqual(storage.header.destroyNode, 0)
      XCTAssertEqual(storage.___destroyNodes, [0,1,2])
      XCTAssertEqual(storage.header.destroyCount, 3)
      XCTAssertEqual(storage.__left_(2), .nullptr)
    }
#endif
  }
}
#endif
