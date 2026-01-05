//
//  MemoryTests.swift
//  TrailingArrayTest
//
//  Created by narumij on 2025/12/28.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule

  final class UnsafeTreeBasicTests: XCTestCase {

    enum Base: ScalarValueComparer & CompareUniqueTrait & HasDefaultThreeWayComparator {
      typealias _Key = Int
      typealias Element = Int
    }

    func testCreateZero() async throws {
      let storage = UnsafeTree<Base>.create(minimumCapacity: 0)
      XCTAssertEqual(storage.freshPoolCapacity, 0)
      XCTAssertEqual(storage.count, 0)
      XCTAssertEqual(storage.__root, storage.nullptr)
      XCTAssertEqual(storage.__begin_node_, storage.end)
    }

    func testCreate() async throws {
      let storage = UnsafeTree<Base>.create(minimumCapacity: 4)
      XCTAssertEqual(storage.freshPoolCapacity, 4)
      XCTAssertEqual(storage.count, 0)
      XCTAssertEqual(storage.__root, storage.nullptr)
      XCTAssertEqual(storage.__begin_node_, storage.end)
    }

    func testConstruct() async throws {
      let storage = UnsafeTree<Base>.create(minimumCapacity: 4)
      XCTAssertEqual(storage.freshPoolCapacity, 4)
      let ptr = storage.__construct_node(100)
      XCTAssertEqual(storage.__value_(ptr), 100)
      storage.___element(ptr, 20)
      XCTAssertEqual(storage.__value_(ptr), 20)
      storage.___element(ptr, 50)
      XCTAssertEqual(storage.__value_(ptr), 50)
    }

    func testDestroy0() async throws {
      let storage = UnsafeTree<Base>.create(minimumCapacity: 4)
      let ptr = storage.__construct_node(100)
      XCTAssertEqual(storage.__value_(ptr), 100)
      storage.destroy(ptr)
      XCTAssertEqual(storage.__value_(ptr), 100)
    }

    func testDestroyStack() async throws {
      let storage = UnsafeTree<Base>.create(minimumCapacity: 4)
      //    storage.initializedCount = 4
      _ = storage.__construct_node(0)
      _ = storage.__construct_node(2)
      _ = storage.__construct_node(4)
      _ = storage.__construct_node(8)
      XCTAssertEqual(storage._header[0].index, 0)
      XCTAssertEqual(storage._header[1].index, 1)
      XCTAssertEqual(storage._header[2].index, 2)
      XCTAssertEqual(storage._header[3].index, 3)
      XCTAssertEqual(storage._header.destroyNode, storage.nullptr)
      XCTAssertEqual(storage.___destroyNodes, [])
      XCTAssertEqual(storage._header.destroyCount, 0)
      storage._header.___pushRecycle(storage._header[0])
      XCTAssertEqual(storage._header.destroyNode, storage._header[0])
      XCTAssertEqual(storage.__left_(storage._header[0]), storage.nullptr)
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
      let storage = UnsafeTree<Base>.create(minimumCapacity: 4)
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
      while s != storage.nullptr , c != storage.nullptr {
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
          XCTAssertEqual(storage._buffer.header.destroyNode.index, 0)
          XCTAssertEqual(storage._buffer.header.___destroyNodes, [0])
          XCTAssertEqual(storage._buffer.header.destroyCount, 1)
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
            XCTAssertEqual(storage._buffer.header.destroyNode.index, 1)
            XCTAssertEqual(storage._buffer.header.___destroyNodes, [1])
            XCTAssertEqual(storage._buffer.header.destroyCount, 1)
          }
          storage.destroy(p)
          XCTAssertEqual(storage.count, 0)
          XCTAssertEqual(storage._buffer.header.destroyNode.index, 0)
          XCTAssertEqual(storage._buffer.header.___destroyNodes, [0, 1])
          XCTAssertEqual(storage._buffer.header.destroyCount, 2)
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
              XCTAssertEqual(storage._buffer.header.destroyNode.index, 2)
              XCTAssertEqual(storage._buffer.header.___destroyNodes, [2])
              XCTAssertEqual(storage._buffer.header.destroyCount, 1)
              XCTAssertEqual(storage.__left_(2), .nullptr)
            }
            storage.destroy(p)
            XCTAssertEqual(storage.count, 1)
            XCTAssertEqual(storage._buffer.header.destroyNode.index, 1)
            XCTAssertEqual(storage._buffer.header.___destroyNodes, [1, 2])
            XCTAssertEqual(storage._buffer.header.destroyCount, 2)
            XCTAssertEqual(storage.__left_(2), .nullptr)
          }
          storage.destroy(p)
          XCTAssertEqual(storage._buffer.header.destroyNode.index, 0)
          XCTAssertEqual(storage._buffer.header.___destroyNodes, [0, 1, 2])
          XCTAssertEqual(storage._buffer.header.destroyCount, 3)
          XCTAssertEqual(storage.__left_(2), .nullptr)
        }
      #endif
    }

    func testInsert() async throws {
      //    throw XCTSkip()
      let storage = UnsafeTree<Base>.create(minimumCapacity: 5)
      for i in 0..<5 {
        _ = storage.__insert_unique(i)
        XCTAssertTrue(storage.__tree_invariant(storage.__root))
      }
      XCTAssertEqual(storage.lower_bound(3).index, 3)
      var begin = storage.__begin_node_
      XCTAssertEqual(UnsafeNode.value(begin), 0)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(UnsafeNode.value(begin), 1)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(UnsafeNode.value(begin), 2)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(UnsafeNode.value(begin), 3)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(UnsafeNode.value(begin), 4)
      begin = storage.__tree_next_iter(begin)
      XCTAssertEqual(begin, storage.end)
    }

    func testInsert2() async throws {
      //    throw XCTSkip()
      let storage = UnsafeTree<Base>.create(minimumCapacity: 5)
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
      XCTAssertEqual(UnsafeNode.value(begin), 0)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(UnsafeNode.value(begin), 1)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(UnsafeNode.value(begin), 2)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(UnsafeNode.value(begin), 3)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(UnsafeNode.value(begin), 4)
      begin = copy.__tree_next_iter(begin)
      XCTAssertEqual(begin, copy.end)
    }
  }
#endif
