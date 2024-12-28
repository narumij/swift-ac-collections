//
//  ManagedBufferTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/12/27.
//

import XCTest

@testable import RedBlackTreeModule

final class ManagedBufferTests: XCTestCase {

  enum VC: ScalarValueComparer {
    typealias _Key = Int
    typealias Element = Int
  }

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testCreateZero() async throws {
    let storage = ___RedBlackTree.___Buffer<VC, Int>.empty
    XCTAssertEqual(storage.capacity, 0)
    XCTAssertEqual(storage.count, 0)
    XCTAssertEqual(storage.__left_, .nullptr)
    XCTAssertEqual(storage.__begin_node, .end)
  }

  func testCreate() async throws {
    let storage = ___RedBlackTree.___Buffer<VC,Int>.create(withCapacity: 4)
    XCTAssertEqual(storage.capacity, 4)
    XCTAssertEqual(storage.count, 0)
    XCTAssertEqual(storage.__left_, .nullptr)
    XCTAssertEqual(storage.__begin_node, .end)
  }

  func testConstruct() async throws {
    let storage = ___RedBlackTree.___Buffer<VC,Int>.create(withCapacity: 4)
    let ptr = storage.__construct_node(100)
    XCTAssertEqual(storage[node : ptr].__value_, 100)
    storage[node : ptr].__value_ = 20
    XCTAssertEqual(storage[node : ptr].__value_, 20)
    storage[node : ptr].__value_ = 50
    XCTAssertEqual(storage[node : ptr].__value_, 50)
  }

  func testDestroy0() async throws {
    let storage = ___RedBlackTree.___Buffer<VC,Int>.create(withCapacity: 4)
    let ptr = storage.__construct_node(100)
    XCTAssertEqual(storage[node : ptr].__value_, 100)
    storage.destroy(ptr)
    XCTAssertEqual(storage[node : ptr].__value_, 100)
  }
  
  func testDestroyStack() async throws {
    let storage = ___RedBlackTree.___Buffer<VC,Int>.create(withCapacity: 4)
    storage.header.initializedCount = 4
    XCTAssertEqual(storage.header.destroyNode, .nullptr)
    XCTAssertEqual(storage.___destroyNodes, [])
    XCTAssertEqual(storage.header.destroyCount, 0)
    storage.___pushDestroy(0)
    XCTAssertEqual(storage.header.destroyNode, 0)
    XCTAssertEqual(storage[node : 0].__right_, .nullptr)
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
  }

  func testConstructDestroy() async throws {
    let storage = ___RedBlackTree.___Buffer<VC,Int>.create(withCapacity: 4)
    do {
      let p = storage.__construct_node(-1)
      XCTAssertEqual(storage.count, 1)
      XCTAssertEqual(p, 0)
      storage.destroy(p)
      XCTAssertEqual(storage.count, 0)
      XCTAssertEqual(storage.header.destroyNode, 0)
      XCTAssertEqual(storage.___destroyNodes, [0])
      XCTAssertEqual(storage.header.destroyCount, 1)
      XCTAssertEqual(storage[node : 0].__right_, .nullptr)
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
      XCTAssertEqual(storage[node : 1].__right_, .nullptr)
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
          XCTAssertEqual(storage[node : 2].__right_, .nullptr)
        }
        storage.destroy(p)
        XCTAssertEqual(storage.count, 1)
        XCTAssertEqual(storage.header.destroyNode, 1)
        XCTAssertEqual(storage.___destroyNodes, [1,2])
        XCTAssertEqual(storage.header.destroyCount, 2)
        XCTAssertEqual(storage[node : 2].__right_, .nullptr)
      }
      storage.destroy(p)
      XCTAssertEqual(storage.header.destroyNode, 0)
      XCTAssertEqual(storage.___destroyNodes, [0,1,2])
      XCTAssertEqual(storage.header.destroyCount, 3)
      XCTAssertEqual(storage[node : 2].__right_, .nullptr)
    }
  }
}
