import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if COMPATIBLE_ATCODER_2025
  final class SetAtCoder2025CompatibilityTests: RedBlackTreeTestCase {
    func testRemoveLast() throws {
      var members: RedBlackTreeSet<Int> = [1, 3, 5, 7, 9]
      XCTAssertEqual(members.removeLast(), 9)
      XCTAssertEqual(members.count, 4)
      XCTAssertEqual(members.removeLast(), 7)
      XCTAssertEqual(members.count, 3)
      XCTAssertEqual(members.removeLast(), 5)
      XCTAssertEqual(members.count, 2)
      XCTAssertEqual(members.removeLast(), 3)
      XCTAssertEqual(members.count, 1)
      XCTAssertEqual(members.removeLast(), 1)
      XCTAssertEqual(members.count, 0)
    }

    func testRemoveWithRange1() throws {
      var members = RedBlackTreeSet(0..<10)
      for i in members.startIndex..<members.endIndex { members.remove(at: i) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithRange2() throws {
      var members = RedBlackTreeSet(0..<10)
      (members.startIndex..<members.endIndex).forEach { members.remove(at: $0) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithRange3() throws {
      var members = RedBlackTreeSet(0..<10)
      for i in (members.startIndex..<members.endIndex).reversed() { members.remove(at: i) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithRange4() throws {
      var members = RedBlackTreeSet(0..<10)
      (members.startIndex..<members.endIndex).reversed().forEach { members.remove(at: $0) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices1() throws {
      var members = RedBlackTreeSet(0..<10)
      for i in members.indices { members.remove(at: i) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices2() throws {
      var members = RedBlackTreeSet(0..<10)
      members.indices.forEach { members.remove(at: $0) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices3() throws {
      var members = RedBlackTreeSet(0..<10)
      for i in members.indices.reversed() { members.remove(at: i) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithIndices4() throws {
      var members = RedBlackTreeSet(0..<10)
      members.indices.reversed().forEach { members.remove(at: $0) }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWithSubIndices() throws {
      var members = RedBlackTreeSet(0..<10)
      for i in members.elements(in: 2..<8).indices { members.remove(at: i) }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices2() throws {
      var members = RedBlackTreeSet(0..<10)
      members.elements(in: 2..<8).indices.forEach { members.remove(at: $0) }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices3() throws {
      var members = RedBlackTreeSet(0..<10)
      for i in members.elements(in: 2..<8).indices.reversed() { members.remove(at: i) }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSubIndices4() throws {
      var members = RedBlackTreeSet(0..<10)
      members.elements(in: 2..<8).indices.reversed().forEach { members.remove(at: $0) }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }
  }
  #if DEBUG
  extension SetRemoveTest_10 {
    func testRemoveWith___Indices() throws {
      for i in members.___node_positions() {
        members.__tree_._unchecked_remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWith___Indices2() throws {
      members.___node_positions().forEach { i in
        members.__tree_._unchecked_remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }

    func testRemoveWith___Indices3() throws {
      members.___node_positions().reversed().forEach { i in
        members.__tree_._unchecked_remove(at: i)
      }
      XCTAssertEqual(members + [], [])
    }
  }
  #endif

  #if DEBUG
  extension SetRemoveTest_10 {
    func testRemoveWithSub___Indices() throws {
      for i in members.elements(in: 2..<8).___node_positions() {
        members.__tree_._unchecked_remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSub___Indices2() throws {
      members.elements(in: 2..<8).___node_positions().forEach { i in
        members.__tree_._unchecked_remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }

    func testRemoveWithSub___Indices4() throws {
      members.elements(in: 2..<8).___node_positions().reversed().forEach { i in
        members.__tree_._unchecked_remove(at: i)
      }
      XCTAssertEqual(members + [], [0, 1, 8, 9])
    }
  }
  #endif

  extension SetTests {
    func testInitNaive0() throws {
      let set = RedBlackTreeSet<Int>(naive: 0..<0)
      XCTAssertEqual(set.elements, (0..<0) + [])
      XCTAssertEqual(set.count, 0)
      XCTAssertTrue(set.isEmpty)
      XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 0)
    }
  }

  extension SetTests {
    func testInitCollection3() throws {
      let set = RedBlackTreeSet<Int>(naive: [2, 3, 3, 0, 0, 1, 1, 1])
      XCTAssertEqual(set.elements, [0, 1, 2, 3])
      XCTAssertEqual(set.count, 4)
      XCTAssertFalse(set.isEmpty)
      XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), set.count)
    }
  }

  extension SetTests {
    func testSubsequence() throws {
      var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
      XCTAssertEqual(set[set.startIndex..<set.endIndex].map { $0 }, [1, 2, 3, 4, 5])
      XCTAssertEqual(set[set.lowerBound(2)..<set.lowerBound(4)].map { $0 }, [2, 3])
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
      var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
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

  extension SetTests {
    func testSubsequence4() throws {
      let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
      let sub = set.elements(in: 1..<3)
      throw XCTSkip("Fatal error: RedBlackTree index is out of range.")
      XCTAssertNotEqual(sub[set.startIndex..<set.endIndex].map { $0 }, [1, 2, 3, 4, 5])
    }
  }

  extension SetTests {
    func testSubsequence5() throws {
      let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
      let sub = set.elements(in: 1..<3)
      XCTAssertEqual(sub[set.lowerBound(1)..<set.lowerBound(3)].map { $0 }, [1, 2])
      XCTAssertEqual(sub[sub.startIndex..<sub.endIndex].map { $0 }, [1, 2])
      XCTAssertEqual(sub[sub.startIndex..<sub.index(before: sub.endIndex)].map { $0 }, [1])
      XCTAssertEqual(sub.map { $0 }, [1, 2])
      XCTAssertEqual(set.elements(in: 1..<3).map { $0 }, [1, 2])
    }
  }

  extension SetTests {
    func testIndex100() throws {
      let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
      XCTAssertEqual(set.index(set.startIndex, offsetBy: 6), set.endIndex)
      XCTAssertEqual(set.index(set.endIndex, offsetBy: -6), set.startIndex)
      let sub = set.elements(in: 2..<5)
      XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
      XCTAssertEqual(sub.index(sub.startIndex, offsetBy: 3), sub.endIndex)
      XCTAssertEqual(sub.index(sub.endIndex, offsetBy: -3), sub.startIndex)
    }

    func testIndex10() throws {
      let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
      XCTAssertNotNil(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex))
      XCTAssertNil(set.index(set.startIndex, offsetBy: 7, limitedBy: set.endIndex))
      XCTAssertNotNil(set.index(set.endIndex, offsetBy: -6, limitedBy: set.startIndex))
      XCTAssertNil(set.index(set.endIndex, offsetBy: -7, limitedBy: set.startIndex))
      let sub = set.elements(in: 2..<5)
      XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
      XCTAssertNotNil(sub.index(sub.startIndex, offsetBy: 3, limitedBy: sub.endIndex))
      XCTAssertNil(sub.index(sub.startIndex, offsetBy: 4, limitedBy: sub.endIndex))
      XCTAssertNotNil(sub.index(sub.endIndex, offsetBy: -3, limitedBy: sub.startIndex))
      XCTAssertNil(sub.index(sub.endIndex, offsetBy: -4, limitedBy: sub.startIndex))
    }

    func testIndex11() throws {
      let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
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
      i = sub.startIndex
      XCTAssertTrue(sub.formIndex(&i, offsetBy: 3, limitedBy: sub.endIndex))
      i = sub.startIndex
      XCTAssertFalse(sub.formIndex(&i, offsetBy: 4, limitedBy: sub.endIndex))
      i = sub.endIndex
      XCTAssertTrue(sub.formIndex(&i, offsetBy: -3, limitedBy: sub.startIndex))
      i = sub.endIndex
      XCTAssertFalse(sub.formIndex(&i, offsetBy: -4, limitedBy: sub.startIndex))
    }
  }

  extension SetTests {
    func testIndex12() throws {
      let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
      var i = set.startIndex
      set.formIndex(&i, offsetBy: 6)
      XCTAssertEqual(i, set.endIndex)
      i = set.endIndex
      set.formIndex(&i, offsetBy: -6)
      XCTAssertEqual(i, set.startIndex)
      let sub = set.elements(in: 2..<5)
      XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
      i = sub.startIndex
      sub.formIndex(&i, offsetBy: 3)
      XCTAssertEqual(i, sub.endIndex)
      i = sub.endIndex
      sub.formIndex(&i, offsetBy: -3)
      XCTAssertEqual(i, sub.startIndex)
    }
  }

  #if DEBUG
  extension SetTests {
    func testSubSeqSubscript() throws {
      let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
      XCTAssertEqual(set.elements(in: 2..<4)[set.startIndex + 2], 3)
      var a = 0
      set.elements(in: 2...4).forEach {
        a += $0
      }
      XCTAssertEqual(a, 2 + 3 + 4)
    }
  }
  #endif

  extension SetTests {
    func testIndexValidation2() throws {
      let _set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6, 7]
      let set = _set.elements(in: 2..<6)
      XCTAssertTrue(set.isValid(index: set.startIndex))
      XCTAssertTrue(set.isValid(index: set.endIndex))
      typealias Index = RedBlackTreeSet<Int>.Index
      #if DEBUG
        XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawTag: .end).value, .end)
        XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawTag: 5).value, 5)

        XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: .nullptr as Int)))
        XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 0)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 1)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 2)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 3)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 4)))
        XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 5)))
        XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 6)))
      //        XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawTag: 7))) // TODO: rawTag関連コードの整理時に、このテストの必要性を再検討する
      #endif
    }
  }

  extension SetTests {
    func testLeftUnsafeSmoke() {
      typealias Set = RedBlackTreeSet<Int>
      #if DEBUG
        let repeatCount = 1
      #else
        let repeatCount = 100
      #endif
      for _ in 0..<repeatCount {
        let count = Int.random(in: 0..<1_000_000)
        let a = Set(0..<count)
        do {
          var p: Set.Index? = a.startIndex
          while p != a.endIndex {
            p = p?.next
          }
        }
        do {
          var p: Set.Index? = a.endIndex
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

  extension SetTests {
    func testIsValidRangeSmoke() throws {
      let a = RedBlackTreeSet<Int>(naive: [0, 1, 2, 3, 4, 5])
      XCTAssertTrue(a.isValid(a.lowerBound(2)..<a.upperBound(4)))
    }

    func testSortedReversed() throws {
      let source = [0, 1, 2, 3, 4, 5]
      let a = RedBlackTreeSet<Int>(naive: source)
      XCTAssertEqual(a.sorted() + [], source)
      XCTAssertEqual(a.reversed() + [], source.reversed())
    }

    func testForEach_enumeration() throws {
      let source = [0, 1, 2, 3, 4, 5]
      let a = RedBlackTreeSet<Int>(naive: source)
      var p: RedBlackTreeSet<Int>.Index? = a.startIndex
      a.forEach { i, v in
        XCTAssertEqual(i, p)
        XCTAssertEqual(a[p!], v)
        p = p?.next
      }
    }

    func testInitNaive_with_Sequence() throws {
      let source = [0, 1, 2, 3, 4, 5]
      let a = RedBlackTreeSet<Int>(naive: AnySequence(source))
      XCTAssertEqual(a.sorted() + [], source)
    }
  }

  extension SetCopyOnWriteTests {
      func testSet4000() throws {
        let count = 1500
        var xy: [Int: RedBlackTreeSet<Int>] = [1: .init(0..<count)]
        xy[1]?._copyCount = 0
        let N = 100
        var loopCount = 0
        for i in 0..<count / N {
          loopCount += 1
          // for文の場合イテレータに処理が移行するので木を保持しないが、
          // forEachは利用ではこの分離ないので、CoWが発生するようになった
          // 以前はこれを回避するよう設計で工夫していたが、その工夫自体のオーバーヘッドがもったいない
          // わざわざsliceを改修するつもりもなく、このままとなります
          xy[1]?.elements(in: (i * N)..<(i * N + N)).forEach { i, v in
            xy[1]?.remove(at: i)
          }
        }
        XCTAssertEqual(xy[1]!.count, 0)
        //    XCTAssertEqual(xy[1]!.copyCount, count / N)
        XCTAssertEqual(xy[1]!._copyCount, 1, "CoW関連構造の変更に伴い結果が変化")
        XCTAssertEqual(loopCount, count / N)
      }
  }

  extension RedBlackTreeSetBidirectionalTests {
    func testForwardAndBackwardIteration() {
      let s: RedBlackTreeSet = [1, 3, 5, 7, 9]
      // forward
      var fwd: [Int] = []
      for idx in s.indices { fwd.append(s[idx]) }
      // backward
      var bwd: [Int] = []
      var i = s.index(before: s.endIndex)
      while true {
        bwd.append(s[i])
        if i == s.startIndex { break }
        i = s.index(before: i)
      }
      XCTAssertEqual(fwd, [1, 3, 5, 7, 9])
      XCTAssertEqual(bwd, [9, 7, 5, 3, 1])
    }
  }

  extension SetSubSequenceTests {
    func testSliceStartEndCount() {
      let base = RedBlackTreeSet(0..<10)  // [0‥9]
      let slice = base.elements(in: 2..<6)  // [2,3,4,5]

      XCTAssertEqual(slice.count, 4)
      XCTAssertEqual(slice.first, 2)
      #if COMPATIBLE_ATCODER_2025
        XCTAssertEqual(slice.last, 5)
      #endif
      XCTAssertEqual(
        slice.distance(
          from: slice.startIndex,
          to: slice.endIndex), 4)
    }
  }

  extension SetSubSequenceTests {
    func testSliceIndexOffsetting() {
      let set: RedBlackTreeSet = [0, 1, 2, 3, 4, 5, 6]
      let slice = set.elements(in: 1...4)  // [1,2,3,4]

      let idx2 = slice.index(slice.startIndex, offsetBy: 2)
      XCTAssertEqual(slice[idx2], 3)

      let nilIdx = slice.index(
        slice.startIndex,
        offsetBy: 10,
        limitedBy: slice.endIndex)
      XCTAssertNil(nilIdx)
    }
  }

  extension SetSubSequenceTests {
    func testIndexInvalidationAfterBaseMutation() throws {
      var base: RedBlackTreeSet = [0, 1, 2, 3]
      let slice = base.elements(in: 1..<3)  // [1,2]

      let b_idx = base.firstIndex(of: 1)!
      let idx = slice.firstIndex(of: 1)!
      XCTAssertTrue(base.isValid(index: b_idx)) // これは従来と同じ挙動
      XCTAssertTrue(base.isValid(index: idx)) // これは従来と同じ挙動
      XCTAssertTrue(slice.isValid(index: idx)) // これは従来と同じ挙動
      
      base.remove(1)  // 基集合を変化させる

      XCTAssertFalse(base.isValid(index: b_idx)) // これは従来と同じ挙動
      XCTAssertFalse(base.isValid(index: idx)) // これは従来と同じ挙動
//      XCTAssertFalse(slice.isValid(index: idx)) // なぜ連動してfalseになる想定だったのか思い出せない
      XCTAssertTrue(slice.isValid(index: idx), " 内部挙動の変更でCoW後のsliceに強く紐付いている")

      base.insert(1)
      #if DEBUG
        // 内部的には再利用で同一ノードとなる
        XCTAssertEqual(base.firstIndex(of: 1)?.value, idx.value, "これは固定された仕様では無く、あくまで確認")
      #endif

      XCTAssertFalse(base.isValid(index: b_idx), "内部挙動変更でfalseとなった")
      XCTAssertFalse(base.isValid(index: idx)) // これは従来と同じ挙動
//      XCTAssertFalse(slice.isValid(index: idx)) // なぜ連動してfalseになる想定だったのか思い出せない
      XCTAssertTrue(slice.isValid(index: idx), " 内部挙動の変更でCoW後のslideに強く紐付いている")
    }
  }

  extension SetPointerTests {
    func testPointer() throws {
      // 邪魔くさく感じたので廃止した
      //      XCTAssertTrue(members.startIndex.isStart)
      //      XCTAssertFalse(members.endIndex.isStart)
      XCTAssertFalse(members.startIndex.isEnd)
      XCTAssertTrue(members.endIndex.isEnd)
    }

    #if DEBUG
      func testPointer2() throws {
        if let it = members.startIndex.next {
          XCTAssertFalse(members.___is_garbaged(it))
          XCTAssertEqual(it.pointee, 1)
          XCTAssertNotNil(it.previous)
          XCTAssertNotNil(it.next)
          members.remove(at: it)  // itが分離するようになった
          XCTAssertTrue(members.___is_garbaged(it))  // membersにとっては無効
          XCTAssertNil(it.pointee)  // it自体は過去の木に結びついていて有効
          XCTAssertNil(it.previous)
          XCTAssertNil(it.next)
        }
      }
    #endif

    func testPointerNext() throws {
      XCTAssertEqual(members.startIndex.pointee, 0)
      XCTAssertEqual(members.startIndex.next?.pointee, 1)
      XCTAssertEqual(members.startIndex.next?.next?.pointee, 2)
      XCTAssertEqual(members.startIndex.next?.next?.next?.pointee, 3)
      XCTAssertEqual(members.startIndex.next?.next?.next?.next?.pointee, 4)
      XCTAssertNil(members.startIndex.next?.next?.next?.next?.next?.pointee)
      XCTAssertEqual(members.startIndex.next?.next?.next?.next?.next, members.endIndex)
      XCTAssertNil(members.startIndex.next?.next?.next?.next?.next?.next)
      XCTAssertNil(members.endIndex.next)
    }

    func testPointerPrev() throws {
      XCTAssertNil(members.endIndex.pointee)
      XCTAssertEqual(members.endIndex.previous?.pointee, 4)
      XCTAssertEqual(members.endIndex.previous?.previous?.pointee, 3)
      XCTAssertEqual(members.endIndex.previous?.previous?.previous?.pointee, 2)
      XCTAssertEqual(members.endIndex.previous?.previous?.previous?.previous?.pointee, 1)
      XCTAssertEqual(members.endIndex.previous?.previous?.previous?.previous?.previous?.pointee, 0)
      XCTAssertEqual(
        members.endIndex.previous?.previous?.previous?.previous?.previous, members.startIndex)
      XCTAssertNil(members.endIndex.previous?.previous?.previous?.previous?.previous?.previous)
      XCTAssertNil(members.startIndex.previous)
    }

    func testPointerOffset0() throws {
      XCTAssertEqual((members.startIndex).pointee, 0)
      XCTAssertEqual(members.startIndex.advanced(by: 1).pointee, 1)
      XCTAssertEqual(members.startIndex.advanced(by: 2).pointee, 2)
      XCTAssertEqual(members.startIndex.advanced(by: 3).pointee, 3)
      XCTAssertEqual(members.startIndex.advanced(by: 4).pointee, 4)
      XCTAssertNil(members.startIndex.advanced(by: 5).pointee)
      XCTAssertEqual(members.startIndex.advanced(by: 5), members.endIndex)
      XCTAssertNil(members.startIndex.advanced(by: 6).pointee)
    }

    func testPointerOffset2() throws {
      XCTAssertNil((members.endIndex).pointee)
      XCTAssertEqual(members.endIndex.advanced(by: -1).pointee, 4)
      XCTAssertEqual(members.endIndex.advanced(by: -2).pointee, 3)
      XCTAssertEqual(members.endIndex.advanced(by: -3).pointee, 2)
      XCTAssertEqual(members.endIndex.advanced(by: -4).pointee, 1)
      XCTAssertEqual(members.endIndex.advanced(by: -5).pointee, 0)
      XCTAssertEqual(members.endIndex.advanced(by: -5), members.startIndex)
      XCTAssertNil(members.startIndex.advanced(by: -6).pointee)
    }

    #if DEBUG
      func testValidBehavior1() throws {
        let indices = members.indices + []
        for i in indices.indices {
          members.remove(at: indices[i])
          for j in indices.startIndex..<i {
            XCTAssertTrue(members.___is_garbaged(indices[j]))
          }
          for j in i.advanced(by: 1)..<indices.endIndex {
            XCTAssertFalse(members.___is_garbaged(indices[j]))
          }
        }
      }

      func testValidBehavior2() throws {
        let indices = members.indices + []
        for i in indices.indices.reversed() {
          members.remove(at: indices[i])
          for j in indices.startIndex..<i {
            XCTAssertFalse(members.___is_garbaged(indices[j]))
          }
          for j in i.advanced(by: 1)..<indices.endIndex {
            XCTAssertTrue(members.___is_garbaged(indices[j]))
          }
        }
      }
    #endif
  
  }

  extension SetPerformanceTests {
      #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceFirstIndex4() throws {
        let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 - 1 }), s.index(before: s.endIndex))
        }
      }
      #endif

      #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceFirstIndex5() throws {
        let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 0 }), s.startIndex)
        }
      }
      #endif

      #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceFirstIndex6() throws {
        let s: RedBlackTreeSet<Int> = .init(0..<1_000_000)
        self.measure {
          XCTAssertEqual(s.firstIndex(where: { $0 >= 1_000_000 }), nil)
        }
      }
      #endif
  }

  extension SetPerformanceTests {
      #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceCompare0() throws {
        let set: RedBlackTreeSet<Int> = .init(0..<1_000_000)
        XCTAssertTrue(set.startIndex < set.endIndex)
        XCTAssertFalse(set.startIndex == set.endIndex)
        XCTAssertFalse(set.startIndex > set.endIndex)
        self.measure {
          let _ = set.startIndex < set.endIndex
        }
      }
      #endif

      #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceCompare1() throws {
        let set: RedBlackTreeSet<Int> = .init(0..<1_000_000)
        let l = set.index(before: set.endIndex)
        let r = set.endIndex
        XCTAssertTrue(l < r)
        XCTAssertFalse(l == r)
        XCTAssertFalse(l > r)
        self.measure {
          let _ = l < r
        }
      }
      #endif

      #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceCompare2() throws {
        let set: RedBlackTreeSet<Int> = .init(0..<1_000_000)
        let l = set.endIndex
        let r = set.index(before: set.endIndex)
        XCTAssertFalse(l < r)
        XCTAssertFalse(l == r)
        XCTAssertTrue(l > r)
        self.measure {
          let _ = l < r
        }
      }
      #endif

      #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceCompare3() throws {
        let set: RedBlackTreeSet<Int> = .init(0..<1_000_000)
        let l = set.index(before: set.endIndex)
        let r = set.index(before: l)
        XCTAssertFalse(l < r)
        XCTAssertFalse(l == r)
        XCTAssertTrue(l > r)
        self.measure {
          let _ = l < r
        }
      }
      #endif

      #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceCompare4() throws {
        let set: RedBlackTreeSet<Int> = .init(0..<1_000_000)
        let l = set.endIndex
        let r = set.endIndex
        XCTAssertFalse(l < r)
        XCTAssertTrue(l == r)
        XCTAssertFalse(l > r)
        self.measure {
          let _ = l < r
        }
      }
      #endif

      #if ENABLE_PERFORMANCE_TESTING
      func testPerformanceCompare5() throws {
        let set: RedBlackTreeSet<Int> = .init(0..<1_000_000)
        let r = set.index(before: set.endIndex)
        let l = set.index(before: r)
        //    let l = set.index(before: set.endIndex)
        //    let r = set.index(before: l)
        XCTAssertTrue(l < r)
        XCTAssertFalse(l == r)
        XCTAssertFalse(l > r)
        self.measure {
          let _ = l < r
        }
      }
      #endif
  }
  extension SetRemoveTests {
  }

  extension SetTests {
  }

  extension SetTests {
  }

  extension SetTests {
  }

  extension SetTests {
  }

  extension SetTests {
  }

  extension SetTests {
  }

  extension SetTests {
  }

  extension SetTests {
  }

  extension SetTests {
  }

  extension SetTests {
  }

  extension SetCopyOnWriteTests {
  }

  extension SetCopyOnWriteTests {
  }

  extension RedBlackTreeSetCornerCaseTests {
  }

  extension RedBlackTreeSetCornerCaseTests {
  }

  extension RedBlackTreeSetCornerCaseTests {
  }

  extension SetSubSequenceTests {
  }
#endif
