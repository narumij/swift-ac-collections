//
//  MemoryTests.swift
//  TrailingArrayTest
//
//  Created by narumij on 2025/12/28.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule

  final class UnsafeTreeBasicTests: RedBlackTreeTestCase {

    enum Base: ScalarValueComparer & CompareUniqueTrait & HasDefaultThreeWayComparator {
      static func __value_(_ p: UnsafeMutablePointer<RedBlackTreeModule.UnsafeNode>) -> Int {
        fatalError()
      }
      typealias _Key = Int
      typealias Element = Int
    }

    func testCreateZero() async throws {
      let storage = UnsafeTreeV2<Base>.create()
      XCTAssertEqual(storage.capacity, 0)
      XCTAssertEqual(storage.count, 0)
      XCTAssertEqual(storage.__root, storage.nullptr)
      XCTAssertEqual(storage.__begin_node_, storage.end)
    }

    func testCreate() async throws {
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
      XCTAssertGreaterThanOrEqual(storage.capacity, 4)
      XCTAssertEqual(storage.count, 0)
      XCTAssertEqual(storage.__root, storage.nullptr)
      XCTAssertEqual(storage.__begin_node_, storage.end)
    }

    func testConstruct() async throws {
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
      XCTAssertGreaterThanOrEqual(storage.capacity, 4)
      let ptr = storage.__construct_node(100)
      XCTAssertEqual(storage.__value_(ptr), 100)
      storage.___element(ptr, 20)
      XCTAssertEqual(storage.__value_(ptr), 20)
      storage.___element(ptr, 50)
      XCTAssertEqual(storage.__value_(ptr), 50)
    }

    func testPoolIterator() async throws {
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
      XCTAssertGreaterThanOrEqual(storage.capacity, 4)
      _ = storage.__construct_node(100)
      _ = storage.__construct_node(200)
      _ = storage.__construct_node(300)
      _ = storage.__construct_node(400)

      do {
        var it = storage.makeFreshPoolIterator()
        XCTAssertEqual(it.next().map(\.pointee.___raw_index), 0)
        XCTAssertEqual(it.next().map(\.pointee.___raw_index), 1)
        XCTAssertEqual(it.next().map(\.pointee.___raw_index), 2)
        XCTAssertEqual(it.next().map(\.pointee.___raw_index), 3)
        XCTAssertEqual(it.next().map(\.pointee.___raw_index), nil)
        XCTAssertEqual(it.next().map(\.pointee.___raw_index), nil)
      }

      //      throw XCTSkip()

      XCTAssertEqual(
        storage.makeFreshPoolIterator().map(\.pointee.___raw_index),
        [0, 1, 2, 3])

      XCTAssertEqual(
        storage.makeFreshPoolIterator().map { $0.__value_().pointee },
        [100, 200, 300, 400])
    }

    func testDestroy0() async throws {
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
      let ptr = storage.__construct_node(100)
      XCTAssertEqual(storage.__value_(ptr), 100)
      storage.destroy(ptr)
      XCTAssertEqual(storage.__value_(ptr), 100)
    }

    func testDestroyStack() async throws {
      var storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
      //    storage.initializedCount = 4
      _ = storage.__construct_node(0)
      _ = storage.__construct_node(2)
      _ = storage.__construct_node(4)
      _ = storage.__construct_node(8)
      XCTAssertEqual(storage._buffer.header[0].index, 0)
      XCTAssertEqual(storage._buffer.header[1].index, 1)
      XCTAssertEqual(storage._buffer.header[2].index, 2)
      XCTAssertEqual(storage._buffer.header[3].index, 3)
      XCTAssertEqual(storage._buffer.header.recycleHead, storage.nullptr)
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [])
      XCTAssertEqual(storage._buffer.header.recycleCount, 0)
      storage._buffer.header.___pushRecycle(storage._buffer.header[0])
      XCTAssertEqual(storage._buffer.header.recycleHead, storage._buffer.header[0])
      XCTAssertEqual(storage.__left_(storage._buffer.header[0]), storage.nullptr)
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 1)
      storage._buffer.header.___pushRecycle(storage._buffer.header[1])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [1, 0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 2)
      storage._buffer.header.___pushRecycle(storage._buffer.header[2])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [2, 1, 0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 3)
      storage._buffer.header.___pushRecycle(storage._buffer.header[3])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [3, 2, 1, 0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 4)
      XCTAssertEqual(storage._buffer.header.___popRecycle(), storage._buffer.header[3])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [2, 1, 0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 3)
      XCTAssertEqual(storage._buffer.header.___popRecycle(), storage._buffer.header[2])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [1, 0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 2)
      XCTAssertEqual(storage._buffer.header.___popRecycle(), storage._buffer.header[1])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [0])
      XCTAssertEqual(storage._buffer.header.recycleCount, 1)
      XCTAssertEqual(storage._buffer.header.___popRecycle(), storage._buffer.header[0])
      XCTAssertEqual(storage._buffer.header.___recycleNodes, [])
      XCTAssertEqual(storage._buffer.header.recycleCount, 0)
    }

    func testDestroyStack2() async throws {
      //    throw XCTSkip()
      var storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
      _ = storage.__construct_node(0)
      _ = storage.__construct_node(2)
      _ = storage.__construct_node(4)
      _ = storage.__construct_node(8)
      storage._buffer.header.___pushRecycle(storage._buffer.header[0])
      storage._buffer.header.___pushRecycle(storage._buffer.header[1])
      storage._buffer.header.___pushRecycle(storage._buffer.header[2])
      storage._buffer.header.___pushRecycle(storage._buffer.header[3])
      XCTAssertTrue(storage.check())
      storage.withMutableHeader { $0.count = 4 }
      let copy = storage.copy(minimumCapacity: 100)
      XCTAssertEqual(storage._buffer.header.___recycleNodes, copy._buffer.header.___recycleNodes)
      var (s, c) = (storage._buffer.header.recycleHead, copy._buffer.header.recycleHead)
      while s != storage.nullptr, c != storage.nullptr {
        XCTAssertEqual(s.index, s.index)
        XCTAssertEqual(
          s.pointee.__right_.index, c.pointee.__right_.index)
        XCTAssertEqual(
          s.pointee.__left_.index, c.pointee.__left_.index)
        (s, c) = (storage.__left_(s), copy.__left_(c))
      }
    }

    func testConstructDestroy() async throws {
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 4)
        do {
          let p = storage.__construct_node(-1)
          XCTAssertEqual(storage.count, 1)
          XCTAssertEqual(p.index, 0)
          storage.destroy(p)
          XCTAssertEqual(storage.count, 0)
          XCTAssertEqual(storage._buffer.header.recycleHead.index, 0)
          XCTAssertEqual(storage._buffer.header.___recycleNodes, [0])
          XCTAssertEqual(storage._buffer.header.recycleCount, 1)
          XCTAssertEqual(storage.__left_(0), .nullptr)
        }
        do {
          let p = storage.__construct_node(-1)
          XCTAssertEqual(storage.count, 1)
          XCTAssertEqual(p.index, 0)
          do {
            let p = storage.__construct_node(-1)
            XCTAssertEqual(storage.count, 2)
            XCTAssertEqual(p.index, 1)
            storage.destroy(p)
            XCTAssertEqual(storage.count, 1)
            XCTAssertEqual(storage._buffer.header.recycleHead.index, 1)
            XCTAssertEqual(storage._buffer.header.___recycleNodes, [1])
            XCTAssertEqual(storage._buffer.header.recycleCount, 1)
          }
          storage.destroy(p)
          XCTAssertEqual(storage.count, 0)
          XCTAssertEqual(storage._buffer.header.recycleHead.index, 0)
          XCTAssertEqual(storage._buffer.header.___recycleNodes, [0, 1])
          XCTAssertEqual(storage._buffer.header.recycleCount, 2)
          XCTAssertEqual(storage.__left_(1), .nullptr)
        }
        do {
          let p = storage.__construct_node(-1)
          XCTAssertEqual(storage.count, 1)
          XCTAssertEqual(p.index, 0)
          do {
            let p = storage.__construct_node(-1)
            XCTAssertEqual(storage.count, 2)
            XCTAssertEqual(p.index, 1)
            do {
              let p = storage.__construct_node(-1)
              XCTAssertEqual(storage.count, 3)
              XCTAssertEqual(p.index, 2)
              storage.destroy(p)
              XCTAssertEqual(storage.count, 2)
              XCTAssertEqual(storage._buffer.header.recycleHead.index, 2)
              XCTAssertEqual(storage._buffer.header.___recycleNodes, [2])
              XCTAssertEqual(storage._buffer.header.recycleCount, 1)
              XCTAssertEqual(storage.__left_(2), .nullptr)
            }
            storage.destroy(p)
            XCTAssertEqual(storage.count, 1)
            XCTAssertEqual(storage._buffer.header.recycleHead.index, 1)
            XCTAssertEqual(storage._buffer.header.___recycleNodes, [1, 2])
            XCTAssertEqual(storage._buffer.header.recycleCount, 2)
            XCTAssertEqual(storage.__left_(2), .nullptr)
          }
          storage.destroy(p)
          XCTAssertEqual(storage._buffer.header.recycleHead.index, 0)
          XCTAssertEqual(storage._buffer.header.___recycleNodes, [0, 1, 2])
          XCTAssertEqual(storage._buffer.header.recycleCount, 3)
          XCTAssertEqual(storage.__left_(2), .nullptr)
        }
      #endif
    }

    func testInsert() async throws {
      //    throw XCTSkip()
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 5)
      for i in 0..<5 {
        _ = storage.__insert_unique(i)
        XCTAssertTrue(storage.__tree_invariant(storage.__root))
      }
      XCTAssertEqual(storage.lower_bound(3).index, 3)
      var begin = storage.__begin_node_
      XCTAssertEqual(begin.__value_().pointee, 0)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 1)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 2)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 3)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 4)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(begin, storage.end)
    }

    func testInsert2() async throws {
      //    throw XCTSkip()
      let storage = UnsafeTreeV2<Base>.create(minimumCapacity: 5)
      for i in 0..<5 {
        _ = storage.__insert_unique(i)
        XCTAssertTrue(storage.__tree_invariant(storage.__root))
      }
      let copy = storage.copy()
      XCTAssertTrue(copy.__tree_invariant(copy.__root))
      XCTAssertEqual(
        copy.__root.index,
        storage.__root.index)
      XCTAssertEqual(
        copy.__root.pointee.__left_.index,
        storage.__root.pointee.__left_.index)
      XCTAssertEqual(
        copy.__root.pointee.__right_.index,
        storage.__root.pointee.__right_.index)
      XCTAssertEqual(
        copy.__begin_node_.index, storage.__begin_node_.index)
      XCTAssertEqual(
        copy.__begin_node_.pointee.__parent_.index,
        storage.__begin_node_.pointee.__parent_.index)
      XCTAssertEqual(
        copy.__begin_node_.pointee.__right_.index,
        storage.__begin_node_.pointee.__right_.index)

      XCTAssertEqual(copy.lower_bound(3).index, 3)
      var begin = copy.__begin_node_
      XCTAssertEqual(begin.__value_().pointee, 0)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 1)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 2)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 3)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(begin.__value_().pointee, 4)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(begin, copy.end)
    }
  }
#endif
