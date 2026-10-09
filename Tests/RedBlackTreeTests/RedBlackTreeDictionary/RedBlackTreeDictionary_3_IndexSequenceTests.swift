import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryIndexRangeTests: RedBlackTreeTestCase {

    func test_distance_isPositiveForwardAndNegativeBackward() {
      let dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]

      XCTAssertEqual(
        dictionary.distance(from: dictionary.startIndex, to: dictionary.endIndex),
        dictionary.count
      )
      XCTAssertEqual(
        dictionary.distance(from: dictionary.endIndex, to: dictionary.startIndex),
        -dictionary.count
      )
    }

    func test_indexAndFormIndex_moveForwardAndBackwardSymmetrically() {
      let dictionary: RedBlackTreeDictionary<Int, Int> = [1: 10, 2: 20, 3: 30, 4: 40, 5: 50]

      var i = dictionary.startIndex
      for _ in 0..<dictionary.count {
        XCTAssertEqual(dictionary.distance(from: i, to: dictionary.index(after: i)), 1)
        i = dictionary.index(after: i)
      }
      XCTAssertEqual(i, dictionary.endIndex)

      for _ in 0..<dictionary.count {
        XCTAssertEqual(dictionary.distance(from: i, to: dictionary.index(before: i)), -1)
        i = dictionary.index(before: i)
      }
      XCTAssertEqual(i, dictionary.startIndex)

      for _ in 0..<dictionary.count {
        dictionary.formIndex(after: &i)
      }
      XCTAssertEqual(i, dictionary.endIndex)

      for _ in 0..<dictionary.count {
        dictionary.formIndex(before: &i)
      }
      XCTAssertEqual(i, dictionary.startIndex)
    }

    func testIsElementAndIsEndDistinguishElementFromEnd() {
      let dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]

      XCTAssertTrue(dictionary.isElement(at: dictionary.startIndex))
      XCTAssertFalse(dictionary.isEnd(dictionary.startIndex))
      XCTAssertFalse(dictionary.isElement(at: dictionary.endIndex))
      XCTAssertTrue(dictionary.isEnd(dictionary.endIndex))
    }

    func testIsEndRecognizesEmptyDictionaryEndIndex() {
      let dictionary = RedBlackTreeDictionary<Int, String>()

      XCTAssertFalse(dictionary.isElement(at: dictionary.endIndex))
      XCTAssertTrue(dictionary.isEnd(dictionary.endIndex))
    }

    func testIsElementAndIsEndRejectStaleIndex() {
      var dictionary: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]
      let index = dictionary.index(forKey: 1)!

      dictionary.remove(at: index)
      XCTAssertFalse(dictionary.isElement(at: index))
      XCTAssertFalse(dictionary.isEnd(index))
    }

    #if ALLOW_CROSS_TREE_INDEX
      func testIsElementAndIsEndResolveIndicesInCopiedTree() {
        let source: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]
        let copy = source

        XCTAssertTrue(copy.isElement(at: source.index(forKey: 1)!))
        XCTAssertTrue(copy.isEnd(source.endIndex))
      }
    #endif

    #if ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
      /// 発行元の木が解放されたIndexでも、CoWで分岐して生き残った木では対応する要素へ
      /// 解決できること(`index_stale_check.md`のF3)。
      func testIndexOutlivingItsOriginResolvesInSurvivingCopy() {
        @inline(never)
        func makeSurvivingCopyAndIndex() -> (
          RedBlackTreeDictionary<Int, String>, RedBlackTreeDictionary<Int, String>.Index
        ) {
          let source: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]
          var copy = source
          copy.insert((3, "d"))  // CoWでcopyが専用のバッファを持ち、sourceは元のバッファを持つ
          return (copy, source.index(forKey: 1)!)
        }

        // ここでsourceのバッファが解放され、Indexの発行元は失われる
        let (copy, index) = makeSurvivingCopyAndIndex()

        XCTAssertTrue(copy.isElement(at: index))
        XCTAssertEqual(copy[index].key, 1)
        XCTAssertEqual(copy[index].value, "b")
      }

      /// 発行元の木が解放されたIndexは、生き残った木で対応するnodeが削除・再利用されて
      /// いれば拒否されること(`index_stale_check.md`のF4)。
      func testIndexOutlivingItsOriginIsRejectedAfterSurvivingCopyRecyclesItsNode() {
        @inline(never)
        func makeSurvivingCopyAndIndex() -> (
          RedBlackTreeDictionary<Int, String>, RedBlackTreeDictionary<Int, String>.Index
        ) {
          let source: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]
          var copy = source
          copy.remove(at: copy.index(forKey: 1)!)  // CoWが起き、copyでnodeが削除される
          copy.insert((1, "z"))  // 同じslotが新しい世代で再利用される
          return (copy, source.index(forKey: 1)!)
        }

        let (copy, index) = makeSurvivingCopyAndIndex()

        XCTAssertFalse(copy.isElement(at: index))
        XCTAssertFalse(copy.isEnd(index))
        XCTAssertEqual(copy[1], "z", "キー自体はcopyに存在する")
      }
    #endif

  /// index(_:offsetBy:) が指定距離のエントリを指すこと
  func test_index_offsetBy() {
    let dictionary: RedBlackTreeDictionary = [10: "a", 20: "b", 30: "c", 40: "d", 50: "e"]
    let start = dictionary.startIndex

    let idx = dictionary.index(start, offsetBy: 2)

    XCTAssertEqual(dictionary[idx].key, 30)
  }

  /// index(_:offsetBy:limitedBy:) が制限範囲内では移動し、超過した場合はnilを返すこと
  func test_index_offsetBy_limitedBy() {
    let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
    let start = dictionary.startIndex
    let limit = dictionary.index(after: start)

    let limitedIndex = dictionary.index(start, offsetBy: 2, limitedBy: limit)

    XCTAssertNil(limitedIndex)
  }

  /// formIndex(_:offsetBy:) が正しく指定距離のエントリ位置に移動できること
  func test_formIndex_offsetBy() {
    let dictionary: RedBlackTreeDictionary = [10: "a", 20: "b", 30: "c", 40: "d", 50: "e"]
    var idx = dictionary.startIndex

    dictionary.formIndex(&idx, offsetBy: 3)

    XCTAssertEqual(dictionary[idx].key, 40)
  }

  /// formIndex(_:offsetBy:limitedBy:) が制限範囲内では移動し、超過した場合は失敗すること
  func test_formIndex_offsetBy_limitedBy() {
    let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
    let start = dictionary.startIndex
    let limit = dictionary.index(after: start)

    var idx = start
    let success = dictionary.formIndex(&idx, offsetBy: 2, limitedBy: limit)

    XCTAssertFalse(success)
  }
}
