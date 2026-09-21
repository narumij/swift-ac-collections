import RedBlackTreeCollections
import XCTest

final class Performaces: RedBlackTreeTestCase {

  #if ENABLE_PERFORMANCE_TESTING
    func testPerformanceExample00() throws {
      self.measure {
        let _ = Set<Int>(0..<10_000_000)
      }
    }

    func testPerformanceExample05() throws {
      self.measure {
        var set = Set<Int>(0..<10_000_000)
        for v in 0..<10_000_000 {
          set.remove(v)
        }
      }
    }

    func testPerformanceExample0() throws {
      self.measure {
        let _ = RedBlackTreeSet<Int>(0..<10_000_000)
      }
    }

    func testPerformanceExample1() throws {
      let set = RedBlackTreeSet<Int>(0..<10_000_000)
      self.measure {
        XCTAssertNotEqual(set[set.startIndex..<set.endIndex] + [], [])
      }
    }

    func testPerformanceExample2() throws {
      let set = RedBlackTreeSet<Int>(0..<10_000_000)
      self.measure {
        XCTAssertNotEqual(
          set[set.lowerBound(10_000_000 / 4)..<set.upperBound(10_000_000 / 4 * 3)] + [], [])
      }
    }

    #if !COMPATIBLE_ATCODER_2025
    func testPerformanceExample3() throws {
      self.measure {
        var set = RedBlackTreeSet<Int>(0..<10_000_000)
        #if COMPATIBLE_ATCODER_2025
          set.removeSubrange(set.startIndex..<set.endIndex)
        #else
          set.erase(set.startIndex..<set.endIndex)
        #endif
      }
    }
    #endif


    func testPerformanceExample5() throws {
      self.measure {
        var set = RedBlackTreeSet<Int>(0..<10_000_000)
        for v in 0..<10_000_000 {
          set.remove(v)
        }
      }
    }

    func testPerformanceExample6() throws {
      let set1 = RedBlackTreeSet<Int>(0..<10_000_000)
      let set2 = RedBlackTreeSet<Int>(0..<10_000_000)
      self.measure {
        _ = set1 == set2
      }
    }


    func testPerformanceExample8() throws {
      let set = RedBlackTreeSet<Int>(0..<10_000_000)
      self.measure {
        _ = set.first { $0 > 10_000_000 }
      }
    }

    func testPerformanceExample9() throws {
      self.measure {
        var xy: RedBlackTreeDictionary<Int, RedBlackTreeSet<Int>> = [1: .init(0..<2_000_000)]
        for i in 0..<2_000_000 {
          xy[1]?.remove(i)
        }
      }
    }

    func testPerformanceExample10() throws {
      var xy: [Int: [Int]] = [1: (0..<2_000_000) + []]
      self.measure {
        for i in 0..<2_000_000 {
          _ = xy[1]?[i] = 100
          _ = 1 + (xy[1]?[i / 2] ?? 0)
        }
      }
    }

    func testPerformanceExample11() throws {
      var xy: [Int: [Int]] = [1: (0..<2_000_000) + []]
      self.measure {
        for i in 0..<2_000_000 {
          _ = xy[1]?[i] = 100
          _ = xy[1]?.withUnsafeBufferPointer { xy in
            1 + xy.baseAddress![i / 2]
          }
        }
      }
    }

    func testPerformanceExample12() throws {
      let set = RedBlackTreeSet<Int>(0..<10_000_000)
      self.measure {
        // func 0.125 sec
        // SequenceIterator 0.145 sec
        // IndexingIterator 0.152 sec
        XCTAssertNotEqual(set.map { $0 + 1 }, [])
      }
    }
  #endif

  #if false
    #if ENABLE_PERFORMANCE_TESTING
    func testPerformanceCopy1() throws {
      let set = RedBlackTreeSet<Int>(0..<1)
      var a = set._storage
      //    self.measure {
      for _ in 0..<1_000_000 {
        a = a.copy()
      }
      //    }
      print("a.capacity", a.capacity)
    }
    #endif

    #if ENABLE_PERFORMANCE_TESTING
    func testPerformanceCopy32() throws {
      let set = RedBlackTreeSet<Int>(0..<24)
      var a = set._storage
      //    self.measure {
      for _ in 0..<1_000_000 {
        a = a.copy()
      }
      //    }
      print("a.capacity", a.capacity)
    }
    #endif

    #if ENABLE_PERFORMANCE_TESTING
    func testPerformanceCopy64() throws {
      let set = RedBlackTreeSet<Int>(0..<64)
      var a = set._storage
      //    self.measure {
      for _ in 0..<1_000_000 {
        a = a.copy()
      }
      //    }
      print("a.capacity", a.capacity)
    }
    #endif

    #if ENABLE_PERFORMANCE_TESTING
    func testPerformanceCopy128() throws {
      let set = RedBlackTreeSet<Int>(0..<128)
      var a = set._storage
      //    self.measure {
      for _ in 0..<1_000_000 {
        a = a.copy()
      }
      //    }
      print("a.capacity", a.capacity)
    }
    #endif

    #if ENABLE_PERFORMANCE_TESTING
    func testPerformanceCopy256() throws {
      let set = RedBlackTreeSet<Int>(0..<256)
      var a = set._storage
      self.measure {
        for _ in 0..<1_000_000 {
          a = a.copy()
        }
      }
    }
    #endif
  #endif
}
