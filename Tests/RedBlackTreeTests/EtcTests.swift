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

  // 辞書の位置添字で取り出した要素は、辞書を後から変更・削除しても壊れないこと。

  #if !COMPATIBLE_ATCODER_2025
    func testDictionaryPositionSubscriptElementsOutliveMutation() {
      final class Box: Equatable {
        let id: Int
        init(_ id: Int) { self.id = id }
        static func == (lhs: Box, rhs: Box) -> Bool { lhs.id == rhs.id }
      }
      var dictionary = RedBlackTreeDictionary<String, Box>()
      for i in 0 ..< 200 { dictionary["key\(i)"] = Box(i) }

      var taken: [(key: String, value: Box)] = []
      var i = dictionary.startIndex
      while i != dictionary.endIndex {
        taken.append(dictionary[i])
        let (k, v) = dictionary[i]
        XCTAssertEqual(dictionary[k]?.id, v.id)
        i = dictionary.index(after: i)
      }

      dictionary.removeAll()
      for j in 0 ..< 200 { dictionary["other\(j)"] = Box(-j) }

      XCTAssertEqual(taken.count, 200)
      XCTAssertEqual(Set(taken.map(\.key)).count, 200)
      for (key, value) in taken {
        XCTAssertEqual(key, "key\(value.id)")
      }
    }
  #endif

  // RBT-098：共有中の空でない木に、空の木をmerge・insert(contentsOf:)しても、木をコピーしないこと。

  #if !COMPATIBLE_ATCODER_2025
    func testSetMergeEmptySetOnSharedTreeDoesNotCopy() {
      let original: RedBlackTreeSet<Int> = [1, 2, 3]
      var shared = original

      shared.merge(RedBlackTreeSet<Int>())

      XCTAssertEqual(Array(shared), [1, 2, 3])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のSetのmergeで木がコピーされた")
    }

    func testSetMergeEmptyMultiSetOnSharedTreeDoesNotCopy() {
      let original: RedBlackTreeSet<Int> = [1, 2, 3]
      var shared = original

      shared.merge(RedBlackTreeMultiSet<Int>())

      XCTAssertEqual(Array(shared), [1, 2, 3])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のMultiSetのmergeで木がコピーされた")
    }

    func testMultiSetInsertContentsOfEmptySetOnSharedTreeDoesNotCopy() {
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3]
      var shared = original

      shared.insert(contentsOf: RedBlackTreeSet<Int>())

      XCTAssertEqual(Array(shared), [1, 2, 2, 3])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のSetのinsert(contentsOf:)で木がコピーされた")
    }

    func testMultiSetInsertContentsOfEmptyMultiSetOnSharedTreeDoesNotCopy() {
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3]
      var shared = original

      shared.insert(contentsOf: RedBlackTreeMultiSet<Int>())

      XCTAssertEqual(Array(shared), [1, 2, 2, 3])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のMultiSetのinsert(contentsOf:)で木がコピーされた")
    }

    func testDictionaryMergeEmptyDictionaryOnSharedTreeDoesNotCopy() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
      var shared = original

      shared.merge(RedBlackTreeDictionary<Int, String>()) { $1 }

      XCTAssertEqual(shared.map(\.key), [1, 2, 3])
      XCTAssertEqual(shared.map(\.value), ["a", "b", "c"])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のDictionaryのmergeで木がコピーされた")
    }

    func testMultiMapInsertContentsOfEmptyMultiMapOnSharedTreeDoesNotCopy() {
      var original = RedBlackTreeMultiMap<Int, String>()
      original.insert(key: 1, value: "a")
      original.insert(key: 2, value: "b")
      original.insert(key: 2, value: "c")
      var shared = original

      shared.insert(contentsOf: RedBlackTreeMultiMap<Int, String>())

      XCTAssertEqual(shared.map(\.key), [1, 2, 2])
      XCTAssertEqual(shared.map(\.value), ["a", "b", "c"])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のMultiMapのinsert(contentsOf:)で木がコピーされた")
    }
  #endif
}
