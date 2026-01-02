//
//  MemoryTests.swift
//  TrailingArrayTest
//
//  Created by narumij on 2025/12/28.
//

import XCTest

#if DEBUG
@testable import RedBlackTreeModule

final class UnsafeTreeMemoryTests: XCTestCase {

  enum Base: ScalarValueComparer & CompareUniqueTrait & HasDefaultThreeWayComparator {
    typealias _Key = Int
    typealias Element = Int
  }

  public typealias ___Tree = UnsafeTree

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testCreateZero() async throws {
    let storage = ___Tree<Base>.create(minimumCapacity: 0)
    XCTAssertEqual(storage.freshPoolCapacity, 0)
    XCTAssertEqual(storage.count, 0)
    XCTAssertEqual(storage.__root, nil)
    XCTAssertEqual(storage.__begin_node_, storage.end)
  }

  func testCreate() async throws {
    let storage = ___Tree<Base>.create(minimumCapacity: 4)
    XCTAssertEqual(storage.freshPoolCapacity, 4)
    XCTAssertEqual(storage.count, 0)
    XCTAssertEqual(storage.__root, nil)
    XCTAssertEqual(storage.__begin_node_, storage.end)
  }

  func testConstruct() async throws {
    let storage = ___Tree<Base>.create(minimumCapacity: 4)
    XCTAssertEqual(storage.freshPoolCapacity, 4)
    let ptr = storage.__construct_node(100)
    XCTAssertEqual(storage.__value_(ptr), 100)
    storage.___element(ptr, 20)
    XCTAssertEqual(storage.__value_(ptr), 20)
    storage.___element(ptr, 50)
    XCTAssertEqual(storage.__value_(ptr), 50)
  }

  func testDestroy0() async throws {
    let storage = ___Tree<Base>.create(minimumCapacity: 4)
    let ptr = storage.__construct_node(100)
    XCTAssertEqual(storage.__value_(ptr), 100)
    storage.destroy(ptr)
    XCTAssertEqual(storage.__value_(ptr), 100)
  }

  func testDestroyStack() async throws {
    let storage = ___Tree<Base>.create(minimumCapacity: 4)
    //    storage.initializedCount = 4
    _ = storage.__construct_node(0)
    _ = storage.__construct_node(2)
    _ = storage.__construct_node(4)
    _ = storage.__construct_node(8)
    XCTAssertEqual(storage._header[0]?.pointee.___node_id_, 0)
    XCTAssertEqual(storage._header[1]?.pointee.___node_id_, 1)
    XCTAssertEqual(storage._header[2]?.pointee.___node_id_, 2)
    XCTAssertEqual(storage._header[3]?.pointee.___node_id_, 3)
    XCTAssertEqual(storage._header.destroyNode, nil)
    XCTAssertEqual(storage.___destroyNodes, [])
    XCTAssertEqual(storage._header.destroyCount, 0)
    storage._header.___pushRecycle(storage._header[0])
    XCTAssertEqual(storage._header.destroyNode, storage._header[0])
    XCTAssertEqual(storage.__left_(storage._header[0]), nil)
    XCTAssertEqual(storage.___destroyNodes, [0])
    XCTAssertEqual(storage._header.destroyCount, 1)
    storage._header.___pushRecycle(storage._header[1])
    XCTAssertEqual(storage.___destroyNodes, [1, 0])
    XCTAssertEqual(storage._header.destroyCount, 2)
    storage._header.___pushRecycle(storage._header[2])
    XCTAssertEqual(storage.___destroyNodes, [2, 1, 0])
    XCTAssertEqual(storage._header.destroyCount, 3)
    storage._header.___pushRecycle(storage._header[3])
    XCTAssertEqual(storage.___destroyNodes, [3, 2, 1, 0])
    XCTAssertEqual(storage._header.destroyCount, 4)
    XCTAssertEqual(storage._header.___popRecycle(), storage._header[3])
    XCTAssertEqual(storage.___destroyNodes, [2, 1, 0])
    XCTAssertEqual(storage._header.destroyCount, 3)
    XCTAssertEqual(storage._header.___popRecycle(), storage._header[2])
    XCTAssertEqual(storage.___destroyNodes, [1, 0])
    XCTAssertEqual(storage._header.destroyCount, 2)
    XCTAssertEqual(storage._header.___popRecycle(), storage._header[1])
    XCTAssertEqual(storage.___destroyNodes, [0])
    XCTAssertEqual(storage._header.destroyCount, 1)
    XCTAssertEqual(storage._header.___popRecycle(), storage._header[0])
    XCTAssertEqual(storage.___destroyNodes, [])
    XCTAssertEqual(storage._header.destroyCount, 0)
  }

  func testDestroyStack2() async throws {
//    throw XCTSkip()
    let storage = ___Tree<Base>.create(minimumCapacity: 4)
    _ = storage.__construct_node(0)
    _ = storage.__construct_node(2)
    _ = storage.__construct_node(4)
    _ = storage.__construct_node(8)
    storage._header.___pushRecycle(storage._header[0])
    storage._header.___pushRecycle(storage._header[1])
    storage._header.___pushRecycle(storage._header[2])
    storage._header.___pushRecycle(storage._header[3])
    let copy = storage.copy(minimumCapacity: 100)
    XCTAssertEqual(storage.___destroyNodes, copy.___destroyNodes)
    var (s, c) = (storage._header.destroyNode, copy._header.destroyNode)
    while let ss = s, let cc = c {
      XCTAssertEqual(ss.pointee.___node_id_, cc.pointee.___node_id_)
      XCTAssertEqual(ss.pointee.__right_?.pointee.___node_id_, cc.pointee.__right_?.pointee.___node_id_)
      XCTAssertEqual(ss.pointee.__left_?.pointee.___node_id_, cc.pointee.__left_?.pointee.___node_id_)
      (s, c) = (storage.__left_(ss), copy.__left_(cc))
    }
  }

  func testInsert() async throws {
//    throw XCTSkip()
    let storage = ___Tree<Base>.create(minimumCapacity: 5)
    for i in 0..<5 {
      _ = storage.__insert_unique(i)
      XCTAssertTrue(storage.__tree_invariant(storage.__root))
    }
    XCTAssertEqual(storage.lower_bound(3)?.pointee.___node_id_, 3)
    var begin = storage.__begin_node_
    XCTAssertEqual(UnsafePair<Base._Value>.__value_(begin!).pointee, 0)
    begin = storage.__tree_next_iter(begin)
    XCTAssertEqual(UnsafePair<Base._Value>.__value_(begin!).pointee, 1)
    begin = storage.__tree_next_iter(begin)
    XCTAssertEqual(UnsafePair<Base._Value>.__value_(begin!).pointee, 2)
    begin = storage.__tree_next_iter(begin)
    XCTAssertEqual(UnsafePair<Base._Value>.__value_(begin!).pointee, 3)
    begin = storage.__tree_next_iter(begin)
    XCTAssertEqual(UnsafePair<Base._Value>.__value_(begin!).pointee, 4)
    begin = storage.__tree_next_iter(begin)
    XCTAssertEqual(begin, storage.end)
  }

  func testInsert2() async throws {
//    throw XCTSkip()
    let storage = ___Tree<Base>.create(minimumCapacity: 5)
    for i in 0..<5 {
      _ = storage.__insert_unique(i)
      XCTAssertTrue(storage.__tree_invariant(storage.__root))
    }
    let copy = storage.copy()
    XCTAssertTrue(copy.__tree_invariant(copy.__root))
    XCTAssertEqual(
      copy.__root?.pointee.___node_id_,
      storage.__root?.pointee.___node_id_)
    XCTAssertEqual(
      copy.__root?.pointee.__left_?.pointee.___node_id_,
      storage.__root?.pointee.__left_?.pointee.___node_id_)
    XCTAssertEqual(
      copy.__root?.pointee.__right_?.pointee.___node_id_,
      storage.__root?.pointee.__right_?.pointee.___node_id_)
    XCTAssertEqual(copy.__begin_node_?.pointee.___node_id_, storage.__begin_node_?.pointee.___node_id_)
    XCTAssertEqual(
      copy.__begin_node_?.pointee.__parent_?.pointee.___node_id_,
      storage.__begin_node_?.pointee.__parent_?.pointee.___node_id_)
    XCTAssertEqual(
      copy.__begin_node_?.pointee.__right_?.pointee.___node_id_,
      storage.__begin_node_?.pointee.__right_?.pointee.___node_id_)

    XCTAssertEqual(copy.lower_bound(3)?.pointee.___node_id_, 3)
    var begin = copy.__begin_node_
    XCTAssertEqual(UnsafePair<Base._Value>.__value_(begin!).pointee, 0)
    begin = copy.__tree_next_iter(begin)
    XCTAssertEqual(UnsafePair<Base._Value>.__value_(begin!).pointee, 1)
    begin = copy.__tree_next_iter(begin)
    XCTAssertEqual(UnsafePair<Base._Value>.__value_(begin!).pointee, 2)
    begin = copy.__tree_next_iter(begin)
    XCTAssertEqual(UnsafePair<Base._Value>.__value_(begin!).pointee, 3)
    begin = copy.__tree_next_iter(begin)
    XCTAssertEqual(UnsafePair<Base._Value>.__value_(begin!).pointee, 4)
    begin = copy.__tree_next_iter(begin)
    XCTAssertEqual(begin, copy.end)
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
#endif
