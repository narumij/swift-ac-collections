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

  enum TestKey: _KeyCustomProtocol {
    @inlinable @inline(__always)
    static func value_comp(_ a: Int, _ b: Int) -> Bool { a < b }
  }

  #if DEBUG
    func testMinimum() throws {
      let cache = _MemoizeCacheBase<TestKey, Int>(minimumCapacity: 10)
      XCTAssertEqual(cache._tree.count, 0)
      XCTAssertEqual(cache._tree.capacity, 10)
    }

    func testMaximum() throws {
      var cache = _MemoizeCacheBase<TestKey, Int>(minimumCapacity: 0)
      XCTAssertEqual(cache._tree.count, 0)
      XCTAssertEqual(cache._tree.capacity, 0)
      var finalCapacity: Int? = nil
      for i in 0..<200 {
        cache[i] = i
        if finalCapacity == nil, cache._tree.capacity >= 100 {
          finalCapacity = cache._tree.capacity
        }
        if let finalCapacity {
          // 最終的に定まったキャパシティが変化しない
          XCTAssertGreaterThanOrEqual(cache._tree.capacity, finalCapacity, "\(i)")
        }
      }
    }
  #endif
  
  func testMaximum2() throws {
    var cache = _MemoizeCacheBase<TestKey, Int>(minimumCapacity: 0)
    cache[0] = 0
    XCTAssertEqual(cache[0], 0)
    cache[1] = 1
    XCTAssertEqual(cache[0], 0)
    cache[2] = 2
    XCTAssertEqual(cache[0], 0)
    cache[3] = 3
    XCTAssertEqual(cache[0], 0)
    cache[4] = 4
    XCTAssertEqual(cache[0], 0)
    var i = 5
    while cache.count < cache.capacity {
      cache[i] = i
      i += 1
      XCTAssertEqual(cache[0], 0)
    }
    cache[i] = i
    XCTAssertEqual(cache[0], 0) // 消えない挙動にした
    XCTAssertEqual(cache[1], 1) // 消えない挙動にした
    XCTAssertEqual(cache[i], i) // 新しいモノが登録されている
    i += 1
    cache[i] = i
    XCTAssertEqual(cache[0], 0) // 消えない挙動にした
    XCTAssertEqual(cache[1], 1) // 消えない挙動にした
    XCTAssertEqual(cache[i], i) // 新しいモノが登録されている
    i += 1
  }

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
        XCTAssertEqual(Memoized_Ver4.tarai(x: 24, y: 12, z: 0), 24)
      }
    }
  #endif
}

