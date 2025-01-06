//
//  MemoizeCacheTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/01/06.
//

import RedBlackTreeModule
import XCTest

final class MemoizeCacheTests: XCTestCase {

#if true || ENABLE_PERFORMANCE_TESTING
  func testTak0() throws {
    XCTAssertEqual(Naive.tarai(x: 2, y: 1, z: 0), 2)
    XCTAssertEqual(Naive.tarai(x: 4, y: 2, z: 0), 4)
    XCTAssertEqual(Naive.tarai(x: 6, y: 3, z: 0), 6)
    XCTAssertEqual(Naive.tarai(x: 8, y: 4, z: 0), 8)
    XCTAssertEqual(Naive.tarai(x: 10, y: 5, z: 0), 10)
    XCTAssertEqual(Naive.tarai(x: 12, y: 6, z: 0), 12)
  }

  func testTak1() throws {
    XCTAssertEqual(Naive.tarai(x: 14, y: 7, z: 0), 14)
  }

  func testPerformanceTak0() throws {
//    let tarai = Tak()
    self.measure {
      XCTAssertEqual(Memoized.tarai(x: 14, y: 7, z: 0), 14)
    }
  }

  func testPerformanceTak1() throws {
//    let tarai = Tak()
    self.measure {
      XCTAssertEqual(Memoized.tarai(x: 20, y: 10, z: 0), 20)
    }
  }
  
  func testPerformanceTak2() throws {
//    let tarai = Tak()
    self.measure {
      XCTAssertEqual(Memoized.tarai(x: 24, y: 12, z: 0), 24)
    }
  }
#endif
}

enum Naive {
  static func tarai(x: Int, y: Int, z: Int) -> Int {
    if x <= y {
      return y
    } else {
      return tarai(
        x: tarai(x: x - 1, y: y, z: z),
        y: tarai(x: y - 1, y: z, z: x),
        z: tarai(x: z - 1, y: x, z: y))
    }
  }
}
// ↑を↓に変換するマクロがあれば、メモ化が楽になる
enum Memoized {
  
  static func tarai(x: Int, y: Int, z: Int) -> Int {
    
    typealias Arg = (x: Int, y: Int, z: Int)
    
    enum Key: CustomKeyProtocol {
      static func value_comp(_ a: Arg, _ b: Arg) -> Bool { a < b }
    }
    
    var storage: ___RedBlackTreeMapBase<Key, Int> = .init()
    
    func memoized(x: Int, y: Int, z: Int) -> Int {
      if let result = storage[(x, y, z)] {
        return result
      }
      let result = body(x: x, y: y, z: z)
      storage[(x,y,z)] = result
      return result
    }
    
    func body(x: Int, y: Int, z: Int) -> Int {
      if x <= y {
        return y
      } else {
        return tarai(
          x: memoized(x: x - 1, y: z, z: z),
          y: memoized(x: y - 1, y: z, z: x),
          z: memoized(x: z - 1, y: x, z: y))
      }
    }
    
    return memoized(x: x, y: y, z: z)
  }
}

