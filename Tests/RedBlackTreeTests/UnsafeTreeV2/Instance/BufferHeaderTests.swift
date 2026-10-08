//
//  BufferHeaderTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections

  final class BufferHeaderTests: PointerRedBlackTreeTestCase {

    typealias Fixture = UnsafeTreeV2BufferHeader
    let null_back = UnsafeNode.nullptr.pointee

    override func setUpWithError() throws {
      try super.setUpWithError()
    }

    override func tearDownWithError() throws {
      UnsafeNode.nullptr.pointee = null_back
      try super.tearDownWithError()
    }

    func testEmptyInitial() throws {
      var header = Fixture(Int.self, nullptr: .nullptr, capacity: 0)
      XCTAssertEqual(header.recycleHead, .nullptr)
      XCTAssertEqual(header.end_ptr.trackingTag, .end)
      XCTAssertEqual(header.end_ptr.__left_, .nullptr)
      XCTAssertEqual(header.begin_ptr.pointee, header.end_ptr)
      XCTAssertEqual(header.freshBucketCurrent?.pop(), nil)
      header.___deallocFreshPool()
    }

    func testInitial() throws {
      for i in 1..<100 {
        var header = Fixture(Int.self, nullptr: .nullptr, capacity: i)
        XCTAssertEqual(header.recycleHead, .nullptr)
        XCTAssertEqual(header.end_ptr.trackingTag, .end)
        XCTAssertEqual(header.end_ptr.__left_, .nullptr)
        XCTAssertEqual(header.begin_ptr.pointee, header.end_ptr)
        var pointers = Set<_NodePtr>()
        for _ in 0..<i {
          // capacity回数popできること
          let p = header.freshBucketCurrent?.pop()
          p?.initialize(to: UnsafeNode.nullptr.pointee)
          p?.__value_().initialize(to: 0)
          p?.pointee.___has_payload_content = true
          nodeInitializedCount += 1
          payloadInitializedCount += 1
          XCTAssertNotEqual(p, nil)
          pointers.insert(p!)
        }
        // capacity回数で使い切ること
        XCTAssertEqual(header.freshBucketCurrent?.pop(), nil)
        // popしたポインタはユニーク個数で指定数あること
        XCTAssertEqual(pointers.count, i)
        header.___deallocFreshPool()
      }
    }

    func testFromZero() throws {
      let null_back = UnsafeNode.nullptr.pointee
      var header = Fixture(Int.self, nullptr: .nullptr, capacity: 0)
      let end_back = header.end_ptr.pointee

      for i in 1..<100 {
        let capa = header.freshPoolCapacity
        header.grow(header.freshPoolCapacity + i)
        XCTAssertEqual(header.freshPoolCapacity - capa, i)
        XCTAssertEqual(header.freshPoolCapacity, header.freshPoolActualCapacity)
      }
      var pointers = Set<_NodePtr>()
      let count = (1..<100).reduce(0, +)
      for _ in 0..<count {
        // capacity回数popできること
        let p = header.__construct_node(0)
        XCTAssertNotEqual(p, nil)
        pointers.insert(p)
      }
      // capacity回数で使い切ること
      XCTAssertEqual(header.popFresh(), nil)
      XCTAssertEqual(header.freshBucketCurrent?.pop(), nil)
      header.freshPoolCapacity += 1  // アサート回避
      // 管理数に狂いが生じていても無理にポインタを返さない
      XCTAssertEqual(header.___popFresh(), .nullptr)
      // popしたポインタはユニーク個数で指定数あること
      XCTAssertEqual(pointers.count, count)
      // end nodeは別腹であること
      XCTAssertFalse(pointers.contains(header.end_ptr))

      for p in pointers {
        // 0未満はsentinelなので、アサートではねられる
        p.pointee.___tracking_tag = _TrackingTag.max
        header.___pushRecycle(p)
        XCTAssertNotEqual(header.recycleHead, .nullptr)
      }

      for _ in 0..<count {
        let p = header.___popRecycle()
        XCTAssertNotNil(p)
        p.__value_().initialize(to: 0)
        p.pointee.___has_payload_content = true
        #if DEBUG
          payloadInitializedCount += 1
        #endif
      }
      XCTAssertEqual(header.recycleHead, .nullptr)
      XCTAssertEqual(header.___popRecycle(), .nullptr)
      header.___deallocFreshPool()
    }

    /// `___popRecycle()` は速度を優先した内部プリミティブであり、空チェックを行わない。
    /// 代わりに、通常のノード生成経路である `__construct_node(_:)` が
    /// `recycleHead` を確認し、利用可能なpoolを選択する責務を持つ。
    ///
    /// このテストでは、低レベル関数の不正利用に対する防御ではなく、
    /// 呼び出し側がその事前条件を満たしながらfresh/recycleを正しく選ぶことを確認する。
    /// あわせて、空のrecycle poolを誤ってpopしてnullノードを変更していないことも確認する。
    func testConstructNodeSelectsAvailablePool() throws {
      let nullBack = UnsafeNode.nullptr.pointee
      var header = Fixture(Int.self, nullptr: .nullptr, capacity: 1)

      // recycle poolが空の場合、`___popRecycle()` を呼ばずfresh poolから取得する。
      let fresh = header.__construct_node(1)
      XCTAssertNotEqual(fresh, .nullptr)
      XCTAssertEqual(header.recycleHead, .nullptr)
      XCTAssertEqual(header.count, 1)
      XCTAssertEqual(nullBack, UnsafeNode.nullptr.pointee)

      // recycle poolに在庫がある場合はfresh poolへ進まず、同じノードを再利用する。
      header.___pushRecycle(fresh)
      XCTAssertEqual(header.recycleHead, fresh)
      XCTAssertEqual(header.count, 0)

      let recycled = header.__construct_node(2)
      XCTAssertEqual(recycled, fresh)
      XCTAssertEqual(header.recycleHead, .nullptr)
      XCTAssertEqual(header.count, 1)
      XCTAssertEqual(nullBack, UnsafeNode.nullptr.pointee)

      header.___deallocFreshPool()
    }
  }
#endif
