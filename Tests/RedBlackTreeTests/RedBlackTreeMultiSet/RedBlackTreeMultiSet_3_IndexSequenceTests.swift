import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetIndexRangeTests: RedBlackTreeTestCase {

  #if !COMPATIBLE_ATCODER_2025
    func testIsElementAndIsEndDistinguishElementFromEnd() {
      let multiset: RedBlackTreeMultiSet = [0, 1, 1, 2]

      XCTAssertTrue(multiset.isElement(at: multiset.startIndex))
      XCTAssertFalse(multiset.isEnd(multiset.startIndex))
      XCTAssertFalse(multiset.isElement(at: multiset.endIndex))
      XCTAssertTrue(multiset.isEnd(multiset.endIndex))
    }

    func testIsEndRecognizesEmptyMultiSetEndIndex() {
      let multiset = RedBlackTreeMultiSet<Int>()

      XCTAssertFalse(multiset.isElement(at: multiset.endIndex))
      XCTAssertTrue(multiset.isEnd(multiset.endIndex))
    }

    func testIsElementAndIsEndRejectStaleIndex() {
      var multiset: RedBlackTreeMultiSet = [0, 1, 1, 2]
      let index = multiset.firstIndex(of: 1)!

      XCTAssertEqual(multiset.remove(at: index), 1)
      XCTAssertFalse(multiset.isElement(at: index))
      XCTAssertFalse(multiset.isEnd(index))
    }

    #if ALLOW_CROSS_TREE_INDEX
      func testIsElementAndIsEndResolveIndicesInCopiedTree() {
        let source: RedBlackTreeMultiSet = [0, 1, 1, 2]
        let copy = source

        XCTAssertTrue(copy.isElement(at: source.firstIndex(of: 1)!))
        XCTAssertTrue(copy.isEnd(source.endIndex))
      }
    #endif

    #if ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
      /// 発行元の木が解放されたIndexでも、CoWで分岐して生き残った木では対応する要素へ
      /// 解決できること(`index_stale_check.md`のF3)。
      func testIndexOutlivingItsOriginResolvesInSurvivingCopy() {
        @inline(never)
        func makeSurvivingCopyAndIndex() -> (
          RedBlackTreeMultiSet<Int>, RedBlackTreeMultiSet<Int>.Index
        ) {
          let source: RedBlackTreeMultiSet = [0, 1, 1, 2]
          var copy = source
          copy.insert(3)  // CoWでcopyが専用のバッファを持ち、sourceは元のバッファを持つ
          return (copy, source.firstIndex(of: 1)!)
        }

        // ここでsourceのバッファが解放され、Indexの発行元は失われる
        let (copy, index) = makeSurvivingCopyAndIndex()

        XCTAssertTrue(copy.isElement(at: index))
        XCTAssertEqual(copy[index], 1)
      }

      /// 発行元の木が解放されたIndexは、生き残った木で対応するnodeが削除・再利用されて
      /// いれば拒否されること(`index_stale_check.md`のF4)。
      func testIndexOutlivingItsOriginIsRejectedAfterSurvivingCopyRecyclesItsNode() {
        @inline(never)
        func makeSurvivingCopyAndIndex() -> (
          RedBlackTreeMultiSet<Int>, RedBlackTreeMultiSet<Int>.Index
        ) {
          let source: RedBlackTreeMultiSet = [0, 1, 1, 2]
          var copy = source
          copy.remove(at: copy.firstIndex(of: 1)!)  // CoWが起き、copyでnodeが削除される
          copy.insert(1)  // 同じslotが新しい世代で再利用される
          return (copy, source.firstIndex(of: 1)!)
        }

        let (copy, index) = makeSurvivingCopyAndIndex()

        XCTAssertFalse(copy.isElement(at: index))
        XCTAssertFalse(copy.isEnd(index))
        XCTAssertEqual(copy.count(of: 1), 2, "要素自体はcopyに存在する")
      }
    #endif
  #endif
}

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeMultiSetFormIndexLimitedTests: RedBlackTreeTestCase {

    /// `formIndex(_:offsetBy:limitedBy:)`は、限界に届かなければ移動して`true`、届けば限界で止まって`false`を返すこと。
    func testFormIndexOffsetByLimitedBy() {
      let m = RedBlackTreeMultiSet<Int>([1, 2, 2, 3])
      var i = m.startIndex
      XCTAssertTrue(m.formIndex(&i, offsetBy: 2, limitedBy: m.endIndex))
      XCTAssertEqual(m[i], 2)
      XCTAssertFalse(m.formIndex(&i, offsetBy: 10, limitedBy: m.endIndex))
      XCTAssertEqual(i, m.endIndex)
    }
  }
#endif
