import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class MemoizeCacheLRUTests: XCTestCase {

  enum TestKey: _KeyCustomProtocol {
    @inlinable @inline(__always)
    static func value_comp(_ a: Int, _ b: Int) -> Bool { a < b }
  }

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // Any test you write for XCTest can be annotated as throws and async.
    // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
    // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
  }
  
#if DEBUG
  func testInit() throws {
    let cache = _MemoizeCacheLRU<TestKey, Int>(minimumCapacity: 10)
    XCTAssertEqual(cache._tree.count, 0)
    XCTAssertEqual(cache._tree.capacity, 10)
  }

  func testQueue() throws {
    var cache = _MemoizeCacheLRU<TestKey, Int>(minimumCapacity: 10)
    cache[0] = 0
//    cache.prepend(0)
    XCTAssertEqual(cache.lru_start, 0)
    XCTAssertEqual(cache.lru_end, 0)
    cache[1] = 1
//    cache.prepend(1)
    XCTAssertEqual(cache.lru_start, 1)
    XCTAssertEqual(cache.lru_end, 0)
    
    XCTAssertEqual(cache.___popLast(), 0)
    XCTAssertEqual(cache.lru_start, 1)
    XCTAssertEqual(cache.lru_end, 1)
    
    XCTAssertEqual(cache.___popLast(), 1)
    XCTAssertEqual(cache.lru_start, -1)
    XCTAssertEqual(cache.lru_end, -1)
  }

  func testQueue2() throws {
    var cache = _MemoizeCacheLRU<TestKey, Int>(minimumCapacity: 10)
    cache[0] = 0
//    cache.prepend(0)
    cache[1] = 1
//    cache.prepend(1)
    cache[2] = 2
//    cache.prepend(2)
    cache[3] = 3
//    cache.prepend(3)
    XCTAssertEqual(cache.lru_start, 3)
    XCTAssertEqual(cache.lru_end, 0)
    XCTAssertEqual(cache.___popLast(), 0)
    XCTAssertEqual(cache.lru_start, 3)
    XCTAssertEqual(cache.lru_end, 1)
    XCTAssertEqual(cache.___popLast(), 1)
    XCTAssertEqual(cache.lru_start, 3)
    XCTAssertEqual(cache.lru_end, 2)
    XCTAssertEqual(cache.___popLast(), 2)
    XCTAssertEqual(cache.lru_start, 3)
    XCTAssertEqual(cache.lru_end, 3)
    XCTAssertEqual(cache.___popLast(), 3)
    XCTAssertEqual(cache.lru_start, .nullptr)
    XCTAssertEqual(cache.lru_end, .nullptr)
    XCTAssertEqual(cache.___popLast(), .nullptr)
  }

  func testQueue3() throws {
    var cache = _MemoizeCacheLRU<TestKey, Int>(minimumCapacity: 10)
    cache[0] = 0
//    cache.prepend(0)
    cache[1] = 1
//    cache.prepend(1)
    cache[2] = 2
//    cache.prepend(2)
    cache[3] = 3
//    cache.prepend(3)
    // 3 2 1 0
    XCTAssertEqual(cache.___pop(0),0) // 3 2 1
    XCTAssertEqual(cache.lru_start, 3)
    XCTAssertEqual(cache.lru_end, 1)
    XCTAssertEqual(cache.___pop(2),2) // 3 1
    XCTAssertEqual(cache.lru_start, 3)
    XCTAssertEqual(cache.lru_end, 1)
    XCTAssertEqual(cache.___pop(1),1) // 3
    XCTAssertEqual(cache.lru_start, 3)
    XCTAssertEqual(cache.lru_end, 3)
    XCTAssertEqual(cache.___pop(3),3) //
    XCTAssertEqual(cache.lru_start, -1)
    XCTAssertEqual(cache.lru_end, -1)
  }

  func testQueue4() throws {
    var cache = _MemoizeCacheLRU<TestKey, Int>(minimumCapacity: 10)
    cache[0] = 0
    cache.___prepend(cache.___pop(0))
    cache[1] = 1
    cache.___prepend(cache.___pop(1))
    cache[2] = 2
    cache.___prepend(cache.___pop(2))
    cache[3] = 3
    cache.___prepend(cache.___pop(3))
    // 3 2 1 0
    cache.___prepend(cache.___pop(0)) // 0 3 2 1
    XCTAssertEqual(cache.lru_start, 0)
    XCTAssertEqual(cache.lru_end, 1)
    cache.___prepend(cache.___pop(2)) // 2 0 3 1
    XCTAssertEqual(cache.lru_start, 2)
    XCTAssertEqual(cache.lru_end, 1)
    XCTAssertEqual(cache.___popLast(), 1)
    XCTAssertEqual(cache.lru_start, 2)
    XCTAssertEqual(cache.lru_end, 3)
    XCTAssertEqual(cache.___popLast(), 3)
    XCTAssertEqual(cache.lru_start, 2)
    XCTAssertEqual(cache.lru_end, 0)
    XCTAssertEqual(cache.___popLast(), 0)
    XCTAssertEqual(cache.lru_start, 2)
    XCTAssertEqual(cache.lru_end, 2)
    XCTAssertEqual(cache.___popLast(), 2)
    XCTAssertEqual(cache.lru_start, -1)
    XCTAssertEqual(cache.lru_end, -1)
  }

  func testMaximum() throws {
    var cache = _MemoizeCacheLRU<TestKey, Int>(minimumCapacity: 0, maximumCapacity: 100)
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
        XCTAssertEqual(cache._tree.capacity, finalCapacity, "\(i)")
      }
    }
  }

#endif

  func testMaximum2() throws {
    var cache = _MemoizeCacheLRU<TestKey, Int>(minimumCapacity: 0, maximumCapacity: 5)
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
    XCTAssertEqual(cache.lru_end, 1)
    var i = 5
    while cache.count < cache.capacity {
      cache[i] = i
      i += 1
      XCTAssertEqual(cache[0], 0)
      XCTAssertEqual(cache.lru_end, 1)
    }
    XCTAssertEqual(cache.lru_end, 1)
    cache[i] = i
    XCTAssertNil(cache[1]) // 1番古いモノが消える
    XCTAssertEqual(cache[0], 0) // 頻繁に触っているので消えない
    XCTAssertEqual(cache[i], i) // 新しいモノが登録されている
    i += 1
    XCTAssertEqual(cache.lru_end, 2)
    cache[i] = i
    XCTAssertNil(cache[1]) // 1番古いモノはすでに消えている
    XCTAssertNil(cache[2]) // 2番目に古いモノが消える
    XCTAssertEqual(cache[0], 0) // 頻繁に触っているので消えない
    XCTAssertEqual(cache[i], i) // 新しいモノが登録されている
    i += 1
  }
  
  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
