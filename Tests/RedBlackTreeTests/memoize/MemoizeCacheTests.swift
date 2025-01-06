//
//  MemoizeCacheTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/01/06.
//

import RedBlackTreeModule
import XCTest

final class MemoizeCacheTests: XCTestCase {

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
    let tarai = Tak()
    self.measure {
      XCTAssertEqual(tarai(x: 14, y: 7, z: 0), 14)
    }
  }

  func testPerformanceTak1() throws {
    let tarai = Tak()
    self.measure {
      XCTAssertEqual(tarai(x: 20, y: 10, z: 0), 20)
    }
  }
  
  func testPerformanceTak2() throws {
    let tarai = Tak()
    self.measure {
      XCTAssertEqual(tarai(x: 24, y: 12, z: 0), 24)
    }
  }
}

@dynamicCallable
class Tak {

  func dynamicallyCall(withArguments args: [Int]) -> Int {
    return tarai(x: args[0], y: args[1], z: args[2])
  }
  
  func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Int>) -> Int {
    return tarai(x: args[0].value, y: args[1].value, z: args[2].value)
  }

  typealias Arg = (Int, Int, Int)

  @usableFromInline
  enum Key: CustomKeyProtocol {
    @inlinable
    static func value_comp(_ a: Arg, _ b: Arg) -> Bool {
      a < b
    }
  }

  var tarai_memo: ___RedBlackTreeMapBase<Key, Int> = .init()

  func tarai(x: Int, y: Int, z: Int) -> Int {
    if let result = tarai_memo[(x, y, z)] {
      return result
    }
    let result = tarai_prime(x: x, y: y, z: z)
    tarai_memo[(x,y,z)] = result
    return result
  }

  func tarai_prime(x: Int, y: Int, z: Int) -> Int {
    if x <= y {
      return y
    } else {
      return tarai(
        x: tarai(x: x - 1, y: z, z: z),
        y: tarai(x: y - 1, y: z, z: x),
        z: tarai(x: z - 1, y: x, z: y))
    }
  }
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

