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

  func testDestroy() async throws {
    let storage = ___RedBlackTree.___Storage<VC,Int>.create(withCapacity: 4)
    let ptr = storage.__construct_node(100)
    XCTAssertEqual(storage[ptr].__value_, 100)
    storage.destroy(ptr)
    XCTAssertEqual(storage[ptr].__value_, 100)
  }
}
