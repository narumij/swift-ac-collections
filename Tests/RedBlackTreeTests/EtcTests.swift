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

    #if false
      // 以下、2026-11-07〜08のバグ探しで再現した不具合。各テストは正しい挙動を期待するので、修正前は失敗する。
      // 停止しない・解放済みメモリを読むものは、その旨を各テストに書いた。

      // merge失敗後、走査が存在しない要素を返し、等値比較も崩れる（RBT-058の続き）。
      func testMergeThrowLeavesNoPhantomElement() {
        enum Stop: Error { case requested }
        var dictionary: RedBlackTreeDictionary<Int, Int> = [1: 1, 2: 2, 3: 3]
        XCTAssertThrowsError(try dictionary.merge([(1, 10), (0, 0)]) { _, _ in
          throw Stop.requested
        })
        XCTAssertEqual(dictionary.sorted { $0.key < $1.key }.map(\.key), [1, 2, 3])
        XCTAssertEqual(dictionary, [1: 1, 2: 2, 3: 3])
      }

    #endif

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

    #if false && ENABLE_EXPERIMENTAL_LRU
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

    #if false
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

    #if false
      // 見つからないキーの削除で、共有中のストレージを丸ごとコピーする（Set／MultiSetは修正済み）。
      // 4型への横展開で見つけた。修正前は失敗する。
      func testNoOpRemovalKeepsSharedStorageDictionary() {
        let dictionary = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<100).map { ($0, $0) })
        var copy = dictionary
        _ = copy.removeValue(forKey: -1)
        XCTAssertTrue(dictionary.isTriviallyIdentical(to: copy))
      }

      func testNoOpRemovalKeepsSharedStorageMultiMap() {
        let multiMap = RedBlackTreeMultiMap(keysWithValues: (0..<100).map { ($0, $0) })
        var copy = multiMap
        _ = copy.eraseUnique(-1)
        _ = copy.eraseMulti(-1)
        XCTAssertTrue(multiMap.isTriviallyIdentical(to: copy))

        let empty = RedBlackTreeMultiMap<Int, Int>()
        var emptyCopy = empty
        _ = emptyCopy.eraseUnique(0)
        _ = emptyCopy.eraseMulti(0)
        XCTAssertTrue(empty.isTriviallyIdentical(to: emptyCopy))
      }
    #endif

    #if false
      // letで共有した木から複数スレッドが同時に最初のIndexを作ると、_lazyDetachの遅延生成が競合する。
      // releaseで同じ位置のIndex同士が一致しないことがある。TSanではdata raceとして報告される。
      func testConcurrentFirstIndexCreationAgrees() {
        nonisolated(unsafe) let indices = UnsafeMutablePointer<RedBlackTreeSet<Int>.Index?>
          .allocate(capacity: 2)
        indices.initialize(repeating: nil, count: 2)
        defer { indices.deinitialize(count: 2); indices.deallocate() }
        var mismatches = 0
        for trial in 0..<20_000 {
          var set = RedBlackTreeSet<Int>()
          set.insert(trial)
          let shared = set
          DispatchQueue.concurrentPerform(iterations: 2) { thread in
            indices[thread] = shared.startIndex
          }
          if indices[0]! != indices[1]! || indices[0]! != shared.startIndex { mismatches += 1 }
        }
        XCTAssertEqual(mismatches, 0)
      }
    #endif

  #endif

}
