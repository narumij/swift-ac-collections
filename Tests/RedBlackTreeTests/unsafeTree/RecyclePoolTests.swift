//
//  RecyclePoolTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule

  final class RecyclePoolTests: XCTestCase, _UnsafeNodePtrType, _UnsafeNodeRecyclePool {
    var recycleHead: _NodePtr = .nullptr
    var count: Int = 0
    var freshPoolUsedCount: Int = 0
    var nullptr: _NodePtr { .nullptr }
    var freshBucketAllocator: _UnsafeNodeFreshBucketAllocator = .init(
      valueType: Bool.self, deinitialize: { $0.assumingMemoryBound(to: Bool.self).pointee = false })

    struct FixtureNode {
      var node: UnsafeNode
      var initialized: Bool = true
      var padding: UInt64 = 0
    }

    var fixtures: UnsafeMutablePointer<FixtureNode>!
    
    let nodeCount = 10

    override func setUpWithError() throws {
      // Put setup code here. This method is called before the invocation of each test method in the class.
      recycleHead = .nullptr
      count = 0
      fixtures = UnsafeMutablePointer<FixtureNode>.allocate(capacity: nodeCount)
      for i in 0..<nodeCount {
        fixtures
          .advanced(by: i)
          .initialize(to:
              .init(node: .create(id: i)))
      }
      freshPoolUsedCount = nodeCount
    }

    override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      fixtures.deinitialize(count: nodeCount)
      fixtures.deallocate()
    }

    func testExample() throws {
      // This is an example of a functional test case.
      // Use XCTAssert and related functions to verify your tests produce the correct results.
      // Any test you write for XCTest can be annotated as throws and async.
      // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
      // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
      // This is an example of a performance test case.
      self.measure {
        // Put the code you want to measure the time of here.
      }
    }

  }
#endif
