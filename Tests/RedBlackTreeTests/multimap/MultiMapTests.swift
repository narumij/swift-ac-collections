import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

func keyValue<K, V>(_ k: K, _ v: V) -> (key: K, value: V) { (k, v) }
func keyValue<K, V>(_ kv: (K, V)) -> (key: K, value: V) {
  (kv.0, kv.1)
}
func _value<K, V>(_ k: K, _ v: V) -> RedBlackTreePair<K, V> { RedBlackTreePair(k, v) }
func _value<K, V>(_ kv: (K, V)) -> RedBlackTreePair<K, V> { RedBlackTreePair(kv.0, kv.1) }

func tuple<K, V>(_ kv: (key: K, value: V)) -> (K, V) {
  (kv.key, kv.value)
}
func __key<K, V>(_ kv: (key: K, value: V)) -> K {
  kv.key
}
func __value<K, V>(_ kv: (key: K, value: V)) -> V {
  kv.value
}

func AssertEquenceEqual<A, B, C, D>(_ lhs: A, _ rhs: B)
where
  A: Sequence, B: Sequence, A.Element == (key: C, value: D), A.Element == B.Element,
  C: Equatable, D: Equatable
{
  XCTAssertTrue(lhs.elementsEqual(rhs, by: ==))
}

extension Optional where Wrapped == Int {
  fileprivate mutating func hoge() {
    self = .some(1515)
  }
}

final class MultiMapTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  typealias Target = RedBlackTreeMultiMap

  func testInitEmtpy() throws {
    let map = Target<Int, Int>()
    XCTAssertEqual(map.count, 0)
    XCTAssertTrue(map.isEmpty)
    XCTAssertNil(map.first)
    XCTAssertNil(map.last)
    XCTAssertEqual(map.distance(from: map.startIndex, to: map.endIndex), 0)
  }

  func testRedBlackTreeCapacity() throws {
    var numbers: Target<Int, Int> = .init(minimumCapacity: 3)
    XCTAssertGreaterThanOrEqual(numbers.capacity, 3)
    numbers.reserveCapacity(4)
    XCTAssertGreaterThanOrEqual(numbers.capacity, 4)
    XCTAssertEqual(numbers.distance(from: numbers.startIndex, to: numbers.endIndex), 0)
  }

  #if COMPATIBLE_ATCODER_2025
    func testUsage1() throws {
      // 意外と普通のユースケースでバグがあることが判明
      var map = Target<Int, Int>()
      XCTAssertEqual(map[0].map(\.value), [])
      map.insert((0, 1))
      //    map.updateValue(1, forKey: 0)
      XCTAssertEqual(map[0].map(\.value), [1])
      XCTAssertEqual(map[1].map(\.value), [])
      XCTAssertTrue(zip(map.map { (__key($0), __value($0)) }, [(0, 1)]).allSatisfy(==))
      map.removeAll(forKey: 0)
      //    map.removeValue(forKey: 0)
      XCTAssertEqual(map[0].map(\.value), [])
      XCTAssertEqual(map[1].map(\.value), [])
      XCTAssertTrue(zip(map.map { (__key($0), __value($0)) }, []).allSatisfy(==))
      map.insert((1, 2))
      //    map.updateValue(20, forKey: 10)
      XCTAssertEqual(map[0].map(\.value), [])
      XCTAssertEqual(map[1].map(\.value), [2])
      XCTAssertEqual(map.map(\.key), [1])
      XCTAssertEqual(map.map(\.value), [2])
      map.removeAll(forKey: 1)
      //    map.removeValue(forKey: 10)
      XCTAssertEqual(map[0].map(\.value), [])
      XCTAssertEqual(map[1].map(\.value), [])
      XCTAssertEqual(map.map(\.key), [])
      XCTAssertEqual(map.map(\.value), [])
    }
  #else
    func testUsage1() throws {
      // 意外と普通のユースケースでバグがあることが判明
      var map = Target<Int, Int>()
      XCTAssertEqual(map[0] + [], [])
      map.insert((0, 1))
      //    map.updateValue(1, forKey: 0)
      XCTAssertEqual(map[0] + [], [1])
      XCTAssertEqual(map[1] + [], [])
      XCTAssertTrue(zip(map.map { (__key($0), __value($0)) }, [(0, 1)]).allSatisfy(==))
      map.removeAll(forKey: 0)
      //    map.removeValue(forKey: 0)
      XCTAssertEqual(map[0] + [], [])
      XCTAssertEqual(map[1] + [], [])
      XCTAssertTrue(zip(map.map { (__key($0), __value($0)) }, []).allSatisfy(==))
      map.insert((1, 2))
      //    map.updateValue(20, forKey: 10)
      XCTAssertEqual(map[0] + [], [])
      XCTAssertEqual(map[1] + [], [2])
      XCTAssertEqual(map.map(\.key), [1])
      XCTAssertEqual(map.map(\.value), [2])
      map.removeAll(forKey: 1)
      //    map.removeValue(forKey: 10)
      XCTAssertEqual(map[0] + [], [])
      XCTAssertEqual(map[1] + [], [])
      XCTAssertEqual(map.map(\.key), [])
      XCTAssertEqual(map.map(\.value), [])
    }
  #endif

  #if COMPATIBLE_ATCODER_2025
    func testUsage2() throws {
      var map = Target<Int, Int>()
      XCTAssertEqual(map[0].map(\.value), [])
      map.insert((0, 0))
      XCTAssertEqual(map[0].map(\.value), [0])
      XCTAssertEqual(map[1].map(\.value), [])
      map.insert((1, 2))
      XCTAssertEqual(map[0].map(\.value), [0])
      XCTAssertEqual(map[1].map(\.value), [2])
      map.removeAll(forKey: 0)
      XCTAssertEqual(map[0].map(\.value), [])
      XCTAssertEqual(map[1].map(\.value), [2])
      map.removeAll(forKey: 1)
      XCTAssertEqual(map[0].map(\.value), [])
      XCTAssertEqual(map[1].map(\.value), [])
      map.insert((1, 3))
      XCTAssertEqual(map[0].map(\.value), [])
      XCTAssertEqual(map[1].map(\.value), [3])
    }
  #else
    func testUsage2() throws {
      var map = Target<Int, Int>()
      XCTAssertEqual(map[0] + [], [])
      map.insert((0, 0))
      XCTAssertEqual(map[0] + [], [0])
      XCTAssertEqual(map[1] + [], [])
      map.insert((1, 2))
      XCTAssertEqual(map[0] + [], [0])
      XCTAssertEqual(map[1] + [], [2])
      map.removeAll(forKey: 0)
      XCTAssertEqual(map[0] + [], [])
      XCTAssertEqual(map[1] + [], [2])
      map.removeAll(forKey: 1)
      XCTAssertEqual(map[0] + [], [])
      XCTAssertEqual(map[1] + [], [])
      map.insert((1, 3))
      XCTAssertEqual(map[0] + [], [])
      XCTAssertEqual(map[1] + [], [3])
    }
  #endif

  #if COMPATIBLE_ATCODER_2025
    func testUsage3() throws {
      var map = Target<Int, Int>()
      map.insert((0, 0))
      XCTAssertEqual(map[0].map(\.value), [0])
      map.remove(at: map.startIndex)
      XCTAssertEqual(map[0].map(\.value), [])
      XCTAssertTrue(map.isEmpty)
      map.insert((0, 0))
      XCTAssertEqual(map[0].map(\.value), [0])
      map.remove(at: map.startIndex)
      XCTAssertEqual(map[0].map(\.value), [])
      XCTAssertTrue(map.isEmpty)
    }
  #else
    func testUsage3() throws {
      var map = Target<Int, Int>()
      map.insert((0, 0))
      XCTAssertEqual(map[0] + [], [0])
      map.remove(at: map.startIndex)
      XCTAssertEqual(map[0] + [], [])
      XCTAssertTrue(map.isEmpty)
      map.insert((0, 0))
      XCTAssertEqual(map[0] + [], [0])
      map.remove(at: map.startIndex)
      XCTAssertEqual(map[0] + [], [])
      XCTAssertTrue(map.isEmpty)
    }
  #endif

  #if COMPATIBLE_ATCODER_2025
    func testLiteral() throws {
      let map: Target<Int, Int> = [1: 0, 1: 2, 3: 4, 5: 6, 5: 7]
      XCTAssertEqual(map[1].map(\.value), [0, 2])
      XCTAssertEqual(map[3].map(\.value), [4])
      XCTAssertEqual(map[5].map(\.value), [6, 7])
      XCTAssertEqual(map.count(forKey: 0), 0)
      XCTAssertEqual(map.count(forKey: 1), 2)
      XCTAssertEqual(map.count(forKey: 3), 1)
      XCTAssertEqual(map.count(forKey: 5), 2)
    }
  #else
    func testLiteral() throws {
      let map: Target<Int, Int> = [1: 0, 1: 2, 3: 4, 5: 6, 5: 7]
      XCTAssertEqual(map[1] + [], [0, 2])
      XCTAssertEqual(map[3] + [], [4])
      XCTAssertEqual(map[5] + [], [6, 7])
      XCTAssertEqual(map.count(forKey: 0), 0)
      XCTAssertEqual(map.count(forKey: 1), 2)
      XCTAssertEqual(map.count(forKey: 3), 1)
      XCTAssertEqual(map.count(forKey: 5), 2)
    }
  #endif

  func testSmoke() throws {
    let b: Target<Int, [Int]> = [1: [1, 2], 2: [2, 3], 3: [3, 4]]
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

  #if COMPATIBLE_ATCODER_2025
    func testInitUniqueKeysWithValues() throws {
      let dict = Target(multiKeysWithValues: [(1, 10), (2, 20)])
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(dict.keys() + [], [1, 2])
        XCTAssertEqual(dict.values() + [], [10, 20])
      #else
        XCTAssertEqual(dict.keys + [], [1, 2])
        XCTAssertEqual(dict.values + [], [10, 20])
      #endif
      XCTAssertEqual(dict[0].map(\.value), [])
      XCTAssertEqual(dict[1].map(\.value), [10])
      XCTAssertEqual(dict[2].map(\.value), [20])
      XCTAssertEqual(dict[3].map(\.value), [])
    }
  #else
    func testInitUniqueKeysWithValues() throws {
      let dict = Target(multiKeysWithValues: [(1, 10), (2, 20)])
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(dict.keys() + [], [1, 2])
        XCTAssertEqual(dict.values() + [], [10, 20])
      #else
        XCTAssertEqual(dict.keys + [], [1, 2])
        XCTAssertEqual(dict.values + [], [10, 20])
      #endif
      XCTAssertEqual(dict[0] + [], [])
      XCTAssertEqual(dict[1] + [], [10])
      XCTAssertEqual(dict[2] + [], [20])
      XCTAssertEqual(dict[3] + [], [])
    }
  #endif

  #if COMPATIBLE_ATCODER_2025
    func testInitUniqueKeysWithValues2() throws {
      let dict = Target(multiKeysWithValues: AnySequence([(1, 10), (2, 20)]))
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(dict.keys() + [], [1, 2])
        XCTAssertEqual(dict.values() + [], [10, 20])
      #else
        XCTAssertEqual(dict.keys + [], [1, 2])
        XCTAssertEqual(dict.values + [], [10, 20])
      #endif
      XCTAssertEqual(dict[0].map(\.value), [])
      XCTAssertEqual(dict[1].map(\.value), [10])
      XCTAssertEqual(dict[2].map(\.value), [20])
      XCTAssertEqual(dict[3].map(\.value), [])
    }
  #else
    func testInitUniqueKeysWithValues2() throws {
      let dict = Target(multiKeysWithValues: AnySequence([(1, 10), (2, 20)]))
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(dict.keys() + [], [1, 2])
        XCTAssertEqual(dict.values() + [], [10, 20])
      #else
        XCTAssertEqual(dict.keys + [], [1, 2])
        XCTAssertEqual(dict.values + [], [10, 20])
      #endif
      XCTAssertEqual(dict[0] + [], [])
      XCTAssertEqual(dict[1] + [], [10])
      XCTAssertEqual(dict[2] + [], [20])
      XCTAssertEqual(dict[3] + [], [])
    }
  #endif

  #if false
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
  #endif

  #if COMPATIBLE_ATCODER_2025
    func testInitUniquingKeysWith() throws {
      do {
        let dict = Target(
          multiKeysWithValues: [(1, 10), (1, 11), (2, 20), (2, 22)])
        #if COMPATIBLE_ATCODER_2025
          XCTAssertEqual(dict.keys() + [], [1, 1, 2, 2])
          XCTAssertEqual(dict.values() + [], [10, 11, 20, 22])
        #else
          XCTAssertEqual(dict.keys + [], [1, 1, 2, 2])
          XCTAssertEqual(dict.values + [], [10, 11, 20, 22])
        #endif
        XCTAssertEqual(dict[0].map(\.value), [])
        XCTAssertEqual(dict[1].map(\.value), [10, 11])
        XCTAssertEqual(dict[2].map(\.value), [20, 22])
        XCTAssertEqual(dict[3].map(\.value), [])
      }
    }
  #else
    func testInitUniquingKeysWith() throws {
      do {
        let dict = Target(
          multiKeysWithValues: [(1, 10), (1, 11), (2, 20), (2, 22)])
        #if COMPATIBLE_ATCODER_2025
          XCTAssertEqual(dict.keys() + [], [1, 1, 2, 2])
          XCTAssertEqual(dict.values() + [], [10, 11, 20, 22])
        #else
          XCTAssertEqual(dict.keys + [], [1, 1, 2, 2])
          XCTAssertEqual(dict.values + [], [10, 11, 20, 22])
        #endif
        XCTAssertEqual(dict[0] + [], [])
        XCTAssertEqual(dict[1] + [], [10, 11])
        XCTAssertEqual(dict[2] + [], [20, 22])
        XCTAssertEqual(dict[3] + [], [])
      }
    }
  #endif

  #if COMPATIBLE_ATCODER_2025
    func testInitNaive() throws {
      do {
        let dict = Target(
          naive: [(1, 10), (1, 11), (2, 20), (2, 22)].map { keyValue($0, $1) })
        #if COMPATIBLE_ATCODER_2025
          XCTAssertEqual(dict.keys() + [], [1, 1, 2, 2])
          XCTAssertEqual(dict.values() + [], [10, 11, 20, 22])
        #else
          XCTAssertEqual(dict.keys + [], [1, 1, 2, 2])
          XCTAssertEqual(dict.values + [], [10, 11, 20, 22])
        #endif
        XCTAssertEqual(dict[0].map(\.value), [])
        XCTAssertEqual(dict[1].map(\.value), [10, 11])
        XCTAssertEqual(dict[2].map(\.value), [20, 22])
        XCTAssertEqual(dict[3].map(\.value), [])
      }
    }
  #else
    func testInitNaive() throws {
      do {
        let dict = Target(
          naive: [(1, 10), (1, 11), (2, 20), (2, 22)].map { keyValue($0, $1) })
        #if COMPATIBLE_ATCODER_2025
          XCTAssertEqual(dict.keys() + [], [1, 1, 2, 2])
          XCTAssertEqual(dict.values() + [], [10, 11, 20, 22])
        #else
          XCTAssertEqual(dict.keys + [], [1, 1, 2, 2])
          XCTAssertEqual(dict.values + [], [10, 11, 20, 22])
        #endif
        XCTAssertEqual(dict[0] + [], [])
        XCTAssertEqual(dict[1] + [], [10, 11])
        XCTAssertEqual(dict[2] + [], [20, 22])
        XCTAssertEqual(dict[3] + [], [])
      }
    }
  #endif

  #if false
    func testInitGroupingBy_() throws {
      let students = ["Kofi", "Abena", "Efua", "Kweku", "Akosua"]
      let studentsByLetter = Dictionary(grouping: students, by: { $0.first! })
      XCTAssertEqual(
        studentsByLetter, ["E": ["Efua"], "K": ["Kofi", "Kweku"], "A": ["Abena", "Akosua"]])
    }
  #endif

  func testInitGroupingBy() throws {
    let students = ["Kofi", "Abena", "Efua", "Kweku", "Akosua"]
    let studentsByLetter = Target(grouping: students, by: { $0.first! })
    XCTAssertEqual(
      studentsByLetter, ["E": "Efua", "K": "Kofi", "K": "Kweku", "A": "Abena", "A": "Akosua"])
  }

  func testInitGroupingBy2() throws {
    let students = AnySequence(0..<100)
    let studentsByLetter = Target(grouping: students, by: { $0 % 10 })
    XCTAssertEqual(
      studentsByLetter,
      [
        0: 0, 0: 10, 0: 20, 0: 30, 0: 40, 0: 50, 0: 60, 0: 70, 0: 80, 0: 90,
        1: 1, 1: 11, 1: 21, 1: 31, 1: 41, 1: 51, 1: 61, 1: 71, 1: 81, 1: 91,
        2: 2, 2: 12, 2: 22, 2: 32, 2: 42, 2: 52, 2: 62, 2: 72, 2: 82, 2: 92,
        3: 3, 3: 13, 3: 23, 3: 33, 3: 43, 3: 53, 3: 63, 3: 73, 3: 83, 3: 93,
        4: 4, 4: 14, 4: 24, 4: 34, 4: 44, 4: 54, 4: 64, 4: 74, 4: 84, 4: 94,
        5: 5, 5: 15, 5: 25, 5: 35, 5: 45, 5: 55, 5: 65, 5: 75, 5: 85, 5: 95,
        6: 6, 6: 16, 6: 26, 6: 36, 6: 46, 6: 56, 6: 66, 6: 76, 6: 86, 6: 96,
        7: 7, 7: 17, 7: 27, 7: 37, 7: 47, 7: 57, 7: 67, 7: 77, 7: 87, 7: 97,
        8: 8, 8: 18, 8: 28, 8: 38, 8: 48, 8: 58, 8: 68, 8: 78, 8: 88, 8: 98,
        9: 9, 9: 19, 9: 29, 9: 39, 9: 49, 9: 59, 9: 69, 9: 79, 9: 89, 9: 99,
      ])
  }

  #if false
    func testUpdate_() throws {
      var dict = [1: 1, 2: 2, 3: 3]
      XCTAssertEqual(dict.updateValue(0, forKey: 0), nil)
      XCTAssertEqual(dict[1], 1)
      XCTAssertEqual(dict.updateValue(10, forKey: 1), 1)
      XCTAssertEqual(dict[1], 10)
    }
  #endif

  #if COMPATIBLE_ATCODER_2025
    func testUpdate() throws {
      var dict = [1: 1, 2: 2, 3: 3] as Target<Int, Int>
      #if DEBUG
        XCTAssertEqual(
          dict.updateValue(
            0,
            at: Target<Int, Int>.Index.unsafe(tree: dict.__tree_, rawValue: .nullptr))?.value,
          nil)
      #endif
      XCTAssertEqual(dict.updateValue(0, at: dict.endIndex)?.value, nil)
      XCTAssertEqual(dict[1].map(\.value), [1])
      XCTAssertEqual(dict.updateValue(10, at: dict.firstIndex(of: 1)!)?.value, 1)
      XCTAssertEqual(dict[1].map(\.value), [10])
    }
  #else
    func testUpdate() throws {
      var dict = [1: 1, 2: 2, 3: 3] as Target<Int, Int>
      #if DEBUG
        XCTAssertEqual(
          dict.updateValue(
            0,
            at: Target<Int, Int>.Index.unsafe(tree: dict.__tree_, rawValue: .nullptr))?.value,
          nil)
      #endif
      XCTAssertEqual(dict.updateValue(0, at: dict.endIndex)?.value, nil)
      XCTAssertEqual(dict[1] + [], [1])
      XCTAssertEqual(dict.updateValue(10, at: dict.firstIndex(of: 1)!)?.value, 1)
      XCTAssertEqual(dict[1] + [], [10])
    }
  #endif

  func testBound() throws {
    let dict = [1: 10, 3: 30, 5: 50] as Target<Int, Int>
    XCTAssertEqual(dict.lowerBound(2), dict.index(after: dict.startIndex))
    XCTAssertEqual(dict.lowerBound(3), dict.index(after: dict.startIndex))
    XCTAssertEqual(dict.upperBound(2), dict.index(after: dict.startIndex))
    XCTAssertEqual(dict.upperBound(3), dict.index(dict.startIndex, offsetBy: 2))
  }

  #if false
    func testArrayAccess1() throws {
      let set = [0: 0, 1: 10, 2: 20, 3: 30, 4: 40] as Target<Int, Int>
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 0)].key, 0)
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 1)].key, 1)
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 2)].key, 2)
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 3)].key, 3)
      XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 4)].key, 4)
    }

    func testArrayAccess2() throws {
      let set = [0: 0, 1: 10, 2: 20, 3: 30, 4: 40] as Target<Int, Int>
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -5)].key, 0)
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -4)].key, 1)
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -3)].key, 2)
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -2)].key, 3)
      XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -1)].key, 4)
    }
  #endif

  func testIndex() throws {
    let set = [0: 0, 1: 10, 2: 20, 3: 30, 4: 40] as Target<Int, Int>
    XCTAssertEqual(set.firstIndex(of: 0), set.startIndex)
    XCTAssertEqual(set.firstIndex(of: 2), set.index(set.startIndex, offsetBy: 2))
    XCTAssertEqual(set.firstIndex(of: 5), nil)
  }

  func testIndexLimit1() throws {
    let set = [0: 0, 1: 10, 2: 20, 3: 30, 4: 40] as Target<Int, Int>
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
    let set = [0: 0, 1: 10, 2: 20, 3: 30, 4: 40] as Target<Int, Int>
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
      let set = [0: 0, 1: 10, 2: 20, 3: 30, 4: 40] as Target<Int, Int>
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

  func testRandom() throws {
    var set = Target<Int, Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(forKey: i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(forKey: i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in set {
      set.removeAll(forKey: i.key)
      XCTAssertTrue(set.___tree_invariant())
    }
  }

  func testRandom2() throws {
    var set = Target<Int, Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    XCTAssertEqual(set.map { $0.key }, set[set.startIndex..<set.endIndex].map { $0.key })
    XCTAssertEqual(set.map { $0.value }, set[set.startIndex..<set.endIndex].map { $0.value })
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(forKey: i)
      XCTAssertTrue(set.___tree_invariant())
    }
    XCTAssertEqual(set.map { $0.key }, set[set.startIndex..<set.endIndex].map { $0.key })
    XCTAssertEqual(set.map { $0.value }, set[set.startIndex..<set.endIndex].map { $0.value })
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    XCTAssertEqual(set.map { $0.key }, set[set.startIndex..<set.endIndex].map { $0.key })
    XCTAssertEqual(set.map { $0.value }, set[set.startIndex..<set.endIndex].map { $0.value })
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(forKey: i)
      XCTAssertTrue(set.___tree_invariant())
    }
    XCTAssertEqual(set.map { $0.key }, set[set.startIndex..<set.endIndex].map { $0.key })
    XCTAssertEqual(set.map { $0.value }, set[set.startIndex..<set.endIndex].map { $0.value })
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    XCTAssertEqual(set.map { $0.key }, set[set.startIndex..<set.endIndex].map { $0.key })
    XCTAssertEqual(set.map { $0.value }, set[set.startIndex..<set.endIndex].map { $0.value })
    print("set.count", set.count)
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      print("set._copyCount", set._copyCount)
    #endif
    for i in set[set.startIndex..<set.endIndex] {
      // erase multiなので、CoWなしだと、ポインタが破壊される
      set.removeAll(forKey: i.key)
      XCTAssertTrue(set.___tree_invariant())
    }
  }

  func testRandom3() throws {
    var set = Target<Int, Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(forKey: i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(forKey: i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
  }

  func testRandom4() throws {
    var set = Target<Int, Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(forKey: i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(forKey: i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
  }

  func testEqualtable() throws {
    XCTAssertEqual(Target<Int, Int>(), [:])
    XCTAssertNotEqual(Target<Int, Int>(), [1: 1])
    XCTAssertEqual([1: 1] as Target<Int, Int>, [1: 1])
    XCTAssertNotEqual([1: 1, 2: 2] as Target<Int, Int>, [1: 1])
    XCTAssertNotEqual([2: 2, 3: 3] as Target<Int, Int>, [1: 1, 2: 2])
  }

  func testFirstLast() throws {
    let dict = [1: 11, 2: 22, 3: 33] as Target<Int, Int>
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
    let dict = [1: 11, 2: 22, 3: 33] as Target<Int, Int>
    var d: [Int: Int] = [:]
    dict.forEach { kv in
      d[__key(kv)] = __value(kv)
    }
    XCTAssertEqual(d, [1: 11, 2: 22, 3: 33])
  }

  func testSubsequence() throws {
    var set: Target<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    let sub = set.elements(in: 2..<4)
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
    var set: Target<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    let sub = set.elements(in: 2...4)
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

  func testSubsequence4() throws {
    //      let set: Target<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    //      let sub = set.elements(in: 1..<3)
    throw XCTSkip("Fatal error: RedBlackTree index is out of range.")
    //      XCTAssertNotEqual(sub[set.startIndex..<set.endIndex].map { $0.key }, [1, 2, 3, 4, 5])
  }

  func testSubsequence5() throws {
    let set: Target<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    let sub = set.elements(in: 1..<3)
    XCTAssertEqual(sub[set.lowerBound(1)..<set.lowerBound(3)].map { $0.key }, [1, 2])
    XCTAssertEqual(sub[sub.startIndex..<sub.endIndex].map { $0.key }, [1, 2])
    XCTAssertEqual(sub[sub.startIndex..<sub.index(before: sub.endIndex)].map { $0.key }, [1])
  }

  func testSubsequence6() throws {
    let set: Target<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    let sub = set[set.startIndex..<set.endIndex]
    XCTAssertEqual(sub.map { $0.key }, [1, 2, 3, 4, 5])
  }

  func testSubsequence7() throws {
    var set: Target<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    let sub = set[set.startIndex..<set.endIndex]
    var a: [String] = []
    for (_, value) in sub.map(tuple) {
      a.append(value)
    }
    XCTAssertEqual(a, ["a", "b", "c", "d", "e"])
    sub.map(tuple).forEach { key, value in
      set.insert(key: key, value: "?")
    }
    XCTAssertEqual(set.map(\.value), ["a", "?", "b", "?", "c", "?", "d", "?", "e", "?"])
  }

  #if false
    func testEnumeratedSequence1() throws {
      let set: Target<Int, String> = [1: "a", 2: "b", 3: "c"]
      var d: [String: Int] = [:]
      set.enumerated().forEach {
        d[$0.element.value] = $0.offset.rawValue
      }
      XCTAssertEqual(d, ["a": 0, "b": 1, "c": 2])
    }

    func testEnumeratedSequence2() throws {
      let set: Target<Int, String> = [1: "a", 2: "b", 3: "c"]
      var d: [String: Int] = [:]
      set.elements(in: 2...3).enumerated().forEach {
        d[$0.element.value] = $0.offset.rawValue
      }
      XCTAssertEqual(d, ["b": 1, "c": 2])
    }

    func testEnumeratedSequence3() throws {
      let set: Target<Int, String> = [1: "a", 2: "b", 3: "c"]
      var d: [String: Int] = [:]
      for (o, e) in set.enumerated() {
        d[e.value] = o.rawValue
      }
      XCTAssertEqual(d, ["a": 0, "b": 1, "c": 2])
    }

    func testEnumeratedSequence4() throws {
      let set: Target<Int, String> = [1: "a", 2: "b", 3: "c"]
      var d: [String: Int] = [:]
      for (o, e) in set.elements(in: 2...3).enumerated() {
        d[e.value] = o.rawValue
      }
      XCTAssertEqual(d, ["b": 1, "c": 2])
    }
  #endif

  func testIndex0() throws {
    let set: Target<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50]
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
    let set: Target<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50]
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
    let sub = set.elements(in: 2..<5)
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
    let set: Target<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50]
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
    let sub = set.elements(in: 2..<5)
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
    let set: Target<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50, 6: 60]
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 6), set.endIndex)
    XCTAssertEqual(set.index(set.endIndex, offsetBy: -6), set.startIndex)
    let sub = set.elements(in: 2..<5)
    XCTAssertEqual(sub.map { $0.key }, [2, 3, 4])
    XCTAssertEqual(sub.index(sub.startIndex, offsetBy: 3), sub.endIndex)
    XCTAssertEqual(sub.index(sub.endIndex, offsetBy: -3), sub.startIndex)
  }

  func testIndex10() throws {
    let set: Target<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50, 6: 60]
    XCTAssertNotNil(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex))
    XCTAssertNil(set.index(set.startIndex, offsetBy: 7, limitedBy: set.endIndex))
    XCTAssertNotNil(set.index(set.endIndex, offsetBy: -6, limitedBy: set.startIndex))
    XCTAssertNil(set.index(set.endIndex, offsetBy: -7, limitedBy: set.startIndex))
    let sub = set.elements(in: 2..<5)
    XCTAssertEqual(sub.map { $0.key }, [2, 3, 4])
    XCTAssertNotNil(sub.index(sub.startIndex, offsetBy: 3, limitedBy: sub.endIndex))
    XCTAssertNil(sub.index(sub.startIndex, offsetBy: 4, limitedBy: sub.endIndex))
    XCTAssertNotNil(sub.index(sub.endIndex, offsetBy: -3, limitedBy: sub.startIndex))
    XCTAssertNil(sub.index(sub.endIndex, offsetBy: -4, limitedBy: sub.startIndex))
  }

  func testIndex11() throws {
    let set: Target<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50, 6: 60]
    var i = set.startIndex
    XCTAssertTrue(set.formIndex(&i, offsetBy: 6, limitedBy: set.endIndex))
    i = set.startIndex
    XCTAssertFalse(set.formIndex(&i, offsetBy: 7, limitedBy: set.endIndex))
    i = set.endIndex
    XCTAssertTrue(set.formIndex(&i, offsetBy: -6, limitedBy: set.startIndex))
    i = set.endIndex
    XCTAssertFalse(set.formIndex(&i, offsetBy: -7, limitedBy: set.startIndex))
    let sub = set.elements(in: 2..<5)
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
    let set: Target<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50, 6: 60]
    var i = set.startIndex
    set.formIndex(&i, offsetBy: 6)
    XCTAssertEqual(i, set.endIndex)
    i = set.endIndex
    set.formIndex(&i, offsetBy: -6)
    XCTAssertEqual(i, set.startIndex)
    let sub = set.elements(in: 2..<5)
    XCTAssertEqual(sub.map { $0.key }, [2, 3, 4])
    i = sub.startIndex
    sub.formIndex(&i, offsetBy: 3)
    XCTAssertEqual(i, sub.endIndex)
    i = sub.endIndex
    sub.formIndex(&i, offsetBy: -3)
    XCTAssertEqual(i, sub.startIndex)
  }

  func testRangeSubscript() throws {
    let set: Target<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 6: 60, 7: 70]
    let l2 = set.lowerBound(2)
    let u2 = set.upperBound(4)
    AssertEquenceEqual(set[l2..<u2].map { $0 }, [2, 3, 4].map { keyValue($0, $0 * 10) })
    AssertEquenceEqual(set[l2...].map { $0 }, [2, 3, 4, 6, 7].map { keyValue($0, $0 * 10) })
    AssertEquenceEqual(set[u2...].map { $0 }, [6, 7].map { keyValue($0, $0 * 10) })
    AssertEquenceEqual(set[..<u2].map { $0 }, [1, 2, 3, 4].map { keyValue($0, $0 * 10) })
    AssertEquenceEqual(set[...u2].map { $0 }, [1, 2, 3, 4, 6].map { keyValue($0, $0 * 10) })
    AssertEquenceEqual(
      set[..<set.endIndex].map { $0 }, [1, 2, 3, 4, 6, 7].map { keyValue($0, $0 * 10) })
  }

  #if !COMPATIBLE_ATCODER_2025
    func testRangeSubscriptUnchecked() throws {
      let set: Target<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 6: 60, 7: 70]
      let l2 = set.lowerBound(2)
      let u2 = set.upperBound(4)
      AssertEquenceEqual(
        set[unchecked: l2..<u2].map { $0 }, [2, 3, 4].map { keyValue($0, $0 * 10) })
      AssertEquenceEqual(
        set[unchecked: l2...].map { $0 }, [2, 3, 4, 6, 7].map { keyValue($0, $0 * 10) })
      AssertEquenceEqual(set[unchecked: u2...].map { $0 }, [6, 7].map { keyValue($0, $0 * 10) })
      AssertEquenceEqual(
        set[unchecked: ..<u2].map { $0 }, [1, 2, 3, 4].map { keyValue($0, $0 * 10) })
      AssertEquenceEqual(
        set[unchecked: ...u2].map { $0 }, [1, 2, 3, 4, 6].map { keyValue($0, $0 * 10) })
      AssertEquenceEqual(
        set[unchecked: ..<set.endIndex].map { $0 },
        [1, 2, 3, 4, 6, 7].map { keyValue($0, $0 * 10) })
    }
  #endif

  func testIndexValidation() throws {
    let set: Target<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    XCTAssertTrue(set.isValid(index: set.startIndex))
    XCTAssertFalse(set.isValid(index: set.endIndex))  // 仕様変更。subscriptやremoveにつかえないので
    typealias Index = Target<Int, String>.Index
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
    let _set: Target<Int, String> = [
      1: "a", 2: "b", 3: "c", 4: "d", 5: "e", 6: "f", 7: "g",
    ]
    let set = _set.elements(in: 2..<6)
    XCTAssertTrue(set.isValid(index: set.startIndex))
    XCTAssertTrue(set.isValid(index: set.endIndex))
    typealias Index = Target<Int, String>.Index
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
    let dict: Target<String, Int> = ["a": 1, "b": 2, "c": 3]
    XCTAssertTrue(dict.contains(key: "a"))
    XCTAssertTrue(dict.contains(key: "b"))
    XCTAssertFalse(dict.contains(key: "d"))
  }

  func testMinAndMax() {
    var dict: Target<String, Int> = [:]
    XCTAssertNil(dict.min())
    XCTAssertNil(dict.max())

    dict.insert(key: "b", value: 2)
    dict.insert(key: "a", value: 1)
    dict.insert(key: "c", value: 3)

    let minPair = dict.min()
    XCTAssertEqual(minPair?.key, "a")
    XCTAssertEqual(minPair?.value, 1)

    let maxPair = dict.max()
    XCTAssertEqual(maxPair?.key, "c")
    XCTAssertEqual(maxPair?.value, 3)
  }

  func testEqual1() throws {
    do {
      let a = Target<Int, Int>()
      let b = Target<Int, Int>()
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a = Target<Int, Int>()
      let b: Target<Int, Int> = [(0, 0)]
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
    do {
      let a: Target<Int, Int> = [(0, 0)]
      let b: Target<Int, Int> = [(0, 0)]
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a: Target<Int, Int> = [(0, 0), (1, 1)]
      let b: Target<Int, Int> = [(0, 0)]
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
    do {
      let a: Target<Int, Int> = [(0, 0), (1, 1)]
      let b: Target<Int, Int> = [(0, 0), (1, 1)]
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
  }

  func testEqual2() throws {
    let aa = Target<Int, Int>(multiKeysWithValues: [0, 1, 2, 3, 4, 5].map { ($0, $0) })
    let bb = Target<Int, Int>(multiKeysWithValues: [3, 4, 5, 6, 7, 8].map { ($0, $0) })
    do {
      let a = aa[0..<0]
      let b = bb[3..<3]
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a = aa[3..<6]
      let b = bb[3..<6]
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a = aa[2..<6]
      let b = bb[3..<6]
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
    do {
      let a = aa[3..<6]
      let b = bb[3..<7]
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
  }

  func testCompare1() throws {
    do {
      let a: Target<Int, Int> = []
      let b: Target<Int, Int> = []
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a: Target<Int, Int> = []
      let b: Target<Int, Int> = [(0, 0)]
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a: Target<Int, Int> = [(0, 0)]
      let b: Target<Int, Int> = [(0, 0)]
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a: Target<Int, Int> = [(0, 0)]
      let b: Target<Int, Int> = [(1, 1)]
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a: Target<Int, Int> = [(0, 0), (1, 1)]
      let b: Target<Int, Int> = [(0, 0)]
      XCTAssertFalse(a < b)
      XCTAssertTrue(b < a)
    }
    do {
      let a: Target<Int, Int> = [(0, 0), (1, 1)]
      let b: Target<Int, Int> = [(0, 0), (1, 1)]
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a: Target<Int, Int> = [(0, 0), (1, 1), (2, 2)]
      let b: Target<Int, Int> = [(0, 0), (1, 1), (3, 3)]
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
  }

  func testMeld() throws {
    do {
      var a: Target<Int, Int> = [0: 10, 1: 30]
      let b: Target<Int, Int> = [0: 20, 1: 40]
      a.meld(b)
      AssertEquenceEqual(a + [], [(0, 10), (0, 20), (1, 30), (1, 40)].map { keyValue($0) })
    }
  }

  func testMelding() throws {
    do {
      let a: Target<Int, Int> = [0: 10, 1: 30]
      let b: Target<Int, Int> = [0: 20, 1: 40]
      AssertEquenceEqual(
        a.melding(b) + [], [(0, 10), (0, 20), (1, 30), (1, 40)].map { keyValue($0) })
    }
  }

  func testAdd() throws {
    do {
      let a: Target<Int, Int> = [0: 10, 1: 30]
      let b: Target<Int, Int> = [0: 20, 1: 40]
      let c = a + b
      AssertEquenceEqual(c + [], [(0, 10), (0, 20), (1, 30), (1, 40)].map { keyValue($0) })
    }
  }

  func testAddEqual() throws {
    do {
      var a: Target<Int, Int> = [0: 10, 1: 30]
      let b: Target<Int, Int> = [0: 20, 1: 40]
      a += b
      AssertEquenceEqual(a + [], [(0, 10), (0, 20), (1, 30), (1, 40)].map { keyValue($0) })
    }
  }

  func testIsValidRangeSmoke() throws {
    let a = RedBlackTreeMultiMap<Int, Int>(naive: [0, 1, 2, 3, 4, 5].map { keyValue($0, $0) })
    XCTAssertTrue(a.isValid(a.lowerBound(2)..<a.upperBound(4)))
  }

  #if !COMPATIBLE_ATCODER_2025
    func testSortedReversed() throws {
      let source = [0, 1, 2, 3, 4, 5].map { keyValue($0, $0 * 10) }
      let a = RedBlackTreeMultiMap<Int, Int>(multiKeysWithValues: source)
      AssertEquenceEqual(a.sorted() + [], source)
      AssertEquenceEqual(a.reversed() + [], source.reversed())
    }
  #endif

  func testForEach_enumeration() throws {
    let source = [0, 1, 2, 3, 4, 5].map { keyValue($0, $0 * 10) }
    let a = RedBlackTreeMultiMap<Int, Int>(multiKeysWithValues: source)
    var p: RedBlackTreeMultiMap<Int, Int>.Index? = a.startIndex
    a.forEach { i, v in
      XCTAssertEqual(i, p)
      XCTAssertTrue(a[p!] == v)
      p = p?.next
    }
  }

  #if !COMPATIBLE_ATCODER_2025
    func testInitNaive_with_Sequence() throws {
      let source = [0, 1, 2, 3, 4, 5].map { keyValue($0, $0 * 10) }
      let a = RedBlackTreeMultiMap<Int, Int>(naive: AnySequence(source))
      AssertEquenceEqual(a.sorted() + [], source)
    }
  #endif
}
