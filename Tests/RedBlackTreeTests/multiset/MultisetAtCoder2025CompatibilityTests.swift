import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultisetSubSequenceTests {
    func testSliceIndexOffsetting() {
      let m: RedBlackTreeMultiSet = [5, 5, 6, 7, 7, 8]
      let slice = m.elements(in: 5...7)  // 5,5,6,7,7

      let idx = slice.index(slice.startIndex, offsetBy: 3)
      XCTAssertEqual(slice[idx], 7)

      // limitedBy: 成功
      let ok = slice.index(
        slice.startIndex, offsetBy: 4,
        limitedBy: slice.endIndex)
      XCTAssertNotNil(ok)
      XCTAssertEqual(slice[ok!], 7)

      // limitedBy: 失敗 → nil
      let fail = slice.index(
        slice.startIndex, offsetBy: 10,
        limitedBy: slice.endIndex)
      XCTAssertNil(fail)
    }

    // MARK: 距離の対称性 ---------------------------------------------------

    func testDistanceSymmetry() {
      let ms: RedBlackTreeMultiSet = [0, 1, 1, 2, 3, 3, 4, 4, 4]
      let slice = ms.elements(in: 1...3)  // 1,1,2,3,3
      let i = slice.index(slice.startIndex, offsetBy: 1)  // 2番目 (1)
      let j = slice.index(slice.startIndex, offsetBy: 4)  // 5番目 (3)
      XCTAssertEqual(slice.distance(from: i, to: j), 3)
      XCTAssertEqual(slice.distance(from: j, to: i), -3)
    }

    // MARK: index invalidation after base mutation ------------------------

    func testIndexInvalidationAfterBaseMutation() throws {
      #if !USE_OLD_FIND
        throw XCTSkip("挙動が変わるためスキップ")
      #endif

      var base: RedBlackTreeMultiSet = [1, 1, 2, 2, 3]
      let slice = base.elements(in: 1...2)  // 1,1,2,2

      let idx = slice.firstIndex(of: 1)!  // 指すノードは 1
      _ = base.remove(1)  // 重複 1 個削除 (木再構成)

      XCTAssertFalse(base.isValid(index: idx))

      throw XCTSkip("setと統一の動作ならばFalseだが、multiset特有の事情でCoWが発生するため、未対応")

      //    XCTAssertFalse(slice.isValid(index: idx))
    }
  }

  extension MultisetPointerTests {
    func testPointerNext() throws {
      XCTAssertEqual(members.startIndex.pointee, 0)
      XCTAssertEqual(members.startIndex.next?.pointee, 0)
      XCTAssertEqual(members.startIndex.next?.next?.pointee, 1)
      XCTAssertEqual(members.startIndex.next?.next?.next?.pointee, 2)
      XCTAssertEqual(members.startIndex.next?.next?.next?.next?.pointee, 2)
      XCTAssertEqual(members.startIndex.next?.next?.next?.next?.next, members.endIndex)
      XCTAssertNil(members.startIndex.next?.next?.next?.next?.next?.next)
      XCTAssertNil(members.endIndex.next)
    }

    func testPointer2() throws {
      if let it = members.startIndex.next {
        XCTAssertFalse(members.___is_garbaged(it))
        XCTAssertEqual(it.pointee, 0)
        XCTAssertNotNil(it.previous)
        XCTAssertNotNil(it.next)
        members.remove(at: it)
        XCTAssertTrue(members.___is_garbaged(it))
        throw XCTSkip("CoWの挙動変更のため")
        XCTAssertNil(it.pointee)
        XCTAssertNil(it.previous)
        XCTAssertNil(it.next)
      }
    }

    func testPointerPrev() throws {
      XCTAssertNil(members.endIndex.pointee)
      XCTAssertEqual(members.endIndex.previous?.pointee, 2)
      XCTAssertEqual(members.endIndex.previous?.previous?.pointee, 2)
      XCTAssertEqual(members.endIndex.previous?.previous?.previous?.pointee, 1)
      XCTAssertEqual(members.endIndex.previous?.previous?.previous?.previous?.pointee, 0)
      XCTAssertEqual(members.endIndex.previous?.previous?.previous?.previous?.previous?.pointee, 0)
      XCTAssertEqual(
        members.endIndex.previous?.previous?.previous?.previous?.previous, members.startIndex)
      XCTAssertNil(members.endIndex.previous?.previous?.previous?.previous?.previous?.previous)
      XCTAssertNil(members.startIndex.previous)
    }

    func testPointerOffset0() throws {
      XCTAssertEqual((members.startIndex).pointee, 0)
      XCTAssertEqual(members.startIndex.advanced(by: 1).pointee, 0)
      XCTAssertEqual(members.startIndex.advanced(by: 2).pointee, 1)
      XCTAssertEqual(members.startIndex.advanced(by: 3).pointee, 2)
      XCTAssertEqual(members.startIndex.advanced(by: 4).pointee, 2)
      XCTAssertNil(members.startIndex.advanced(by: 5).pointee)
      XCTAssertEqual(members.startIndex.advanced(by: 5), members.endIndex)
      XCTAssertNil(members.startIndex.advanced(by: 6).pointee)
    }

    func testPointerOffset2() throws {
      XCTAssertNil((members.endIndex).pointee)
      XCTAssertEqual(members.endIndex.advanced(by: -1).pointee, 2)
      XCTAssertEqual(members.endIndex.advanced(by: -2).pointee, 2)
      XCTAssertEqual(members.endIndex.advanced(by: -3).pointee, 1)
      XCTAssertEqual(members.endIndex.advanced(by: -4).pointee, 0)
      XCTAssertEqual(members.endIndex.advanced(by: -5).pointee, 0)
      XCTAssertEqual(members.endIndex.advanced(by: -5), members.startIndex)
      XCTAssertNil(members.startIndex.advanced(by: -6).pointee)
    }
  }

  extension MultisetTests {
    func testRandom() throws {
      var set = RedBlackTreeMultiSet<Int>()
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.insert(i)
        XCTAssertTrue(set.___tree_invariant())
      }
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.removeAll(i)
        XCTAssertTrue(set.___tree_invariant())
      }
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.insert(i)
        XCTAssertTrue(set.___tree_invariant())
      }
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.removeAll(i)
        XCTAssertTrue(set.___tree_invariant())
      }
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.insert(i)
        XCTAssertTrue(set.___tree_invariant())
      }
      #if COMPATIBLE_ATCODER_2025
        for i in set {
          set.removeAll(i)
          XCTAssertTrue(set.___tree_invariant())
        }
      #endif
    }

    func testRandom2() throws {
      var set = RedBlackTreeMultiSet<Int>()
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.insert(i)
        XCTAssertTrue(set.___tree_invariant())
      }
      XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.removeAll(i)
        XCTAssertTrue(set.___tree_invariant())
      }
      XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.insert(i)
        XCTAssertTrue(set.___tree_invariant())
      }
      XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.removeAll(i)
        XCTAssertTrue(set.___tree_invariant())
      }
      XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
      for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
        set.insert(i)
        XCTAssertTrue(set.___tree_invariant())
      }
      XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
      print("set.count", set.count)
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        print("set._copyCount", set._copyCount)
      #endif
      #if COMPATIBLE_ATCODER_2025
        for i in set[set.startIndex..<set.endIndex] {
          // erase multiなので、CoWなしだと、ポインタが破壊される
          set.removeAll(i)
          XCTAssertTrue(set.___tree_invariant())
        }
      #endif
    }
  }

  extension MultisetTests {
    func testRedBlackTreeConveniences() throws {
      let numbers: RedBlackTreeMultiSet = [1, 3, 5, 7, 9]

      XCTAssertEqual(numbers.lessThan(4), 3)
      XCTAssertEqual(numbers.lessThanOrEqual(4), 3)
      XCTAssertEqual(numbers.lessThan(5), 3)
      XCTAssertEqual(numbers.lessThanOrEqual(5), 5)

      XCTAssertEqual(numbers.greaterThan(6), 7)
      XCTAssertEqual(numbers.greaterThanOrEqual(6), 7)
      XCTAssertEqual(numbers.greaterThan(5), 7)
      XCTAssertEqual(numbers.greaterThanOrEqual(5), 5)
    }
  }

  extension MultisetTests {
    func testSubsequence() throws {
      var set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
      let sub = set[2..<4]
      XCTAssertEqual(sub[set.lowerBound(2)], 2)
      XCTAssertEqual(sub[set.lowerBound(3)], 3)
      XCTAssertEqual(set.upperBound(3), sub.endIndex)
      XCTAssertEqual(set.lowerBound(4), sub.endIndex)
      XCTAssertEqual(sub.count, 2)
      XCTAssertEqual(sub.map { $0 }, [2, 3])
      #if COMPATIBLE_ATCODER_2025
        set.remove(contentsOf: 2..<4)
        XCTAssertEqual(set.map { $0 }, [1, 4, 5])
      #endif
    }

    func testSubsequence2() throws {
      var set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
      let sub = set.elements(in: 2...4)
      XCTAssertEqual(sub[set.lowerBound(2)], 2)
      XCTAssertEqual(sub[set.lowerBound(4)], 4)
      XCTAssertEqual(set.upperBound(4), sub.endIndex)
      XCTAssertEqual(set.lowerBound(5), sub.endIndex)
      XCTAssertEqual(sub.count, 3)
      XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
      #if COMPATIBLE_ATCODER_2025
        set.remove(contentsOf: 2...4)
        XCTAssertEqual(set.map { $0 }, [1, 5])
      #endif
    }
  }

  extension MultisetTests {
    func testSubsequence5() throws {
      let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
      let sub = set.elements(in: 1..<3)
      XCTAssertEqual(sub[set.lowerBound(1)..<set.lowerBound(3)].map { $0 }, [1, 2])
      XCTAssertEqual(sub[sub.startIndex..<sub.endIndex].map { $0 }, [1, 2])
      XCTAssertEqual(sub[sub.startIndex..<sub.index(before: sub.endIndex)].map { $0 }, [1])
      XCTAssertEqual(sub.map { $0 }, [1, 2])
      XCTAssertEqual(set.elements(in: 1..<3).map { $0 }, [1, 2])
    }

    func testSubsequence6() throws {
      let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
      let sub = set.elements(in: 2..<3)
      XCTAssertEqual(sub.map { $0 }, [2, 2, 2])
      XCTAssertEqual(sub[set.lowerBound(2)..<set.lowerBound(3)].map { $0 }, [2, 2, 2])
      XCTAssertEqual(sub[sub.startIndex..<sub.endIndex].map { $0 }, [2, 2, 2])
      XCTAssertEqual(sub[sub.startIndex..<sub.index(before: sub.endIndex)].map { $0 }, [2, 2])
      XCTAssertEqual(set.elements(in: 2..<3).map { $0 }, [2, 2, 2])
    }

    func testSubsequence7() throws {
      let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
      let sub = set.elements(in: 2...2)
      XCTAssertEqual(sub.map { $0 }, [2, 2, 2])
      XCTAssertEqual(sub[set.lowerBound(2)..<set.upperBound(2)].map { $0 }, [2, 2, 2])
      XCTAssertEqual(sub[sub.startIndex..<sub.endIndex].map { $0 }, [2, 2, 2])
      XCTAssertEqual(sub[sub.startIndex..<sub.index(before: sub.endIndex)].map { $0 }, [2, 2])
      XCTAssertEqual(set.elements(in: 2..<3).map { $0 }, [2, 2, 2])
    }
  }

  #if DEBUG
    extension MultisetTests {
      func testSubSeqSubscript() throws {
        let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
        XCTAssertEqual(set.elements(in: 2..<4)[set.startIndex + 2], 3)
        var a = 0
        set.elements(in: 2...4).forEach {
          a += $0
        }
        XCTAssertEqual(a, 2 + 3 + 4)
      }
    }
  #endif

  extension MultisetTests {
    func testAdd() throws {
      do {
        let a = RedBlackTreeMultiSet<Int>([0, 1])
        let b = RedBlackTreeMultiSet<Int>([0, 1])
        //      a.meld(b)
        XCTAssertEqual((a + b) + [], [0, 0, 1, 1])
      }
      do {
        let a = RedBlackTreeMultiSet<Int>([0, 1])
        let b = RedBlackTreeMultiSet<Int>([1, 2])
        //      a.meld(b)
        XCTAssertEqual((a + b) + [], [0, 1, 1, 2])
      }
      do {
        let a = RedBlackTreeMultiSet<Int>([0, 1])
        let b = RedBlackTreeMultiSet<Int>([2, 3])
        //      a.meld(b)
        XCTAssertEqual((a + b) + [], [0, 1, 2, 3])
      }
      do {
        let a = RedBlackTreeMultiSet<Int>([0, 1])
        let b = RedBlackTreeMultiSet<Int>([0, 1])
        //      a.meld(b)
        XCTAssertEqual((a + b) + [], [0, 0, 1, 1])
      }
      do {
        let a = RedBlackTreeMultiSet<Int>([1, 2])
        let b = RedBlackTreeMultiSet<Int>([0, 1])
        //      a.meld(b)
        XCTAssertEqual((a + b) + [], [0, 1, 1, 2])
      }
      do {
        let a = RedBlackTreeMultiSet<Int>([2, 3])
        let b = RedBlackTreeMultiSet<Int>([0, 1])
        //      a.meld(b)
        XCTAssertEqual((a + b) + [], [0, 1, 2, 3])
      }
    }

    func testAddEqual() throws {
      do {
        var a = RedBlackTreeMultiSet<Int>([0, 1])
        let b = RedBlackTreeMultiSet<Int>([0, 1])
        a += b
        XCTAssertEqual(a + [], [0, 0, 1, 1])
      }
      do {
        var a = RedBlackTreeMultiSet<Int>([0, 1])
        let b = RedBlackTreeMultiSet<Int>([1, 2])
        a += b
        XCTAssertEqual(a + [], [0, 1, 1, 2])
      }
      do {
        var a = RedBlackTreeMultiSet<Int>([0, 1])
        let b = RedBlackTreeMultiSet<Int>([2, 3])
        a += b
        XCTAssertEqual(a + [], [0, 1, 2, 3])
      }
      do {
        var a = RedBlackTreeMultiSet<Int>([0, 1])
        let b = RedBlackTreeMultiSet<Int>([0, 1])
        a += b
        XCTAssertEqual(a + [], [0, 0, 1, 1])
      }
      do {
        var a = RedBlackTreeMultiSet<Int>([1, 2])
        let b = RedBlackTreeMultiSet<Int>([0, 1])
        a += b
        XCTAssertEqual(a + [], [0, 1, 1, 2])
      }
      do {
        var a = RedBlackTreeMultiSet<Int>([2, 3])
        let b = RedBlackTreeMultiSet<Int>([0, 1])
        a += b
        XCTAssertEqual(a + [], [0, 1, 2, 3])
      }
    }
  }

  extension MultisetTests {
    func testLeftUnsafeSmoke() {
      typealias MultiSet = RedBlackTreeMultiSet<Int>
      #if DEBUG
        let repeatCount = 1
      #else
        let repeatCount = 100
      #endif
      for _ in 0..<repeatCount {
        let count = Int.random(in: 0..<1_000_000)
        let a = MultiSet(0..<count)
        do {
          var p: MultiSet.Index? = a.startIndex
          while p != a.endIndex {
            p = p?.next
          }
        }
        do {
          var p: MultiSet.Index? = a.endIndex
          while p != a.startIndex {
            p = p?.previous
          }
        }
        do {
          _ = a.equalRange(Int.random(in: 0..<count))
        }
        do {
          _ = a.min()
        }
      }
    }
  }

  extension MultisetTests {
    func testForEach_enumeration() throws {
      let source = [0, 1, 2, 3, 4, 5]
      let a = RedBlackTreeMultiSet<Int>(naive: source)
      var p: RedBlackTreeMultiSet<Int>.Index? = a.startIndex
      a.forEach { i, v in
        XCTAssertEqual(i, p)
        XCTAssertEqual(a[p!], v)
        p = p?.next
      }
    }
  }

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    extension MultisetCopyOnWriteTests {
      func testSet4000() throws {
        let count = 1500
        var xy: [Int: RedBlackTreeMultiSet<Int>] = [1: .init(0..<count)]
        xy[1]?._copyCount = 0
        let N = 100
        var loopCount = 0
        for i in 0..<count / N {
          loopCount += 1
          xy[1]?.elements(in: (i * N)..<(i * N + N)).forEach { i, v in
            xy[1]?.remove(at: i)
          }
        }
        XCTAssertEqual(xy[1]!.count, 0)
        XCTAssertEqual(xy[1]!._copyCount, 1, "CoW挙動変更に伴い修正")
        XCTAssertEqual(loopCount, count / N)
      }
    }
  #endif

  extension MultisetRemoveTests {
    func testSmokeRemove0() throws {
      var s: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })
      XCTAssertEqual(s + [], (0..<2_000).flatMap { [$0, $0] })
      for i in s {
        s.removeAll(i)
      }
    }

    func testSmokeRemove1() throws {
      var s: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })
      let b = s.lowerBound(0)
      let e = s.lowerBound(10_000)
      XCTAssertEqual(s[b..<e] + [], (0..<2_000).flatMap { [$0, $0] })
      XCTAssertEqual(s.elements(in: 0..<10_000) + [], (0..<2_000).flatMap { [$0, $0] })
      for i in s.elements(in: 0..<10_000) {
        s.removeAll(i)
      }
    }
  }

  extension MultisetRemoveTests {
    func testSmokeRemove2() throws {
      var s: RedBlackTreeMultiSet<Int> = .init((0..<2_000).flatMap { [$0, $0] })
      for i in s.elements(in: 0..<10_000) + [] {
        s.removeAll(i)
      }
    }
  }

  extension MultisetRemoveTests {
    func testRemoveSubrange() throws {
      for l in 0..<10 {
        for h in l...10 {
          var members: RedBlackTreeMultiSet = [1, 1, 3, 3, 5, 7, 9, 9]
          members.removeSubrange(members.lowerBound(l)..<members.upperBound(h))
          XCTAssertEqual(
            members.map { $0 }, [1, 1, 3, 3, 5, 7, 9, 9].filter { !(l...h).contains($0) })
        }
      }
    }

    func testRemoveWithIndices() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      for i in members.indices {
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices2() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      members.indices.forEach { i in
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices3() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      for i in members.indices.reversed() {
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices4() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      members.indices.reversed().forEach { i in
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }
  }

  #if DEBUG
    extension MultisetRemoveTests {
      func testRemoveWith___Indices() throws {
        var members = RedBlackTreeMultiSet<Int>(0..<10)
        for i in members.___node_positions() {
          members.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(members + [], [])
      }

      func testRemoveWith___Indices2() throws {
        var members = RedBlackTreeMultiSet<Int>(0..<10)
        members.___node_positions().forEach { i in
          members.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(members + [], [])
      }

      func testRemoveWith___Indices3() throws {
        var members = RedBlackTreeMultiSet<Int>(0..<10)
        members.___node_positions().reversed().forEach { i in
          members.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(members + [], [])
      }
    }
  #endif

  extension MultisetRemoveTests {
    func testRemoveWithSubIndices() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      for i in members.elements(in: 2..<8).indices {
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices2() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      members.elements(in: 2..<8).indices.forEach { i in
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices3() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      for i in members.elements(in: 2..<8).indices.reversed() {
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices4() throws {
      var members = RedBlackTreeMultiSet<Int>(0..<10)
      members.elements(in: 2..<8).indices.reversed().forEach { i in
        members.remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }
  }

  #if DEBUG
    extension MultisetRemoveTests {
      func testRemoveWithSub___Indices() throws {
        var members = RedBlackTreeMultiSet<Int>(0..<10)
        for i in members.elements(in: 2..<8).___node_positions() {
          members.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(members + [], [0, 1, 8, 9])
      }

      func testRemoveWithSub___Indices2() throws {
        var members = RedBlackTreeMultiSet<Int>(0..<10)
        members.elements(in: 2..<8).___node_positions().forEach { i in
          members.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(members + [], [0, 1, 8, 9])
      }

      func testRemoveWithSub___Indices4() throws {
        var members = RedBlackTreeMultiSet<Int>(0..<10)
        members.elements(in: 2..<8).___node_positions().reversed().forEach { i in
          members.__tree_._unchecked_remove(at: i)
        }
        XCTAssertEqual(members + [], [0, 1, 8, 9])
      }
    }
  #endif

  extension MultisetPerfomarnceTests {
    #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceFirstIndex4() throws {
        let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 - 1 }), s.index(before: s.endIndex))
        }
      }
    #endif

    #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceFirstIndex5() throws {
        let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 0 }), s.startIndex)
        }
      }
    #endif

    #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceFirstIndex6() throws {
        let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 }), nil)
        }
      }
    #endif
  }
  extension RedBlackTreeMultisetSubSequenceTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  extension MultisetTests {
  }

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    extension MultisetCopyOnWriteTests {
    }

    extension MultisetCopyOnWriteTests {
    }

    extension MultisetCopyOnWriteTests {
    }

    extension MultisetCopyOnWriteTests {
    }

    extension MultisetCopyOnWriteTests {
    }

    extension MultisetCopyOnWriteTests {
    }

    extension MultisetCopyOnWriteTests {
    }
  #endif

  extension MultisetRemoveTests {
  }

  extension MultisetRemoveTests {
  }

  extension MultisetRemoveTests {
  }

  extension RedBlackTreeMultisetCornerCaseTests {
  }

  extension RedBlackTreeMultisetCornerCaseTests {
  }

  extension RedBlackTreeMultisetCornerCaseTests {
  }

  extension RedBlackTreeMultisetCornerCaseTests {
  }
#endif
