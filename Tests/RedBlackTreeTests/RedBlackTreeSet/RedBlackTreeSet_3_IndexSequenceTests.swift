import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetIndexRangeTests: RedBlackTreeTestCase {

    func testIsElementAndIsEndDistinguishElementFromEnd() {
      let set: RedBlackTreeSet = [0, 1, 2]

      XCTAssertTrue(set.isElement(at: set.startIndex))
      XCTAssertFalse(set.isEnd(set.startIndex))
      XCTAssertFalse(set.isElement(at: set.endIndex))
      XCTAssertTrue(set.isEnd(set.endIndex))
    }

    func testIsEndRecognizesEmptySetEndIndex() {
      let set = RedBlackTreeSet<Int>()

      XCTAssertFalse(set.isElement(at: set.endIndex))
      XCTAssertTrue(set.isEnd(set.endIndex))
    }

    func testIsElementAndIsEndRejectStaleIndex() {
      var set: RedBlackTreeSet = [0, 1, 2]
      let index = set.find(1)

      XCTAssertEqual(set.remove(at: index), 1)
      XCTAssertFalse(set.isElement(at: index))
      XCTAssertFalse(set.isEnd(index))
    }

    #if ALLOW_CROSS_TREE_INDEX
      func testIsElementAndIsEndResolveIndicesInCopiedTree() {
        let source: RedBlackTreeSet = [0, 1, 2]
        let copy = source

        XCTAssertTrue(copy.isElement(at: source.find(1)))
        XCTAssertTrue(copy.isEnd(source.endIndex))
      }
    #endif

    #if ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
      /// 発行元の木が解放されたIndexでも、CoWで分岐して生き残った木では対応する要素へ
      /// 解決できること(`index_stale_check.md`のF3)。
      func testIndexOutlivingItsOriginResolvesInSurvivingCopy() {
        @inline(never)
        func makeSurvivingCopyAndIndex() -> (RedBlackTreeSet<Int>, RedBlackTreeSet<Int>.Index) {
          let source: RedBlackTreeSet = [0, 1, 2]
          var copy = source
          copy.insert(3)  // CoWでcopyが専用のバッファを持ち、sourceは元のバッファを持つ
          return (copy, source.find(1))
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
        func makeSurvivingCopyAndIndex() -> (RedBlackTreeSet<Int>, RedBlackTreeSet<Int>.Index) {
          let source: RedBlackTreeSet = [0, 1, 2]
          var copy = source
          copy.remove(1)  // CoWが起き、copyでnodeが削除される
          copy.insert(1)  // 同じslotが新しい世代で再利用される
          return (copy, source.find(1))
        }

        let (copy, index) = makeSurvivingCopyAndIndex()

        XCTAssertFalse(copy.isElement(at: index))
        XCTAssertFalse(copy.isEnd(index))
        XCTAssertTrue(copy.contains(1), "要素自体はcopyに存在する")
      }
    #endif

    /// コピー後に片方をCoW変異させても、発行元(コピー元)に対するIndexの有効性チェックは影響を受けないこと
    func testIndexValidityAgainstOriginIsUnaffectedByCopyThenMutateCoW() throws {
      var b = RedBlackTreeSet<Int>(0..<20)
      let a = b
      XCTAssertTrue(b.isElement(at: a.startIndex))
      XCTAssertTrue(a.isElement(at: b.startIndex))
      XCTAssertEqual(a.startIndex, b.startIndex)

      let b0 = b.startIndex
      b.removeFirst()  // この時点でCoWが発生する

      XCTAssertTrue(b0.isValid, "発行元(a)に対するチェックは有効を示す")
      // CoWで分岐した相手の変更は、このIndexの有効性に影響しない(`Design-RuntimeChecks.md`の
      // 「状態ごとの結果」、`index_stale_check.md`のF列)。
      XCTAssertTrue(a.isElement(at: b0), "直感に反するが、発行元では引き続き要素として扱われる")
      XCTAssertEqual(b.sorted(), Array(1..<20))

      XCTAssertFalse(b.isElement(at: b0), "CoW後のb自身に対しては無効化されていること")
    }

    /// コピー後に連続してCoW変異(removeLast→removeFirst)させた場合、2回目以降はCoWが発生せず、Indexが正しく無効化されること
    func testIndexValidityAfterConsecutiveMutationsWithOnlyFirstTriggeringCoW() throws {
      var b = RedBlackTreeSet<Int>(0..<20)
      let a = b
      XCTAssertTrue(b.isElement(at: a.startIndex))
      XCTAssertTrue(a.isElement(at: b.startIndex))
      XCTAssertEqual(a.startIndex, b.startIndex)

      b.removeLast()  // この時点でCoWが発生する
      let b0 = b.startIndex
      b.removeFirst()  // CoWは発生しない(既にユニーク)

      XCTAssertFalse(b0.isValid)
      XCTAssertFalse(b.isElement(at: b0))
      #if USE_LAZY_DETACH || !ALLOW_CROSS_TREE_INDEX
        XCTAssertFalse(a.isElement(at: b0))
      #else
        // Indexは受け取り側の木のnodeとだけ照合する(`Design-RuntimeChecks.md`の「状態ごとの結果」)。
        XCTAssertTrue(a.isElement(at: b0), "ソース側世代チェックが省略されているため")
      #endif
      XCTAssertEqual(b.sorted(), Array(1..<19))
    }

  /// formIndex(after:)/(before:) がindex(after:)/(before:)と同じ順序で全要素を辿り、境界で正しく停止すること
  func testFormIndexAfterAndBeforeMatchIndexAfterAndBeforeTraversal() {
    var set = RedBlackTreeSet<Int>(0..<5)

    var forward: [Int] = []
    var i = set.startIndex
    while i != set.endIndex {
      forward.append(set[i])
      set.formIndex(after: &i)
    }
    XCTAssertEqual(forward, [0, 1, 2, 3, 4])
    XCTAssertEqual(i, set.endIndex)

    var backward: [Int] = []
    var j = set.endIndex
    while j != set.startIndex {
      set.formIndex(before: &j)
      backward.append(set[j])
    }
    XCTAssertEqual(backward, [4, 3, 2, 1, 0])
  }
}
