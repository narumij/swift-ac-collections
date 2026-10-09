import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

final class RedBlackTreeMultiMapPerformanceTests: RedBlackTreeTestCase {

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
      let m: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        XCTAssertEqual(m.distance(from: m.endIndex, to: m.startIndex), -1_000_000)
      }
    }

    func testPerformanceIndexOffsetBy1() throws {
      let m: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        XCTAssertEqual(m.index(m.startIndex, offsetBy: 1_000_000), m.endIndex)
      }
    }

    func testPerformanceIndexOffsetBy2() throws {
      let m: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        XCTAssertEqual(m.index(m.endIndex, offsetBy: -1_000_000), m.startIndex)
      }
    }

    func testPerformanceFirstIndex1() throws {
      let m: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        XCTAssertEqual(m.firstIndex(of: 1_000_000 - 1), m.index(before: m.endIndex))
      }
    }

    func testPerformanceFirstIndex2() throws {
      let m: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        XCTAssertEqual(m.firstIndex(of: 0), m.startIndex)
      }
    }

    func testPerformanceFirstIndex3() throws {
      let m: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        XCTAssertEqual(m.firstIndex(of: 1_000_000), nil)
      }
    }

    func testPerformanceInit0() throws {
      let pairs = sequence.map { ($0, $0) }
      self.measure {
        let _ = RedBlackTreeMultiMap<Int, Int>(keysWithValues: pairs)
      }
    }

    func testPerformanceDistance0() throws {
      let m: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      XCTAssertEqual(m.distance(from: m.startIndex, to: m.endIndex), 1_000_000)
      self.measure {
        let _ = m.distance(from: m.startIndex, to: m.endIndex)
      }
    }

    func testPerformanceDistance1() throws {
      let m: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      let l = m.index(before: m.endIndex)
      let r = m.endIndex
      XCTAssertEqual(m.distance(from: l, to: r), 1)
      self.measure {
        let _ = m.distance(from: l, to: r)
      }
    }

    func testPerformanceDistance2() throws {
      let m: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      let l = m.endIndex
      let r = m.index(before: m.endIndex)
      XCTAssertEqual(m.distance(from: l, to: r), -1)
      self.measure {
        let _ = m.distance(from: l, to: r)
      }
    }

    func testPerformanceDistance3() throws {
      let m: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      let l = m.index(before: m.endIndex)
      let r = m.index(before: l)
      XCTAssertEqual(m.distance(from: l, to: r), -1)
      self.measure {
        let _ = m.distance(from: l, to: r)
      }
    }

    func testPerformanceDistance4() throws {
      let m: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      let l = m.endIndex
      let r = m.endIndex
      XCTAssertEqual(m.distance(from: l, to: r), 0)
      self.measure {
        let _ = m.distance(from: l, to: r)
      }
    }

    func testPerformanceEraseFullRange() throws {
      self.measure {
        var m: RedBlackTreeMultiMap<Int, Int> = .init(
          keysWithValues: (0..<1_000_000).map { ($0, $0) })
          _ = m.erase(m.startIndex..<m.endIndex)
      }
    }

    func testPerformanceEquatable() throws {
      let m1: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      let m2: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        _ = m1 == m2
      }
    }

    func testPerformanceFirstWhere() throws {
      let m: RedBlackTreeMultiMap<Int, Int> = .init(
        keysWithValues: (0..<1_000_000).map { ($0, $0) })
      self.measure {
        _ = m.first { $0.key > 1_000_000 }
      }
    }
  #endif
}
