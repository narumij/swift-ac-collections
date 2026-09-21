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
      func testPerformanceFirstIndex4() throws {
        let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 - 1 }), s.index(before: s.endIndex))
        }
      }

      func testPerformanceFirstIndex5() throws {
        let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 0 }), s.startIndex)
        }
      }

      func testPerformanceFirstIndex6() throws {
        let s: RedBlackTreeMultiSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 }), nil)
        }
      }
  }
  extension RedBlackTreeMultisetSubSequenceTests {
  func testSliceCountFirstLast() {
    // 0 1 1 2 3 3 3 4
    let base: RedBlackTreeMultiSet = [0, 1, 1, 2, 3, 3, 3, 4]
    let slice = base.elements(in: 1...3)  // 1,1,2,3,3,3

    XCTAssertEqual(slice.count, 6)
    XCTAssertEqual(slice.first, 1)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(slice.last, 3)
      XCTAssertEqual(
        slice.distance(
          from: slice.startIndex,
          to: slice.endIndex), 6)
    #endif
  }
  }

  extension MultisetTests {
  func testRemove() throws {
    var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(set.removeAll(0), 0)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(1), 1)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(2), 2)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(3), 3)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(4), 4)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(0), nil)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(1), nil)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(2), nil)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(3), nil)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(4), nil)
      XCTAssertTrue(set.sorted().isEmpty)
    #else
      XCTAssertEqual(set.eraseMulti(0), 1)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(1), 1)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(2), 1)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(3), 1)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(4), 1)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(0), 0)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(1), 0)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(2), 0)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(3), 0)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(4), 0)
      XCTAssertTrue(set.sorted().isEmpty)
    #endif
  }
  }

  extension MultisetTests {
  func testContains() throws {
    var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set.count, 5)
    XCTAssertEqual(set.contains(-1), false)
    XCTAssertEqual(set.contains(0), true)
    XCTAssertEqual(set.contains(1), true)
    XCTAssertEqual(set.contains(2), true)
    XCTAssertEqual(set.contains(3), true)
    XCTAssertEqual(set.contains(4), true)
    XCTAssertEqual(set.contains(5), false)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(set.removeAll(1), 1)
      XCTAssertEqual(set.removeAll(3), 3)
      XCTAssertEqual(set.removeAll(1), nil)
      XCTAssertEqual(set.removeAll(3), nil)
    #else
      XCTAssertEqual(set.eraseMulti(1), 1)
      XCTAssertEqual(set.eraseMulti(3), 1)
      XCTAssertEqual(set.eraseMulti(1), 0)
      XCTAssertEqual(set.eraseMulti(3), 0)
    #endif
    XCTAssertEqual(set.sorted(), [0, 2, 4])
    XCTAssertEqual(set.contains(-1), false)
    XCTAssertEqual(set.contains(0), true)
    XCTAssertEqual(set.contains(1), false)
    XCTAssertEqual(set.contains(2), true)
    XCTAssertEqual(set.contains(3), false)
    XCTAssertEqual(set.contains(4), true)
    XCTAssertEqual(set.contains(5), false)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(set.removeAll(2), 2)
      XCTAssertEqual(set.removeAll(1), nil)
      XCTAssertEqual(set.removeAll(2), nil)
      XCTAssertEqual(set.removeAll(3), nil)
    #else
      XCTAssertEqual(set.eraseMulti(2), 1)
      XCTAssertEqual(set.eraseMulti(1), 0)
      XCTAssertEqual(set.eraseMulti(2), 0)
      XCTAssertEqual(set.eraseMulti(3), 0)
    #endif
    XCTAssertEqual(set.sorted(), [0, 4])
    XCTAssertEqual(set.contains(-1), false)
    XCTAssertEqual(set.contains(0), true)
    XCTAssertEqual(set.contains(1), false)
    XCTAssertEqual(set.contains(2), false)
    XCTAssertEqual(set.contains(3), false)
    XCTAssertEqual(set.contains(4), true)
    XCTAssertEqual(set.contains(5), false)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(set.removeAll(0), 0)
      XCTAssertEqual(set.removeAll(1), nil)
      XCTAssertEqual(set.removeAll(2), nil)
      XCTAssertEqual(set.removeAll(3), nil)
      XCTAssertEqual(set.removeAll(4), 4)
    #else
      XCTAssertEqual(set.eraseMulti(0), 1)
      XCTAssertEqual(set.eraseMulti(1), 0)
      XCTAssertEqual(set.eraseMulti(2), 0)
      XCTAssertEqual(set.eraseMulti(3), 0)
      XCTAssertEqual(set.eraseMulti(4), 1)
    #endif
    XCTAssertEqual(set.contains(-1), false)
    XCTAssertEqual(set.contains(0), false)
    XCTAssertEqual(set.contains(1), false)
    XCTAssertEqual(set.contains(2), false)
    XCTAssertEqual(set.contains(3), false)
    XCTAssertEqual(set.contains(4), false)
    XCTAssertEqual(set.contains(5), false)
    XCTAssertEqual(set.sorted(), [])
  }
  }

  extension MultisetTests {
  func testLeftRight() throws {
    var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set.count, 5)
    XCTAssertEqual(set.left(-1).index, 0)
    //      XCTAssertEqual(set.elements.count { $0 < -1 }, 0)
    XCTAssertEqual(set.left(0).index, 0)
    //      XCTAssertEqual(set.elements.count { $0 < 0 }, 0)
    XCTAssertEqual(set.left(1).index, 1)
    //      XCTAssertEqual(set.elements.count { $0 < 1 }, 1)
    XCTAssertEqual(set.left(2).index, 2)
    XCTAssertEqual(set.left(3).index, 3)
    XCTAssertEqual(set.left(4).index, 4)
    XCTAssertEqual(set.left(5).index, 5)
    XCTAssertEqual(set.left(6).index, 5)
    XCTAssertEqual(set.right(-1).index, 0)
    //      XCTAssertEqual(set.elements.count { $0 <= -1 }, 0)
    XCTAssertEqual(set.right(0).index, 1)
    //      XCTAssertEqual(set.elements.count { $0 <= 0 }, 1)
    XCTAssertEqual(set.right(1).index, 2)
    //      XCTAssertEqual(set.elements.count { $0 <= 1 }, 2)
    XCTAssertEqual(set.right(2).index, 3)
    XCTAssertEqual(set.right(3).index, 4)
    XCTAssertEqual(set.right(4).index, 5)
    XCTAssertEqual(set.right(5).index, 5)
    XCTAssertEqual(set.right(6).index, 5)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(set.removeAll(1), 1)
      XCTAssertEqual(set.removeAll(3), 3)
      XCTAssertEqual(set.removeAll(1), nil)
      XCTAssertEqual(set.removeAll(3), nil)
    #else
      XCTAssertEqual(set.eraseMulti(1), 1)
      XCTAssertEqual(set.eraseMulti(3), 1)
      XCTAssertEqual(set.eraseMulti(1), 0)
      XCTAssertEqual(set.eraseMulti(3), 0)
    #endif
    XCTAssertEqual(set.sorted(), [0, 2, 4])
    XCTAssertEqual(set.left(-1).index, 0)
    XCTAssertEqual(set.left(0).index, 0)
    XCTAssertEqual(set.left(1).index, 1)
    XCTAssertEqual(set.left(2).index, 1)
    XCTAssertEqual(set.left(3).index, 2)
    XCTAssertEqual(set.left(4).index, 2)
    XCTAssertEqual(set.left(5).index, 3)
    XCTAssertEqual(set.right(-1).index, 0)
    XCTAssertEqual(set.right(0).index, 1)
    XCTAssertEqual(set.right(1).index, 1)
    XCTAssertEqual(set.right(2).index, 2)
    XCTAssertEqual(set.right(3).index, 2)
    XCTAssertEqual(set.right(4).index, 3)
    XCTAssertEqual(set.right(5).index, 3)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(set.removeAll(2), 2)
      XCTAssertEqual(set.removeAll(1), nil)
      XCTAssertEqual(set.removeAll(2), nil)
      XCTAssertEqual(set.removeAll(3), nil)
    #else
      XCTAssertEqual(set.eraseMulti(2), 1)
      XCTAssertEqual(set.eraseMulti(1), 0)
      XCTAssertEqual(set.eraseMulti(2), 0)
      XCTAssertEqual(set.eraseMulti(3), 0)
    #endif
    XCTAssertEqual(set.sorted(), [0, 4])
    XCTAssertEqual(set.left(-1).index, 0)
    XCTAssertEqual(set.left(0).index, 0)
    XCTAssertEqual(set.left(1).index, 1)
    XCTAssertEqual(set.left(2).index, 1)
    XCTAssertEqual(set.left(3).index, 1)
    XCTAssertEqual(set.left(4).index, 1)
    XCTAssertEqual(set.left(5).index, 2)
    XCTAssertEqual(set.right(-1).index, 0)
    XCTAssertEqual(set.right(0).index, 1)
    XCTAssertEqual(set.right(1).index, 1)
    XCTAssertEqual(set.right(2).index, 1)
    XCTAssertEqual(set.right(3).index, 1)
    XCTAssertEqual(set.right(4).index, 2)
    XCTAssertEqual(set.right(5).index, 2)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(set.removeAll(0), 0)
      XCTAssertEqual(set.removeAll(1), nil)
      XCTAssertEqual(set.removeAll(2), nil)
      XCTAssertEqual(set.removeAll(3), nil)
      XCTAssertEqual(set.removeAll(4), 4)
    #else
      XCTAssertEqual(set.eraseMulti(0), 1)
      XCTAssertEqual(set.eraseMulti(1), 0)
      XCTAssertEqual(set.eraseMulti(2), 0)
      XCTAssertEqual(set.eraseMulti(3), 0)
      XCTAssertEqual(set.eraseMulti(4), 1)
    #endif
    XCTAssertEqual(set.left(-1).index, 0)
    XCTAssertEqual(set.left(0).index, 0)
    XCTAssertEqual(set.left(1).index, 0)
    XCTAssertEqual(set.left(2).index, 0)
    XCTAssertEqual(set.left(3).index, 0)
    XCTAssertEqual(set.left(4).index, 0)
    XCTAssertEqual(set.left(5).index, 0)
    XCTAssertEqual(set.right(-1).index, 0)
    XCTAssertEqual(set.right(0).index, 0)
    XCTAssertEqual(set.right(1).index, 0)
    XCTAssertEqual(set.right(2).index, 0)
    XCTAssertEqual(set.right(3).index, 0)
    XCTAssertEqual(set.right(4).index, 0)
    XCTAssertEqual(set.right(5).index, 0)
    XCTAssertEqual(set.sorted(), [])
  }
  }

  extension MultisetTests {
  func testRandom3() throws {
    var set = RedBlackTreeMultiSet<Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(i)
      #else
        set.eraseMulti(i)
      #endif
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(i)
      #else
        set.eraseMulti(i)
      #endif
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
  }
  }

  extension MultisetTests {
  func testRandom4() throws {
    var set = RedBlackTreeMultiSet<Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(i)
      #else
        set.eraseMulti(i)
      #endif
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(i)
      #else
        set.eraseMulti(i)
      #endif
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
  }
  }

  extension MultisetTests {
    func testRedBlackTreeSetFirstIndex() throws {
      var members: RedBlackTreeMultiSet = [1, 3, 5, 7, 9]
      XCTAssertEqual(members.firstIndex(of: 3)?.value, .init(1))
      XCTAssertEqual(members.firstIndex(of: 2), nil)
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(members.firstIndex(where: { $0 > 3 })?.value, .init(2))
        XCTAssertEqual(members.firstIndex(where: { $0 > 9 }), nil)
      #endif
      XCTAssertEqual(members.sorted(), [1, 3, 5, 7, 9])
      XCTAssertEqual(members.removeFirst(), 1)
      XCTAssertEqual(members.removeFirst(), 3)
      XCTAssertEqual(members.removeFirst(), 5)
      XCTAssertEqual(members.removeFirst(), 7)
      XCTAssertEqual(members.removeFirst(), 9)
    }
  }

  extension MultisetTests {
  func testContainsAllSatisfy() throws {
    let dict = [1, 2, 2, 2, 3, 3, 4, 5] as RedBlackTreeMultiSet<Int>
    XCTAssertEqual(dict.first, 1)
    XCTAssertEqual(dict.last, 5)
    XCTAssertEqual(dict.first(where: { $0 > 4 }), 5)
    XCTAssertEqual(dict.first(where: { $0 > 5 }), nil)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(dict.firstIndex(where: { $0 > 4 }), dict.index(before: dict.endIndex))
      XCTAssertEqual(dict.firstIndex(where: { $0 > 5 }), nil)
    #endif
    XCTAssertTrue(dict.contains(where: { $0 > 3 }))
    XCTAssertFalse(dict.contains(where: { $0 > 5 }))
    XCTAssertTrue(dict.allSatisfy({ $0 > 0 }))
    XCTAssertFalse(dict.allSatisfy({ $0 > 1 }))
  }
  }

  extension MultisetTests {
  func testIndex00() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
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

  extension MultisetTests {
  func testIndex000() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
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

  extension MultisetTests {
  func testIndex2() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
    let sub = set[set.index(after: set.lowerBound(2))..<set.upperBound(2)]
    XCTAssertEqual(sub.map { $0 }, [2, 2])
    #if COMPATIBLE_ATCODER_2025
      XCTAssertTrue(set.index(after: set.lowerBound(2)) < set.upperBound(2))
    #endif
  }
  }

  extension MultisetTests {
  func testIndex3() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
    let sub = set[set.index(after: set.lowerBound(2))...set.index(before: set.upperBound(2))]
    XCTAssertEqual(sub.map { $0 }, [2, 2])
    #if COMPATIBLE_ATCODER_2025
      XCTAssertTrue(set.index(after: set.lowerBound(2)) < set.index(before: set.upperBound(2)))
    #endif
  }
  }

  extension MultisetTests {
    func testIndex5() throws {
      let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
      let sub = set[set.index(after: set.lowerBound(2))..<set.upperBound(2)]
      XCTAssertEqual(sub.map { $0 }, [2, 2])
      #if COMPATIBLE_ATCODER_2025
        XCTAssertTrue(set.index(after: set.lowerBound(2)) < set.upperBound(2))
      #endif
    }
  }

  extension MultisetTests {
    func testIndex6() throws {
      let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
      let sub = set[
        set.index(after: set.lowerBound(2))...set.index(before: set.upperBound(2))]
      XCTAssertEqual(sub.map { $0 }, [2, 2])
      #if COMPATIBLE_ATCODER_2025
        XCTAssertTrue(set.index(after: set.lowerBound(2)) < set.index(before: set.upperBound(2)))
      #endif
    }
  }

  extension MultisetTests {
  func testIndex100() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5, 6]
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 6), set.endIndex)
    XCTAssertEqual(set.index(set.endIndex, offsetBy: -6), set.startIndex)
    let sub = set.elements(in: 2..<5)
    XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(sub.index(sub.startIndex, offsetBy: 3), sub.endIndex)
      XCTAssertEqual(sub.index(sub.endIndex, offsetBy: -3), sub.startIndex)
    #endif
  }
  }

  extension MultisetTests {
  func testIndex10() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5, 6]
    XCTAssertNotNil(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex))
    XCTAssertNil(set.index(set.startIndex, offsetBy: 7, limitedBy: set.endIndex))
    XCTAssertNotNil(set.index(set.endIndex, offsetBy: -6, limitedBy: set.startIndex))
    XCTAssertNil(set.index(set.endIndex, offsetBy: -7, limitedBy: set.startIndex))
    let sub = set.elements(in: 2..<5)
    XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
    #if COMPATIBLE_ATCODER_2025
      XCTAssertNotNil(sub.index(sub.startIndex, offsetBy: 3, limitedBy: sub.endIndex))
      XCTAssertNil(sub.index(sub.startIndex, offsetBy: 4, limitedBy: sub.endIndex))
      XCTAssertNotNil(sub.index(sub.endIndex, offsetBy: -3, limitedBy: sub.startIndex))
      XCTAssertNil(sub.index(sub.endIndex, offsetBy: -4, limitedBy: sub.startIndex))
    #endif
  }
  }

  extension MultisetTests {
  func testIndex11() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5, 6]
    var i = set.startIndex
    XCTAssertTrue(set.formIndex(&i, offsetBy: 6, limitedBy: set.endIndex))
    i = set.startIndex
    XCTAssertFalse(set.formIndex(&i, offsetBy: 7, limitedBy: set.endIndex))
    i = set.endIndex
    XCTAssertTrue(set.formIndex(&i, offsetBy: -6, limitedBy: set.startIndex))
    i = set.endIndex
    XCTAssertFalse(set.formIndex(&i, offsetBy: -7, limitedBy: set.startIndex))
    let sub = set.elements(in: 2..<5)
    XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
    #if COMPATIBLE_ATCODER_2025
      i = sub.startIndex
      XCTAssertTrue(sub.formIndex(&i, offsetBy: 3, limitedBy: sub.endIndex))
      i = sub.startIndex
      XCTAssertFalse(sub.formIndex(&i, offsetBy: 4, limitedBy: sub.endIndex))
      i = sub.endIndex
      XCTAssertTrue(sub.formIndex(&i, offsetBy: -3, limitedBy: sub.startIndex))
      i = sub.endIndex
      XCTAssertFalse(sub.formIndex(&i, offsetBy: -4, limitedBy: sub.startIndex))
    #endif
  }
  }

  extension MultisetTests {
  func testIndex12() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5, 6]
    var i = set.startIndex
    set.formIndex(&i, offsetBy: 6)
    XCTAssertEqual(i, set.endIndex)
    i = set.endIndex
    set.formIndex(&i, offsetBy: -6)
    XCTAssertEqual(i, set.startIndex)
    let sub = set.elements(in: 2..<5)
    XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
    #if COMPATIBLE_ATCODER_2025
      i = sub.startIndex
      sub.formIndex(&i, offsetBy: 3)
      XCTAssertEqual(i, sub.endIndex)
      i = sub.endIndex
      sub.formIndex(&i, offsetBy: -3)
      XCTAssertEqual(i, sub.startIndex)
    #endif
  }
  }

  extension MultisetTests {
  func testIndexValidation() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
    #if COMPATIBLE_ATCODER_2025
      XCTAssertTrue(set.isValid(index: set.startIndex))
      XCTAssertFalse(set.isValid(index: set.endIndex))  // 仕様変更。subscriptやremoveにつかえないので
      typealias Index = RedBlackTreeMultiSet<Int>.Index
      #if DEBUG
        XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawTag: .end).value, .end)
        // UnsafeTreeでは、範囲外のインデックスを作成できない
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
      typealias Index = RedBlackTreeMultiSet<Int>.Index
      #if DEBUG
        XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawTag: .end).value, .end)
        // UnsafeTreeでは、範囲外のインデックスを作成できない
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

  extension MultisetCopyOnWriteTests {
    func testSet2() throws {
      var set = RedBlackTreeMultiSet<Int>(minimumCapacity: 1)
      XCTAssertEqual(set._copyCount, 0)
      set.insert(0)
      XCTAssertEqual(set._copyCount, 0)
      #if COMPATIBLE_ATCODER_2025
        set.removeAll(0)
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
      print(set.filter { $0 != 0 })
      print(set.reduce(0, +))
      print(set.reduce(into: []) { $0.append($1) })
      XCTAssertEqual(set._copyCount, 0)
    }
  }

  extension MultisetCopyOnWriteTests {
    func testSet3() throws {
      var tree = RedBlackTreeMultiSet<Int>(0..<20)
      tree._copyCount = 0
      for v in tree {
        #if COMPATIBLE_ATCODER_2025
          tree.removeAll(v)  // strong ensure unique
        #else
          tree.eraseMulti(v)  // strong ensure unique
        #endif
      }
      XCTAssertEqual(tree.count, 0)
      #if COMPATIBLE_ATCODER_2025 || true
        XCTAssertEqual(tree._copyCount, 1)  // multi setの場合、インデックスを破壊するので1とする
      #else
        XCTAssertEqual(tree._copyCount, 0)  // 強強度CoWの廃止により、コピー回数は増えない。
      #endif
    }
  }

  extension MultisetCopyOnWriteTests {
    func testSet3_2() throws {
      var tree = RedBlackTreeMultiSet<Int>(0..<20)
      tree._copyCount = 0
      for v in tree + [] {
        #if COMPATIBLE_ATCODER_2025
          tree.removeAll(v)  // strong ensure unique
        #else
          tree.eraseMulti(v)  // strong ensure unique
        #endif
      }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 0)  // mapで操作が済んでいるので、インデックス破壊の心配がない
    }
  }

  extension MultisetCopyOnWriteTests {
    func testSet4() throws {
      var tree = RedBlackTreeMultiSet<Int>(0..<20)
      tree._copyCount = 0
      tree.forEach { v in
        #if COMPATIBLE_ATCODER_2025
          tree.removeAll(v)
        #else
          tree.eraseMulti(v)
        #endif
      }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 1)
    }
  }

  extension MultisetCopyOnWriteTests {
    func testSet5() throws {
      var tree = RedBlackTreeMultiSet<Int>(0..<20)
      tree._copyCount = 0
      for v in tree + [] {
        #if COMPATIBLE_ATCODER_2025
          tree.removeAll(v)
        #else
          tree.eraseMulti(v)
        #endif
      }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 0)
    }
  }

  extension MultisetCopyOnWriteTests {
    func testSet6() throws {
      var tree = RedBlackTreeMultiSet<Int>(0..<20)
      tree._copyCount = 0
      for v in tree.filter({ _ in true }) {
        #if COMPATIBLE_ATCODER_2025
          tree.removeAll(v)
        #else
          tree.eraseMulti(v)
        #endif
      }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 0)
    }
  }

  extension MultisetCopyOnWriteTests {
    func testSet3000() throws {
      let count = 1500
      var loopCount = 0
      var xy: [Int: RedBlackTreeMultiSet<Int>] = [1: .init(0..<count)]
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

  extension MultisetRemoveTests {
  func testRemove1() throws {
    var set = RedBlackTreeMultiSet<Int>([0, 0, 1, 1, 2])
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(set.remove(0), 0)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.remove(0), 0)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.remove(1), 1)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.remove(1), 1)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.remove(2), 2)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.remove(0), nil)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.remove(1), nil)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.remove(2), nil)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.remove(3), nil)
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertEqual(set.remove(4), nil)
      XCTAssertTrue(set.sorted().isEmpty)
    #else
      XCTAssertTrue(set.eraseUnique(0))
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertTrue(set.eraseUnique(0))
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertTrue(set.eraseUnique(1))
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertTrue(set.eraseUnique(1))
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertTrue(set.eraseUnique(2))
      XCTAssertTrue(set.sorted().isEmpty)

      XCTAssertFalse(set.eraseUnique(0))
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertFalse(set.eraseUnique(1))
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertFalse(set.eraseUnique(2))
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertFalse(set.eraseUnique(3))
      XCTAssertTrue(set.sorted().isEmpty)
      XCTAssertFalse(set.eraseUnique(4))
      XCTAssertTrue(set.sorted().isEmpty)
    #endif
  }
  }

  extension MultisetRemoveTests {
  func testRemoveAll() throws {
    var set = RedBlackTreeMultiSet<Int>([0, 0, 1, 1, 2])
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(set.removeAll(0), 0)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(0), nil)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(1), 1)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(1), nil)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.removeAll(2), 2)
      XCTAssertTrue(set.sorted().isEmpty)
    #else
      XCTAssertEqual(set.eraseMulti(0), 2)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(0), 0)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(1), 2)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(1), 0)
      XCTAssertFalse(set.sorted().isEmpty)
      XCTAssertEqual(set.eraseMulti(2), 1)
      XCTAssertTrue(set.sorted().isEmpty)
    #endif
  }
  }

  extension MultisetRemoveTests {
  func testRemoveLimit() throws {
    var members: RedBlackTreeMultiSet = [Int.min, Int.min, Int.max, Int.max]
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(members.count, 4)
      members.removeAll(Int.min)
      XCTAssertEqual(members.count, 2)
      members.removeAll(Int.max)
      XCTAssertEqual(members.count, 0)
    #else
      XCTAssertEqual(members.count, 4)
      members.eraseMulti(Int.min)
      XCTAssertEqual(members.count, 2)
      members.eraseMulti(Int.max)
      XCTAssertEqual(members.count, 0)
    #endif
  }
  }

  extension RedBlackTreeMultisetCornerCaseTests {
  func testRemoveOneVersusRemoveAll() {
    var ms: RedBlackTreeMultiSet = [5, 5, 5]

    #if COMPATIBLE_ATCODER_2025
      XCTAssertNotNil(ms.remove(5))  // 1 個だけ
      XCTAssertEqual(ms.count(of: 5), 2)
      XCTAssertNotNil(ms.removeAll(5))  // 全消し
      XCTAssertFalse(ms.contains(5))
      XCTAssertNil(ms.removeAll(5))  // もう無いので nil
    #else
      XCTAssertNotNil(ms.eraseUnique(5))  // 1 個だけ
      XCTAssertEqual(ms.count(of: 5), 2)
      XCTAssertNotEqual(ms.eraseMulti(5), 0)  // 全消し
      XCTAssertFalse(ms.contains(5))
      XCTAssertEqual(ms.eraseMulti(5), 0)  // もう無いので 0
    #endif
  }
  }

  extension RedBlackTreeMultisetCornerCaseTests {
  func testIndexInvalidationAfterErase() {
    var ms: RedBlackTreeMultiSet = [9, 9, 9]
    let idx = ms.firstIndex(of: 9)!
    ms.remove(at: idx)
    #if COMPATIBLE_ATCODER_2025
      XCTAssertFalse(ms.isValid(index: idx))
    #else
      XCTAssertFalse(ms.isValid(idx))
    #endif
  }
  }

  extension RedBlackTreeMultisetCornerCaseTests {
  func testRemoveSubrange() {
    var ms: RedBlackTreeMultiSet = [0, 1, 2, 2, 3, 4]
    let l = ms.lowerBound(2)
    let r = ms.upperBound(2)  // 半開なので 2 のみ消す
    #if COMPATIBLE_ATCODER_2025
      ms.removeSubrange(l..<r)
    #else
    _ = ms.erase(l..<r)
    #endif
    XCTAssertEqual(ms.sorted(), [0, 1, 3, 4])
  }
  }

  extension RedBlackTreeMultisetCornerCaseTests {
  func testRandomizedAgainstReferenceMultiset() {
    var rng = SplitMix64(seed: 0xBADC0DE)
    let rounds = 150
    let opsPerRound = 400

    for _ in 0..<rounds {
      var ms = RedBlackTreeMultiSet<Int>()
      var ref = ReferenceMultiset()

      for _ in 0..<opsPerRound {
        let v = Int(rng.next() & 0x3F)  // 0…63
        switch rng.next() & 3 {
        case 0:  // insert
          ms.insert(v)
          ref.insert(v)
        case 1:  // remove one
          #if COMPATIBLE_ATCODER_2025
            _ = ms.remove(v)
            ref.removeOne(v)
          #else
            _ = ms.eraseUnique(v)
            ref.removeOne(v)
          #endif
        case 2:  // removeAll
          #if COMPATIBLE_ATCODER_2025
            _ = ms.removeAll(v)
            ref.removeAll(v)
          #else
            _ = ms.eraseMulti(v)
            ref.removeAll(v)
          #endif
        default:  // count check only
          break
        }
        // 同期検証
        XCTAssertEqual(ms.count(of: v), ref.count(of: v))
      }
      XCTAssertEqual(ms.sorted(), ref.sorted)
    }
  }
  }
#endif
