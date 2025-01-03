//
//  RedBlackTreePerformaces.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/12/22.
//

import RedBlackTreeModule
import XCTest

#if true
final class RedBlackTreePerformaces: XCTestCase {

  override func setUpWithError() throws {
  }

  override func tearDownWithError() throws {
  }

  func testPerformanceExample00() throws {
    throw XCTSkip()
    self.measure {
      let set = Set<Int>(0..<10_000_000)
    }
  }

  func testPerformanceExample05() throws {
    throw XCTSkip()
    var set = Set<Int>(0..<10_000_000)
    self.measure {
      for v in 0..<10_000_000 {
        set.remove(v)
      }
    }
  }

  func testPerformanceExample0() throws {
    throw XCTSkip()
    self.measure {
      let set = RedBlackTreeSet<Int>(0..<10_000_000)
    }
  }

  func testPerformanceExample1() throws {
    throw XCTSkip()
    let set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      XCTAssertNotEqual(set[set.startIndex ..< set.endIndex] + [], [])
    }
  }

  func testPerformanceExample2() throws {
    throw XCTSkip()
    let set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      XCTAssertNotEqual(
        set[set.lowerBound(10_000_000 / 4)..<set.upperBound(10_000_000 / 4 * 3)] + [], [])
    }
  }

  func testPerformanceExample3() throws {
    throw XCTSkip()
    var set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      set.removeSubrange(set.startIndex ..< set.endIndex)
    }
  }

  func testPerformanceExample4() throws {
    throw XCTSkip()
    var set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      set.enumerated()
        .forEach { i, v in
          set.remove(at: i)
        }
    }
  }
  
  func testPerformanceExample5() throws {
    throw XCTSkip()
    var set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      for v in 0..<10_000_000 {
        set.remove(v)
      }
    }
  }

  func testPerformanceExample6() throws {
    throw XCTSkip()
    var set1 = RedBlackTreeSet<Int>(0..<10_000_000)
    var set2 = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      _ = set1 == set2
    }
  }

  func testPerformanceExample7() throws {
    throw XCTSkip()
    var set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      _ = set.firstIndex { $0 > 10_000_000 }
    }
  }

  func testPerformanceExample8() throws {
    throw XCTSkip()
    var set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      _ = set.first { $0 > 10_000_000 }
    }
  }

  func testPerformanceExample9() throws {
    throw XCTSkip()
    var xy: RedBlackTreeDictionary<Int,RedBlackTreeSet<Int>> = [1: .init(0 ..< 2_000_000)]
    self.measure {
      for i in 0 ..< 2_000_000 {
        xy[1]?.remove(i)
      }
    }
  }

  func testPerformanceExample10() throws {
    throw XCTSkip()
    var xy: [Int:[Int]] = [1:(0 ..< 2_000_000) + []]
    self.measure {
      for i in 0 ..< 2_000_000 {
        _ = xy[1]?[i] = 100
        _ = 1 + (xy[1]?[i / 2] ?? 0)
      }
    }
  }
  
  func testPerformanceExample11() throws {
    throw XCTSkip()
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
    throw XCTSkip()
    let set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      // func 0.125 sec
      // SequenceIterator 0.145 sec
      // IndexingIterator 0.152 sec
      XCTAssertNotEqual(set.map{ $0 + 1 }, [])
    }
  }

}
#endif
