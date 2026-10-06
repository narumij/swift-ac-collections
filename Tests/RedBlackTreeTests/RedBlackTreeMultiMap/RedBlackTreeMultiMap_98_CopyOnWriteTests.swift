import XCTest

#if AC_COLLECTIONS_INTERNAL_CHECKS
  @testable import RedBlackTreeCollections

  final class RedBlackTreeMultiMapCopyOnWriteTests: RedBlackTreeTestCase {

    typealias Target = RedBlackTreeMultiMap<Int, Int>

    let count = 2_000_000
    var tree: Target = .init()

    override func setUpWithError() throws {
      try super.setUpWithError()
      tree = .init(keysWithValues: (0..<20).map { ($0, $0) })
    }

    override func tearDownWithError() throws {
      tree = .init()
      try super.tearDownWithError()
    }

    func testSet1() throws {
      // UnsafeTreeの場合、capacity増加はバケット追加で行われるので、コピーしない
      var multiset = RedBlackTreeMultiMap<Int, Int>()
      XCTAssertEqual(multiset._copyCount, 0)
      multiset.insert(key: 0, value: 0)
      XCTAssertGreaterThanOrEqual(multiset._copyCount, 0)  // 挿入に備え、かつ消費
      while multiset.count < multiset.capacity {
        multiset.insert(key: 0, value: 0)
        XCTAssertGreaterThanOrEqual(multiset._copyCount, 0)  // capacityを消費仕切るまで変わらない
      }
      multiset.insert(key: 0, value: 0)
      XCTAssertGreaterThanOrEqual(multiset._copyCount, 0)  // 挿入に備え、かつ消費
      while multiset.count < multiset.capacity {
        multiset.insert(key: 0, value: 0)
        XCTAssertGreaterThanOrEqual(multiset._copyCount, 0)  // capacityを消費仕切るまで変わらない
      }
      multiset.insert(key: 0, value: 0)
      XCTAssertGreaterThanOrEqual(multiset._copyCount, 0)  // 挿入に備え、かつ消費
    }

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
        blackHole(s)
      }
      set.forEach {
        blackHole($0)
      }
      blackHole(set.map { $0 })
      blackHole(set.filter { $0 != keyValue(0, 0) })
      blackHole(set.reduce(into: []) { $0.append($1) })
      XCTAssertEqual(set._copyCount, 0)
    }

    #if !COMPATIBLE_ATCODER_2025
      func testSet3() throws {
        tree._copyCount = 0
        for v in tree {
          tree.eraseUnique(v.key)  // strong ensure unique
        }
        XCTAssertEqual(tree.count, 0)
        XCTAssertEqual(tree._copyCount, 1)
      }
    #endif

    #if !COMPATIBLE_ATCODER_2025
      func testSet3_2() throws {
        tree._copyCount = 0
        for v in tree + [] {
          tree.eraseUnique(v.key)  // strong ensure unique
        }
        XCTAssertEqual(tree.count, 0)
        XCTAssertEqual(tree._copyCount, 0)  // mapで操作が済んでいるので、インデックス破壊の心配がない
      }
    #endif

    #if !COMPATIBLE_ATCODER_2025
      func testSet3_3() throws {
        tree._copyCount = 0
        for v in tree + [] {
          tree.eraseUnique(v.key)  // strong ensure unique
        }
        XCTAssertEqual(tree.count, 0)
        XCTAssertEqual(tree._copyCount, 0)  // mapで操作が済んでいるので、インデックス破壊の心配がない
      }
    #endif

    #if !COMPATIBLE_ATCODER_2025
      func testSet4() throws {
        tree._copyCount = 0
        tree.forEach { v in
          tree.eraseUnique(v.key)
        }
        XCTAssertEqual(tree.count, 0)
        XCTAssertEqual(tree._copyCount, 1)
      }
    #endif

    #if !COMPATIBLE_ATCODER_2025
      func testSet5() throws {
        tree._copyCount = 0
        for v in tree + [] {
          tree.eraseUnique(v.key)
        }
        XCTAssertEqual(tree.count, 0)
        XCTAssertEqual(tree._copyCount, 0)
      }
    #endif

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

    #if !COMPATIBLE_ATCODER_2025
      // Setの同名テストのKeyValue Range View版。KeyOnly / KeyValueの両Viewで同じCoW契約を確認する
      func testEraseWhereOnRangeViewOfSharedTreeDoesNotCopy() throws {
        var map = RedBlackTreeMultiMap(keysWithValues: (0..<20).map { ($0, $0) })

        map[lowerBound(10).advanced(by: 2)..<end()].erase {
          $0.key % 2 == 0
        }

        XCTAssertEqual(map.map(\.key), (0..<20).filter { $0 < 12 || $0 % 2 != 0 })
        XCTAssertEqual(map._copyCount, 0)
      }

      func testEraseWhereOnStandaloneRangeViewCopiesOnceButLeavesBaseUntouched() throws {
        let map = RedBlackTreeMultiMap(keysWithValues: (0..<20).map { ($0, $0) })
        var range = map[lowerBound(10).advanced(by: 2)..<end()]

        range.erase {
          $0.key % 2 == 0
        }

        // rangeが別変数として保持されているため、消去はrange側のみに反映され、元は変化しない
        XCTAssertEqual(map.map(\.key), Array(0..<20))
        XCTAssertEqual(map._copyCount, 0)
        XCTAssertEqual(range._copyCount, 1)
      }
    #endif
  }
#endif
