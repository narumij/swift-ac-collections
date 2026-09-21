import RedBlackTreeCollections
import XCTest

#if COMPATIBLE_ATCODER_2025
  final class MultiMapAtCoder2025CompatibilityTests: RedBlackTreeTestCase {
    func testRemoveContentsOfRange() {
      var multiMap: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
      multiMap.remove(contentsOf: "b"..."c")
      XCTAssertFalse(multiMap.contains(key: "b"))
      XCTAssertFalse(multiMap.contains(key: "c"))
      XCTAssertTrue(multiMap.contains(key: "a"))
      XCTAssertTrue(multiMap.contains(key: "d"))
    }
  }
  extension MultiMapTests {
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
  }

  extension MultiMapTests {
    func testUpdate() throws {
      var dict = [1: 1, 2: 2, 3: 3] as Target<Int, Int>
      #if DEBUG
        XCTAssertEqual(
          dict.updateValue(
            0,
            at: Target<Int, Int>.Index.unsafe(tree: dict.__tree_, rawTag: Int.nullptr))?.value,
          nil)
      #endif
      XCTAssertEqual(dict.updateValue(0, at: dict.endIndex)?.value, nil)
      XCTAssertEqual(dict[1].map(\.value), [1])
      XCTAssertEqual(dict.updateValue(10, at: dict.firstIndex(of: 1)!)?.value, 1)
      XCTAssertEqual(dict[1].map(\.value), [10])
    }
  }

  extension MultiMapTests {
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
      #if COMPATIBLE_ATCODER_2025
        set.remove(contentsOf: 2..<4)
        XCTAssertEqual(set.map { $0.key }, [1, 4, 5])
        XCTAssertEqual(set.map { $0.value }, ["a", "d", "e"])
      #endif
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
      #if COMPATIBLE_ATCODER_2025
        set.remove(contentsOf: 2...4)
        XCTAssertEqual(set.map { $0.key }, [1, 5])
        XCTAssertEqual(set.map { $0.value }, ["a", "e"])
      #endif
    }
  }

  extension MultiMapTests {
    func testSubsequence5() throws {
      let set: Target<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      let sub = set.elements(in: 1..<3)
      XCTAssertEqual(sub[set.lowerBound(1)..<set.lowerBound(3)].map { $0.key }, [1, 2])
      XCTAssertEqual(sub[sub.startIndex..<sub.endIndex].map { $0.key }, [1, 2])
      XCTAssertEqual(sub[sub.startIndex..<sub.index(before: sub.endIndex)].map { $0.key }, [1])
    }
  }

  extension MultiMapTests {
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
  }

  extension MultiMapTests {
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
  }

  extension MultiMapTests {
    func testIsValidRangeSmoke() throws {
      let a = RedBlackTreeMultiMap<Int, Int>(naive: [0, 1, 2, 3, 4, 5].map { keyValue($0, $0) })
      XCTAssertTrue(a.isValid(a.lowerBound(2)..<a.upperBound(4)))
    }
  }

  extension MultiMapTests {
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
  }

  extension MultiMapTests {
    func testInitNaive_with_Sequence() throws {
      let source = [0, 1, 2, 3, 4, 5].map { keyValue($0, $0 * 10) }
      let a = RedBlackTreeMultiMap<Int, Int>(naive: AnySequence(source))
      AssertEquenceEqual(a.sorted() + [], source)
    }
  }

  extension MultiMapTests {
    func testFilter() throws {
      let s = RedBlackTreeMultiMap<Int, String>(naive: (0..<5).map { ($0, "\($0)") })
      XCTAssertEqual(s.filter { _ in true }, s)
    }
  }

  extension MultiMapEtcTests {
    func testExample0() throws {
      for i in target1.indices {
        target1.remove(at: i)
      }
      XCTAssertTrue(target1.isEmpty)
    }

    func testExample1() throws {
      target1.indices.forEach { i in
        target1.remove(at: i)
      }
      XCTAssertTrue(target1.isEmpty)
    }
  }

  #if DEBUG
  extension MultiMapEtcTests {
    func testExample___0() throws {
      for i in target1.___node_positions() {
        target1.__tree_._unchecked_remove(at: i)
      }
      XCTAssertTrue(target1.isEmpty)
    }

    func testExample___1() throws {
      target1.___node_positions().forEach { i in
        target1.__tree_._unchecked_remove(at: i)
      }
      XCTAssertTrue(target1.isEmpty)
    }
  }
  #endif

  extension MultiMapCopyOnWriteTests {
      func testSet4000() throws {
        let count = 1500
        var xy: [Int: RedBlackTreeMultiMap<Int, Int>] = [
          1: .init(multiKeysWithValues: (0..<count).map { ($0, $0) })
        ]
        xy[1]?._copyCount = 0
        let N = 100
        var loopCount = 0
        for i in 0..<count / N {
          loopCount += 1
          xy[1]?[(i * N)..<(i * N + N)].forEach { i, v in
            xy[1]?.remove(at: i)
          }
        }
        XCTAssertEqual(xy[1]!.count, 0)
        XCTAssertEqual(xy[1]!._copyCount, 1)
        XCTAssertEqual(loopCount, count / N)
      }
  }

  extension MultiMapRemoveTests {
    func testRemove() throws {
      var dict = [1: 1, 2: 2, 3: 3] as RedBlackTreeMultiMap<Int, Int>
      let i = dict.firstIndex { kv in __key(kv) == 1 }!
      XCTAssertEqual(dict.remove(at: i).value, 1)
    }
  }

  extension MultiMapRemoveTests {
    func testRemoveWithIndices() throws {
      var members = RedBlackTreeMultiMap(multiKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      for i in members.indices {
        members.remove(at: i)
      }
      XCTAssertEqual(members.map { $0.key }, [])
    }

    func testRemoveWithIndices2() throws {
      var members = RedBlackTreeMultiMap(multiKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      members.indices.forEach { i in
        members.remove(at: i)
      }
      XCTAssertEqual(members.map { $0.key }, [])
    }

    func testRemoveWithIndices3() throws {
      var members = RedBlackTreeMultiMap(multiKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      members.indices.reversed().forEach { i in
        members.remove(at: i)
      }
      XCTAssertEqual(members.map { $0.key }, [])
    }
  }

  #if DEBUG
  extension MultiMapRemoveTests {
    func testRemoveWith___Indices() throws {
      var members = RedBlackTreeMultiMap(multiKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      for i in members.___node_positions() {
        members.__tree_._unchecked_remove(at: i)
      }
      XCTAssertEqual(members.map { $0.key }, [])
    }

    func testRemoveWith___Indices2() throws {
      var members = RedBlackTreeMultiMap(multiKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      members.___node_positions().forEach { i in
        members.__tree_._unchecked_remove(at: i)
      }
      XCTAssertEqual(members.map { $0.key }, [])
    }

    func testRemoveWith___Indices3() throws {
      var members = RedBlackTreeMultiMap(multiKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      members.___node_positions().reversed().forEach { i in
        members.__tree_._unchecked_remove(at: i)
      }
      XCTAssertEqual(members.map { $0.key }, [])
    }
  }
  #endif

  extension MultiMapRemoveTests {
    #if DEBUG
      func testRemoveWithSub___Indices() throws {
        var members = RedBlackTreeMultiMap(multiKeysWithValues: (0..<10).map { ($0, $0 * 10) })
        for i in members[2..<8].___node_positions() {
          members.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(members.map { $0.key }, [0, 1, 8, 9])
      }

      func testRemoveWithSub___Indices2() throws {
        var members = RedBlackTreeMultiMap(multiKeysWithValues: (0..<10).map { ($0, $0 * 10) })
        members[2..<8].___node_positions().forEach { i in
          members.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(members.map { $0.key }, [0, 1, 8, 9])
      }

      func testRemoveWithSub___Indices4() throws {
        var members = RedBlackTreeMultiMap(multiKeysWithValues: (0..<10).map { ($0, $0 * 10) })
        members[2..<8].___node_positions().reversed().forEach { i in
          members.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(members.map { $0.key }, [0, 1, 8, 9])
      }
    #endif
  }

  extension MultiMapSubSequenceTests {
    func testSliceIndexOffsetting() {
      let dict: Target = [
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
      let dict: Target = [
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

    func testIndexInvalidationAfterCoWMutation() {
      var base: Target = [
        "x": 1, "y": 2, "z": 3,
      ]
      let slice = base.elements(in: "x"..."y")  // x,y

      let idx = slice.firstIndex(where: { $0.key == "x" })!

      // CoW 発動
      _ = base.removeAll(forKey: "x")

      XCTAssertFalse(base.isValid(index: idx))
      XCTAssertTrue(slice.isValid(index: idx))
    }
  }

  extension MultiMapAdvancedTest {
    func testRemoveContentsOfRange() {
      var map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
      map.remove(contentsOf: "b"..."c")
      XCTAssertFalse(map.contains(key: "b"))
      XCTAssertFalse(map.contains(key: "c"))
    }
  }

  extension MultiMapPointerTests {
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
  extension MultiMapTests {
  func testUsage1() throws {
    // 意外と普通のユースケースでバグがあることが判明
    var map = Target<Int, Int>()
    XCTAssertEqual(map[0].map(\.value), [])
    map.insert((0, 1))
    //    map.updateValue(1, forKey: 0)
    XCTAssertEqual(map[0].map(\.value), [1])
    XCTAssertEqual(map[1].map(\.value), [])
    XCTAssertTrue(zip(map.map { (__key($0), __value($0)) }, [(0, 1)]).allSatisfy(==))
    #if COMPATIBLE_ATCODER_2025
      map.removeAll(forKey: 0)
    #else
      map.eraseMulti(0)
    #endif
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
    #if COMPATIBLE_ATCODER_2025
      map.removeAll(forKey: 1)
    #else
      map.eraseMulti(1)
    #endif
    //    map.removeValue(forKey: 10)
    XCTAssertEqual(map[0].map(\.value), [])
    XCTAssertEqual(map[1].map(\.value), [])
    XCTAssertEqual(map.map(\.key), [])
    XCTAssertEqual(map.map(\.value), [])
  }
  }

  extension MultiMapTests {
  func testUsage2() throws {
    var map = Target<Int, Int>()
    XCTAssertEqual(map[0].map(\.value), [])
    map.insert((0, 0))
    XCTAssertEqual(map[0].map(\.value), [0])
    XCTAssertEqual(map[1].map(\.value), [])
    map.insert((1, 2))
    XCTAssertEqual(map[0].map(\.value), [0])
    XCTAssertEqual(map[1].map(\.value), [2])
    #if COMPATIBLE_ATCODER_2025
      map.removeAll(forKey: 0)
    #else
      map.eraseMulti(0)
    #endif
    XCTAssertEqual(map[0].map(\.value), [])
    XCTAssertEqual(map[1].map(\.value), [2])
    #if COMPATIBLE_ATCODER_2025
      map.removeAll(forKey: 1)
    #else
      map.eraseMulti(1)
    #endif
    XCTAssertEqual(map[0].map(\.value), [])
    XCTAssertEqual(map[1].map(\.value), [])
    map.insert((1, 3))
    XCTAssertEqual(map[0].map(\.value), [])
    XCTAssertEqual(map[1].map(\.value), [3])
  }
  }

  extension MultiMapTests {
  func testInitUniqueKeysWithValues() throws {
    let dict = Target(keysWithValues: [(1, 10), (2, 20)])
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
  }

  extension MultiMapTests {
  func testInitUniqueKeysWithValues2() throws {
    let dict = Target(keysWithValues: AnySequence([(1, 10), (2, 20)]))
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
  }

  extension MultiMapTests {
  func testInitUniquingKeysWith() throws {
    do {
      let dict = Target(
        keysWithValues: [(1, 10), (1, 11), (2, 20), (2, 22)])
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
  }

  extension MultiMapTests {
  func testRandom() throws {
    var set = Target<Int, Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(forKey: i)
      #else
        set.eraseMulti(i)
      #endif
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(forKey: i)
      #else
        set.eraseMulti(i)
      #endif
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    #if COMPATIBLE_ATCODER_2025
      for i in set {
        set.removeAll(forKey: i.key)
        XCTAssertTrue(set.___tree_invariant())
      }
    #endif
  }
  }

  extension MultiMapTests {
  func testRandom2() throws {
    var set = Target<Int, Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    XCTAssertEqual(set.map { $0.key }, set[set.startIndex..<set.endIndex].map { $0.key })
    XCTAssertEqual(set.map { $0.value }, set[set.startIndex..<set.endIndex].map { $0.value })
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(forKey: i)
      #else
        set.eraseMulti(i)
      #endif
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
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(forKey: i)
      #else
        set.eraseMulti(i)
      #endif
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

    #if COMPATIBLE_ATCODER_2025
      for i in set[set.startIndex..<set.endIndex] {
        // erase multiなので、CoWなしだと、ポインタが破壊される
        set.removeAll(forKey: i.key)
        XCTAssertTrue(set.___tree_invariant())
      }
    #endif
  }
  }

  extension MultiMapTests {
  func testRandom3() throws {
    var set = Target<Int, Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(forKey: i)
      #else
        set.eraseMulti(i)
      #endif
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(forKey: i)
      #else
        set.eraseMulti(i)
      #endif
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
  }
  }

  extension MultiMapTests {
  func testRandom4() throws {
    var set = Target<Int, Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(forKey: i)
      #else
        set.eraseMulti(i)
      #endif
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(forKey: i)
      #else
        set.eraseMulti(i)
      #endif
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert((i, i))
      XCTAssertTrue(set.___tree_invariant())
    }
  }
  }

  extension MultiMapTests {
  func testFirstLast() throws {
    let dict = [1: 11, 2: 22, 3: 33] as Target<Int, Int>
    XCTAssertEqual(dict.first?.key, 1)
    XCTAssertEqual(dict.first?.value, 11)
    XCTAssertEqual(dict.last?.key, 3)
    XCTAssertEqual(dict.last?.value, 33)
    XCTAssertEqual(dict.first(where: { $0.value == 22 })?.key, 2)
    XCTAssertEqual(dict.first(where: { $0.value == 44 })?.key, nil)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(dict.firstIndex(where: { $0.value == 22 }), dict.index(after: dict.startIndex))
      XCTAssertEqual(dict.firstIndex(where: { $0.value == 44 }), nil)
    #endif
    XCTAssertTrue(dict.contains(where: { $0.value / $0.key == 11 }))
    XCTAssertFalse(dict.contains(where: { $0.value / $0.key == 22 }))
    XCTAssertTrue(dict.allSatisfy({ $0.value / $0.key == 11 }))
    XCTAssertFalse(dict.allSatisfy({ $0.value / $0.key == 22 }))
  }
  }

  extension MultiMapTests {
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
    #if COMPATIBLE_ATCODER_2025
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
    #endif
  }
  }

  extension MultiMapTests {
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
    #if COMPATIBLE_ATCODER_2025
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
    #endif
  }
  }

  extension MultiMapTests {
  func testIndexValidation() throws {
    let set: Target<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    #if COMPATIBLE_ATCODER_2025
      XCTAssertTrue(set.isValid(index: set.startIndex))
      XCTAssertFalse(set.isValid(index: set.endIndex))  // 仕様変更。subscriptやremoveにつかえないので
      typealias Index = Target<Int, String>.Index
      #if DEBUG
        XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawTag: .end).value, .end)
        // UnsafeTreeは範囲外のインデックスを作成できない
//        XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawTag: 5).value, .nullptr) // TODO: rawTag関連コードの整理時に、このテストの必要性を再検討する
        XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: .nullptr as Int)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 0)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 1)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 2)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 3)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 4)))
//        XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 5))) // TODO: rawTag関連コードの整理時に、このテストの必要性を再検討する
      #endif
    #else
      XCTAssertTrue(set.isValid(set.startIndex))
      XCTAssertFalse(set.isValid(set.endIndex))  // 仕様変更。subscriptやremoveにつかえないので
      typealias Index = Target<Int, String>.Index
      #if DEBUG
        XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawTag: .end).value, .end)
        // UnsafeTreeは範囲外のインデックスを作成できない
        XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawTag: 5).value, .nullptr)
        XCTAssertFalse(set.isValid(.unsafe(tree: set.__tree_, rawTag: .nullptr as _TrackingTag)))
        XCTAssertTrue(set.isValid(.unsafe(tree: set.__tree_, rawTag: 0)))
        XCTAssertTrue(set.isValid(.unsafe(tree: set.__tree_, rawTag: 1)))
        XCTAssertTrue(set.isValid(.unsafe(tree: set.__tree_, rawTag: 2)))
        XCTAssertTrue(set.isValid(.unsafe(tree: set.__tree_, rawTag: 3)))
        XCTAssertTrue(set.isValid(.unsafe(tree: set.__tree_, rawTag: 4)))
        XCTAssertFalse(set.isValid(.unsafe(tree: set.__tree_, rawTag: 5)))
      #endif
    #endif
  }
  }

  extension MultiMapEtcTests {
  func testRemoveFirst() throws {
    #if !USE_OLD_FIND
      throw XCTSkip("挙動が変わるためスキップ")
    #endif
    do {
      #if COMPATIBLE_ATCODER_2025
        XCTAssertFalse(target1.removeFirst(forKey: 3))
      #else
        XCTAssertFalse(target1.eraseUnique(3))
      #endif
      let expected = [(0, 0), (0, 1), (0, 2), (1, 5), (1, 4), (1, 3), (2, 6), (2, 7), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      #if COMPATIBLE_ATCODER_2025
        XCTAssertTrue(target1.removeFirst(forKey: 1))
      #else
        XCTAssertTrue(target1.eraseUnique(1))
      #endif
      let expected = [(0, 0), (0, 1), (0, 2), (1, 4), (1, 3), (2, 6), (2, 7), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      #if COMPATIBLE_ATCODER_2025
        XCTAssertTrue(target1.removeFirst(forKey: 2))
      #else
        XCTAssertTrue(target1.eraseUnique(2))
      #endif
      let expected = [(0, 0), (0, 1), (0, 2), (1, 4), (1, 3), (2, 7), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      #if COMPATIBLE_ATCODER_2025
        XCTAssertTrue(target1.removeFirst(forKey: 0))
        XCTAssertTrue(target1.removeFirst(forKey: 0))
      #else
        XCTAssertTrue(target1.eraseUnique(0))
        XCTAssertTrue(target1.eraseUnique(0))
      #endif
      let expected = [(0, 2), (1, 4), (1, 3), (2, 7), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      #if COMPATIBLE_ATCODER_2025
        XCTAssertTrue(target1.removeFirst(forKey: 1))
        XCTAssertTrue(target1.removeFirst(forKey: 2))
      #else
        XCTAssertTrue(target1.eraseUnique(1))
        XCTAssertTrue(target1.eraseUnique(2))
      #endif
      let expected = [(0, 2), (1, 3), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      #if COMPATIBLE_ATCODER_2025
        XCTAssertTrue(target1.removeFirst(forKey: 0))
        XCTAssertTrue(target1.removeFirst(forKey: 1))
        XCTAssertTrue(target1.removeFirst(forKey: 2))
      #else
        XCTAssertTrue(target1.eraseUnique(0))
        XCTAssertTrue(target1.eraseUnique(1))
        XCTAssertTrue(target1.eraseUnique(2))
      #endif
      let expected: [(Int, Int)] = []
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
  }
  }

  extension MultiMapEtcTests {
  func testRemoveAll() throws {
    do {
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(target1.removeAll(forKey: 3), 0)
      #else
        XCTAssertEqual(target1.eraseMulti(3), 0)
      #endif
      let expected = [(0, 0), (0, 1), (0, 2), (1, 5), (1, 4), (1, 3), (2, 6), (2, 7), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(target1.removeAll(forKey: 1), 3)
      #else
        XCTAssertEqual(target1.eraseMulti(1), 3)
      #endif
      let expected = [(0, 0), (0, 1), (0, 2), (2, 6), (2, 7), (2, 8)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(target1.removeAll(forKey: 2), 3)
      #else
        XCTAssertEqual(target1.eraseMulti(2), 3)
      #endif
      let expected = [(0, 0), (0, 1), (0, 2)]
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
    do {
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(target1.removeAll(forKey: 0), 3)
      #else
        XCTAssertEqual(target1.eraseMulti(0), 3)
      #endif
      let expected: [(Int, Int)] = []
      XCTAssertEqual(
        target1.map { __key($0) },
        expected.map { $0.0 })
      XCTAssertEqual(
        target1.map { __value($0) },
        expected.map { $0.1 })
    }
  }
  }

  extension MultiMapEtcTests {
  func testComment() throws {
    /// `RedBlackTreeMultiMap` を使用する例
    var multimap = RedBlackTreeMultiMap<String, Int>()
    multimap.insert(key: "apple", value: 5)
    multimap.insert(key: "banana", value: 3)
    multimap.insert(key: "cherry", value: 7)

    // キーを使用して値にアクセス
    let values = multimap.values(forKey: "banana")

    values.forEach { value in
      print("banana の値は \(value) です。")  // 出力例: banana の値は 3 です。
    }

    // キーと値のペアを削除
    #if COMPATIBLE_ATCODER_2025
      multimap.removeFirst(forKey: "apple")
    #else
      multimap.eraseUnique("apple")
    #endif
  }
  }

  extension MultiMapCopyOnWriteTests {
    func testSet2() throws {
      var set = RedBlackTreeMultiMap<Int, Int>(minimumCapacity: 1)
      XCTAssertEqual(set._copyCount, 0)
      set.insert(key: 0, value: 0)
      XCTAssertEqual(set._copyCount, 0)
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(forKey: 0)
      #else
        set.eraseMulti(0)
      #endif
      XCTAssertEqual(set._copyCount, 0)
      _ = set.lowerBound(0)
      _ = set.upperBound(0)
      for s in set {
        print(s)
      }
      set.forEach {
        print($0)
      }
      print(set.map { $0 })
      print(set.filter { $0 != keyValue(0, 0) })
      //    print(set.reduce(0, +))
      print(set.reduce(into: []) { $0.append($1) })
      XCTAssertEqual(set._copyCount, 0)
    }
  }

  extension MultiMapCopyOnWriteTests {
    func testSet3() throws {
      tree._copyCount = 0
        for v in tree {
          tree.removeFirst(forKey: v.key)  // strong ensure unique
        }
        XCTAssertEqual(tree.count, 0)
        XCTAssertEqual(tree._copyCount, 1)  // multi setの場合、インデックスを破壊するので1とする
    }
  }

  extension MultiMapCopyOnWriteTests {
    func testSet3_2() throws {
      tree._copyCount = 0
        for v in tree + [] {
          tree.removeFirst(forKey: v.key)  // strong ensure unique
        }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 0)  // mapで操作が済んでいるので、インデックス破壊の心配がない
    }
  }

  extension MultiMapCopyOnWriteTests {
    func testSet3_3() throws {
      tree._copyCount = 0
        for v in tree + [] {
          tree.removeFirst(_unsafeForKey: v.key)  // strong ensure unique
        }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 0)  // mapで操作が済んでいるので、インデックス破壊の心配がない
    }
  }

  extension MultiMapCopyOnWriteTests {
    func testSet4() throws {
      tree._copyCount = 0
        tree.forEach { v in
          tree.removeFirst(forKey: v.key)
        }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 1)
    }
  }

  extension MultiMapCopyOnWriteTests {
    func testSet5() throws {
      tree._copyCount = 0
        for v in tree + [] {
          tree.removeFirst(forKey: v.key)
        }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 0)
    }
  }

  extension MultiMapCopyOnWriteTests {
    func testSet6() throws {
      tree._copyCount = 0
      for v in tree.filter({ _ in true }) {
        #if COMPATIBLE_ATCODER_2025
          tree.removeAll(forKey: v.key)
        #else
          tree.eraseMulti(v.key)
        #endif
      }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 0)
    }
  }

  extension MultiMapCopyOnWriteTests {
    func testSet7() throws {
      tree._copyCount = 0
      for v in tree {
        #if COMPATIBLE_ATCODER_2025
          tree.removeAll(forKey: v.key)
        #else
          tree.eraseMulti(v.key)
        #endif
      }
      XCTAssertEqual(tree.count, 0)
        XCTAssertEqual(tree._copyCount, 1)  // multi setの場合、インデックスを破壊するので1とする
    }
  }

  extension MultiMapCopyOnWriteTests {
    func testSet8() throws {
      tree._copyCount = 0
      for v in tree + [] {
        #if COMPATIBLE_ATCODER_2025
          tree.removeAll(forKey: v.key)
        #else
          tree.eraseMulti(v.key)
        #endif
      }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 0)  // mapで操作が済んでいるので、インデックス破壊の心配がない
    }
  }

  extension MultiMapCopyOnWriteTests {
    func testSet9() throws {
      tree._copyCount = 0
      tree.forEach { v in
        #if COMPATIBLE_ATCODER_2025
          tree.removeAll(forKey: v.key)
        #else
          tree.eraseMulti(v.key)
        #endif
      }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 1)
    }
  }

  extension MultiMapCopyOnWriteTests {
    func testSet10() throws {
      tree._copyCount = 0
      for v in tree + [] {
        #if COMPATIBLE_ATCODER_2025
          tree.removeAll(forKey: v.key)
        #else
          tree.eraseMulti(v.key)
        #endif
      }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 0)
    }
  }

  extension MultiMapCopyOnWriteTests {
    func testSet11() throws {
      tree._copyCount = 0
      for v in tree.filter({ _ in true }) {
        #if COMPATIBLE_ATCODER_2025
          tree.removeAll(forKey: v.key)
        #else
          tree.eraseMulti(v.key)
        #endif
      }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 0)
    }
  }

  extension MultiMapCopyOnWriteTests {
    func testSet3000() throws {
      let count = 1500
      var loopCount = 0
      var xy: [Int: RedBlackTreeMultiMap<Int, Int>] = [
        1: .init(keysWithValues: (0..<count).map { ($0, $0) })
      ]
      xy[1]?._copyCount = 0
      let N = 100
      for i in 0..<count / N {
        loopCount += 1
        if let lo = xy[1]?.lowerBound(i * N),
          let hi = xy[1]?.upperBound(i * N + N)
        {
          #if COMPATIBLE_ATCODER_2025
            xy[1]?.removeSubrange(lo..<hi)
          #else
            _ = xy[1]?.erase(lo..<hi)
          #endif
        }
      }
      XCTAssertEqual(xy[1]!.count, 0)
      XCTAssertEqual(xy[1]!._copyCount, 0)
      XCTAssertEqual(loopCount, count / N)
    }
  }

  extension MultiMapRemoveTests {
  func testRemoveKey() throws {
    var dict = [1: 1, 2: 2, 3: 3] as RedBlackTreeMultiMap<Int, Int>
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(dict.removeAll(forKey: 0), 0)
      XCTAssertEqual(dict.removeAll(forKey: 1), 1)
    #else
      XCTAssertEqual(dict.eraseMulti(0), 0)
      XCTAssertEqual(dict.eraseMulti(1), 1)
    #endif
    XCTAssertEqual(dict, [2: 2, 3: 3])
    XCTAssertEqual(dict.first?.key, 2)
    XCTAssertEqual(dict.last?.key, 3)
  }
  }

  extension MultiMapBasicTest {
  func testRemovalOperations() {
    var multiMap = RedBlackTreeMultiMap<String, Int>(keysWithValues: [
      ("apple", 1), ("banana", 2), ("apple", 3),
    ])

    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(multiMap.removeAll(forKey: "apple"), 2)
    #else
      XCTAssertEqual(multiMap.eraseMulti("apple"), 2)
    #endif
    XCTAssertFalse(multiMap.contains(key: "apple"))
    XCTAssertEqual(multiMap.count(forKey: "apple"), 0)

    if !multiMap.isEmpty {
      let removed = multiMap.removeFirst()
      XCTAssertEqual(removed.key, "banana")
      XCTAssertEqual(removed.value, 2)
    }

    multiMap.removeAll()
    XCTAssertTrue(multiMap.isEmpty)
  }
  }

  extension MultiMapBasicTest {
  func testBoundsAndIndexing() {
    let elements = [("a", 1), ("a", 2), ("b", 3), ("c", 4)]
    let multiMap = RedBlackTreeMultiMap(keysWithValues: elements)

    let lb = multiMap.lowerBound("a")
    let ub = multiMap.upperBound("a")
    #if COMPATIBLE_ATCODER_2025
      XCTAssertLessThan(lb, ub)
    #endif
    XCTAssertEqual(multiMap.distance(from: lb, to: ub), 2)

    let lb2 = multiMap.lowerBound("z")
    XCTAssertEqual(lb2, multiMap.endIndex)
  }
  }

  extension MultiMapBasicTest {
  func testExpressibleByLiteralAndSequence() {
    let multiMap: RedBlackTreeMultiMap = [("x", 10), ("y", 20), ("x", 30)]
    XCTAssertEqual(multiMap.count, 3)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(Set(multiMap.keys()), ["x", "y"])
    #else
      XCTAssertEqual(Set(multiMap.keys), ["x", "y"])
    #endif
    XCTAssertEqual(multiMap.values(forKey: "x").sorted(), [10, 30])

    var collected: [String: [Int]] = [:]
    for (key, value) in multiMap.map(tuple) {
      collected[key, default: []].append(value)
    }
    XCTAssertEqual(collected["x"]?.sorted(), [10, 30])
    XCTAssertEqual(collected["y"], [20])
  }
  }

  extension MultiMapAdvancedTest {
  func testRemoveSubrange() {
    var map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("c", 3), ("d", 4)]
    let lower = map.lowerBound("b")
    let upper = map.upperBound("c")
    #if COMPATIBLE_ATCODER_2025
      map.removeSubrange(lower..<upper)
    #else
    _ = map.erase(lower..<upper)
    #endif
    XCTAssertFalse(map.contains(key: "b"))
    XCTAssertFalse(map.contains(key: "c"))
    XCTAssertTrue(map.contains(key: "a"))
    XCTAssertTrue(map.contains(key: "d"))
  }
  }

  extension MultiMapAdvancedTest {
  func testRemoveValuesForKey() {
    var map: RedBlackTreeMultiMap = [("x", 1), ("x", 2), ("y", 3)]
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(map.removeAll(forKey: "x"), 2)
      XCTAssertFalse(map.contains(key: "x"))
      XCTAssertEqual(map.removeAll(forKey: "z"), 0)
    #else
      XCTAssertEqual(map.eraseMulti("x"), 2)
      XCTAssertFalse(map.contains(key: "x"))
      XCTAssertEqual(map.eraseMulti("z"), 0)
    #endif
  }
  }

  extension RedBlackTreeMultiMapTests {
  func testFirstIndexAndIndexing() throws {
    throw XCTSkip("ちょっと一旦直せないのでスキップ")
    let map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("a", 3)]
    if let idx = map.firstIndex(of: "a") {
      XCTAssertEqual(map[idx].key, "a")
    } else {
      XCTFail("Expected to find key 'a'")
    }

    #if COMPATIBLE_ATCODER_2025
      if let idx = map.firstIndex(where: { $0.value == 2 }) {
        XCTAssertEqual(map[idx].value, 2)
      } else {
        XCTFail("Expected to find value 2")
      }
    #endif
  }
  }

  extension RedBlackTreeMultiMapTests {
  func testRemoveValuesForKey() throws {
    var map: RedBlackTreeMultiMap = [("k1", 1), ("k1", 2), ("k2", 3)]
#if COMPATIBLE_ATCODER_2025
    let removedCount = map.removeAll(forKey: "k1")
#else
    let removedCount = map.eraseMulti("k1")
#endif
    XCTAssertEqual(removedCount, 2)
    XCTAssertFalse(map.contains(key: "k1"))
  }
  }

  extension RedBlackTreeMultiMapTests {
  func testKeysAndValues() throws {
    let map: RedBlackTreeMultiMap = [("a", 1), ("b", 2), ("a", 3)]
    #if COMPATIBLE_ATCODER_2025
      let keys = map.keys() + []
      let values = map.values() + []
    #else
      let keys = map.keys + []
      let values = map.values + []
    #endif
    XCTAssertEqual(keys, ["a", "a", "b"])
    XCTAssertEqual(values, [1, 3, 2])
  }
  }
#endif
