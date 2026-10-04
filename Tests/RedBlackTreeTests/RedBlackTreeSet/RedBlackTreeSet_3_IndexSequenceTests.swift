import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetIndexRangeTests: RedBlackTreeTestCase {

  #if !COMPATIBLE_ATCODER_2025
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
        XCTAssertTrue(a.isElement(at: b0), "ソース側世代チェックが省略されているため")
      #endif
      XCTAssertEqual(b.sorted(), Array(1..<19))
    }
  #endif

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
