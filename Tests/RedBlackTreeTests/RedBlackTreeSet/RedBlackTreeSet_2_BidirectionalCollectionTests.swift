import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetBidirectionalCollectionTests: RedBlackTreeTestCase {

  /// startIndexとendIndexの正しさ、および範囲外インデックスの確認を行うこと
  func test_startIndex_endIndex() {
    // 事前条件: 集合に[1,2,3]
    let set = RedBlackTreeSet([1, 2, 3])

    // 実行: startIndex, endIndex取得
    let start = set.startIndex
    let end = set.endIndex

    // 事後条件:
    // - startIndexが最初の要素を指すこと
    XCTAssertEqual(set[start], 1)

    // - index(after: startIndex)が2番目の要素を指すこと
    let secondIndex = set.index(after: start)
    XCTAssertEqual(set[secondIndex], 2)

    // - index(before: endIndex)が最後の要素を指すこと
    let lastIndex = set.index(before: end)
    XCTAssertEqual(set[lastIndex], 3)

    // - endIndex自体は範囲外でアクセス不可である（コメントのみ記載）
    // XCTAssertThrowsError { _ = set[end] } // コメント: 実行すると範囲外アクセスでクラッシュのため、説明のみ
  }

  /// countが要素数と一致すること
  func test_count_matchesElementCount() {
    // 事前条件: 集合に[1,2,3,4,5]
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])

    // 実行: count取得
    let count = set.count

    // 事後条件:
    // - count == 5
    XCTAssertEqual(count, 5)
  }

  /// distance(from:to:)が正しい距離を返すこと
  func test_distance_fromTo() {
    // 事前条件: 集合に[1,2,3,4,5]
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let start = set.startIndex
    let end = set.endIndex

    // 実行: distance計算
    let distance = set.distance(from: start, to: end)

    // 事後条件:
    // - distance == count
    XCTAssertEqual(distance, set.count)
  }

  /// index操作（offsetBy:）が正しく動作すること
  func test_index_offsetBy() {
    // 事前条件: 集合に[10,20,30,40,50]
    let set = RedBlackTreeSet([10, 20, 30, 40, 50])
    let start = set.startIndex

    // 実行: index(offsetBy:2)
    let idx = set.index(start, offsetBy: 2)

    // 事後条件:
    // - idxが要素30の位置
    XCTAssertEqual(set[idx], 30)
  }

  /// index操作（offsetBy:limitedBy:）が正しく制限されること
  func test_index_offsetBy_limitedBy() {
    // 事前条件: 集合に[1,2,3]
    let set = RedBlackTreeSet([1, 2, 3])
    let start = set.startIndex
    let limit = set.index(after: start)

    // 実行: offsetBy(2, limitedBy: limit)
    let limitedIndex = set.index(start, offsetBy: 2, limitedBy: limit)

    // 事後条件:
    // - limit == index(after: start)（2要素目まで許容）
    // - limitedIndex == nil（制限超過でnil）
    XCTAssertNil(limitedIndex)
  }

  /// subscriptで範囲アクセスが正しいこと
  func test_subscript_rangeAccess() {
    // 事前条件: 集合に[1,2,3,4,5]
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let start = set.index(after: set.startIndex)
    let end = set.index(before: set.endIndex)

    // 実行: subscriptアクセス
    let slice = set[start..<end]

    // 事後条件:
    // - slice.map { $0 } == [2,3,4]
    XCTAssertEqual(slice + [], [2, 3, 4])
  }

  /// formIndex(after:)とformIndex(before:)が正しく動作すること
  func test_formIndex_after_before() {
    // 事前条件: 集合に[10,20,30]
    let set = RedBlackTreeSet([10, 20, 30])
    var idx = set.startIndex

    // 実行: formIndex(after:), formIndex(before:)
    set.formIndex(after: &idx)
    XCTAssertEqual(set[idx], 20)

    set.formIndex(before: &idx)
    XCTAssertEqual(set[idx], 10)
  }

  /// formIndex(_:offsetBy:) が正しく指定距離のインデックス位置に移動できること
  func test_formIndex_offsetBy() {
    // 事前条件: 集合に[10,20,30,40,50]
    let set = RedBlackTreeSet([10, 20, 30, 40, 50])
    var idx = set.startIndex

    // 実行: offsetBy(3) → 4番目の要素(40)を指す
    set.formIndex(&idx, offsetBy: 3)

    // 事後条件:
    // - idxが要素40を指すこと
    XCTAssertEqual(set[idx], 40)
  }

  /// formIndex(_:offsetBy:limitedBy:) が制限範囲内では移動し、超過した場合は失敗すること
  func test_formIndex_offsetBy_limitedBy() {
    // 事前条件: 集合に[1,2,3,4,5]
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])
    var idx = set.startIndex
    let limit = set.index(after: set.startIndex)  // 2番目までを制限

    // 実行: offsetBy(2, limitedBy: limit) → 制限超過で移動不可
    let didMove = set.formIndex(&idx, offsetBy: 2, limitedBy: limit)

    // 事後条件:
    // - 限度到達でfalse
    // - idxはlimitまで移動
    XCTAssertFalse(didMove)
    XCTAssertEqual(idx, limit)

    // 実行: offsetBy(1, limitedBy: limit) → 制限内で移動成功
    var idx2 = set.startIndex
    let didMove2 = set.formIndex(&idx2, offsetBy: 1, limitedBy: limit)

    // 事後条件:
    // - 移動成功でtrue
    // - idx2が要素2を指す
    XCTAssertTrue(didMove2)
    XCTAssertEqual(set[idx2], 2)
  }
}

extension RedBlackTreeSetBidirectionalCollectionTests {

  /// SubSequenceに対してforEachを用いた列挙が正しく行われること
  func test_subSequence_forEach() {
    // 事前条件: 集合に[1,2,3,4,5]を用意すること
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [2,3,4]

    // 実行: sub.forEachにより要素を列挙すること
    var elements: [Int] = []
    sub.forEach { elements.append($0) }

    // 事後条件:
    // - 列挙結果が[2,3,4]であること
    XCTAssertEqual(elements, [2, 3, 4])
  }

  /// SubSequenceに対してmakeIteratorを用いた列挙が正しく行われること
  func test_subSequence_makeIterator() {
    // 事前条件: 集合に[10,20,30,40,50]を用意すること
    let set = RedBlackTreeSet([10, 20, 30, 40, 50])
    let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [20,30,40]

    // 実行: makeIteratorを使用して要素を列挙すること
    var iter = sub.makeIterator()
    var collected: [Int] = []
    while let e = iter.next() {
      collected.append(e)
    }

    // 事後条件:
    // - 列挙結果が[20,30,40]であること
    XCTAssertEqual(collected, [20, 30, 40])
  }



}

extension RedBlackTreeSetBidirectionalCollectionTests {




}
