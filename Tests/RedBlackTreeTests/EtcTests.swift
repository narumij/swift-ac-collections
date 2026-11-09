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

  // RBT-102：MultiMapの位置添字で取り出した要素は、同値キーの並びどおりで、元の木を後から変更・破棄しても壊れないこと。

  #if !COMPATIBLE_ATCODER_2025
    func testMultiMapPositionSubscriptReadsEquivalentKeysInOrder() {
      var map = RedBlackTreeMultiMap<String, String>()
      map.insert(key: "b", value: "b0")
      map.insert(key: "a", value: "a0")
      map.insert(key: "b", value: "b1")
      map.insert(key: "a", value: "a1")
      map.insert(key: "b", value: "b2")

      var pairs: [String] = []
      var i = map.startIndex
      while i != map.endIndex {
        pairs.append("\(map[i].key):\(map[i].value)")
        i = map.index(after: i)
      }
      XCTAssertEqual(pairs, ["a:a0", "a:a1", "b:b0", "b:b1", "b:b2"])
    }

    func testMultiMapPositionSubscriptElementsOutliveMutation() {
      final class Box {
        let id: Int
        init(_ id: Int) { self.id = id }
      }
      var map = RedBlackTreeMultiMap<String, Box>()
      for i in 0 ..< 200 { map.insert(key: "key\(i / 2)", value: Box(i)) }

      var taken: [(key: String, value: Box)] = []
      var i = map.startIndex
      while i != map.endIndex {
        taken.append(map[i])
        i = map.index(after: i)
      }

      map.removeAll()
      for j in 0 ..< 200 { map.insert(key: "other\(j)", value: Box(-j)) }

      XCTAssertEqual(taken.count, 200)
      for (key, value) in taken {
        XCTAssertEqual(key, "key\(value.id / 2)")
      }
    }

    func testMultiMapPositionSubscriptOnSharedTreeKeepsSharedStorage() {
      var original = RedBlackTreeMultiMap<String, [Int]>()
      original.insert(key: "a", value: [1])
      original.insert(key: "a", value: [2])
      let shared = original

      let element = shared[shared.index(after: shared.startIndex)]

      XCTAssertEqual(element.key, "a")
      XCTAssertEqual(element.value, [2])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original))
      original.insert(key: "a", value: [3])
      XCTAssertEqual(element.value, [2])
      XCTAssertEqual(shared.map(\.value), [[1], [2]])
    }
  #endif
}
