import RedBlackTreeModule
import XCTest

final class SetPerformanceTests: XCTestCase {

  var random: [Int] = []
  var sequence: [Int] = []

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    random = (0..<2_000_000).shuffled()
    sequence = (0..<2_000_000) + []
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  #if ENABLE_PERFORMANCE_TESTING
    func testPerformanceDistanceFromTo() throws {
      throw XCTSkip()
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        // BidirectionalCollectionの実装の場合、0.3sec
        // 木の場合、0.08sec
        // 片方がendIndexの場合、その部分だけO(1)となるよう修正
        XCTAssertEqual(s.distance(from: s.endIndex, to: s.startIndex), -1_000_000)
      }
    }

    func testPerformanceIndexOffsetBy1() throws {
      throw XCTSkip()
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.index(s.startIndex, offsetBy: 1_000_000), s.endIndex)
      }
    }

    func testPerformanceIndexOffsetBy2() throws {
      throw XCTSkip()
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.index(s.endIndex, offsetBy: -1_000_000), s.startIndex)
      }
    }

    func testPerformanceFirstIndex1() throws {
      throw XCTSkip()
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 1_000_000 - 1), s.index(before: s.endIndex))
      }
    }

    func testPerformanceFirstIndex2() throws {
      throw XCTSkip()
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 0), s.startIndex)
      }
    }

    func testPerformanceFirstIndex3() throws {
      throw XCTSkip()
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 1_000_000), nil)
      }
    }

    func testPerformanceFirstIndex4() throws {
      throw XCTSkip()
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 - 1 }), s.index(before: s.endIndex))
      }
    }

    func testPerformanceFirstIndex5() throws {
      throw XCTSkip()
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(where: { $0 >= 0 }), s.startIndex)
      }
    }

    func testPerformanceFirstIndex6() throws {
      throw XCTSkip()
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 }), nil)
      }
    }

    func testPerformanceInit0() throws {
      throw XCTSkip()
      self.measure {
        let _ = RedBlackTreeSet<Int>(sequence)
      }
    }

    func testPerformanceInit1() throws {
      throw XCTSkip()
      self.measure {
        let _ = RedBlackTreeSet<Int>(_sequence: sequence)
      }
    }

    func testPerformanceInit2() throws {
      throw XCTSkip()
      self.measure {
        let _ = RedBlackTreeSet<Int>(random)
      }
    }

    func testPerformanceInit3() throws {
      throw XCTSkip()
      self.measure {
        let _ = RedBlackTreeSet<Int>(_sequence: random)
      }
    }
  #endif
}
