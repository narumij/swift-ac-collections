import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

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
  
  func testPerformanceDistance0() throws {
//    throw XCTSkip()
    let set: RedBlackTreeSet<Int> = .init(0 ..< 1_000_000)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 1_000_000)
    self.measure {
      let _ = set.distance(from: set.startIndex, to: set.endIndex)
    }
  }

  func testPerformanceDistance1() throws {
//    throw XCTSkip()
    let set: RedBlackTreeSet<Int> = .init(0 ..< 1_000_000)
    let l = set.index(before: set.endIndex)
    let r = set.endIndex
    XCTAssertEqual(set.distance(from: l, to: r), 1)
    self.measure {
      let _ = set.distance(from: l, to: r)
    }
  }

  func testPerformanceDistance2() throws {
//    throw XCTSkip()
    let set: RedBlackTreeSet<Int> = .init(0 ..< 1_000_000)
    let l = set.endIndex
    let r = set.index(before: set.endIndex)
    XCTAssertEqual(set.distance(from: l, to: r), -1)
    self.measure {
      let _ = set.distance(from: l, to: r)
    }
  }
  
  func testPerformanceDistance3() throws {
//    throw XCTSkip()
    let set: RedBlackTreeSet<Int> = .init(0 ..< 1_000_000)
    let l = set.index(before: set.endIndex)
    let r = set.index(before: l)
    XCTAssertEqual(set.distance(from: l, to: r), -1)
    self.measure {
      let _ = set.distance(from: l, to: r)
    }
  }

  func testPerformanceDistance4() throws {
//    throw XCTSkip()
    let set: RedBlackTreeSet<Int> = .init(0 ..< 1_000_000)
    let l = set.endIndex
    let r = set.endIndex
    XCTAssertEqual(set.distance(from: l, to: r), 0)
    self.measure {
      let _ = set.distance(from: l, to: r)
    }
  }

  func testPerformanceCompare0() throws {
//    throw XCTSkip()
    let set: RedBlackTreeSet<Int> = .init(0 ..< 1_000_000)
    XCTAssertTrue(set.startIndex < set.endIndex)
    XCTAssertFalse(set.startIndex == set.endIndex)
    XCTAssertFalse(set.startIndex > set.endIndex)
    self.measure {
      let _ = set.startIndex < set.endIndex
    }
  }

  func testPerformanceCompare1() throws {
//    throw XCTSkip()
    let set: RedBlackTreeSet<Int> = .init(0 ..< 1_000_000)
    let l = set.index(before: set.endIndex)
    let r = set.endIndex
    XCTAssertTrue(l < r)
    XCTAssertFalse(l == r)
    XCTAssertFalse(l > r)
    self.measure {
      let _ = l < r
    }
  }

  func testPerformanceCompare2() throws {
//    throw XCTSkip()
    let set: RedBlackTreeSet<Int> = .init(0 ..< 1_000_000)
    let l = set.endIndex
    let r = set.index(before: set.endIndex)
    XCTAssertFalse(l < r)
    XCTAssertFalse(l == r)
    XCTAssertTrue(l > r)
    self.measure {
      let _ = l < r
    }
  }
  
  func testPerformanceCompare3() throws {
//    throw XCTSkip()
    let set: RedBlackTreeSet<Int> = .init(0 ..< 1_000_000)
    let l = set.index(before: set.endIndex)
    let r = set.index(before: l)
    XCTAssertFalse(l < r)
    XCTAssertFalse(l == r)
    XCTAssertTrue(l > r)
    self.measure {
      let _ = l < r
    }
  }

  func testPerformanceCompare4() throws {
//    throw XCTSkip()
    let set: RedBlackTreeSet<Int> = .init(0 ..< 1_000_000)
    let l = set.endIndex
    let r = set.endIndex
    XCTAssertFalse(l < r)
    XCTAssertTrue(l == r)
    XCTAssertFalse(l > r)
    self.measure {
      let _ = l < r
    }
  }
  
  func testPerformanceCompare5() throws {
//    throw XCTSkip()
    let set: RedBlackTreeSet<Int> = .init(0 ..< 1_000_000)
    let r = set.index(before: set.endIndex)
    let l = set.index(before: r)
//    let l = set.index(before: set.endIndex)
//    let r = set.index(before: l)
    XCTAssertTrue(l < r)
    XCTAssertFalse(l == r)
    XCTAssertFalse(l > r)
    self.measure {
      let _ = l < r
    }
  }

#if DEBUG && false
  // <でinvalid判定する場合は以下のようにしたいが、invalid判定を削ったので、不要な仕様となった。
  func testInvalid() throws {
//    throw XCTSkip()
    var set: RedBlackTreeSet<Int> = .init(0 ..< 2)
    set.reserveCapacity(4)
    XCTAssertGreaterThanOrEqual(set.capacity, 2)
    let valid0 = RedBlackTreeSet<Int>.TreePointer(__storage: set._storage, pointer: 0)
    let valid1 = RedBlackTreeSet<Int>.TreePointer(__storage: set._storage, pointer: 1)
    let invalid2 = RedBlackTreeSet<Int>.TreePointer(__storage: set._storage, pointer: 2)
    let invalid3 = RedBlackTreeSet<Int>.TreePointer(__storage: set._storage, pointer: 3)
    XCTAssertTrue(valid0.isValid)
    XCTAssertTrue(valid1.isValid)
    XCTAssertFalse(invalid2.isValid)
    XCTAssertFalse(invalid3.isValid)
    let _ /* smoke */ = invalid2 ..< invalid3
    let _ /* smoke */ = invalid3 ..< invalid2
    let _ /* smoke */ = invalid2 ..< invalid2
    let _ /* smoke */ = invalid2 ..< valid1
    let _ /* smoke */ = valid1 ..< invalid2
    XCTAssertFalse(invalid2 < invalid3)
    XCTAssertFalse(invalid2 > invalid3)
    XCTAssertFalse(invalid2 == invalid3)
//    XCTAssertFalse(invalid2 == invalid2) // 期待と異なるが、一旦目をつむる
    XCTAssertFalse(valid1 < invalid3)
    XCTAssertFalse(valid1 > invalid3)
    XCTAssertFalse(valid1 == invalid3)
    XCTAssertFalse(valid1 == invalid2)
    XCTAssertFalse(set.endIndex < invalid2)
    XCTAssertFalse(invalid2 < set.endIndex)
  }
#endif

  #endif
}
