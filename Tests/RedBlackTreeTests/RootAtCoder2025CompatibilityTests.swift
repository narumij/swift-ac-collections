import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if COMPATIBLE_ATCODER_2025
  extension Performaces {
      func testPerformanceExample4() throws {
        self.measure {
          var set = RedBlackTreeSet<Int>(0..<10_000_000)
          set
            .forEach { i, v in
              set.remove(at: i)
            }
        }
      }
  }

  extension Performaces {
      func testPerformanceExample7() throws {
        let set = RedBlackTreeSet<Int>(0..<10_000_000)
        self.measure {
          _ = set.firstIndex { $0 > 10_000_000 }
        }
      }
  }

  extension NaiveIteratorTests {
      func testWrappedForward() throws {
        let a = RedBlackTreeSet<Int>(0..<5)
        let wrapped = UnsafeIterator._RemoveAware(
          source: UnsafeIterator._Obverse1(
            _start: a.__tree_.__begin_node_,
            _end: a.__tree_.__end_node))
        XCTAssertEqual(wrapped.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5))
      }

      func testWrappedReverse() throws {
        let a = RedBlackTreeSet<Int>(0..<5)
        let wrapped = UnsafeIterator._RemoveAware(
          source: UnsafeIterator._Reverse1(
            _start: a.__tree_.__begin_node_,
            _end: a.__tree_.__end_node))
        XCTAssertEqual(wrapped.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5).reversed())
      }
  }

  extension ReferenceTests {
    func testExample() throws {
      var a = RedBlackTreeSet<DeinitializeCounter>((0..<3).map { DeinitializeCounter(num: $0) })
      XCTAssertEqual(Self.count, 3)
      for i in a.indices {
        a.remove(at: i)
      }
      XCTAssertEqual(Self.count, 0)
    }
  }

  extension EtcTests {
    func testExample4() throws {
      let b: RedBlackTreeSet<Int> = [1, 2, 3, 4]
      XCTAssertEqual(b.endIndex.distance(to: b.startIndex), -4)
      var result = [Int]()
      for p in b.startIndex..<b.endIndex {
        result.append(p.pointee!)
      }
      XCTAssertEqual(result, [1, 2, 3, 4])
      //    for p in stride(from: b.startIndex, to: b.endIndex, by: 1) {
      //      result.append(p.pointee!)
      //    }
      //    XCTAssertEqual(result, [1,2,3,4] + [1,2,3,4])
      //    for p in stride(from: b.endIndex.previous!, through: b.startIndex, by: -1) {
      //      result.append(p.pointee!)
      //    }
      //    XCTAssertEqual(result, [1,2,3,4] + [1,2,3,4] + [4,3,2,1])

      XCTAssertEqual(b.endIndex - b.startIndex, 4)
      XCTAssertEqual(b.startIndex + 4, b.endIndex)
      XCTAssertEqual(b.endIndex - 4, b.startIndex)

      for p in (b.startIndex..<b.endIndex).reversed() {
        result.append(p.pointee!)
      }

      //    XCTAssertEqual(b.endIndex.rawValue, .end)
      //    XCTAssertEqual(b.endIndex.advanced(by: 1).rawValue, .nullptr)
      //    XCTAssertEqual(b[b.endIndex.advanced(by: 1)], 0)
      //    let b = Array<Int>()
      //    var c = b.startIndex
      //    c = c.advanced(by: -1)
      //    print(b[c])
    }
  }

  extension EtcTests {
    func testIndices() throws {
      _ = RedBlackTreeSet<Int>().indices
      _ = RedBlackTreeMultiSet<Int>().indices
      _ = RedBlackTreeMultiMap<Int, Int>().indices
      _ = RedBlackTreeDictionary<Int, Int>().indices
      let s = RedBlackTreeSet<Int>()
      _ = s[s.startIndex..<s.endIndex].indices
    }
  }

  extension EtcTests {
    func testRange() throws {
      let a = [0, 1, 2]
      let b = RedBlackTreeSet<Int>([0, 1, 2])
      _ = a[0...]
      XCTAssertTrue(b[b.startIndex.advanced(by: 1)...].elementsEqual([1, 2]))
      XCTAssertEqual(b.endIndex.pointee, nil)
      XCTAssertEqual(b.endIndex.advanced(by: -1).pointee, 2)
      XCTAssertEqual(b.endIndex.advanced(by: -2).pointee, 1)
      XCTAssertEqual(a[...a.endIndex.advanced(by: -1)] + [], [0, 1, 2])
      XCTAssertEqual(a[..<a.endIndex.advanced(by: -1)] + [], [0, 1])
      XCTAssertNotEqual(b.endIndex, b.endIndex.advanced(by: -1))
      XCTAssertEqual(b[...b.endIndex.advanced(by: -1)] + [], [0, 1, 2])
      XCTAssertEqual(b[..<b.endIndex.advanced(by: -1)] + [], [0, 1])
      XCTAssertTrue(b[(b.startIndex + 1)...].elementsEqual([1, 2]))
      XCTAssertTrue(b[..<(b.endIndex - 1)].elementsEqual([0, 1]))
      XCTAssertTrue(b[...].elementsEqual([0, 1, 2]))
    }
  }

  extension EtcTests {
    func test_subSequence_index_offsetBy_limitedBy_and_formIndex_offsetBy_limitedBy2() throws {
      // 事前条件: 集合に[1,2,3,4,5]を用意すること
      let set = RedBlackTreeSet([1, 2, 3, 4, 5])
      let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [2,3,4]

      let start = sub.startIndex
      let limit = sub.index(after: start)

      // 実行: index(offsetBy:limitedBy:)とformIndex(offsetBy:limitedBy:)を呼び出すこと

      // index(offsetBy:limitedBy:)成功パターン
      let indexLimitedSuccess = sub.index(start, offsetBy: 1, limitedBy: limit)
      XCTAssertEqual(indexLimitedSuccess, limit)  // 事後条件: 成功時にlimitを返すこと

      // index(offsetBy:limitedBy:)失敗パターン
      let indexLimitedFail = sub.index(start, offsetBy: 3, limitedBy: limit)
      XCTAssertNil(indexLimitedFail)  // 事後条件: 失敗時にnilを返すこと

      // formIndex(offsetBy:limitedBy:)成功パターン
      var formIndexSuccess = start
      let success = sub.formIndex(&formIndexSuccess, offsetBy: 1, limitedBy: limit)
      XCTAssertTrue(success)  // 事後条件: 成功時にtrueを返すこと
      XCTAssertEqual(formIndexSuccess, limit)  // 事後条件: インデックスがlimitを指すこと

      // formIndex(offsetBy:limitedBy:)失敗パターン
      var formIndexFail = start
      let fail = sub.formIndex(&formIndexFail, offsetBy: 3, limitedBy: limit)
      XCTAssertFalse(fail)  // 事後条件: 失敗時にfalseを返すこと
      //    XCTAssertEqual(formIndexFail, start)  // 事後条件: インデックスが変わらないこと
      XCTAssertEqual(formIndexFail, limit)  // limitまで進んでいる。いつから？？？？
    }
  }

  extension EtcTests {
    func testBackwordIterator1() throws {
      let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
      let seq = AnySequence { set.indices.reversed() }
      var result: [Int] = []
      for i in seq {
        result.append(set[i])
      }
      XCTAssertEqual(set.reversed(), result)
    }

    func testBackwordIterator2() throws {
      var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
      let seq = AnySequence { set.reversed().indices }
      for i in seq {
        set.remove(at: i)
      }
      XCTAssertEqual(set + [], [])
      XCTAssertTrue(set.isEmpty)
    }
  }

  #if DEBUG
  extension EtcTests {
    func testRev() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [Int]()
      a.__tree_.___rev_for_each_(__p: a.startIndex.sealed, __l: a.endIndex.sealed) { p in
        result.append(p.index)
      }
      XCTAssertEqual(result, [2, 1, 0])
    }
  }
  #endif

  extension EtcTests {
    func testObv() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [RedBlackTreeSet<Int>.Index]()
      a.forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [a.startIndex + 0, a.startIndex + 1, a.startIndex + 2])
    }
  }

  extension EtcTests {
    func testSubObv() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [RedBlackTreeSet<Int>.Index]()
      a[a.startIndex..<a.endIndex].forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [a.startIndex + 0, a.startIndex + 1, a.startIndex + 2])
    }
  }

  extension EtcTests {
    func testRev2() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [RedBlackTreeSet<Int>.Index]()
      a.reversed().forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [a.startIndex + 2, a.startIndex + 1, a.startIndex + 0])
    }
  }

  extension EtcTests {
    func testSubRev2() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [RedBlackTreeSet<Int>.Index]()
      a[a.startIndex..<a.endIndex].reversed().forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [a.startIndex + 2, a.startIndex + 1, a.startIndex + 0])
    }

    func testSubRev3() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [RedBlackTreeSet<Int>.Index]()
      a[a.endIndex..<a.endIndex].reversed().forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [])
    }

    func testSubRev4() throws {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      var result = [RedBlackTreeSet<Int>.Index]()
      a[a.startIndex..<a.startIndex].reversed().forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [])
    }

    func testSubRev5() throws {
      let a = RedBlackTreeSet<Int>([0])
      var result = [RedBlackTreeSet<Int>.Index]()
      a[a.startIndex..<a.endIndex].reversed().forEach { i, p in
        result.append(i)
      }
      XCTAssertEqual(result, [a.startIndex])
    }
  }

  extension EtcTests {
    func testSubRev9() throws {
      let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
        ("a", 0), ("b", 1), ("c", 2),
      ])
      do {
        var result = [String]()
        #if COMPATIBLE_ATCODER_2025
          a[a.endIndex..<a.endIndex].reversed().keys().forEach { i in
            result.append(i)
          }
        #else
          a[a.endIndex..<a.endIndex].reversed().keys.forEach { i in
            result.append(i)
          }
        #endif
        XCTAssertEqual(result, [])
      }
      do {
        var result = [String]()
        #if COMPATIBLE_ATCODER_2025
          a[a.endIndex..<a.endIndex].keys().reversed().forEach { i in
            result.append(i)
          }
        #else
          a[a.endIndex..<a.endIndex].keys.reversed().forEach { i in
            result.append(i)
          }
        #endif
        XCTAssertEqual(result, [])
      }
    }

    func testSubRev10() throws {
      let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
        ("a", 0), ("b", 1), ("c", 2),
      ])
      do {
        var result = [String]()
        #if COMPATIBLE_ATCODER_2025
          a[a.startIndex..<a.startIndex].reversed().keys().forEach { i in
            result.append(i)
          }
        #else
          a[a.startIndex..<a.startIndex].reversed().keys.forEach { i in
            result.append(i)
          }
        #endif
        XCTAssertEqual(result, [])
      }
      do {
        var result = [String]()
        #if COMPATIBLE_ATCODER_2025
          a[a.startIndex..<a.startIndex].keys().reversed().forEach { i in
            result.append(i)
          }
        #else
          a[a.startIndex..<a.startIndex].keys.reversed().forEach { i in
            result.append(i)
          }
        #endif
        XCTAssertEqual(result, [])
      }
    }

    func testSubRev11() throws {
      let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
        ("a", 0), ("b", 1), ("c", 2),
      ])
      do {
        var result = [String]()
        #if COMPATIBLE_ATCODER_2025
          a[a.startIndex..<a.endIndex].reversed().keys().forEach { i in
            result.append(i)
          }
        #else
          a[a.startIndex..<a.endIndex].reversed().keys.forEach { i in
            result.append(i)
          }
        #endif
        XCTAssertEqual(result, ["c", "b", "a"])
      }
      do {
        var result = [String]()
        #if COMPATIBLE_ATCODER_2025
          a[a.startIndex..<a.endIndex].keys().reversed().forEach { i in
            result.append(i)
          }
        #else
          a[a.startIndex..<a.endIndex].keys.reversed().forEach { i in
            result.append(i)
          }
        #endif
        XCTAssertEqual(result, ["c", "b", "a"])
      }
    }

    func testSubRev12() throws {
      let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
        ("a", 0), ("b", 1), ("c", 2),
      ])
      do {
        var result = [Int]()
        #if COMPATIBLE_ATCODER_2025
          a[a.endIndex..<a.endIndex].reversed().values().forEach { i in
            result.append(i)
          }
        #else
          a[a.endIndex..<a.endIndex].reversed().values.forEach { i in
            result.append(i)
          }
        #endif
        XCTAssertEqual(result, [])
      }
      do {
        var result = [Int]()
        #if COMPATIBLE_ATCODER_2025
          a[a.endIndex..<a.endIndex].values().reversed().forEach { i in
            result.append(i)
          }
        #else
          a[a.endIndex..<a.endIndex].values.reversed().forEach { i in
            result.append(i)
          }
        #endif
        XCTAssertEqual(result, [])
      }
    }

    func testSubRev13() throws {
      let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
        ("a", 0), ("b", 1), ("c", 2),
      ])
      do {
        var result = [Int]()
        #if COMPATIBLE_ATCODER_2025
          a[a.startIndex..<a.startIndex].reversed().values().forEach { i in
            result.append(i)
          }
        #else
          a[a.startIndex..<a.startIndex].reversed().values.forEach { i in
            result.append(i)
          }
        #endif
        XCTAssertEqual(result, [])
      }
      do {
        var result = [Int]()
        #if COMPATIBLE_ATCODER_2025
          a[a.startIndex..<a.startIndex].values().reversed().forEach { i in
            result.append(i)
          }
        #else
          a[a.startIndex..<a.startIndex].values.reversed().forEach { i in
            result.append(i)
          }
        #endif
        XCTAssertEqual(result, [])
      }
    }

    func testSubRev14() throws {
      let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
        ("a", 0), ("b", 1), ("c", 2),
      ])
      do {
        var result = [Int]()
        #if COMPATIBLE_ATCODER_2025
          a[a.startIndex..<a.endIndex].reversed().values().forEach { i in
            result.append(i)
          }
        #else
          a[a.startIndex..<a.endIndex].reversed().values.forEach { i in
            result.append(i)
          }
        #endif
        XCTAssertEqual(result, [2, 1, 0])
      }
      do {
        var result = [Int]()
        #if COMPATIBLE_ATCODER_2025
          a[a.startIndex..<a.endIndex].values().reversed().forEach { i in
            result.append(i)
          }
        #else
          a[a.startIndex..<a.endIndex].values.reversed().forEach { i in
            result.append(i)
          }
        #endif
        XCTAssertEqual(result, [2, 1, 0])
      }
    }

    func testSubRev15() throws {
      let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
        ("a", 0), ("b", 1), ("c", 2),
      ])
      do {
        var result = [RedBlackTreeDictionary<String, Int>.Index]()
        a[a.endIndex..<a.endIndex].reversed().indices.forEach { i in
          result.append(i)
        }
        XCTAssertEqual(result, [])
      }
      do {
        var result = [RedBlackTreeDictionary<String, Int>.Index]()
        a[a.endIndex..<a.endIndex].indices.reversed().forEach { i in
          result.append(i)
        }
        XCTAssertEqual(result, [])
      }
    }

    func testSubRev16() throws {
      let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
        ("a", 0), ("b", 1), ("c", 2),
      ])
      do {
        var result = [RedBlackTreeDictionary<String, Int>.Index]()
        a[a.startIndex..<a.startIndex].reversed().indices.forEach { i in
          result.append(i)
        }
        XCTAssertEqual(result, [])
      }
      do {
        var result = [RedBlackTreeDictionary<String, Int>.Index]()
        a[a.startIndex..<a.startIndex].indices.reversed().forEach { i in
          result.append(i)
        }
        XCTAssertEqual(result, [])
      }
    }

    func testSubRev17() throws {
      let a = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: [
        ("a", 0), ("b", 1), ("c", 2),
      ])
      do {
        var result = [RedBlackTreeDictionary<String, Int>.Index]()
        a[a.startIndex..<a.endIndex].reversed().indices.forEach { i in
          result.append(i)
        }
        XCTAssertEqual(result, [2, 1, 0].map { a.startIndex + $0 })
      }
      do {
        var result = [RedBlackTreeDictionary<String, Int>.Index]()
        a[a.startIndex..<a.endIndex].indices.reversed().forEach { i in
          result.append(i)
        }
        XCTAssertEqual(result, [2, 1, 0].map { a.startIndex + $0 })
      }
    }
  }

  #if DEBUG
  extension EtcTests {
    func testMapBehavior() throws {
      let a = RedBlackTreeSet<Int>(0..<10)
      do {
        let n = a.count
        XCTAssertEqual(n, 10)

        var result = ContiguousArray<Int>()
        result.reserveCapacity(n)

        var i = a.startIndex

        for _ in 0..<n {
          result.append(a[i])
          a.formIndex(after: &i)
          XCTAssertNotEqual(i.rawValue, a.nullptr)
        }

        XCTAssertNotEqual(i.rawValue, a.nullptr)
        XCTAssertEqual(a.endIndex, i)
      }
    }
  }
  #endif
#endif
