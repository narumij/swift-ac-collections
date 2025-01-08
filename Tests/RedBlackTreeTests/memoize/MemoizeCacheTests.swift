//
//  MemoizeCacheTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/01/06.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class MemoizeCacheTests: XCTestCase {

  enum TestKey: KeyCustomProtocol {
    @inlinable @inline(__always)
    static func value_comp(_ a: Int, _ b: Int) -> Bool { a < b }
  }

  #if DEBUG
    func testMinimum() throws {
      var cache = MemoizeCacheBase<TestKey, Int>(minimumCapacity: 10)
      XCTAssertEqual(cache._tree.count, 0)
      XCTAssertEqual(cache._tree.capacity, 10)
    }

    func testMaximum() throws {
      var cache = MemoizeCacheBase<TestKey, Int>(minimumCapacity: 0, maximumCapacity: 100)
      XCTAssertEqual(cache._tree.count, 0)
      XCTAssertEqual(cache._tree.capacity, 0)
      var over: Int? = nil
      for i in 0..<200 {
        cache[i] = i
        if over == nil, cache._tree.capacity >= 100 {
          over = cache._tree.capacity
        }
        if let over {
          XCTAssertLessThanOrEqual(cache._tree.capacity, over, "\(i)")
        }
      }
    }
  #endif

  #if true || ENABLE_PERFORMANCE_TESTING
    func testTak0() throws {
      XCTAssertEqual(Naive.tarai(2, y: 1, z: 0), 2)
      XCTAssertEqual(Naive.tarai(4, y: 2, z: 0), 4)
      XCTAssertEqual(Naive.tarai(6, y: 3, z: 0), 6)
      XCTAssertEqual(Naive.tarai(8, y: 4, z: 0), 8)
      XCTAssertEqual(Naive.tarai(10, y: 5, z: 0), 10)
      XCTAssertEqual(Naive.tarai(12, y: 6, z: 0), 12)
    }

    func testTak1() throws {
      XCTAssertEqual(Naive.tarai(14, y: 7, z: 0), 14)
    }

    func testPerformanceTak0() throws {
      //    let tarai = Tak()
      self.measure {
        XCTAssertEqual(Memoized_Ver2.tarai(x: 14, y: 7, z: 0), 14)
      }
    }

    func testPerformanceTak1() throws {
      //    let tarai = Tak()
      self.measure {
        XCTAssertEqual(Memoized_Ver2.tarai(x: 20, y: 10, z: 0), 20)
      }
    }

    func testPerformanceTak2() throws {
      //    let tarai = Tak()
      self.measure {
        XCTAssertEqual(Memoized_Ver2.tarai(x: 24, y: 12, z: 0), 24)
      }
    }
  #endif
}

