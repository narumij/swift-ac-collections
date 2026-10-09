import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

final class RedBlackTreeSetPerformanceTests: RedBlackTreeTestCase {

  var random: [Int] = []
  var sequence: [Int] = []

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
    random = (0..<2_000_000).shuffled()
    sequence = (0..<2_000_000) + []
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }

  #if ENABLE_PERFORMANCE_TESTING
    func testPerformanceDistanceFromTo() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        // BidirectionalCollectionの実装の場合、0.3sec
        // 木の場合、0.08sec
        // 片方がendIndexの場合、その部分だけO(1)となるよう修正
        XCTAssertEqual(s.distance(from: s.endIndex, to: s.startIndex), -1_000_000)
      }
    }

    func testPerformanceIndexOffsetBy1() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.index(s.startIndex, offsetBy: 1_000_000), s.endIndex)
      }
    }

    func testPerformanceIndexOffsetBy2() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.index(s.endIndex, offsetBy: -1_000_000), s.startIndex)
      }
    }

    func testPerformanceFirstIndex1() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 1_000_000 - 1), s.index(before: s.endIndex))
      }
    }

    func testPerformanceFirstIndex2() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 0), s.startIndex)
      }
    }

    func testPerformanceFirstIndex3() throws {
      let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      self.measure {
        XCTAssertEqual(s.firstIndex(of: 1_000_000), nil)
      }
    }


    func testPerformanceInit0() throws {
      self.measure {
        let _ = RedBlackTreeSet<Int>(sequence)
      }
    }

    func testPerformanceEraseFullRange() throws {
      self.measure {
        var set = RedBlackTreeSet<Int>(0..<10_000_000)
          set.erase(set.startIndex..<set.endIndex)
      }
    }

    func testPerformanceEquatable() throws {
      let set1 = RedBlackTreeSet<Int>(0..<10_000_000)
      let set2 = RedBlackTreeSet<Int>(0..<10_000_000)
      self.measure {
        _ = set1 == set2
      }
    }

    func testPerformanceFirstWhere() throws {
      let set = RedBlackTreeSet<Int>(0..<10_000_000)
      self.measure {
        _ = set.first { $0 > 10_000_000 }
      }
    }

    #if PERFOMANCE_CHECK
      func testPerformanceInit1() throws {
        self.measure {
          let _ = RedBlackTreeSet<Int>(_sequence: sequence)
        }
      }
    #endif

    #if PERFOMANCE_CHECK
      func testPerformanceInit2() throws {
        self.measure {
          // 昔は内部でソートしていたが、今はそのおせっかいをやめているので、
          // ランダムなままの場合、並びによって性能が変化する
          // GitHub Actionsのテストで性能低下を検出される場合もあるが、
          // 意図的なリグレッションなので、特に対処しない
          let _ = RedBlackTreeSet<Int>(random)
        }
      }
    #endif

    #if PERFOMANCE_CHECK
      func testPerformanceInit3() throws {
        self.measure {
          let _ = RedBlackTreeSet<Int>(_sequence: random)
        }
      }
    #endif

    func testPerformanceDistance0() throws {
      let set: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 1_000_000)
      self.measure {
        let _ = set.distance(from: set.startIndex, to: set.endIndex)
      }
    }

    func testPerformanceDistance1() throws {
      let set: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      let l = set.index(before: set.endIndex)
      let r = set.endIndex
      XCTAssertEqual(set.distance(from: l, to: r), 1)
      self.measure {
        let _ = set.distance(from: l, to: r)
      }
    }

    func testPerformanceDistance2() throws {
      let set: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      let l = set.endIndex
      let r = set.index(before: set.endIndex)
      XCTAssertEqual(set.distance(from: l, to: r), -1)
      self.measure {
        let _ = set.distance(from: l, to: r)
      }
    }

    func testPerformanceDistance3() throws {
      let set: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      let l = set.index(before: set.endIndex)
      let r = set.index(before: l)
      XCTAssertEqual(set.distance(from: l, to: r), -1)
      self.measure {
        let _ = set.distance(from: l, to: r)
      }
    }

    func testPerformanceDistance4() throws {
      let set: RedBlackTreeSet<Int> = .init(0..<1_000_000)
      let l = set.endIndex
      let r = set.endIndex
      XCTAssertEqual(set.distance(from: l, to: r), 0)
      self.measure {
        let _ = set.distance(from: l, to: r)
      }
    }



  #endif
}
