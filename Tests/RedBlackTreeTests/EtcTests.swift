// このファイル自体は整理整頓時に消さないこと
import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

/// 棚卸し用の雑多な検証置き場。
final class EtcTests: RedBlackTreeTestCase, _UnsafeNodePtrType {

  override func setUpWithError() throws {
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    try super.tearDownWithError()
  }

  #if !COMPATIBLE_ATCODER_2025
    #if false  // RBT-063: 意味論の検討が必要なため、対応は後で行う。
      // 多重系の.lessThanOrEqual/.greaterThanOrEqualが同値の端ではなく途中の要素を指す。
      // findを__find_equal版にしている（unsafe_tree+find.swiftで保留中）ことの影響なので、findの扱いと合わせて判断する。
      #if ENABLE_EXPERIMENTAL_TREE_BOUND_COMPARISONS
      func testMultiBoundsOrEqualReachEndsOfEqualRun() {
        let multiSet: RedBlackTreeMultiSet<Int> = [1, 5, 5, 5, 7]
        XCTAssertEqual(Array(multiSet[...(.lessThanOrEqual(5))]), [1, 5, 5, 5])
        XCTAssertEqual(Array(multiSet[(.greaterThanOrEqual(5))...]), [5, 5, 5, 7])
        var erased = multiSet
        _ = erased.erase(.lessThanOrEqual(5))
        XCTAssertEqual(Array(erased), [1, 5, 5, 7])  // 最後の5を消す

        var multiMap = RedBlackTreeMultiMap<Int, String>()
        multiMap.insert(key: 5, value: "a")
        multiMap.insert(key: 5, value: "b")
        multiMap.insert(key: 5, value: "c")
        XCTAssertEqual(multiMap[.lessThanOrEqual(5)]?.value, "c")
        XCTAssertEqual(multiMap[.greaterThanOrEqual(5)]?.value, "a")
      }
      #endif

    #endif

    #if false && ENABLE_EXPERIMENTAL_LRU // LRUはあとまわし
      // LRUをmaxCount: 0で作って値を入れると、count == -1になる（ASanではheap-buffer-overflow）。
      func testLRUZeroMaxCountStaysEmpty() {
        var cache = ___LRUMemoizeStorage<Int, Int>(maxCount: 0)
        cache[1] = 1
        XCTAssertEqual(cache.count, 0)
        XCTAssertNil(cache[1])
      }

      // LRUのコピー側でgetしただけで、元の値の追い出し順が変わる。
      func testLRUGetOnCopyDoesNotAffectOriginal() {
        var original = ___LRUMemoizeStorage<Int, Int>(maxCount: 3)
        original[1] = 10
        original[2] = 20
        original[3] = 30
        var copy = original
        _ = copy[1]
        original[4] = 40  // originalだけなら1を追い出す
        original[5] = 50  // originalだけなら2を追い出す
        XCTAssertNil(original[1])
        XCTAssertNil(original[2])
        XCTAssertEqual(original[3], 30)
        XCTAssertEqual(original[4], 40)
        XCTAssertEqual(original[5], 50)
      }

    #endif

    #if false // 木の作成時の世代管理の問題
      // 空にした木をコピーしてから挿入すると、削除前のIndexが新しい要素に解決する。
      func testIndexOfRemovedElementStaysInvalidAfterCopyingEmptyTree() {
        var set: RedBlackTreeSet<Int> = [1]
        let index = set.startIndex
        set.remove(1)
        var copy = set
        copy.insert(2)
        XCTAssertFalse(copy.isElement(at: index))
      }

      // コピーして両方に挿入すると、片方のIndexがもう片方の別の要素に解決する。
      func testIndexFromDivergedCopyIsNotElementOfOther() {
        var a: RedBlackTreeSet<Int> = [1]
        var b = a
        a.insert(5)
        b.insert(7)
        let index = a.firstIndex(of: 5)!
        XCTAssertFalse(b.isElement(at: index))
      }

      // form系で木を作り直すと、前のIndexが同じ番号の新しいノードに解決する。
      func testIndexIsInvalidAfterFormUnionRebuild() {
        var set = RedBlackTreeSet([0, 2, 4])
        let index = set.firstIndex(of: 4)!
        set.formUnion(RedBlackTreeSet([1, 3]))
        if set.isElement(at: index) {
          XCTAssertEqual(set[index], 4)
        }
      }

    #endif

  #endif

  // RBT-081/RBT-088：共有中の空でない木に、何も消さない述語でerase(where:)しても、
  // 木をコピーしないこと。述語は各要素に1回ずつ、順に呼ばれること。

  #if !COMPATIBLE_ATCODER_2025
    func testEraseWhereNothingMatchesFromSharedSetDoesNotCopy() {
      let original: RedBlackTreeSet<Int> = [1, 2, 3]
      var shared = original
      var visited: [Int] = []

      shared.erase { visited.append($0); return false }

      XCTAssertEqual(visited, [1, 2, 3])
      XCTAssertEqual(Array(shared), [1, 2, 3])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(where:)で木がコピーされた")
    }

    func testEraseWhereSomeMatchFromSharedSetCallsPredicateOncePerElement() {
      let original: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
      var shared = original
      var visited: [Int] = []

      shared.erase { visited.append($0); return $0 % 2 == 0 }

      XCTAssertEqual(visited, [1, 2, 3, 4, 5])
      XCTAssertEqual(Array(shared), [1, 3, 5])
      XCTAssertEqual(Array(original), [1, 2, 3, 4, 5])
    }

    func testEraseWhereSomeMatchFromSharedMultiSetCallsPredicateOncePerElement() {
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 4]
      var shared = original
      var visited: [Int] = []

      shared.erase { visited.append($0); return $0 % 2 == 0 }

      XCTAssertEqual(visited, [1, 2, 2, 3, 4])
      XCTAssertEqual(Array(shared), [1, 3])
      XCTAssertEqual(Array(original), [1, 2, 2, 3, 4])
    }

    func testEraseWhereSomeMatchFromSharedDictionaryCallsPredicateOncePerElement() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d"]
      var shared = original
      var visited: [Int] = []

      shared.erase { visited.append($0.key); return $0.key % 2 == 0 }

      XCTAssertEqual(visited, [1, 2, 3, 4])
      XCTAssertEqual(shared.map(\.key), [1, 3])
      XCTAssertEqual(original.map(\.key), [1, 2, 3, 4])
    }

    func testEraseWhereSomeMatchFromSharedMultiMapCallsPredicateOncePerElement() {
      let original: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b"), (2, "c"), (3, "d")]
      var shared = original
      var visited: [Int] = []

      shared.erase { visited.append($0.key); return $0.key % 2 == 0 }

      XCTAssertEqual(visited, [1, 2, 2, 3])
      XCTAssertEqual(shared.map(\.key), [1, 3])
      XCTAssertEqual(original.map(\.key), [1, 2, 2, 3])
    }

    func testEraseWhereNothingMatchesFromSharedMultiSetDoesNotCopy() {
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3]
      var shared = original
      var visited: [Int] = []

      shared.erase { visited.append($0); return false }

      XCTAssertEqual(visited, [1, 2, 2, 3])
      XCTAssertEqual(Array(shared), [1, 2, 2, 3])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(where:)で木がコピーされた")
    }

    func testEraseWhereNothingMatchesFromSharedDictionaryDoesNotCopy() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      var shared = original
      var visited: [Int] = []

      shared.erase { visited.append($0.key); return false }

      XCTAssertEqual(visited, [1, 2, 3])
      XCTAssertEqual(shared.map(\.key), [1, 2, 3])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(where:)で木がコピーされた")
    }

    func testEraseWhereNothingMatchesFromSharedMultiMapDoesNotCopy() {
      let original: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b"), (2, "c")]
      var shared = original
      var visited: [Int] = []

      shared.erase { visited.append($0.key); return false }

      XCTAssertEqual(visited, [1, 2, 2])
      XCTAssertEqual(shared.map(\.key), [1, 2, 2])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(where:)で木がコピーされた")
    }
  #endif
}
