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
#endif
