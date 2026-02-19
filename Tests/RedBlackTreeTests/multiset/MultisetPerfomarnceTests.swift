import RedBlackTreeModule
import XCTest

final class MultisetPerfomarnceTests: RedBlackTreeTestCase {

  #if ENABLE_PERFORMANCE_TESTING
    func testPerformanceDistanceFromTo() throws {
      let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
      self.measure {
        // BidirectionalCollectionの実装の場合、0.3sec
        // 木の場合、0.08sec
        // 片方がendIndexの場合、その部分だけO(1)となるよう修正
        XCTAssertEqual(s.distance(from: s.endIndex, to: s.startIndex), -1_000_000)
      }
    }

    func testPerformanceIndexOffsetBy1() throws {
      let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.index(s.startIndex, offsetBy: 1_000_000), s.endIndex)
      }
    }

    func testPerformanceIndexOffsetBy2() throws {
      let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.index(s.endIndex, offsetBy: -1_000_000), s.startIndex)
      }
    }

    func testPerformanceFirstIndex1() throws {
      let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 1_000_000 - 1), s.index(before: s.endIndex))
      }
    }

    func testPerformanceFirstIndex2() throws {
      let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 0), s.startIndex)
      }
    }

    func testPerformanceFirstIndex3() throws {
      let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 1_000_000), nil)
      }
    }

    #if COMPATIBLE_ATCODER_2025
      func testPerformanceFirstIndex4() throws {
        let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 - 1 }), s.index(before: s.endIndex))
        }
      }

      func testPerformanceFirstIndex5() throws {
        let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 0 }), s.startIndex)
        }
      }

      func testPerformanceFirstIndex6() throws {
        let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 }), nil)
        }
      }
    #endif
  
  #endif
}
