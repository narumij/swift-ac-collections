import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetInsertionTests: RedBlackTreeTestCase {

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

  #if !COMPATIBLE_ATCODER_2025 && ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
    /// 再利用されたnodeのIndexが、CoW後も同じ世代のnodeを指すこと
    func test_indexInserting_preservesGenerationAcrossCopyOnWrite() {
      var set = RedBlackTreeSet<Int>()

      let staleIndex = set.index(inserting: 1).index
      XCTAssertTrue(set.removeSafe(at: staleIndex))

      let currentIndex = set.index(inserting: 1).index
      XCTAssertFalse(set.isValid(staleIndex))
      XCTAssertTrue(set.isValid(currentIndex))

      var copy = set

      XCTAssertFalse(copy.isValid(staleIndex))
      XCTAssertTrue(copy.removeSafe(at: currentIndex))
      XCTAssertFalse(copy.contains(1))
      XCTAssertTrue(set.contains(1))
    }

    /// CoWで分岐した一方の世代変更が、他方の同世代Indexを無効にしないこと
    func test_indexInserting_tracksGenerationInTheTargetTree() {
      var source = RedBlackTreeSet<Int>()
      let index = source.index(inserting: 1).index

      var copy = source
      copy.insert(2)

      XCTAssertTrue(source.removeSafe(at: index))
      _ = source.index(inserting: 1)

      XCTAssertTrue(copy.isValid(index))
      XCTAssertTrue(copy.removeSafe(at: index))
      XCTAssertFalse(copy.contains(1))
    }
  #endif
}
