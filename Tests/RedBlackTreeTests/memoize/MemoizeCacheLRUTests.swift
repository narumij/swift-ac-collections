import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class MemoizeCacheLRUTests: XCTestCase {

  typealias TestKey = Int

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
    let cache = ___LRUMemoizeStorage<TestKey, Int>(minimumCapacity: 10)
    XCTAssertEqual(cache.__tree_.count, 0)
    XCTAssertEqual(cache.__tree_.capacity, 10)
  }

  func testQueue() throws {
    var cache = ___LRUMemoizeStorage<TestKey, Int>(minimumCapacity: 10)
    cache[0] = 0
//    cache.prepend(0)
    XCTAssertEqual(cache._rankHighest, 0)
    XCTAssertEqual(cache._rankLowest, 0)
    cache[1] = 1
//    cache.prepend(1)
    XCTAssertEqual(cache._rankHighest, 1)
    XCTAssertEqual(cache._rankLowest, 0)
    
    XCTAssertEqual(cache.___popRankLowest(), 0)
    XCTAssertEqual(cache._rankHighest, 1)
    XCTAssertEqual(cache._rankLowest, 1)
    
    XCTAssertEqual(cache.___popRankLowest(), 1)
    XCTAssertEqual(cache._rankHighest, -1)
    XCTAssertEqual(cache._rankLowest, -1)
  }

  func testQueue2() throws {
    var cache = ___LRUMemoizeStorage<TestKey, Int>(minimumCapacity: 10)
    cache[0] = 0
//    cache.prepend(0)
    cache[1] = 1
//    cache.prepend(1)
    cache[2] = 2
//    cache.prepend(2)
    cache[3] = 3
//    cache.prepend(3)
    XCTAssertEqual(cache._rankHighest, 3)
    XCTAssertEqual(cache._rankLowest, 0)
    XCTAssertEqual(cache.___popRankLowest(), 0)
    XCTAssertEqual(cache._rankHighest, 3)
    XCTAssertEqual(cache._rankLowest, 1)
    XCTAssertEqual(cache.___popRankLowest(), 1)
    XCTAssertEqual(cache._rankHighest, 3)
    XCTAssertEqual(cache._rankLowest, 2)
    XCTAssertEqual(cache.___popRankLowest(), 2)
    XCTAssertEqual(cache._rankHighest, 3)
    XCTAssertEqual(cache._rankLowest, 3)
    XCTAssertEqual(cache.___popRankLowest(), 3)
    XCTAssertEqual(cache._rankHighest, .nullptr)
    XCTAssertEqual(cache._rankLowest, .nullptr)
    XCTAssertEqual(cache.___popRankLowest(), .nullptr)
  }

  func testQueue3() throws {
    var cache = ___LRUMemoizeStorage<TestKey, Int>(minimumCapacity: 10)
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
    XCTAssertEqual(cache._rankHighest, 3)
    XCTAssertEqual(cache._rankLowest, 1)
    XCTAssertEqual(cache.___pop(2),2) // 3 1
    XCTAssertEqual(cache._rankHighest, 3)
    XCTAssertEqual(cache._rankLowest, 1)
    XCTAssertEqual(cache.___pop(1),1) // 3
    XCTAssertEqual(cache._rankHighest, 3)
    XCTAssertEqual(cache._rankLowest, 3)
    XCTAssertEqual(cache.___pop(3),3) //
    XCTAssertEqual(cache._rankHighest, -1)
    XCTAssertEqual(cache._rankLowest, -1)
  }

  func testQueue4() throws {
    var cache = ___LRUMemoizeStorage<TestKey, Int>(minimumCapacity: 10)
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
    XCTAssertEqual(cache._rankHighest, 0)
    XCTAssertEqual(cache._rankLowest, 1)
    cache.___prepend(cache.___pop(2)) // 2 0 3 1
    XCTAssertEqual(cache._rankHighest, 2)
    XCTAssertEqual(cache._rankLowest, 1)
    XCTAssertEqual(cache.___popRankLowest(), 1)
    XCTAssertEqual(cache._rankHighest, 2)
    XCTAssertEqual(cache._rankLowest, 3)
    XCTAssertEqual(cache.___popRankLowest(), 3)
    XCTAssertEqual(cache._rankHighest, 2)
    XCTAssertEqual(cache._rankLowest, 0)
    XCTAssertEqual(cache.___popRankLowest(), 0)
    XCTAssertEqual(cache._rankHighest, 2)
    XCTAssertEqual(cache._rankLowest, 2)
    XCTAssertEqual(cache.___popRankLowest(), 2)
    XCTAssertEqual(cache._rankHighest, -1)
    XCTAssertEqual(cache._rankLowest, -1)
  }

  func testMaximum() throws {
    var cache = ___LRUMemoizeStorage<TestKey, Int>(minimumCapacity: 0, maxCount: 100)
    XCTAssertEqual(cache.__tree_.count, 0)
    XCTAssertEqual(cache.__tree_.capacity, 0)
    var finalCapacity: Int? = nil
    for i in 0..<200 {
      cache[i] = i
      if finalCapacity == nil, cache.__tree_.capacity >= 100 {
        finalCapacity = cache.__tree_.capacity
      }
      if let finalCapacity {
        // 最終的に定まったキャパシティが変化しない
        XCTAssertEqual(cache.__tree_.capacity, finalCapacity, "\(i)")
      }
    }
  }

  func testMaximum2() throws {
    var cache = ___LRUMemoizeStorage<TestKey, Int>(minimumCapacity: 0, maxCount: 5)
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
    XCTAssertEqual(cache._rankLowest, 1)
    var i = 5
    while cache.count < cache.capacity {
      cache[i] = i
      i += 1
      XCTAssertEqual(cache[0], 0)
      XCTAssertEqual(cache._rankLowest, 1)
    }
    XCTAssertEqual(cache._rankLowest, 1)
    cache[i] = i
    XCTAssertNil(cache[1]) // 1番古いモノが消える
    XCTAssertEqual(cache[0], 0) // 頻繁に触っているので消えない
    XCTAssertEqual(cache[i], i) // 新しいモノが登録されている
    i += 1
    XCTAssertEqual(cache._rankLowest, 2)
    cache[i] = i
    XCTAssertNil(cache[1]) // 1番古いモノはすでに消えている
    XCTAssertNil(cache[2]) // 2番目に古いモノが消える
    XCTAssertEqual(cache[0], 0) // 頻繁に触っているので消えない
    XCTAssertEqual(cache[i], i) // 新しいモノが登録されている
    i += 1
  }
#endif

  func testCopyOnWrite() throws {
#if AC_COLLECTIONS_INTERNAL_CHECKS
    var cache0 = ___LRUMemoizeStorage<TestKey, Int>(minimumCapacity: 2)
    XCTAssertEqual(cache0._copyCount, 0)
    let cache1 = cache0
    XCTAssertEqual(cache0._copyCount, 0)
    cache0[0] = 0
    XCTAssertEqual(cache0._copyCount, 0) // キャパシティ変化以外でコピーが発生しない
    _fixLifetime(cache1)
#endif
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
