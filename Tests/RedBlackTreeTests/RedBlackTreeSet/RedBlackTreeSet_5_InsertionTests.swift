import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetInsertionTests: RedBlackTreeTestCase {

  private final class ComparableReference: Comparable {
    let key: Int
    let label: String

    init(key: Int, label: String) {
      self.key = key
      self.label = label
    }

    static func == (lhs: ComparableReference, rhs: ComparableReference) -> Bool {
      lhs.key == rhs.key
    }

    static func < (lhs: ComparableReference, rhs: ComparableReference) -> Bool {
      lhs.key < rhs.key
    }
  }

  private struct RunnableTask: Comparable {
    let pid: Int
    let virtualRuntime: Int

    static func < (lhs: Self, rhs: Self) -> Bool {
      if lhs.virtualRuntime != rhs.virtualRuntime {
        return lhs.virtualRuntime < rhs.virtualRuntime
      }
      return lhs.pid < rhs.pid
    }
  }

  /// 要素を挿入した場合、集合に含まれること
  func test_insert_singleElement() {
    // 事前条件: 空集合を用意
    var set = RedBlackTreeSet<Int>()

    // 実行: 要素3を挿入
    let result = set.insert(3)

    // 事後条件:
    // - 挿入結果.inserted == true（新規追加）
    // - 挿入後要素数 == 1
    // - map { $0 } == [3]
    XCTAssertTrue(result.inserted)
    XCTAssertEqual(set.count, 1)
    XCTAssertEqual(set + [], [3])
  }

  /// 同じ要素を再挿入した場合、挿入結果.insertedがfalseであり集合に重複はないこと
  func test_insert_duplicateElement() {
    // 事前条件: 要素3を持つ集合を用意
    var set = RedBlackTreeSet([3])

    // 実行: 要素3を再挿入
    let result = set.insert(3)

    // 事後条件:
    // - 挿入結果.inserted == false（既存要素）
    // - 挿入後要素数 == 1（重複なし）
    // - map { $0 } == [3]
    XCTAssertFalse(result.inserted)
    XCTAssertEqual(set.count, 1)
    XCTAssertEqual(set + [], [3])
  }

  /// 複数要素をinsert(contentsOf:)で挿入した場合、全要素が含まれること
  func test_insert_multipleElements() {
    // 事前条件: 空集合を用意
    var set = RedBlackTreeSet<Int>()

    // 実行: [1,2,3,4,5]を挿入
    set.merge([1, 2, 3, 4, 5])

    // 事後条件:
    // - 要素数 == 5
    // - 要素は昇順（順序保証仕様）
    XCTAssertEqual(set.count, 5)
    XCTAssertEqual(set + [], [1, 2, 3, 4, 5])
  }

  /// 別のRedBlackTreeSetの要素をinsert(contentsOf:)で追加できること
  func test_insert_fromAnotherSet() {
    // 事前条件: setA = [1,3], setB = [2,4]
    var setA = RedBlackTreeSet([1, 3])
    let setB = RedBlackTreeSet([2, 4])

    // 実行: setAにsetBの要素を挿入
    setA.merge(setB)

    // 事後条件:
    // - 要素数 == 4
    // - 要素は昇順（順序保証仕様）
    XCTAssertEqual(setA.count, 4)
    XCTAssertEqual(setA + [], [1, 2, 3, 4])
  }

  /// 別のRedBlackTreeMultiSetの要素をinsert(contentsOf:)で追加できること
  func test_insert_fromMultiSet() {
    // 事前条件: set = [1,3], multiSet = [2,4,4]
    var set = RedBlackTreeSet([1, 3])
    let multiSet = RedBlackTreeMultiSet([2, 4, 4])

    // 実行: setにmultiSetの要素を挿入
    set.merge(multiSet)

    // 事後条件:
    // - 要素数 == 4（重複要素は無視）
    // - 要素は昇順（順序保証仕様）
    XCTAssertEqual(set.count, 4)
    XCTAssertEqual(set + [], [1, 2, 3, 4])
  }

  /// 標準ライブラリのSetをmerge(_:)で追加できること
  func test_merge_fromSwiftSet() {
    var set: RedBlackTreeSet<Int> = [1, 2, 3]
    let swiftSet: Set<Int> = [4, 5, 6]

    set.merge(swiftSet)

    XCTAssertEqual(set + [], [1, 2, 3, 4, 5, 6])
  }

  /// merging(_:) が別のSetを統合した新しい集合を返し、元の集合を変更しないこと
  func test_mergingSetReturnsNewSetWithoutMutatingSource() {
    let set: RedBlackTreeSet = [1, 2]
    let merged = set.merging(RedBlackTreeSet([2, 3, 100]))

    XCTAssertEqual(merged + [], [1, 2, 3, 100])
    XCTAssertEqual(set + [], [1, 2])
  }

  /// merging(_:) がMultiSetの重複を除いて統合すること
  func test_mergingMultiSetRemovesDuplicates() {
    let set: RedBlackTreeSet = [1, 2]
    let merged = set.merging(RedBlackTreeMultiSet([2, 3, 3, 100]))

    XCTAssertEqual(merged + [], [1, 2, 3, 100])
    XCTAssertEqual(set + [], [1, 2])
  }

  /// merging(_:) が任意のSequenceを統合できること
  func test_mergingSequenceReturnsSortedUniqueElements() {
    let set: RedBlackTreeSet = [1, 2]
    let merged = set.merging([100, 3, 3])

    XCTAssertEqual(merged + [], [1, 2, 3, 100])
    XCTAssertEqual(set + [], [1, 2])
  }

  /// update(with:)で既存要素が更新されず、新規要素は追加されること
  func test_update_withElement() {
    // 事前条件: 集合に[1,3]を用意
    var set = RedBlackTreeSet([1, 3])

    // 実行: update(with:2)とupdate(with:3)
    let updateNew = set.update(with: 2)
    let updateExisting = set.update(with: 3)

    // 事後条件:
    // - updateNew == nil（新規要素）
    // - updateExisting == 3（既存要素で更新されず）
    // - 要素数 == 3
    // - 要素は昇順（順序保証仕様）
    XCTAssertNil(updateNew)
    XCTAssertEqual(updateExisting, 3)
    XCTAssertEqual(set.count, 3)
    XCTAssertEqual(set + [], [1, 2, 3])
  }

  /// update(with:) が同順序の参照を置換して、以前格納されていた参照を返すこと
  func test_updateReplacesEquivalentReferenceAndReturnsPreviousMember() {
    let original = ComparableReference(key: 3, label: "original")
    let replacement = ComparableReference(key: 3, label: "replacement")
    var set: RedBlackTreeSet = [original]

    XCTAssertTrue(set.update(with: replacement) === original)
    XCTAssertTrue(set.first === replacement)
    XCTAssertNil(set.update(with: ComparableReference(key: 10, label: "new")))
  }

  /// insert(_:) が同順序の参照を置換せず、既存の参照を返すこと
  func test_insertEquivalentReferencePreservesExistingMember() {
    let original = ComparableReference(key: 3, label: "original")
    let duplicate = ComparableReference(key: 3, label: "duplicate")
    var set = RedBlackTreeSet<ComparableReference>()

    let inserted = set.insert(original)
    let rejected = set.insert(duplicate)

    XCTAssertTrue(inserted.inserted)
    XCTAssertTrue(inserted.memberAfterInsert === original)
    XCTAssertFalse(rejected.inserted)
    XCTAssertTrue(rejected.memberAfterInsert === original)
  }

    /// ヒント付きinsertが新規要素と重複要素を正しく扱うこと
    func test_insert_withHint() {
      var set = RedBlackTreeSet([10, 30])

      let insertedWithGoodHint = set.insert(20, hint: set.firstIndex(of: 30)!)
      XCTAssertTrue(insertedWithGoodHint.inserted)
      XCTAssertEqual(set[insertedWithGoodHint.indexAfterInsert], 20)
      XCTAssertEqual(set + [], [10, 20, 30])

      let insertedWithBadHint = set.insert(25, hint: set.startIndex)
      XCTAssertTrue(insertedWithBadHint.inserted)
      XCTAssertEqual(set[insertedWithBadHint.indexAfterInsert], 25)
      XCTAssertEqual(set + [], [10, 20, 25, 30])

      let duplicate = set.insert(20, hint: set.endIndex)
      XCTAssertFalse(duplicate.inserted)
      XCTAssertEqual(set[duplicate.indexAfterInsert], 20)
      XCTAssertEqual(set + [], [10, 20, 25, 30])
    }

    /// ヒント付きupdateが新規要素ではnilを返し、重複要素では旧要素を返すこと
    func test_update_withHint() {
      var set = RedBlackTreeSet([10, 30])

      let insertedWithGoodHint = set.update(20, hint: set.firstIndex(of: 30)!)
      XCTAssertNil(insertedWithGoodHint)
      XCTAssertEqual(set + [], [10, 20, 30])

      let insertedWithBadHint = set.update(25, hint: set.startIndex)
      XCTAssertNil(insertedWithBadHint)
      XCTAssertEqual(set + [], [10, 20, 25, 30])

      let duplicate = set.update(20, hint: set.endIndex)
      XCTAssertEqual(duplicate, 20)
      XCTAssertEqual(set + [], [10, 20, 25, 30])
    }

  #if ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
    /// Linuxのスケジューラ風に、run queueへのenqueue時にIndexを保存し、
    /// sleep/dequeue時はtaskを再検索せず、そのIndexから取り除く主用途の実験。
    func test_indexInserting_linuxSchedulerStyleRunQueueExperiment() {
      var runQueue = RedBlackTreeSet<RunnableTask>()
      let interactive = RunnableTask(pid: 101, virtualRuntime: 10)
      let background = RunnableTask(pid: 202, virtualRuntime: 30)

      let (interactiveInserted, _) = runQueue.index(inserting: interactive)
      let (backgroundInserted, backgroundIndex) = runQueue.index(inserting: background)

      XCTAssertTrue(interactiveInserted)
      XCTAssertTrue(backgroundInserted)
      XCTAssertEqual(runQueue.first, interactive)

      // The background task sleeps: dequeue it directly through its saved Index.
      let successor = runQueue.erase(exactly: backgroundIndex)

      XCTAssertEqual(successor, runQueue.endIndex)
      XCTAssertEqual(Array(runQueue), [interactive])
    }

    /// 空のSetに対して`erase(exactly:)`を呼んでもトラップせず、`nil`を返すこと。
    /// トラップしない以上、無駄なCoW(共有される空シングルトンバッファからの退避)も
    /// 発生しないこと。
    func test_eraseExactly_onEmptySetReturnsNilWithoutCopy() {
      var set = RedBlackTreeSet<Int>()

      #if AC_COLLECTIONS_INTERNAL_CHECKS
        XCTAssertEqual(set._copyCount, 0)
      #endif
      XCTAssertNil(set.erase(exactly: set.startIndex))
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        XCTAssertEqual(set._copyCount, 0, "空の削除はnilを返すだけで、バッファのコピーを発生させないはず")
      #endif
      XCTAssertNil(set.erase(exactly: set.endIndex))
    }
  #endif

  #if DEBUG && ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
    /// CoW後もindex(inserting:)で保存したIndexから対象を削除できること
    func test_indexInserting_savedIndicesRemainUsableAfterCopyOnWrite() {
      var set = RedBlackTreeSet(0..<8)

      // recycle countが進んだnodeもCoWで正しく引き継がれることを確認する。
      let removedIndex = set.firstIndex(of: 4)!
      XCTAssertTrue((set.erase(exactly: removedIndex) != nil))
      let recycled = set.index(inserting: 8)
      XCTAssertTrue(recycled.inserted)

      set._copyCount = 0
      let shared = set

      withExtendedLifetime(shared) {
        var saved: [(element: Int, index: RedBlackTreeSet<Int>.Index)] = [
          (8, recycled.index)
        ]

        // 最初の挿入でCoWし、その後もしばらく挿入とIndex保存を続ける。
        for element in 9..<64 {
          let result = set.index(inserting: element)
          XCTAssertTrue(result.inserted)
          saved.append((element, result.index))
        }

        XCTAssertGreaterThan(set._copyCount, 0)

        for (element, index) in saved {
          XCTAssertTrue(set.isElement(at: index))
          XCTAssertEqual(set[index], element)
        }

        for (element, index) in saved {
          XCTAssertTrue((set.erase(exactly: index) != nil))
          XCTAssertFalse(set.contains(element))
        }

        XCTAssertGreaterThan(set._copyCount, 0)
        XCTAssertEqual(set + [], [0, 1, 2, 3, 5, 6, 7])
        XCTAssertEqual(shared + [], [0, 1, 2, 3, 5, 6, 7, 8])
      }
    }
  #endif
}
