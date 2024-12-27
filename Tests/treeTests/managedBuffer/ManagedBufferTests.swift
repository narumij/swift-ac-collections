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
    let storage = ___RedBlackTree.___Storage<VC, Int>.empty
    XCTAssertEqual(storage.capacity, 0)
    XCTAssertEqual(storage.count, 0)
    XCTAssertEqual(storage.__left_, .nullptr)
    XCTAssertEqual(storage.__begin_node, .end)
  }

  func testCreate() async throws {
    let storage = ___RedBlackTree.___Storage<VC,Int>.create(withCapacity: 4)
    XCTAssertEqual(storage.capacity, 4)
    XCTAssertEqual(storage.count, 0)
    XCTAssertEqual(storage.__left_, .nullptr)
    XCTAssertEqual(storage.__begin_node, .end)
  }

  func testConstruct() async throws {
    let storage = ___RedBlackTree.___Storage<VC,Int>.create(withCapacity: 4)
    let ptr = storage.__construct_node(100)
    XCTAssertEqual(storage[ptr].__value_, 100)
    storage[ptr].__value_ = 20
    XCTAssertEqual(storage[ptr].__value_, 20)
    storage[ptr].__value_ = 50
    XCTAssertEqual(storage[ptr].__value_, 50)
  }

  func testDestroy0() async throws {
    let storage = ___RedBlackTree.___Storage<VC,Int>.create(withCapacity: 4)
    let ptr = storage.__construct_node(100)
    XCTAssertEqual(storage[ptr].__value_, 100)
    storage.destroy(ptr)
    XCTAssertEqual(storage[ptr].__value_, 100)
  }
  
  func testDestroyStack() async throws {
    let storage = ___RedBlackTree.___Storage<VC,Int>.create(withCapacity: 4)
    storage.__initialized_count = 4
    XCTAssertEqual(storage.header.__destroy_node, .nullptr)
    XCTAssertEqual(storage.destroyNodes, [])
    XCTAssertEqual(storage.__destroy_count, 0)
    storage.pushDestroy(0)
    XCTAssertEqual(storage.header.__destroy_node, 0)
    XCTAssertEqual(storage[0].__right_, .nullptr)
    XCTAssertEqual(storage.destroyNodes, [0])
    XCTAssertEqual(storage.__destroy_count, 1)
    storage.pushDestroy(1)
    XCTAssertEqual(storage.destroyNodes, [1,0])
    XCTAssertEqual(storage.__destroy_count, 2)
    storage.pushDestroy(2)
    XCTAssertEqual(storage.destroyNodes, [2,1,0])
    XCTAssertEqual(storage.__destroy_count, 3)
    storage.pushDestroy(3)
    XCTAssertEqual(storage.destroyNodes, [3,2,1,0])
    XCTAssertEqual(storage.__destroy_count, 4)
    XCTAssertEqual(storage.popDetroy(), 3)
    XCTAssertEqual(storage.destroyNodes, [2,1,0])
    XCTAssertEqual(storage.__destroy_count, 3)
    XCTAssertEqual(storage.popDetroy(), 2)
    XCTAssertEqual(storage.destroyNodes, [1,0])
    XCTAssertEqual(storage.__destroy_count, 2)
    XCTAssertEqual(storage.popDetroy(), 1)
    XCTAssertEqual(storage.destroyNodes, [0])
    XCTAssertEqual(storage.__destroy_count, 1)
    XCTAssertEqual(storage.popDetroy(), 0)
    XCTAssertEqual(storage.destroyNodes, [])
    XCTAssertEqual(storage.__destroy_count, 0)
  }

}
