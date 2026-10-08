import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

final class RedBlackTreeDictionaryPerformanceTests: RedBlackTreeTestCase {

  var random: [Int] = []
  var sequence: [Int] = []

  override func setUpWithError() throws {
    try super.setUpWithError()
    random = (0..<2_000_000).shuffled()
    sequence = (0..<2_000_000) + []
  }

  override func tearDownWithError() throws {
    try super.tearDownWithError()
  }

  #if ENABLE_PERFORMANCE_TESTING
    func testPerformanceDistanceFromTo() throws {
      let d: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        XCTAssertEqual(d.distance(from: d.endIndex, to: d.startIndex), -1_000_000)
      }
    }

    func testPerformanceIndexOffsetBy1() throws {
      let d: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        XCTAssertEqual(d.index(d.startIndex, offsetBy: 1_000_000), d.endIndex)
      }
    }

    func testPerformanceIndexOffsetBy2() throws {
      let d: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        XCTAssertEqual(d.index(d.endIndex, offsetBy: -1_000_000), d.startIndex)
      }
    }

    func testPerformanceFirstIndex1() throws {
      let d: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        XCTAssertEqual(d.firstIndex(of: 1_000_000 - 1), d.index(before: d.endIndex))
      }
    }

    func testPerformanceFirstIndex2() throws {
      let d: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        XCTAssertEqual(d.firstIndex(of: 0), d.startIndex)
      }
    }

    func testPerformanceFirstIndex3() throws {
      let d: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        XCTAssertEqual(d.firstIndex(of: 1_000_000), nil)
      }
    }

    func testPerformanceInit0() throws {
      let pairs = sequence.map { ($0, $0) }
      self.measure {
        let _ = RedBlackTreeDictionary<Int, Int>(uniqueKeysWithValues: pairs)
      }
    }

    func testPerformanceDistance0() throws {
      let d: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      XCTAssertEqual(d.distance(from: d.startIndex, to: d.endIndex), 1_000_000)
      self.measure {
        let _ = d.distance(from: d.startIndex, to: d.endIndex)
      }
    }

    func testPerformanceDistance1() throws {
      let d: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      let l = d.index(before: d.endIndex)
      let r = d.endIndex
      XCTAssertEqual(d.distance(from: l, to: r), 1)
      self.measure {
        let _ = d.distance(from: l, to: r)
      }
    }

    func testPerformanceDistance2() throws {
      let d: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      let l = d.endIndex
      let r = d.index(before: d.endIndex)
      XCTAssertEqual(d.distance(from: l, to: r), -1)
      self.measure {
        let _ = d.distance(from: l, to: r)
      }
    }

    func testPerformanceDistance3() throws {
      let d: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      let l = d.index(before: d.endIndex)
      let r = d.index(before: l)
      XCTAssertEqual(d.distance(from: l, to: r), -1)
      self.measure {
        let _ = d.distance(from: l, to: r)
      }
    }

    func testPerformanceDistance4() throws {
      let d: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      let l = d.endIndex
      let r = d.endIndex
      XCTAssertEqual(d.distance(from: l, to: r), 0)
      self.measure {
        let _ = d.distance(from: l, to: r)
      }
    }

    func testPerformanceEraseFullRange() throws {
      self.measure {
        var d: RedBlackTreeDictionary<Int, Int> = .init(
          uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
        #if COMPATIBLE_ATCODER_2025
          d.removeSubrange(d.startIndex..<d.endIndex)
        #else
          _ = d.erase(d.startIndex..<d.endIndex)
        #endif
      }
    }

    func testPerformanceEquatable() throws {
      let d1: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      let d2: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        _ = d1 == d2
      }
    }

    func testPerformanceFirstWhere() throws {
      let d: RedBlackTreeDictionary<Int, Int> = .init(
        uniqueKeysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        _ = d.first { $0.key > 1_000_000 }
      }
    }
  #endif
}
