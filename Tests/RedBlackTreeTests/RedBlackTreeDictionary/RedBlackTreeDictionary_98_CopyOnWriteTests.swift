import XCTest

#if AC_COLLECTIONS_INTERNAL_CHECKS
  @testable import RedBlackTreeCollections

  final class RedBlackTreeDictionaryCopyOnWriteTests: RedBlackTreeTestCase {

    let count = 2_000_000
    var tree: RedBlackTreeDictionary<Int, Int> = .init()

    override func setUpWithError() throws {
      try super.setUpWithError()
      tree = .init(uniqueKeysWithValues: (0..<20).map { ($0, $0) })
    }

    override func tearDownWithError() throws {
      tree = .init()
      try super.tearDownWithError()
    }

    func testDict1() throws {
      // UnsafeTreeの場合、capacity増加はバケット追加で行われるので、コピーしない
      var dict = RedBlackTreeDictionary<Int, Int>()
      XCTAssertEqual(dict._copyCount, 0)
      dict[0] = 0
      // シングルトンバッファスタートなので、空のオブジェクトは操作で必ずコピーが発生する
      XCTAssertEqual(dict._copyCount, 1)  // 挿入に備えた分増える
      while dict.count < dict.capacity {
        dict[(2..<Int.max).randomElement()!] = 0
        XCTAssertEqual(dict._copyCount, 1)  // 挿入に備えた分増える
      }
      dict[0] = 1
      XCTAssertEqual(dict._copyCount, 1)  // 挿入に備えた分増えるが消費していない
      dict[0] = 2
      XCTAssertEqual(dict._copyCount, 1)  // 挿入に備えた必要分をまだ消費していない
      dict[1] = 1
      XCTAssertEqual(dict._copyCount, 1)  // 挿入に備えた必要分を消費したところ
    }

    func testDict2() throws {
      var dict = RedBlackTreeDictionary<Int, Int>(minimumCapacity: 1)
      XCTAssertEqual(dict._copyCount, 0)
      dict[0] = 0
      XCTAssertEqual(dict._copyCount, 0)
      dict.removeValue(forKey: 0)
      XCTAssertEqual(dict._copyCount, 0)
      _ = dict.lowerBound(0)
      _ = dict.upperBound(0)
      for s in dict {
        blackHole(s)
      }
      dict.forEach {
        blackHole($0)
      }
      blackHole(dict.map { $0 })
      blackHole(dict.filter { $0.key != 0 })
      blackHole(dict.reduce(into: []) { $0.append($1) })
      XCTAssertEqual(dict._copyCount, 0)
    }

    func testDict3() throws {
      tree._copyCount = 0
      for v in tree {
        tree.removeValue(forKey: v.key)
      }
      XCTAssertEqual(tree.count, 0)
        XCTAssertEqual(tree._copyCount, 1)
    }

    func testDict4() throws {
      tree._copyCount = 0
      tree.forEach { v in
        tree.removeValue(forKey: v.key)
      }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 1)
    }

    func testDict5() throws {
      tree._copyCount = 0
      for v in tree + [] {
        tree.removeValue(forKey: v.key)
      }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 0)
    }

    func testDict6() throws {
      tree._copyCount = 0
      for v in tree.filter({ _ in true }) {
        tree.removeValue(forKey: v.key)
      }
      XCTAssertEqual(tree.count, 0)
      XCTAssertEqual(tree._copyCount, 0)
    }

    func testDict3000() throws {
      let count = 1500
      var loopCount = 0
      var xy: [Int: RedBlackTreeDictionary<Int, Int>] = [
        1: .init(uniqueKeysWithValues: (0..<count).map { ($0, $0) })
      ]
      xy[1]?._copyCount = 0
      let N = 100
      for i in 0..<count / N {
        loopCount += 1
        if let lo = xy[1]?.lowerBound(i * N),
          let hi = xy[1]?.upperBound(i * N + N)
        {
            _ = xy[1]?.erase(lo..<hi)
        }
      }
      XCTAssertEqual(xy[1]!.count, 0)
      XCTAssertEqual(xy[1]!._copyCount, 0)
      XCTAssertEqual(loopCount, count / N)
    }

      // Setの同名テストのKeyValue Range View版。KeyOnly / KeyValueの両Viewで同じCoW契約を確認する
      func testEraseWhereOnRangeViewOfSharedTreeDoesNotCopy() throws {
        var dictionary = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<20).map { ($0, $0) })

        dictionary[lowerBound(10).advanced(by: 2)..<end()].erase {
          $0.key % 2 == 0
        }

        XCTAssertEqual(dictionary.map(\.key), (0..<20).filter { $0 < 12 || $0 % 2 != 0 })
        XCTAssertEqual(dictionary._copyCount, 0)
      }

      func testEraseWhereOnStandaloneRangeViewCopiesOnceButLeavesBaseUntouched() throws {
        let dictionary = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<20).map { ($0, $0) })
        var range = dictionary[lowerBound(10).advanced(by: 2)..<end()]

        range.erase {
          $0.key % 2 == 0
        }

        // rangeが別変数として保持されているため、消去はrange側のみに反映され、元は変化しない
        XCTAssertEqual(dictionary.map(\.key), Array(0..<20))
        XCTAssertEqual(dictionary._copyCount, 0)
        XCTAssertEqual(range._copyCount, 1)
      }
  }
#endif
