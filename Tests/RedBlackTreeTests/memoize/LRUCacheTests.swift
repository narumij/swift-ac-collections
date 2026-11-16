#if ENABLE_EXPERIMENTAL_LRU
  import RedBlackTreeCollections
  import XCTest

  // RBT-114: ノンコピーのLRU
  final class LRUCacheTests: XCTestCase {

    func testGetAndSet() {
      var cache = LRUCache<Int, String>()
      XCTAssertNil(cache[1])
      cache[1] = "a"
      cache[2] = "b"
      XCTAssertEqual(cache[1], "a")
      XCTAssertEqual(cache[2], "b")
      XCTAssertEqual(cache.count, 2)
    }

    func testEvictsLeastRecentlyUsed() {
      var cache = LRUCache<Int, Int>(maxCount: 2)
      cache[1] = 10
      cache[2] = 20
      _ = cache[1]  // 2が最も古くなる
      cache[3] = 30
      XCTAssertEqual(cache.count, 2)
      XCTAssertEqual(cache[1], 10)
      XCTAssertNil(cache[2])
      XCTAssertEqual(cache[3], 30)
    }

    func testMaxCount() {
      let cache = LRUCache<Int, Int>(maxCount: 3)
      XCTAssertEqual(cache.maxCount, 3)
    }

    func testRemoveAllKeepingCapacity() {
      var cache = LRUCache<Int, Int>(maxCount: 2)
      for round in 0..<5 {
        cache[round * 10] = round
        cache[round * 10 + 1] = round
        cache[round * 10 + 2] = round
        XCTAssertEqual(cache.count, 2)
        cache.removeAll(keepingCapacity: true)
        XCTAssertEqual(cache.count, 0)
      }
    }

    func testRemoveAll() {
      var cache = LRUCache<Int, Int>(maxCount: 2)
      cache[1] = 1
      cache.removeAll()
      XCTAssertEqual(cache.count, 0)
      XCTAssertNil(cache[1])
      XCTAssertEqual(cache.maxCount, 2)
    }

    func testPassedInout() {
      func fill(_ cache: inout LRUCache<Int, Int>) {
        for i in 0..<10 { cache[i] = i * i }
      }
      var cache = LRUCache<Int, Int>(maxCount: 4)
      fill(&cache)
      XCTAssertEqual(cache.count, 4)
      XCTAssertEqual(cache[9], 81)
      XCTAssertNil(cache[5])
    }

    func testStoredInClass() {
      final class Holder {
        var cache = LRUCache<Int, Int>(maxCount: 2)
      }
      let holder = Holder()
      holder.cache[1] = 1
      holder.cache[2] = 2
      holder.cache[3] = 3
      XCTAssertEqual(holder.cache.count, 2)
      XCTAssertNil(holder.cache[1])
    }
  }
#endif
