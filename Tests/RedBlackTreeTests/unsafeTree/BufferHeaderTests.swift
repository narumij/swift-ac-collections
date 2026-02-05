//
//  BufferHeaderTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule

  final class BufferHeaderTests: PointerRedBlackTreeTestCase {

    typealias Fixture = UnsafeTreeV2BufferHeader

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
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
        let p = header.___popFresh()
        XCTAssertNotEqual(p, nil)
        pointers.insert(p)
      }
      // capacity回数で使い切ること
      XCTAssertEqual(header.popFresh(), nil)
      XCTAssertEqual(header.freshBucketCurrent?.pop(), nil)
      header.freshPoolCapacity += 1 // アサート回避
      // 管理数に狂いが生じていても無理にポインタを返さない
      XCTAssertEqual(header.___popFresh(), .nullptr)
      // popしたポインタはユニーク個数で指定数あること
      XCTAssertEqual(pointers.count, count)
      // end nodeは別腹であること
      XCTAssertFalse(pointers.contains(header.end_ptr))
      
      for p in pointers {
        // 0未満はsentinelなので、アサートではねられる
        p.pointee.___tracking_tag = Int.max
        header.___pushRecycle(p)
        XCTAssertNotEqual(header.recycleHead, .nullptr)
      }
      
      for _ in 0..<count {
        XCTAssertNotNil(header.___popRecycle())
      }
      XCTAssertEqual(header.recycleHead, .nullptr)
      XCTAssertEqual(header.___popRecycle(), .nullptr)
      // 過剰popしてもnullノードを破壊していないこと
      XCTAssertEqual(null_back, UnsafeNode.nullptr.pointee)
      // 過剰popしてもendノードを破壊していないこと
      XCTAssertEqual(end_back, header.end_ptr.pointee)

      header.___deallocFreshPool()
    }

    func testPerformanceExample() throws {
      // This is an example of a performance test case.
      self.measure {
        // Put the code you want to measure the time of here.
      }
    }
  }
#endif
