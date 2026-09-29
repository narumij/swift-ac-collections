import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if COMPATIBLE_ATCODER_2025
  final class PerformacesAtCoder2025LegacyTests: RedBlackTreeTestCase {
    #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceExample4() throws {
        self.measure {
          var set = RedBlackTreeSet<Int>(0..<10_000_000)
          set
            .forEach { i, v in
              set.remove(at: i)
            }
        }
      }

      func testPerformanceExample7() throws {
        let set = RedBlackTreeSet<Int>(0..<10_000_000)
        self.measure {
          _ = set.firstIndex { $0 > 10_000_000 }
        }
      }
    #endif
  }

  #if DEBUG
    extension NaiveIteratorTests {
      func testWrappedForward() throws {
        let a = RedBlackTreeSet<Int>(0..<5)
        let wrapped = UnsafeIterator._RemoveAware(
          source: UnsafeIterator._Obverse1(
            _start: a.__tree_.__begin_node_,
            _end: a.__tree_.__end_node))
        XCTAssertEqual(wrapped.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5))
      }

      func testWrappedReverse() throws {
        let a = RedBlackTreeSet<Int>(0..<5)
        let wrapped = UnsafeIterator._RemoveAware(
          source: UnsafeIterator._Reverse1(
            _start: a.__tree_.__begin_node_,
            _end: a.__tree_.__end_node))
        XCTAssertEqual(wrapped.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5).reversed())
      }
    }
  #endif

  final class ReferenceAtCoder2025LegacyTests: RedBlackTreeTestCase {

    nonisolated(unsafe) static var count: Int = 0

    class DeinitializeCounter: Comparable {
      static func < (lhs: DeinitializeCounter, rhs: DeinitializeCounter) -> Bool {
        lhs.num < rhs.num
      }
      static func == (lhs: DeinitializeCounter, rhs: DeinitializeCounter) -> Bool {
        lhs.num == rhs.num
      }
      internal init(num: Int) {
        self.num = num
        ReferenceAtCoder2025LegacyTests.count += 1
      }
      deinit {
        ReferenceAtCoder2025LegacyTests.count -= 1
      }
      var num: Int
    }

    override func setUpWithError() throws {
      try super.setUpWithError()
      Self.count = 0
    }

    override func tearDownWithError() throws {
      try super.tearDownWithError()
      Self.count = 0
    }

    /// 互換モードの.indicesを経由した1件ずつのremove(at:)でも参照が正しく解放されること
    func testExample() throws {
      var a = RedBlackTreeSet<DeinitializeCounter>((0..<3).map { DeinitializeCounter(num: $0) })
      XCTAssertEqual(Self.count, 3)
      for i in a.indices {
        a.remove(at: i)
      }
      XCTAssertEqual(Self.count, 0)
    }
  }

  #if DEBUG
    extension EtcTests {
      /// 内部の逆順走査ヘルパー___rev_for_each_が正しい順序でノードを列挙すること
      func testRev() throws {
        let a = RedBlackTreeSet<Int>([0, 1, 2])
        var result = [Int]()
        a.__tree_.___rev_for_each_(__p: a.startIndex.sealed, __l: a.endIndex.sealed) { p in
          result.append(p.index)
        }
        XCTAssertEqual(result, [2, 1, 0])
      }
    }
  #endif
#endif
