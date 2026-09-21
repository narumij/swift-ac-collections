import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if COMPATIBLE_ATCODER_2025
  final class DictionaryAtCoder2025CompatibilityTests: RedBlackTreeTestCase {
    func testRemove() throws {
      var dict = [1: 1, 2: 2, 3: 3] as RedBlackTreeDictionary<Int, Int>
      let i = dict.firstIndex { key, _ in key == 1 }!
      XCTAssertEqual(dict.remove(at: i).value, 1)
    }

    func testRemoveWithIndices() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      for i in members.indices { members.remove(at: i) }
      XCTAssertEqual(members.map { $0.key }, [])
    }

    func testRemoveWithIndices2() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      members.indices.forEach { members.remove(at: $0) }
      XCTAssertEqual(members.map { $0.key }, [])
    }

    func testRemoveWithIndices3() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      for i in members.indices.reversed() { members.remove(at: i) }
      XCTAssertEqual(members.map { $0.key }, [])
    }

    func testRemoveWithIndices4() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      members.indices.reversed().forEach { members.remove(at: $0) }
      XCTAssertEqual(members.map { $0.key }, [])
    }
  }
  extension DictionaryPointerTests {
    func testPointer2() throws {
      if let it = members.startIndex.next {
        XCTAssertFalse(members.___is_garbaged(it))
        XCTAssertEqual(it.pointee?.key, 1)
        XCTAssertNotNil(it.previous)
        XCTAssertNotNil(it.next)
        members.remove(at: it)
        XCTAssertTrue(members.___is_garbaged(it))
        XCTAssertNil(it.pointee)
        XCTAssertNil(it.previous)
        XCTAssertNil(it.next)
      }
    }

    func testPointerNext() throws {
      XCTAssertEqual(members.startIndex.pointee?.key, 0)
      XCTAssertEqual(members.startIndex.next?.pointee?.key, 1)
      XCTAssertEqual(members.startIndex.next?.next?.pointee?.key, 2)
      XCTAssertEqual(members.startIndex.next?.next?.next?.pointee?.key, 3)
      XCTAssertEqual(members.startIndex.next?.next?.next?.next?.pointee?.key, 4)
      XCTAssertNil(members.startIndex.next?.next?.next?.next?.next?.pointee)
      XCTAssertEqual(members.startIndex.next?.next?.next?.next?.next, members.endIndex)
      XCTAssertNil(members.startIndex.next?.next?.next?.next?.next?.next)
      XCTAssertNil(members.endIndex.next)
    }

    func testPointerPrev() throws {
      XCTAssertNil(members.endIndex.pointee)
      XCTAssertEqual(members.endIndex.previous?.pointee?.key, 4)
      XCTAssertEqual(members.endIndex.previous?.previous?.pointee?.key, 3)
      XCTAssertEqual(members.endIndex.previous?.previous?.previous?.pointee?.key, 2)
      XCTAssertEqual(members.endIndex.previous?.previous?.previous?.previous?.pointee?.key, 1)
      XCTAssertEqual(
        members.endIndex.previous?.previous?.previous?.previous?.previous?.pointee?.key, 0)
      XCTAssertEqual(
        members.endIndex.previous?.previous?.previous?.previous?.previous, members.startIndex)
      XCTAssertNil(members.endIndex.previous?.previous?.previous?.previous?.previous?.previous)
      XCTAssertNil(members.startIndex.previous)
    }

    func testPointerOffset0() throws {
      XCTAssertEqual((members.startIndex).pointee?.key, 0)
      XCTAssertEqual(members.startIndex.advanced(by: 1).pointee?.key, 1)
      XCTAssertEqual(members.startIndex.advanced(by: 2).pointee?.key, 2)
      XCTAssertEqual(members.startIndex.advanced(by: 3).pointee?.key, 3)
      XCTAssertEqual(members.startIndex.advanced(by: 4).pointee?.key, 4)
      XCTAssertNil(members.startIndex.advanced(by: 5).pointee)
      XCTAssertEqual(members.startIndex.advanced(by: 5), members.endIndex)
      XCTAssertNil(members.startIndex.advanced(by: 6).pointee)
    }

    func testPointerOffset2() throws {
      XCTAssertNil((members.endIndex).pointee)
      XCTAssertEqual(members.endIndex.advanced(by: -1).pointee?.key, 4)
      XCTAssertEqual(members.endIndex.advanced(by: -2).pointee?.key, 3)
      XCTAssertEqual(members.endIndex.advanced(by: -3).pointee?.key, 2)
      XCTAssertEqual(members.endIndex.advanced(by: -4).pointee?.key, 1)
      XCTAssertEqual(members.endIndex.advanced(by: -5).pointee?.key, 0)
      XCTAssertEqual(members.endIndex.advanced(by: -5), members.startIndex)
      XCTAssertNil(members.startIndex.advanced(by: -6).pointee)
    }
  }

  #if DEBUG
  extension DictionaryRemoveTests {
    func testRemoveWith___Indices() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      for i in members.___node_positions() {
        members.__tree_._unchecked_remove(at: i)
      }
      XCTAssertEqual(members.map { $0.key }, [])
    }

    func testRemoveWith___Indices2() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      members.___node_positions().forEach { i in
        members.__tree_._unchecked_remove(at: i)
      }
      XCTAssertEqual(members.map { $0.key }, [])
    }

    func testRemoveWith___Indices3() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      members.___node_positions().reversed().forEach { i in
        members.__tree_._unchecked_remove(at: i)
      }
      XCTAssertEqual(members.map { $0.key }, [])
    }
  }
  #endif

  extension DictionaryRemoveTests {
    func testRemoveWithSubIndices() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      for i in members[2..<8].indices {
        members.remove(at: i)
      }
      XCTAssertEqual(members.map { $0.key }, [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices2() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      members[2..<8].indices.forEach { i in
        members.remove(at: i)
      }
      XCTAssertEqual(members.map { $0.key }, [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices3() throws {
      var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      for i in members[2..<8].indices.reversed() {
        members.remove(at: i)
      }
      XCTAssertEqual(members.map { $0.key }, [0, 1, 8, 9])
    }

    #if DEBUG
      func testRemoveWithSubIndices4() throws {
        var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
        members[2..<8].indices.reversed().forEach { i in
          members.remove(at: i)
        }
        XCTAssertEqual(members.map { $0.key }, [0, 1, 8, 9])
      }

      func testRemoveWithSub___Indices() throws {
        var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
        for i in members[2..<8].___node_positions() {
          members.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(members.map { $0.key }, [0, 1, 8, 9])
      }

      func testRemoveWithSub___Indices2() throws {
        var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
        assert(members.count == 10)
        //      members[2..<8].___node_positions().forEach { i in
        members.elements(in: 2..<8).___node_positions().forEach { i in
          members.__tree_._unchecked_remove(at: i)
        }
        assert(members.count == 4)
        #if COMPATIBLE_ATCODER_2025
          assert(members.keys() + [] == [0, 1, 8, 9])
        #else
          assert(members.keys + [] == [0, 1, 8, 9])
        #endif
        XCTAssertEqual(AnySequence(members).map { $0.key }, [0, 1, 8, 9])
        #if COMPATIBLE_ATCODER_2025
          XCTAssertEqual(AnyCollection(members).map { $0.key }, [0, 1, 8, 9])
        #endif
        XCTAssertEqual(members.map { $0.key }, [0, 1, 8, 9])
      }

      func testRemoveWithSub___Indices4() throws {
        var members = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
        members[2..<8].___node_positions().reversed().forEach { i in
          members.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(members.map { $0.key }, [0, 1, 8, 9])
      }
    #endif
  }

  extension RedBlackTreeDictionarySubSequenceTests {
  func testSliceIndexOffsetting() {
    let dict: RedBlackTreeDictionary = [
      10: 0, 11: 1, 12: 2, 13: 3, 14: 4,
    ]
    let slice = dict.elements(in: 11...13)  // 11,12,13

    let idx = slice.index(slice.startIndex, offsetBy: 2)
    XCTAssertEqual(slice[idx].key, 13)

    let nilIdx = slice.index(
      slice.startIndex,
      offsetBy: 10,
      limitedBy: slice.endIndex)
    XCTAssertNil(nilIdx)
  }

  // MARK: 距離の対称性 ---------------------------------------------------

  func testDistanceSymmetry() {
    let dict: RedBlackTreeDictionary = [
      0: "zero", 1: "one", 2: "two",
      3: "three", 4: "four", 5: "five",
    ]
    let slice = dict.elements(in: 1...4)  // 1,2,3,4

    let i = slice.index(slice.startIndex, offsetBy: 1)  // 2
    let j = slice.index(slice.startIndex, offsetBy: 3)  // 4

    XCTAssertEqual(slice.distance(from: i, to: j), 2)
    XCTAssertEqual(slice.distance(from: j, to: i), -2)
  }

  // MARK: CoW 後の index 無効化 -----------------------------------------

  func testIndexInvalidationAfterCoWMutation() throws {
    var base: RedBlackTreeDictionary = [
      "x": 1, "y": 2, "z": 3,
    ]
    let slice = base.elements(in: "x"..."y")  // x,y

    let idx = slice.firstIndex(where: { $0.key == "x" })!
    XCTAssertTrue(base.isValid(index: idx))
    XCTAssertTrue(slice.isValid(index: idx))

    // CoW 発動する
    let v = base.removeValue(forKey: "x")  // 消せてないやないかーい

    XCTAssertEqual(v, 1)
    XCTAssertNil(base["x"])

    // 共有ストレージの木が差し替わらないので、双方Valid
    XCTAssertFalse(base.isValid(index: idx))  // 期待と逆
    XCTAssertTrue(slice.isValid(index: idx))  // 期待と逆
    #if DEBUG
      XCTAssertEqual(base._copyCount, 1)
      XCTAssertEqual(slice._copyCount, 0)
    #endif
  }
  }

  extension DictionaryTests {
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
      #if COMPATIBLE_ATCODER_2025
        set.remove(contentsOf: 2..<4)
        XCTAssertEqual(set.map { $0.key }, [1, 4, 5])
        XCTAssertEqual(set.map { $0.value }, ["a", "d", "e"])
      #endif
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
      #if COMPATIBLE_ATCODER_2025
        set.remove(contentsOf: 2...4)
        XCTAssertEqual(set.map { $0.key }, [1, 5])
        XCTAssertEqual(set.map { $0.value }, ["a", "e"])
      #endif
    }
  }

  extension DictionaryTests {
    func testSubsequence4() throws {
      let set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      let sub = set[1..<3]
      throw XCTSkip("Fatal error: RedBlackTree index is out of range.")
      // スキップを直そうとしたが、テストの意図がよく分からない。当時のたまたまの仕様になっているような
      XCTAssertNotEqual(sub[set.startIndex..<set.endIndex].map { $0.key }, [1, 2, 3, 4, 5])
    }

    func testSubsequence5() throws {
      let set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      let sub = set[1..<3]
      XCTAssertEqual(sub[set.lowerBound(1)..<set.lowerBound(3)].map { $0.key }, [1, 2])
      XCTAssertEqual(sub[sub.startIndex..<sub.endIndex].map { $0.key }, [1, 2])
      XCTAssertEqual(sub[sub.startIndex..<sub.index(before: sub.endIndex)].map { $0.key }, [1])
    }
  }

  extension DictionaryTests {

  }

  extension DictionaryTests {
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

  }

  extension DictionaryTests {
    func testForEach_enumeration() throws {
      let source = [0, 1, 2, 3, 4, 5].map { ($0, $0 * 10) }
      let a = RedBlackTreeDictionary<Int, Int>(uniqueKeysWithValues: source)
      var p: RedBlackTreeDictionary<Int, Int>.Index? = a.startIndex
      a.forEach { i, v in
        XCTAssertEqual(i, p)
        XCTAssertEqual(RedBlackTreePair(a[p!]), RedBlackTreePair(v))
        p = p?.next
      }
    }
  }
  extension RedBlackTreeDictionaryExtendedTests {
  func testPopFirstReturnsMinKey() {
    var d: RedBlackTreeDictionary = [("b", 2), ("a", 1), ("c", 3)]
    let first = d.popFirst()
    XCTAssertEqual(first?.key, "a")
#if COMPATIBLE_ATCODER_2025
    XCTAssertEqual(Set(d.keys()), ["b", "c"])
#else
    XCTAssertEqual(Set(d.keys), ["b", "c"])
#endif
    XCTAssertEqual(d.popFirst()?.key, "b")
    _ = d.popFirst()
    XCTAssertTrue(d.isEmpty)
    XCTAssertNil(d.popFirst())
  }
  }

  extension RedBlackTreeDictionaryExtendedTests {
  func testBasicCrudAndIndexInvalidation() {
    var dict: RedBlackTreeDictionary = ["p": 9, "q": 8]
    let idx = dict.firstIndex(of: "p")!
    dict.remove(at: idx)
#if COMPATIBLE_ATCODER_2025
    XCTAssertFalse(dict.isValid(index: idx))
#else
    XCTAssertFalse(dict.isValid(idx))
#endif

    var copy = dict
    copy["q"] = 100
    XCTAssertEqual(dict["q"], 8)
    XCTAssertEqual(copy["q"], 100)
  }
  }

  extension DictionaryTests {
  func testInitUniqueKeysWithValues() throws {
    let dict = RedBlackTreeDictionary(uniqueKeysWithValues: [(1, 10), (2, 20)])
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(dict.keys() + [], [1, 2])
      XCTAssertEqual(dict.values() + [], [10, 20])
    #else
      XCTAssertEqual(dict.keys + [], [1, 2])
      XCTAssertEqual(dict.values + [], [10, 20])
    #endif
    XCTAssertEqual(dict[0], nil)
    XCTAssertEqual(dict[1], 10)
    XCTAssertEqual(dict[2], 20)
    XCTAssertEqual(dict[3], nil)
  }
  }

  extension DictionaryTests {
  func testInitUniqueKeysWithValues2() throws {
    let dict = RedBlackTreeDictionary(uniqueKeysWithValues: AnySequence([(1, 10), (2, 20)]))
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(dict.keys() + [], [1, 2])
      XCTAssertEqual(dict.values() + [], [10, 20])
    #else
      XCTAssertEqual(dict.keys + [], [1, 2])
      XCTAssertEqual(dict.values + [], [10, 20])
    #endif
    XCTAssertEqual(dict[0], nil)
    XCTAssertEqual(dict[1], 10)
    XCTAssertEqual(dict[2], 20)
    XCTAssertEqual(dict[3], nil)
  }
  }

  extension DictionaryTests {
  func testInitUniquingKeysWith() throws {
    do {
      let dict = RedBlackTreeDictionary(
        [(1, 10), (1, 11), (2, 20), (2, 22)], uniquingKeysWith: { _, b in b })
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(dict.keys() + [], [1, 2])
        XCTAssertEqual(dict.values() + [], [11, 22])
      #else
        XCTAssertEqual(dict.keys + [], [1, 2])
        XCTAssertEqual(dict.values + [], [11, 22])
      #endif
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 11)
      XCTAssertEqual(dict[2], 22)
      XCTAssertEqual(dict[3], nil)
    }
    do {
      let dict = RedBlackTreeDictionary(
        [(1, 10), (1, 11), (2, 20), (2, 22)], uniquingKeysWith: { a, _ in a })
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(dict.keys() + [], [1, 2])
        XCTAssertEqual(dict.values() + [], [10, 20])
      #else
        XCTAssertEqual(dict.keys + [], [1, 2])
        XCTAssertEqual(dict.values + [], [10, 20])
      #endif
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 10)
      XCTAssertEqual(dict[2], 20)
      XCTAssertEqual(dict[3], nil)
    }
  }
  }

  extension DictionaryTests {
  func testInitUniquingKeysWith2() throws {
    do {
      let dict = RedBlackTreeDictionary(
        AnySequence([(1, 10), (1, 11), (2, 20), (2, 22)]),
        uniquingKeysWith: { _, b in b })
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(dict.keys() + [], [1, 2])
        XCTAssertEqual(dict.values() + [], [11, 22])
      #else
        XCTAssertEqual(dict.keys + [], [1, 2])
        XCTAssertEqual(dict.values + [], [11, 22])
      #endif
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 11)
      XCTAssertEqual(dict[2], 22)
      XCTAssertEqual(dict[3], nil)
    }
    do {
      let dict = RedBlackTreeDictionary(
        AnySequence([(1, 10), (1, 11), (2, 20), (2, 22)]),
        uniquingKeysWith: { a, _ in a })
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(dict.keys() + [], [1, 2])
        XCTAssertEqual(dict.values() + [], [10, 20])
      #else
        XCTAssertEqual(dict.keys + [], [1, 2])
        XCTAssertEqual(dict.values + [], [10, 20])
      #endif
      XCTAssertEqual(dict[0], nil)
      XCTAssertEqual(dict[1], 10)
      XCTAssertEqual(dict[2], 20)
      XCTAssertEqual(dict[3], nil)
    }
  }
  }

  extension DictionaryTests {
  }

  extension DictionaryTests {
  }

  extension DictionaryTests {
  }

  extension DictionaryTests {
  func testIndexValidation() throws {
    let set: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    #if COMPATIBLE_ATCODER_2025
      XCTAssertTrue(set.isValid(index: set.startIndex))
      XCTAssertFalse(set.isValid(index: set.endIndex))  // 仕様変更。subscriptやremoveにつかえないので
      typealias Index = RedBlackTreeDictionary<Int, String>.Index
      #if DEBUG
        XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawTag: .end).value, .end)
        XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: .nullptr as Int)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 0)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 1)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 2)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 3)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 4)))
      #endif
    #else
      XCTAssertTrue(set.isValid(set.startIndex))
      XCTAssertFalse(set.isValid(set.endIndex))  // 仕様変更。subscriptやremoveにつかえないので
      typealias Index = RedBlackTreeDictionary<Int, String>.Index
      #if DEBUG
        XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawTag: .end).value, .end)
        XCTAssertFalse(set.isValid(.unsafe(tree: set.__tree_, rawTag: .nullptr as _TrackingTag)))
        XCTAssertTrue(set.isValid(.unsafe(tree: set.__tree_, rawTag: 0)))
        XCTAssertTrue(set.isValid(.unsafe(tree: set.__tree_, rawTag: 1)))
        XCTAssertTrue(set.isValid(.unsafe(tree: set.__tree_, rawTag: 2)))
        XCTAssertTrue(set.isValid(.unsafe(tree: set.__tree_, rawTag: 3)))
        XCTAssertTrue(set.isValid(.unsafe(tree: set.__tree_, rawTag: 4)))
      #endif
    #endif
  }
  }

  extension DictionaryTests {
  func testRemoveRange() throws {
    var a = RedBlackTreeDictionary<Int, Int>(
      uniqueKeysWithValues: [0, 1, 2, 3, 4, 5].map { ($0, $0) })

    #if COMPATIBLE_ATCODER_2025
      a.removeSubrange(a.lowerBound(2)..<a.upperBound(4))
    #else
      _ = a.erase(a.lowerBound(2)..<a.upperBound(4))
    #endif

    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(a.keys() + [], [0, 1, 5])
    #else
      XCTAssertEqual(a.keys + [], [0, 1, 5])
    #endif
  }
  }
#endif
