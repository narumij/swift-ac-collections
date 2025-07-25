import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

extension Optional where Wrapped == Int {
  fileprivate mutating func hoge() {
    self = .some(1515)
  }
}

final class DictionaryTests: XCTestCase {

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
    XCTAssertNil(map.first)
    XCTAssertNil(map.last)
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
    let set = RedBlackTreeDictionary<Int, [Int]>(grouping: 0..<10000, by: { $0 })
    XCTAssertFalse(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 10000)
  }

  func testUsage_1() throws {
    var map: [Int: Int] = [:]
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
    var map: [Int: Int] = [:]
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
    //    map.updateValue(1, forKey: 0)
    XCTAssertEqual(map[0], 1)
    XCTAssertEqual(map[1], nil)
    XCTAssertTrue(zip(map.map { ($0.0, $0.1) }, [(0, 1)]).allSatisfy(==))
    map[0] = nil
    //    map.removeValue(forKey: 0)
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], nil)
    XCTAssertTrue(zip(map.map { ($0.0, $0.1) }, []).allSatisfy(==))
    map[1] = 2
    //    map.updateValue(20, forKey: 10)
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], 2)
    XCTAssertEqual(map.map(\.key), [1])
    XCTAssertEqual(map.map(\.value), [2])
    map[1] = nil
    //    map.removeValue(forKey: 10)
    XCTAssertEqual(map[0], nil)
    XCTAssertEqual(map[1], nil)
    XCTAssertEqual(map.map(\.key), [])
    XCTAssertEqual(map.map(\.value), [])
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
    XCTAssertEqual(map[1], [1, 2])
    map[2, default: []] = [3, 4]
    XCTAssertEqual(map[2, default: []], [3, 4])
    XCTAssertEqual(map[3, default: []], [])
  }

  func testSubscriptDefault() throws {
    var map: RedBlackTreeDictionary<Int, [Int]> = [:]
    _ = map[1, default: []]
    XCTAssertEqual(map[1], nil)
    map[1, default: []].append(1)
    XCTAssertEqual(map[1], [1])
    map[1, default: []].append(2)
    XCTAssertEqual(map[1], [1, 2])
    map[2, default: []] = [3, 4]
    XCTAssertEqual(map[2, default: []], [3, 4])
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
    XCTAssertEqual(map[1], [1, 2])
  }

  func testSubscriptDefault3() throws {
    var map: RedBlackTreeDictionary<Int, [Int]> = [:]
    map[1]?.append(1)
    XCTAssertEqual(map[1], nil)
    map[1] = [1]
    XCTAssertEqual(map[1], [1])
    map[1]?.append(2)
    XCTAssertEqual(map[1], [1, 2])
    _ = map[1]?.removeFirst()
    XCTAssertEqual(map[1], [2])
  }

  func testSmoke() throws {
    let b: RedBlackTreeDictionary<Int, [Int]> = [1: [1, 2], 2: [2, 3], 3: [3, 4]]
    print(b)
    debugPrint(b)
  }

  func testInitUniqueKeysWithValues_() throws {
    let dict = [Int: Int](uniqueKeysWithValues: [(1, 10), (2, 20)])
    XCTAssertEqual(dict.keys.sorted(), [1, 2])
    XCTAssertEqual(dict.values.sorted(), [10, 20])
    XCTAssertEqual(dict[0], nil)
    XCTAssertEqual(dict[1], 10)
    XCTAssertEqual(dict[2], 20)
    XCTAssertEqual(dict[3], nil)
  }

  func testInitUniqueKeysWithValues() throws {
    let dict = RedBlackTreeDictionary(uniqueKeysWithValues: [(1, 10), (2, 20)])
    XCTAssertEqual(dict.keys() + [], [1, 2])
    XCTAssertEqual(dict.values() + [], [10, 20])
    XCTAssertEqual(dict[0], nil)
    XCTAssertEqual(dict[1], 10)
    XCTAssertEqual(dict[2], 20)
    XCTAssertEqual(dict[3], nil)
  }

  func testInitUniqueKeysWithValues2() throws {
    let dict = RedBlackTreeDictionary(uniqueKeysWithValues: AnySequence([(1, 10), (2, 20)]))
    XCTAssertEqual(dict.keys() + [], [1, 2])
    XCTAssertEqual(dict.values() + [], [10, 20])
    XCTAssertEqual(dict[0], nil)
    XCTAssertEqual(dict[1], 10)
    XCTAssertEqual(dict[2], 20)
    XCTAssertEqual(dict[3], nil)
  }

  func testInitUniquingKeysWith_() throws {
    do {
      let dict = [Int: Int](
        [(1, 10), (1, 11), (2, 20), (2, 22)], uniquingKeysWith: { _, b in b })
      XCTAssertEqual(dict.keys.sorted(), [1, 2])
      XCTAssertEqual(dict.values.sorted(), [11, 22])
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 11)
      XCTAssertEqual(dict[2], 22)
      XCTAssertEqual(dict[3], nil)
    }
    do {
      let dict = [Int: Int](
        [(1, 10), (1, 11), (2, 20), (2, 22)], uniquingKeysWith: { a, _ in a })
      XCTAssertEqual(dict.keys.sorted(), [1, 2])
      XCTAssertEqual(dict.values.sorted(), [10, 20])
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 10)
      XCTAssertEqual(dict[2], 20)
      XCTAssertEqual(dict[3], nil)
    }
  }

  func testInitUniquingKeysWith() throws {
    do {
      let dict = RedBlackTreeDictionary(
        [(1, 10), (1, 11), (2, 20), (2, 22)], uniquingKeysWith: { _, b in b })
      XCTAssertEqual(dict.keys() + [], [1, 2])
      XCTAssertEqual(dict.values() + [], [11, 22])
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 11)
      XCTAssertEqual(dict[2], 22)
      XCTAssertEqual(dict[3], nil)
    }
    do {
      let dict = RedBlackTreeDictionary(
        [(1, 10), (1, 11), (2, 20), (2, 22)], uniquingKeysWith: { a, _ in a })
      XCTAssertEqual(dict.keys() + [], [1, 2])
      XCTAssertEqual(dict.values() + [], [10, 20])
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 10)
      XCTAssertEqual(dict[2], 20)
      XCTAssertEqual(dict[3], nil)
    }
  }

  func testInitUniquingKeysWith2() throws {
    do {
      let dict = RedBlackTreeDictionary(
        AnySequence([(1, 10), (1, 11), (2, 20), (2, 22)]),
        uniquingKeysWith: { _, b in b })
      XCTAssertEqual(dict.keys() + [], [1, 2])
      XCTAssertEqual(dict.values() + [], [11, 22])
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 11)
      XCTAssertEqual(dict[2], 22)
      XCTAssertEqual(dict[3], nil)
    }
    do {
      let dict = RedBlackTreeDictionary(
        AnySequence([(1, 10), (1, 11), (2, 20), (2, 22)]),
        uniquingKeysWith: { a, _ in a })
      XCTAssertEqual(dict.keys() + [], [1, 2])
      XCTAssertEqual(dict.values() + [], [10, 20])
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 10)
      XCTAssertEqual(dict[2], 20)
      XCTAssertEqual(dict[3], nil)
    }
  }

  func testInitGroupingBy_() throws {
    let students = ["Kofi", "Abena", "Efua", "Kweku", "Akosua"]
    let studentsByLetter = Dictionary(grouping: students, by: { $0.first! })
    XCTAssertEqual(
      studentsByLetter, ["E": ["Efua"], "K": ["Kofi", "Kweku"], "A": ["Abena", "Akosua"]])
  }

  func testInitGroupingBy() throws {
    let students = ["Kofi", "Abena", "Efua", "Kweku", "Akosua"]
    let studentsByLetter = RedBlackTreeDictionary(grouping: students, by: { $0.first! })
    XCTAssertEqual(
      studentsByLetter, ["E": ["Efua"], "K": ["Kofi", "Kweku"], "A": ["Abena", "Akosua"]])
  }

  func testInitGroupingBy2() throws {
    let students = AnySequence(["Kofi", "Abena", "Efua", "Kweku", "Akosua"])
    let studentsByLetter = RedBlackTreeDictionary(grouping: students, by: { $0.first! })
    XCTAssertEqual(
      studentsByLetter, ["E": ["Efua"], "K": ["Kofi", "Kweku"], "A": ["Abena", "Akosua"]])
  }

  func testUpdate_() throws {
    var dict = [1: 1, 2: 2, 3: 3]
    XCTAssertEqual(dict.updateValue(0, forKey: 0), nil)
    XCTAssertEqual(dict[1], 1)
    XCTAssertEqual(dict.updateValue(10, forKey: 1), 1)
    XCTAssertEqual(dict[1], 10)
  }

  func testUpdate() throws {
    var dict = [1: 1, 2: 2, 3: 3] as RedBlackTreeDictionary<Int, Int>
    XCTAssertEqual(dict.updateValue(0, forKey: 0), nil)
    XCTAssertEqual(dict[1], 1)
    XCTAssertEqual(dict.updateValue(10, forKey: 1), 1)
    XCTAssertEqual(dict[1], 10)
  }

  func testBound() throws {
    let dict = [1: 10, 3: 30, 5: 50] as RedBlackTreeDictionary<Int, Int>
    XCTAssertEqual(dict.lowerBound(2), dict.index(after: dict.startIndex))
    XCTAssertEqual(dict.lowerBound(3), dict.index(after: dict.startIndex))
    XCTAssertEqual(dict.upperBound(2), dict.index(after: dict.startIndex))
    XCTAssertEqual(dict.upperBound(3), dict.index(dict.startIndex, offsetBy: 2))
  }

  func testArrayAccess1() throws {
    let set = [0: 0, 1: 10, 2: 20, 3: 30, 4: 40] as RedBlackTreeDictionary<Int, Int>
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 0)].key, 0)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 1)].key, 1)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 2)].key, 2)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 3)].key, 3)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 4)].key, 4)
  }

  func testArrayAccess2() throws {
    let set = [0: 0, 1: 10, 2: 20, 3: 30, 4: 40] as RedBlackTreeDictionary<Int, Int>
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -5)].key, 0)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -4)].key, 1)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -3)].key, 2)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -2)].key, 3)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -1)].key, 4)
  }

  func testIndex() throws {
    let set = [0: 0, 1: 10, 2: 20, 3: 30, 4: 40] as RedBlackTreeDictionary<Int, Int>
    XCTAssertEqual(set.firstIndex(of: 0), set.startIndex)
    XCTAssertEqual(set.firstIndex(of: 2), set.index(set.startIndex, offsetBy: 2))
    XCTAssertEqual(set.firstIndex(of: 5), nil)
  }

  func testIndexLimit1() throws {
    let set = [0: 0, 1: 10, 2: 20, 3: 30, 4: 40] as RedBlackTreeDictionary<Int, Int>
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
    let set = [0: 0, 1: 10, 2: 20, 3: 30, 4: 40] as RedBlackTreeDictionary<Int, Int>
    XCTAssertNotEqual(
      set.index(set.startIndex, offsetBy: 4, limitedBy: set.index(set.startIndex, offsetBy: 4)),
      nil)
    XCTAssertEqual(
      set.index(set.startIndex, offsetBy: 5, limitedBy: set.index(set.startIndex, offsetBy: 4)),
      nil)
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 5, limitedBy: set.endIndex), set.endIndex)
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
    XCTAssertEqual(set.index(set.endIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
  }

  #if DEBUG
    func testIndexLimit3() throws {
      let set = [0: 0, 1: 10, 2: 20, 3: 30, 4: 40] as RedBlackTreeDictionary<Int, Int>
      XCTAssertEqual(set.startIndex.rawValue, .node(0))
      XCTAssertEqual(set.index(before: set.endIndex).rawValue, .node(4))
      XCTAssertEqual(set.index(set.endIndex, offsetBy: -1).rawValue, .node(4))
      XCTAssertEqual(
        set.index(set.endIndex, offsetBy: -1, limitedBy: set.startIndex)?.rawValue, .node(4))
      XCTAssertEqual(set.index(set.endIndex, offsetBy: -5).rawValue, .node(0))
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
  #endif

  func testEqualtable() throws {
    XCTAssertEqual(RedBlackTreeDictionary<Int, Int>(), [:])
    XCTAssertNotEqual(RedBlackTreeDictionary<Int, Int>(), [1: 1])
    XCTAssertEqual([1: 1] as RedBlackTreeDictionary<Int, Int>, [1: 1])
    XCTAssertNotEqual([1: 1, 2: 2] as RedBlackTreeDictionary<Int, Int>, [1: 1])
    XCTAssertNotEqual([2: 2, 3: 3] as RedBlackTreeDictionary<Int, Int>, [1: 1, 2: 2])
  }

  func testFirstLast() throws {
    let dict = [1: 11, 2: 22, 3: 33] as RedBlackTreeDictionary<Int, Int>
    XCTAssertEqual(dict.first?.key, 1)
    XCTAssertEqual(dict.first?.value, 11)
    XCTAssertEqual(dict.last?.key, 3)
    XCTAssertEqual(dict.last?.value, 33)
    XCTAssertEqual(dict.first(where: { $0.value == 22 })?.key, 2)
    XCTAssertEqual(dict.firstIndex(where: { $0.value == 22 }), dict.index(after: dict.startIndex))
    XCTAssertEqual(dict.first(where: { $0.value == 44 })?.key, nil)
    XCTAssertEqual(dict.firstIndex(where: { $0.value == 44 }), nil)
    XCTAssertTrue(dict.contains(where: { $0.value / $0.key == 11 }))
    XCTAssertFalse(dict.contains(where: { $0.value / $0.key == 22 }))
    XCTAssertTrue(dict.allSatisfy({ $0.value / $0.key == 11 }))
    XCTAssertFalse(dict.allSatisfy({ $0.value / $0.key == 22 }))
  }

  func testForEach() throws {
    let dict = [1: 11, 2: 22, 3: 33] as RedBlackTreeDictionary<Int, Int>
    var d: [Int: Int] = [:]
    dict.forEach { k, v in
      d[k] = v
    }
    XCTAssertEqual(d, [1: 11, 2: 22, 3: 33])
  }

  func testSubsequence() throws {
    var set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    let sub = set[2..<4]
    XCTAssertEqual(sub[set.lowerBound(2)].value, "b")
    XCTAssertEqual(sub[set.lowerBound(3)].value, "c")
    XCTAssertEqual(set.lowerBound(4), sub.endIndex)
    XCTAssertEqual(set.upperBound(3), sub.endIndex)
    XCTAssertEqual(sub.count, 2)
    XCTAssertEqual(sub.map { $0.key }, [2, 3])
    XCTAssertEqual(sub.map { $0.value }, ["b", "c"])
    set.remove(contentsOf: 2..<4)
    XCTAssertEqual(set.map { $0.key }, [1, 4, 5])
    XCTAssertEqual(set.map { $0.value }, ["a", "d", "e"])
  }

  func testSubsequence2() throws {
    var set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    let sub = set[2...4]
    XCTAssertEqual(sub[set.lowerBound(2)].value, "b")
    XCTAssertEqual(sub[set.upperBound(3)].value, "d")
    XCTAssertEqual(set.lowerBound(5), sub.endIndex)
    XCTAssertEqual(set.upperBound(4), sub.endIndex)
    XCTAssertEqual(sub.count, 3)
    XCTAssertEqual(sub.map { $0.key }, [2, 3, 4])
    XCTAssertEqual(sub.map { $0.value }, ["b", "c", "d"])
    set.remove(contentsOf: 2...4)
    XCTAssertEqual(set.map { $0.key }, [1, 5])
    XCTAssertEqual(set.map { $0.value }, ["a", "e"])
  }

  func testSubsequence3() throws {
    let set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    XCTAssertEqual(set[1...5].map { $0.key }, [1, 2, 3, 4, 5])
  }

  func testSubsequence4() throws {
    //      let set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    //      let sub = set[1..<3]
    throw XCTSkip("Fatal error: RedBlackTree index is out of range.")
    //      XCTAssertNotEqual(sub[set.startIndex..<set.endIndex].map { $0.key }, [1, 2, 3, 4, 5])
  }

  func testSubsequence5() throws {
    let set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    let sub = set[1..<3]
    XCTAssertEqual(sub[set.lowerBound(1)..<set.lowerBound(3)].map { $0.key }, [1, 2])
    XCTAssertEqual(sub[sub.startIndex..<sub.endIndex].map { $0.key }, [1, 2])
    XCTAssertEqual(sub[sub.startIndex..<sub.index(before: sub.endIndex)].map { $0.key }, [1])
  }

  func testSubsequence6() throws {
    let set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    let sub = set[set.startIndex..<set.endIndex]
    XCTAssertEqual(sub.map { $0.key }, [1, 2, 3, 4, 5])
  }

  func testSubsequence7() throws {
    var set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    let sub = set[set.startIndex..<set.endIndex]
    var a: [String] = []
    for (_, value) in sub {
      a.append(value)
    }
    XCTAssertEqual(a, ["a", "b", "c", "d", "e"])
    sub.forEach { key, value in
      set[key] = "?"
    }
    XCTAssertEqual(set.map { $0.value }, ["?", "?", "?", "?", "?"])
  }

  #if DEBUG && false
    func testEnumeratedSequence1() throws {
      let set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      var d: [String: Int] = [:]
      set.rawIndexedElements.forEach {
        d[$0.element.value] = $0.rawIndex.rawValue
      }
      XCTAssertEqual(d, ["a": 0, "b": 1, "c": 2])
    }

    func testEnumeratedSequence2() throws {
      let set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      var d: [String: Int] = [:]
      set[2...3].rawIndexedElements.forEach {
        d[$0.element.value] = $0.rawIndex.rawValue
      }
      XCTAssertEqual(d, ["b": 1, "c": 2])
    }

    func testEnumeratedSequence3() throws {
      let set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      var d: [String: Int] = [:]
      for (o, e) in set.rawIndexedElements {
        d[e.value] = o.rawValue
      }
      XCTAssertEqual(d, ["a": 0, "b": 1, "c": 2])
    }

    func testEnumeratedSequence4() throws {
      let set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      var d: [String: Int] = [:]
      for (o, e) in set[2...3].rawIndexedElements {
        d[e.value] = o.rawValue
      }
      XCTAssertEqual(d, ["b": 1, "c": 2])
    }
  #endif

  func testIndex0() throws {
    let set: RedBlackTreeDictionary<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50]
    var i = set.startIndex
    for _ in 0..<set.count {
      XCTAssertEqual(set.distance(from: i, to: set.index(after: i)), 1)
      i = set.index(after: i)
    }
    XCTAssertEqual(i, set.endIndex)
    for _ in 0..<set.count {
      XCTAssertEqual(set.distance(from: i, to: set.index(before: i)), -1)
      i = set.index(before: i)
    }
    XCTAssertEqual(i, set.startIndex)
    for _ in 0..<set.count {
      XCTAssertEqual(set.distance(from: set.index(after: i), to: i), -1)
      i = set.index(after: i)
    }
    XCTAssertEqual(i, set.endIndex)
    for _ in 0..<set.count {
      XCTAssertEqual(set.distance(from: set.index(before: i), to: i), 1)
      i = set.index(before: i)
    }
  }

  func testIndex00() throws {
    let set: RedBlackTreeDictionary<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50]
    do {
      var i = set.startIndex
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: set.startIndex, to: i), j)
        i = set.index(after: i)
      }
      XCTAssertEqual(i, set.endIndex)
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: set.endIndex, to: i), -j)
        i = set.index(before: i)
      }
      XCTAssertEqual(i, set.startIndex)
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: i, to: set.startIndex), -j)
        set.formIndex(after: &i)
      }
      XCTAssertEqual(i, set.endIndex)
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: i, to: set.endIndex), j)
        set.formIndex(before: &i)
      }
      XCTAssertEqual(i, set.startIndex)
    }
    let sub = set[2..<5]
    do {
      var i = sub.startIndex
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: sub.startIndex, to: i), j)
        i = sub.index(after: i)
      }
      XCTAssertEqual(i, sub.endIndex)
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: sub.endIndex, to: i), -j)
        i = sub.index(before: i)
      }
      XCTAssertEqual(i, sub.startIndex)
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: i, to: sub.startIndex), -j)
        sub.formIndex(after: &i)
      }
      XCTAssertEqual(i, sub.endIndex)
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: i, to: sub.endIndex), j)
        sub.formIndex(before: &i)
      }
      XCTAssertEqual(i, sub.startIndex)
    }
  }

  func testIndex000() throws {
    let set: RedBlackTreeDictionary<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50]
    do {
      var i = set.startIndex
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: set.startIndex, to: i), j)
        set.formIndex(after: &i)
      }
      XCTAssertEqual(i, set.endIndex)
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: set.endIndex, to: i), -j)
        set.formIndex(before: &i)
      }
      XCTAssertEqual(i, set.startIndex)
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: i, to: set.startIndex), -j)
        set.formIndex(after: &i)
      }
      XCTAssertEqual(i, set.endIndex)
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: i, to: set.endIndex), j)
        set.formIndex(before: &i)
      }
      XCTAssertEqual(i, set.startIndex)
    }
    let sub = set[2..<5]
    do {
      var i = sub.startIndex
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: sub.startIndex, to: i), j)
        sub.formIndex(after: &i)
      }
      XCTAssertEqual(i, sub.endIndex)
      for j in 0..<sub.count {
        XCTAssertEqual(set.distance(from: sub.endIndex, to: i), -j)
        set.formIndex(before: &i)
      }
      XCTAssertEqual(i, sub.startIndex)
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: i, to: sub.startIndex), -j)
        set.formIndex(after: &i)
      }
      XCTAssertEqual(i, sub.endIndex)
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: i, to: sub.endIndex), j)
        set.formIndex(before: &i)
      }
      XCTAssertEqual(i, sub.startIndex)
    }
  }

  func testIndex100() throws {
    let set: RedBlackTreeDictionary<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50, 6: 60]
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 6), set.endIndex)
    XCTAssertEqual(set.index(set.endIndex, offsetBy: -6), set.startIndex)
    let sub = set[2..<5]
    XCTAssertEqual(sub.map { $0.key }, [2, 3, 4])
    XCTAssertEqual(sub.index(sub.startIndex, offsetBy: 3), sub.endIndex)
    XCTAssertEqual(sub.index(sub.endIndex, offsetBy: -3), sub.startIndex)
  }

  func testIndex10() throws {
    let set: RedBlackTreeDictionary<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50, 6: 60]
    XCTAssertNotNil(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex))
    XCTAssertNil(set.index(set.startIndex, offsetBy: 7, limitedBy: set.endIndex))
    XCTAssertNotNil(set.index(set.endIndex, offsetBy: -6, limitedBy: set.startIndex))
    XCTAssertNil(set.index(set.endIndex, offsetBy: -7, limitedBy: set.startIndex))
    let sub = set[2..<5]
    XCTAssertEqual(sub.map { $0.key }, [2, 3, 4])
    XCTAssertNotNil(sub.index(sub.startIndex, offsetBy: 3, limitedBy: sub.endIndex))
    XCTAssertNil(sub.index(sub.startIndex, offsetBy: 4, limitedBy: sub.endIndex))
    XCTAssertNotNil(sub.index(sub.endIndex, offsetBy: -3, limitedBy: sub.startIndex))
    XCTAssertNil(sub.index(sub.endIndex, offsetBy: -4, limitedBy: sub.startIndex))
  }

  func testIndex11() throws {
    let set: RedBlackTreeDictionary<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50, 6: 60]
    var i = set.startIndex
    XCTAssertTrue(set.formIndex(&i, offsetBy: 6, limitedBy: set.endIndex))
    i = set.startIndex
    XCTAssertFalse(set.formIndex(&i, offsetBy: 7, limitedBy: set.endIndex))
    i = set.endIndex
    XCTAssertTrue(set.formIndex(&i, offsetBy: -6, limitedBy: set.startIndex))
    i = set.endIndex
    XCTAssertFalse(set.formIndex(&i, offsetBy: -7, limitedBy: set.startIndex))
    let sub = set[2..<5]
    XCTAssertEqual(sub.map { $0.key }, [2, 3, 4])
    i = sub.startIndex
    XCTAssertTrue(sub.formIndex(&i, offsetBy: 3, limitedBy: sub.endIndex))
    i = sub.startIndex
    XCTAssertFalse(sub.formIndex(&i, offsetBy: 4, limitedBy: sub.endIndex))
    i = sub.endIndex
    XCTAssertTrue(sub.formIndex(&i, offsetBy: -3, limitedBy: sub.startIndex))
    i = sub.endIndex
    XCTAssertFalse(sub.formIndex(&i, offsetBy: -4, limitedBy: sub.startIndex))
  }

  func testIndex12() throws {
    let set: RedBlackTreeDictionary<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50, 6: 60]
    var i = set.startIndex
    set.formIndex(&i, offsetBy: 6)
    XCTAssertEqual(i, set.endIndex)
    i = set.endIndex
    set.formIndex(&i, offsetBy: -6)
    XCTAssertEqual(i, set.startIndex)
    let sub = set[2..<5]
    XCTAssertEqual(sub.map { $0.key }, [2, 3, 4])
    i = sub.startIndex
    sub.formIndex(&i, offsetBy: 3)
    XCTAssertEqual(i, sub.endIndex)
    i = sub.endIndex
    sub.formIndex(&i, offsetBy: -3)
    XCTAssertEqual(i, sub.startIndex)
  }

  func testIndexValidation() throws {
    let set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    XCTAssertTrue(set.isValid(index: set.startIndex))
    XCTAssertFalse(set.isValid(index: set.endIndex)) // 仕様変更。subscriptやremoveにつかえないので
    typealias Index = RedBlackTreeDictionary<Int, String>.Index
    #if DEBUG
      XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawValue: -1).rawValue, -1)
      XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawValue: 5).rawValue, 5)

      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: .nullptr)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 0)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 1)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 2)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 3)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 4)))
      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 5)))
    #endif
  }

  func testIndexValidation2() throws {
    let _set: RedBlackTreeDictionary<Int, String> = [
      1: "a", 2: "b", 3: "c", 4: "d", 5: "e", 6: "f", 7: "g",
    ]
    let set = _set[2..<6]
    XCTAssertTrue(set.isValid(index: set.startIndex))
    XCTAssertTrue(set.isValid(index: set.endIndex))
    typealias Index = RedBlackTreeDictionary<Int, String>.Index
    #if DEBUG
      XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawValue: -1).rawValue, -1)
      XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawValue: 5).rawValue, 5)

      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: .nullptr)))
      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 0)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 1)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 2)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 3)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 4)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 5)))
      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 6)))
      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 7)))
    #endif
  }

  func testContainsKey() {
    let dict: RedBlackTreeDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]
    XCTAssertTrue(dict.contains(key: "a"))
    XCTAssertTrue(dict.contains(key: "b"))
    XCTAssertFalse(dict.contains(key: "d"))
  }

  func testMinAndMax() {
    var dict: RedBlackTreeDictionary<String, Int> = [:]
    XCTAssertNil(dict.min())
    XCTAssertNil(dict.max())

    dict["b"] = 2
    dict["a"] = 1
    dict["c"] = 3

    let minPair = dict.min()
    XCTAssertEqual(minPair?.key, "a")
    XCTAssertEqual(minPair?.value, 1)

    let maxPair = dict.max()
    XCTAssertEqual(maxPair?.key, "c")
    XCTAssertEqual(maxPair?.value, 3)
  }

  func testPopFirst() {
    do {
      var d = RedBlackTreeDictionary<Int, Int>()
      XCTAssertNil(d.popFirst())
    }
    do {
      var d: RedBlackTreeDictionary<Int, Int> = [1: 1]
      XCTAssertEqual(d.popFirst()?.value, 1)
    }
  }
  
  func testEqual1() throws {
    do {
      let a = RedBlackTreeDictionary<Int,Int>()
      let b = RedBlackTreeDictionary<Int,Int>()
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a = RedBlackTreeDictionary<Int,Int>()
      let b: RedBlackTreeDictionary<Int,Int> = [(0,0)]
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
    do {
      let a: RedBlackTreeDictionary<Int,Int> = [(0,0)]
      let b: RedBlackTreeDictionary<Int,Int> = [(0,0)]
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a: RedBlackTreeDictionary<Int,Int> = [(0,0),(1,1)]
      let b: RedBlackTreeDictionary<Int,Int> = [(0,0)]
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
    do {
      let a: RedBlackTreeDictionary<Int,Int> = [(0,0),(1,1)]
      let b: RedBlackTreeDictionary<Int,Int> = [(0,0),(1,1)]
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
  }
  
  func testEqual2() throws {
    let aa = RedBlackTreeDictionary<Int,Int>(uniqueKeysWithValues: [0,1,2,3,4,5].map{ ($0,$0) })
    let bb = RedBlackTreeDictionary<Int,Int>(uniqueKeysWithValues: [3,4,5,6,7,8].map{ ($0,$0) })
    do {
      let a = aa[0 ..< 0]
      let b = bb[3 ..< 3]
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a = aa[3 ..< 6]
      let b = bb[3 ..< 6]
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a = aa[2 ..< 6]
      let b = bb[3 ..< 6]
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
    do {
      let a = aa[3 ..< 6]
      let b = bb[3 ..< 7]
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
  }
    
  func testCompare1() throws {
    do {
      let a: RedBlackTreeDictionary<Int,Int> = []
      let b: RedBlackTreeDictionary<Int,Int> = []
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a: RedBlackTreeDictionary<Int,Int> = []
      let b: RedBlackTreeDictionary<Int,Int> = [(0,0)]
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a: RedBlackTreeDictionary<Int,Int> = [(0,0)]
      let b: RedBlackTreeDictionary<Int,Int> = [(0,0)]
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a: RedBlackTreeDictionary<Int,Int> = [(0,0)]
      let b: RedBlackTreeDictionary<Int,Int> = [(1,1)]
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a: RedBlackTreeDictionary<Int,Int> = [(0,0),(1,1)]
      let b: RedBlackTreeDictionary<Int,Int> = [(0,0)]
      XCTAssertFalse(a < b)
      XCTAssertTrue(b < a)
    }
    do {
      let a: RedBlackTreeDictionary<Int,Int> = [(0,0),(1,1)]
      let b: RedBlackTreeDictionary<Int,Int> = [(0,0),(1,1)]
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a: RedBlackTreeDictionary<Int,Int> = [(0,0),(1,1),(2,2)]
      let b: RedBlackTreeDictionary<Int,Int> = [(0,0),(1,1),(3,3)]
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
  }
}
