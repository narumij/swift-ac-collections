import RedBlackTreeModule
import XCTest

final class Performaces: XCTestCase {

  override func setUpWithError() throws {
  }

  override func tearDownWithError() throws {
  }

#if ENABLE_PERFORMANCE_TESTING
  func testPerformanceExample00() throws {
//    throw XCTSkip()
    self.measure {
      let _ = Set<Int>(0..<10_000_000)
    }
  }

  func testPerformanceExample05() throws {
//    throw XCTSkip()
    self.measure {
      var set = Set<Int>(0..<10_000_000)
      for v in 0..<10_000_000 {
        set.remove(v)
      }
    }
  }

  func testPerformanceExample0() throws {
//    throw XCTSkip()
    self.measure {
      let _ = RedBlackTreeSet<Int>(0..<10_000_000)
    }
  }

  func testPerformanceExample1() throws {
//    throw XCTSkip()
    let set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      XCTAssertNotEqual(set[set.startIndex ..< set.endIndex] + [], [])
    }
  }

  func testPerformanceExample2() throws {
//    throw XCTSkip()
    let set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      XCTAssertNotEqual(
        set[set.lowerBound(10_000_000 / 4)..<set.upperBound(10_000_000 / 4 * 3)] + [], [])
    }
  }

  func testPerformanceExample3() throws {
//    throw XCTSkip()
    self.measure {
      var set = RedBlackTreeSet<Int>(0..<10_000_000)
      set.removeSubrange(set.startIndex ..< set.endIndex)
    }
  }

  func testPerformanceExample4() throws {
//    throw XCTSkip()
    self.measure {
      var set = RedBlackTreeSet<Int>(0..<10_000_000)
      set.rawIndexedElements
        .forEach { i, v in
          set.remove(at: i)
        }
    }
  }
  
  func testPerformanceExample5() throws {
//    throw XCTSkip()
    self.measure {
      var set = RedBlackTreeSet<Int>(0..<10_000_000)
      for v in 0..<10_000_000 {
        set.remove(v)
      }
    }
  }

  func testPerformanceExample6() throws {
//    throw XCTSkip()
    let set1 = RedBlackTreeSet<Int>(0..<10_000_000)
    let set2 = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      _ = set1 == set2
    }
  }

  func testPerformanceExample7() throws {
//    throw XCTSkip()
    let set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      _ = set.firstIndex { $0 > 10_000_000 }
    }
  }

  func testPerformanceExample8() throws {
//    throw XCTSkip()
    let set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      _ = set.first { $0 > 10_000_000 }
    }
  }

  func testPerformanceExample9() throws {
//    throw XCTSkip()
    self.measure {
      var xy: RedBlackTreeDictionary<Int,RedBlackTreeSet<Int>> = [1: .init(0 ..< 2_000_000)]
      for i in 0 ..< 2_000_000 {
        xy[1]?.remove(i)
      }
    }
  }

  func testPerformanceExample10() throws {
//    throw XCTSkip()
    var xy: [Int:[Int]] = [1:(0 ..< 2_000_000) + []]
    self.measure {
      for i in 0 ..< 2_000_000 {
        _ = xy[1]?[i] = 100
        _ = 1 + (xy[1]?[i / 2] ?? 0)
      }
    }
  }
  
  func testPerformanceExample11() throws {
//    throw XCTSkip()
    var xy: [Int:[Int]] = [1:(0 ..< 2_000_000) + []]
    self.measure {
      for i in 0 ..< 2_000_000 {
        _ = xy[1]?[i] = 100
        _ = xy[1]?.withUnsafeBufferPointer { xy in
          1 + xy.baseAddress![i / 2]
        }
      }
    }
  }

  func testPerformanceExample12() throws {
//    throw XCTSkip()
    let set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      // func 0.125 sec
      // SequenceIterator 0.145 sec
      // IndexingIterator 0.152 sec
      XCTAssertNotEqual(set.map{ $0 + 1 }, [])
    }
  }
#endif
  
#if false
  func testPerformanceCopy1() throws {
    let set = RedBlackTreeSet<Int>(0 ..< 1)
    var a = set._storage
//    self.measure {
      for _ in 0 ..< 1_000_000 {
        a = a.copy()
      }
//    }
    print("a.capacity",a.capacity)
  }

  func testPerformanceCopy32() throws {
    let set = RedBlackTreeSet<Int>(0 ..< 24)
    var a = set._storage
//    self.measure {
      for _ in 0 ..< 1_000_000 {
        a = a.copy()
      }
//    }
    print("a.capacity",a.capacity)
  }

  func testPerformanceCopy64() throws {
    let set = RedBlackTreeSet<Int>(0 ..< 64)
    var a = set._storage
//    self.measure {
      for _ in 0 ..< 1_000_000 {
        a = a.copy()
      }
//    }
    print("a.capacity",a.capacity)
  }
  
  func testPerformanceCopy128() throws {
    let set = RedBlackTreeSet<Int>(0 ..< 128)
    var a = set._storage
//    self.measure {
      for _ in 0 ..< 1_000_000 {
        a = a.copy()
      }
//    }
    print("a.capacity",a.capacity)
  }
  
  func testPerformanceCopy256() throws {
    let set = RedBlackTreeSet<Int>(0 ..< 256)
    var a = set._storage
    self.measure {
      for _ in 0 ..< 1_000_000 {
        a = a.copy()
      }
    }
  }
#endif
}
