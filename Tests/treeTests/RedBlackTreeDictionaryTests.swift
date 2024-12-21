//
//  RedBlackTreeMapTests.swift
//  swift-tree
//
//  Created by narumij on 2024/09/23.
//

import RedBlackTreeModule
import XCTest

extension Optional where Wrapped == Int {
  mutating func hoge() {
    self = .some(1515)
  }
}

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
    map[0] = 1
    XCTAssertEqual(map[0], 1)
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
    map[1] = 3
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], 3)
  }

  func testUsage1() throws {
    // 意外と普通のユースケースでバグがあることが判明
    var map = RedBlackTreeDictionary<Int, Int>()
    XCTAssertEqual(map[0], nil)
    map[0] = 1
    XCTAssertEqual(map[0], 1)
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
    map[1] = 3
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], 3)
  }
  
  func testUsage3() throws {
    var map = RedBlackTreeDictionary<Int, Int>()
    map[0] = 0
    XCTAssertEqual(map[0], 0)
    map.remove(at: map.startIndex)
    XCTAssertEqual(map[0], nil)
    XCTAssertTrue(map.isEmpty)
    map[0] = 0
    XCTAssertEqual(map[0], 0)
    map.remove(at: map.startIndex)
    XCTAssertEqual(map[0], nil)
    XCTAssertTrue(map.isEmpty)
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
  
  func testSubscriptDefault() throws {
    var map: RedBlackTreeDictionary<Int, [Int]> = [:]
    _ = map[1, default: []]
    XCTAssertEqual(map[1], nil)
    map[1, default: []].append(1)
    XCTAssertEqual(map[1], [1])
    map[1, default: []].append(2)
    XCTAssertEqual(map[1], [1,2])
  }

  func testSubscriptDefault__1() throws {
    var map: [Int: Int] = [:]
    map[1].hoge()
    XCTAssertEqual(map[1], 1515)
    map[1] = nil
    XCTAssertEqual(map[1], nil)
  }
  
  func testSubscriptDefault__2() throws {
    var map: RedBlackTreeDictionary<Int, Int> = [:]
    map[1].hoge()
    XCTAssertEqual(map[1], 1515)
    map[1] = nil
    XCTAssertEqual(map[1], nil)
  }

  func testSubscriptDefault1() throws {
    var map: [Int: [Int]] = [:]
    map[1]?.append(1)
    XCTAssertEqual(map[1], nil)
    map[1] = [1]
    XCTAssertEqual(map[1], [1])
    map[1]?.append(2)
    XCTAssertEqual(map[1], [1,2])
  }

  func testSubscriptDefault3() throws {
    var map: RedBlackTreeDictionary<Int, [Int]> = [:]
    map[1]?.append(1)
    XCTAssertEqual(map[1], nil)
    map[1] = [1]
    XCTAssertEqual(map[1], [1])
    map[1]?.append(2)
    XCTAssertEqual(map[1], [1,2])
    _ = map[1]?.removeFirst()
    XCTAssertEqual(map[1], [2])
  }

  func testSmoke() throws {
    let b: RedBlackTreeDictionary<Int,[Int]> = [1: [1,2], 2: [2,3], 3: [3, 4]]
    print(b)
    debugPrint(b)
  }

  func testInitUniqueKeysWithValues_() throws {
    let dict = [Int:Int](uniqueKeysWithValues: [(1,10),(2,20)])
    XCTAssertEqual(dict.keys.sorted(), [1,2])
    XCTAssertEqual(dict.values.sorted(), [10,20])
    XCTAssertEqual(dict[0], nil)
    XCTAssertEqual(dict[1], 10)
    XCTAssertEqual(dict[2], 20)
    XCTAssertEqual(dict[3], nil)
  }

  func testInitUniqueKeysWithValues() throws {
    let dict = RedBlackTreeDictionary(uniqueKeysWithValues: [(1,10),(2,20)])
    XCTAssertEqual(dict.keys.sorted(), [1,2])
    XCTAssertEqual(dict.values.sorted(), [10,20])
    XCTAssertEqual(dict[0], nil)
    XCTAssertEqual(dict[1], 10)
    XCTAssertEqual(dict[2], 20)
    XCTAssertEqual(dict[3], nil)
  }

  func testInitUniquingKeysWith_() throws {
    do {
      let dict = [Int:Int]([(1,10),(1,11),(2,20),(2,22)], uniquingKeysWith: { _,b in b })
      XCTAssertEqual(dict.keys.sorted(), [1,2])
      XCTAssertEqual(dict.values.sorted(), [11,22])
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 11)
      XCTAssertEqual(dict[2], 22)
      XCTAssertEqual(dict[3], nil)
    }
    do {
      let dict = [Int:Int]([(1,10),(1,11),(2,20),(2,22)], uniquingKeysWith: { a,_ in a })
      XCTAssertEqual(dict.keys.sorted(), [1,2])
      XCTAssertEqual(dict.values.sorted(), [10,20])
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 10)
      XCTAssertEqual(dict[2], 20)
      XCTAssertEqual(dict[3], nil)
    }
  }

  func testInitUniquingKeysWith() throws {
    do {
      let dict = RedBlackTreeDictionary([(1,10),(1,11),(2,20),(2,22)], uniquingKeysWith: { _,b in b })
      XCTAssertEqual(dict.keys.sorted(), [1,2])
      XCTAssertEqual(dict.values.sorted(), [11,22])
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 11)
      XCTAssertEqual(dict[2], 22)
      XCTAssertEqual(dict[3], nil)
    }
    do {
      let dict = RedBlackTreeDictionary([(1,10),(1,11),(2,20),(2,22)], uniquingKeysWith: { a,_ in a })
      XCTAssertEqual(dict.keys.sorted(), [1,2])
      XCTAssertEqual(dict.values.sorted(), [10,20])
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 10)
      XCTAssertEqual(dict[2], 20)
      XCTAssertEqual(dict[3], nil)
    }
  }
  
  func testInitGroupingBy_() throws {
    let students = ["Kofi", "Abena", "Efua", "Kweku", "Akosua"]
    let studentsByLetter = Dictionary(grouping: students, by: { $0.first! })
    XCTAssertEqual(studentsByLetter, ["E": ["Efua"], "K": ["Kofi", "Kweku"], "A": ["Abena", "Akosua"]])
  }

  func testInitGroupingBy() throws {
    let students = ["Kofi", "Abena", "Efua", "Kweku", "Akosua"]
    let studentsByLetter = RedBlackTreeDictionary(grouping: students, by: { $0.first! })
    XCTAssertEqual(studentsByLetter, ["E": ["Efua"], "K": ["Kofi", "Kweku"], "A": ["Abena", "Akosua"]])
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
