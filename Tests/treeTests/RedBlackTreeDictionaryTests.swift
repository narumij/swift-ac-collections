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
    XCTAssertEqual(map.distance(from: map.startIndex, to: map.endIndex), 0)
  }
  
  func testRedBlackTreeCapacity() throws {
    var numbers: RedBlackTreeDictionary<Int, Int> = .init(minimumCapacity: 3)
    XCTAssertGreaterThanOrEqual(numbers.capacity, 3)
    numbers.reserveCapacity(4)
    XCTAssertGreaterThanOrEqual(numbers.capacity, 4)
    XCTAssertEqual(numbers.distance(from: numbers.startIndex, to: numbers.endIndex), 0)
  }
  
  func testInitRange() throws {
    let set = RedBlackTreeDictionary<Int,[Int]>(grouping: 0..<10000, by: { $0 })
    XCTAssertFalse(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 10000)
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
    map[2, default: []] = [3,4]
    XCTAssertEqual(map[2, default: []], [3,4])
    XCTAssertEqual(map[3, default: []], [])
  }
  
  func testSubscriptDefault() throws {
    var map: RedBlackTreeDictionary<Int, [Int]> = [:]
    _ = map[1, default: []]
    XCTAssertEqual(map[1], nil)
    map[1, default: []].append(1)
    XCTAssertEqual(map[1], [1])
    map[1, default: []].append(2)
    XCTAssertEqual(map[1], [1,2])
    map[2, default: []] = [3,4]
    XCTAssertEqual(map[2, default: []], [3,4])
    XCTAssertEqual(map[3, default: []], [])
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

  func testUpdate_() throws {
    var dict = [1:1,2:2,3:3]
    XCTAssertEqual(dict.updateValue(0, forKey: 0), nil)
    XCTAssertEqual(dict[1], 1)
    XCTAssertEqual(dict.updateValue(10, forKey: 1), 1)
    XCTAssertEqual(dict[1], 10)
  }

  func testUpdate() throws {
    var dict = [1:1,2:2,3:3] as RedBlackTreeDictionary<Int,Int>
    XCTAssertEqual(dict.updateValue(0, forKey: 0), nil)
    XCTAssertEqual(dict[1], 1)
    XCTAssertEqual(dict.updateValue(10, forKey: 1), 1)
    XCTAssertEqual(dict[1], 10)
  }

  func testRemoveKey_() throws {
    var dict = [1:1,2:2,3:3]
    XCTAssertEqual(dict.removeValue(forKey: 0), nil)
    XCTAssertEqual(dict.removeValue(forKey: 1), 1)
    XCTAssertEqual(dict, [2:2,3:3])
  }

  func testRemoveKey() throws {
    var dict = [1:1,2:2,3:3] as RedBlackTreeDictionary<Int,Int>
    XCTAssertEqual(dict.removeValue(forKey: 0), nil)
    XCTAssertEqual(dict.removeValue(forKey: 1), 1)
    XCTAssertEqual(dict, [2:2,3:3])
    XCTAssertEqual(dict.first?.key, 2)
    XCTAssertEqual(dict.last?.key, 3)
  }

  func testRemove_() throws {
    var dict = [1:1,2:2,3:3]
    let i = dict.firstIndex { (k,v) in k == 1 }!
    XCTAssertEqual(dict.remove(at: i).value, 1)
  }

  func testRemove() throws {
    var dict = [1:1,2:2,3:3] as RedBlackTreeDictionary<Int,Int>
    let i = dict.firstIndex { (k,v) in k == 1 }!
    XCTAssertEqual(dict.remove(at: i).value, 1)
  }

  func testRemoveAll_() throws {
    var dict = [1:1,2:2,3:3]
    dict.removeAll(keepingCapacity: true)
    XCTAssertTrue(dict.map { $0 }.isEmpty)
    XCTAssertGreaterThanOrEqual(dict.capacity, 3)
    dict.removeAll(keepingCapacity: false)
    XCTAssertTrue(dict.map { $0 }.isEmpty)
    XCTAssertGreaterThanOrEqual(dict.capacity, 0)
    XCTAssertNil(dict.first)
  }

  func testRemoveAll() throws {
    var dict = [1:1,2:2,3:3] as RedBlackTreeDictionary<Int,Int>
    dict.removeAll(keepingCapacity: true)
    XCTAssertTrue(dict.map { $0 }.isEmpty)
    XCTAssertGreaterThanOrEqual(dict.capacity, 3)
    dict.removeAll(keepingCapacity: false)
    XCTAssertTrue(dict.map { $0 }.isEmpty)
    XCTAssertGreaterThanOrEqual(dict.capacity, 0)
    XCTAssertNil(dict.first)
    XCTAssertNil(dict.last)
  }
  
  func testBound() throws {
    let dict = [1:10,3:30,5:50] as RedBlackTreeDictionary<Int,Int>
    XCTAssertEqual(dict.lowerBound(2), dict.index(after: dict.startIndex))
    XCTAssertEqual(dict.lowerBound(3), dict.index(after: dict.startIndex))
    XCTAssertEqual(dict.upperBound(2), dict.index(after: dict.startIndex))
    XCTAssertEqual(dict.upperBound(3), dict.index(dict.startIndex, offsetBy: 2))
  }

  func testArrayAccess1() throws {
    let set = [0:0, 1:10, 2:20, 3:30, 4:40] as RedBlackTreeDictionary<Int,Int>
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 0)].key, 0)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 1)].key, 1)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 2)].key, 2)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 3)].key, 3)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 4)].key, 4)
  }

  func testArrayAccess2() throws {
    let set = [0:0, 1:10, 2:20, 3:30, 4:40] as RedBlackTreeDictionary<Int,Int>
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -5)].key, 0)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -4)].key, 1)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -3)].key, 2)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -2)].key, 3)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -1)].key, 4)
  }

  func testIndexLimit1() throws {
    let set = [0:0, 1:10, 2:20, 3:30, 4:40] as RedBlackTreeDictionary<Int,Int>
    XCTAssertNotEqual(
      set.index(set.startIndex, offsetBy: 4, limitedBy: set.index(set.startIndex, offsetBy: 4)),
      nil)
    XCTAssertEqual(
      set.index(set.startIndex, offsetBy: 5, limitedBy: set.index(set.startIndex, offsetBy: 4)),
      nil)
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 5, limitedBy: set.endIndex), set.endIndex)
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
    XCTAssertEqual(set.index(set.endIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
    //      XCTAssertEqual(set.index(set.endIndex, offsetBy: -6, limitedBy: set.startIndex), nil)
  }

  func testIndexLimit2() throws {
    let set = [0:0, 1:10, 2:20, 3:30, 4:40] as RedBlackTreeDictionary<Int,Int>
    XCTAssertNotEqual(set.index(set.startIndex, offsetBy: 4, limitedBy: set.index(set.startIndex, offsetBy: 4)), nil)
    XCTAssertEqual(
      set.index(set.startIndex, offsetBy: 5, limitedBy: set.index(set.startIndex, offsetBy: 4)),
      nil)
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 5, limitedBy: set.endIndex), set.endIndex)
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
    XCTAssertEqual(set.index(set.endIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
  }

  func testIndexLimit3() throws {
    let set = [0:0, 1:10, 2:20, 3:30, 4:40] as RedBlackTreeDictionary<Int,Int>
    XCTAssertEqual(set.startIndex, .node(0))
    XCTAssertEqual(set.index(before: set.endIndex), .node(4))
    XCTAssertEqual(set.index(set.endIndex, offsetBy: -1), .node(4))
    XCTAssertEqual(set.index(set.endIndex, offsetBy: -1, limitedBy: set.startIndex), .node(4))
    XCTAssertEqual(set.index(set.endIndex, offsetBy: -5), .node(0))
    XCTAssertEqual(set.index(set.endIndex, offsetBy: -5), set.startIndex)
    XCTAssertNotEqual(
      set.index(set.endIndex, offsetBy: -4, limitedBy: set.index(set.endIndex, offsetBy: -4)),
      nil)
    XCTAssertEqual(
      set.index(set.endIndex, offsetBy: -5, limitedBy: set.index(set.endIndex, offsetBy: -4)),
      nil)
    XCTAssertEqual(
      set.index(set.endIndex, offsetBy: -5, limitedBy: set.startIndex),
      set.startIndex)
    XCTAssertEqual(
      set.index(set.endIndex, offsetBy: -6, limitedBy: set.startIndex),
      nil)
    XCTAssertEqual(
      set.index(set.startIndex, offsetBy: -6, limitedBy: set.startIndex),
      nil)
  }
  
  func testEqualtable() throws {
    XCTAssertEqual(RedBlackTreeDictionary<Int,Int>(), [:])
    XCTAssertNotEqual(RedBlackTreeDictionary<Int,Int>(), [1:1])
    XCTAssertEqual([1:1] as RedBlackTreeDictionary<Int,Int>, [1:1])
    XCTAssertNotEqual([1:1,2:2] as RedBlackTreeDictionary<Int,Int>, [1:1])
    XCTAssertNotEqual([2:2,3:3] as RedBlackTreeDictionary<Int,Int>, [1:1,2:2])
  }
  
  func testFirstLast() throws {
    let dict = [1:11,2:22,3:33] as RedBlackTreeDictionary<Int,Int>
    XCTAssertEqual(dict.first?.key, 1)
    XCTAssertEqual(dict.first?.value, 11)
    XCTAssertEqual(dict.last?.key, 3)
    XCTAssertEqual(dict.last?.value, 33)
    XCTAssertEqual(dict.first(where: { $0.value == 22})?.key, 2)
    XCTAssertEqual(dict.firstIndex(where: { $0.value == 22}), dict.index(after: dict.startIndex))
    XCTAssertEqual(dict.first(where: { $0.value == 44})?.key, nil)
    XCTAssertEqual(dict.firstIndex(where: { $0.value == 44}), nil)
    XCTAssertTrue(dict.contains(where: { $0.value / $0.key == 11 }))
    XCTAssertTrue(dict.allSatisfy({ $0.value / $0.key == 11 }))
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
