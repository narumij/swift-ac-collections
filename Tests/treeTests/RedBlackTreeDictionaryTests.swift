//
//  RedBlackTreeMapTests.swift
//  swift-tree
//
//  Created by narumij on 2024/09/23.
//

import RedBlackTreeModule
import XCTest

final class RedBlackTreeDictionaryTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testInitEmtpy() throws {
    let map = RedBlackTreeDictionary<Int, Int>()
    XCTAssertEqual(map.count, 0)
    XCTAssertTrue(map.isEmpty)
  }

  func testUsage_1() throws {
    var map: [Int:Int] = [:]
    XCTAssertEqual(map[0], nil)
    map[0] = 0
    XCTAssertEqual(map[0], 0)
    XCTAssertEqual(map[1], nil)
    map[0] = nil
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], nil)
    map[1] = 2
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], 2)
    map[1] = nil
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], nil)
  }
  
  func testUsage_2() throws {
    var map: [Int:Int] = [:]
    XCTAssertEqual(map[0], nil)
    map[0] = 0
    XCTAssertEqual(map[0], 0)
    XCTAssertEqual(map[1], nil)
    map[1] = 2
    XCTAssertEqual(map[0], 0)
    XCTAssertEqual(map[1], 2)
    map[0] = nil
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], 2)
    map[1] = nil
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], nil)
  }

  func testUsage1() throws {
    var map = RedBlackTreeDictionary<Int, Int>()
    XCTAssertEqual(map[0], nil)
    map[0] = 0
    XCTAssertEqual(map[0], 0)
    XCTAssertEqual(map[1], nil)
    map[0] = nil
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], nil)
    map[1] = 2
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], 2)
    map[1] = nil
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], nil)
  }
  
  func testUsage2() throws {
    var map = RedBlackTreeDictionary<Int, Int>()
    XCTAssertEqual(map[0], nil)
    map[0] = 0
    XCTAssertEqual(map[0], 0)
    XCTAssertEqual(map[1], nil)
    map[1] = 2
    XCTAssertEqual(map[0], 0)
    XCTAssertEqual(map[1], 2)
    map[0] = nil
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], 2)
    map[1] = nil
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], nil)
  }

  func testLiteral() throws {
    let map: RedBlackTreeDictionary<Int, Int> = [1: 2, 3: 4, 5: 6]
    XCTAssertEqual(map[1], 2)
    XCTAssertEqual(map[3], 4)
    XCTAssertEqual(map[5], 6)
  }

  func testSubscriptDefault0() throws {
    var map: [Int: [Int]] = [:]
    _ = map[1, default: []]
    XCTAssertEqual(map[1], nil)
    map[1, default: []].append(1)
    XCTAssertEqual(map[1], [1])
    map[1, default: []].append(2)
    XCTAssertEqual(map[1], [1,2])
  }
  
  func testSubscriptDefault1() throws {
    var map: [Int: [Int]] = [:]
    map[1] = [1]
    XCTAssertEqual(map[1], [1])
    map[1]?.append(2)
    XCTAssertEqual(map[1], [1,2])
  }

  func testSubscriptDefault() throws {
    var map: RedBlackTreeDictionary<Int, [Int]> = [:]
    _ = map[1, default: []]
    XCTAssertEqual(map[1], nil)
    map[1, default: []].append(1)
    XCTAssertEqual(map[1], [1])
    map[1, default: []].append(2)
    XCTAssertEqual(map[1], [1,2])
  }
  
  func testSubscriptDefault3() throws {
    var map: RedBlackTreeDictionary<Int, [Int]> = [:]
    map[1] = [1]
    XCTAssertEqual(map[1], [1])
    map[1]?.append(2)
    XCTAssertEqual(map[1], [1,2])
    _ = map[1]?.removeFirst()
    XCTAssertEqual(map[1], [2])
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
