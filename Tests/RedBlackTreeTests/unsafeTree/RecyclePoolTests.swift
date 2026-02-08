//
//  RecyclePoolTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule

  final class RecyclePoolTests: RedBlackTreeTestCase {
    
    struct Fixture: _UnsafeNodePtrType, _RecyclePool {
      var recycleHead: _NodePtr = .nullptr
      var count: Int = 0
      var freshPoolUsedCount: Int = 0
      var nullptr: _NodePtr { .nullptr }
      var end_ptr: _NodePtr { .nullptr }
      var freshBucketAllocator: _BucketAllocator = .init(
        valueType: Bool.self, deinitialize: { $0.assumingMemoryBound(to: Bool.self).pointee = false })
    }
    
    struct FixtureNode {
      var node: UnsafeNode
      var initialized: Bool = true
      var padding: UInt64 = 0
    }
    
    var fixture: Fixture = .init()
    var nodes: UnsafeMutablePointer<FixtureNode>!
    
    let nodeCount = 10

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      fixture = .init()
      nodes = UnsafeMutablePointer<FixtureNode>.allocate(capacity: nodeCount)
      for i in 0..<nodeCount {
        nodes
          .advanced(by: i)
          .initialize(to:
              .init(node: .create(tag: i, nullptr: UnsafeNode.nullptr)))
      }
      fixture.count = nodeCount
      fixture.freshPoolUsedCount = nodeCount
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      nodes.deinitialize(count: nodeCount)
      nodes.deallocate()
    }

    func nodePointer(at i: Int) -> UnsafeMutablePointer<UnsafeNode> {
      _ref(to: &nodes.advanced(by: i).pointee.node)
    }
    
    func testPush() throws {
      XCTAssertEqual(fixture.recycleHead, .nullptr)
      for i in 0..<nodeCount {
        XCTAssertEqual(fixture.recycleCount, i)
        fixture.___pushRecycle(nodePointer(at: i))
        XCTAssertNotEqual(fixture.recycleHead, .nullptr)
        XCTAssertEqual(fixture.recycleCount, i + 1)
      }
      for i in 0..<nodeCount {
        XCTAssertEqual(nodePointer(at: i).__value_(as: Bool.self).pointee, false)
      }
      for i in 0..<nodeCount {
        XCTAssertEqual(fixture.recycleCount, nodeCount - i)
        XCTAssertNotEqual(fixture.recycleHead, .nullptr)
        _ = fixture.___popRecycle()
        XCTAssertEqual(fixture.recycleCount, nodeCount - i - 1)
      }
    }
    
    func testFlushSmoke() throws {
      for i in 0..<nodeCount {
        fixture.___pushRecycle(nodePointer(at: i))
      }
      fixture.___flushRecyclePool()
      XCTAssertEqual(fixture.recycleHead, .nullptr)
    }

    func testPerformanceExample() throws {
      // This is an example of a performance test case.
      self.measure {
        // Put the code you want to measure the time of here.
      }
    }

  }
#endif
