//
//  RedBlackTreePerformaces.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/12/22.
//

import RedBlackTreeModule
import XCTest

final class RedBlackTreePerformaces: XCTestCase {

  override func setUpWithError() throws {
  }

  override func tearDownWithError() throws {
  }

  func testPerformanceExample00() throws {
    
    self.measure {
      let set = Set<Int>(0..<10_000_000)
    }
  }

  func testPerformanceExample05() throws {
    var set = Set<Int>(0..<10_000_000)
    self.measure {
      for v in 0..<10_000_000 {
        set.remove(v)
      }
    }
  }

  func testPerformanceExample0() throws {
    
    self.measure {
      let set = RedBlackTreeSet<Int>(0..<10_000_000)
    }
  }

  func testPerformanceExample1() throws {
    let set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      XCTAssertNotEqual(set[set.startIndex..<set.endIndex], [])
    }
  }

  func testPerformanceExample2() throws {
    let set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      XCTAssertNotEqual(
        set[set.lowerBound(10_000_000 / 4)..<set.upperBound(10_000_000 / 4 * 3)], [])
    }
  }

  func testPerformanceExample3() throws {
    var set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      set.remove(from: set.startIndex, to: set.endIndex)
    }
  }

  func testPerformanceExample4() throws {
    var set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      set.enumerated()
        .forEach { i, v in
          set.remove(at: i)
        }
    }
  }
  
  func testPerformanceExample5() throws {
    var set = RedBlackTreeSet<Int>(0..<10_000_000)
    self.measure {
      for v in 0..<10_000_000 {
        set.remove(v)
      }
    }
  }

}
