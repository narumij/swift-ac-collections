import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeSetBidirectionalCollectionTests: XCTestCase {

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
    XCTAssertEqual(slice.map { $0 }, [2, 3, 4])
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
    // - 移動失敗でfalse
    // - idxは移動せずstartIndexのまま
    XCTAssertFalse(didMove)
    XCTAssertEqual(idx, set.startIndex)

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

  /// SubSequenceのstartIndex, endIndex, countが正しく動作すること
  func test_subSequence_index_count() {
    // 事前条件: 集合に[1,2,3,4,5]を用意すること
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [2,3,4]

    // 実行および事後条件:
    // - countが3であること
    XCTAssertEqual(sub.count, 3)
    // - startIndexが2を指すこと
    XCTAssertEqual(sub[sub.startIndex], 2)
    // - index(before: endIndex)が4を指すこと
    XCTAssertEqual(sub[sub.index(before: sub.endIndex)], 4)
  }

  /// SubSequenceのdistance(from:to:)が正しい距離を返すこと
  func test_subSequence_distance() {
    // 事前条件: 集合に[1,2,3,4,5]を用意すること
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [2,3,4]

    // 実行: distance(from: start, to: end)を計算すること
    let dist = sub.distance(from: sub.startIndex, to: sub.endIndex)

    // 事後条件:
    // - 計算結果がsub.count(3)であること
    XCTAssertEqual(dist, sub.count)
  }

  /// SubSequenceのindex(after:)とindex(before:)が正しく動作すること
  func test_subSequence_index_navigation() {
    // 事前条件: 集合に[10,20,30,40,50]を用意すること
    let set = RedBlackTreeSet([10, 20, 30, 40, 50])
    let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [20,30,40]

    // 実行: index(after: start)およびindex(before: end)を取得すること
    let start = sub.startIndex
    let after = sub.index(after: start)
    let beforeEnd = sub.index(before: sub.endIndex)

    // 事後条件:
    // - afterが30を指すこと
    XCTAssertEqual(sub[after], 30)
    // - beforeEndが40を指すこと
    XCTAssertEqual(sub[beforeEnd], 40)
  }
}

extension RedBlackTreeSetBidirectionalCollectionTests {

  /// SubSequenceのindex(_:offsetBy:)とformIndex(offsetBy:)が正しく動作すること
  func test_subSequence_index_offsetBy_and_formIndex_offsetBy() {
    // 事前条件: 集合に[10,20,30,40,50]を用意すること
    let set = RedBlackTreeSet([10, 20, 30, 40, 50])
    let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [20,30,40]

    // 実行: index(offsetBy:)およびformIndex(offsetBy:)を呼び出すこと
    let start = sub.startIndex

    // index(offsetBy:)で2つ先の要素を取得すること
    let offsetIndex = sub.index(start, offsetBy: 2)
    XCTAssertEqual(sub[offsetIndex], 40)  // 事後条件: offsetIndexが40を指すこと

    // formIndex(offsetBy:)で2つ先に移動できること
    var formIndex = start
    sub.formIndex(&formIndex, offsetBy: 2)
    XCTAssertEqual(sub[formIndex], 40)  // 事後条件: formIndexが40を指すこと
  }

  /// SubSequenceのindex(_:offsetBy:limitedBy:)とformIndex(offsetBy:limitedBy:)が正しく動作すること
  func test_subSequence_index_offsetBy_limitedBy_and_formIndex_offsetBy_limitedBy() {
    // 事前条件: 集合に[1,2,3,4,5]を用意すること
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [2,3,4]

    let start = sub.startIndex
    let limit = sub.index(after: start)

    // 実行: index(offsetBy:limitedBy:)とformIndex(offsetBy:limitedBy:)を呼び出すこと

    // index(offsetBy:limitedBy:)成功パターン
    let indexLimitedSuccess = sub.index(start, offsetBy: 1, limitedBy: limit)
    XCTAssertEqual(indexLimitedSuccess, limit)  // 事後条件: 成功時にlimitを返すこと

    // index(offsetBy:limitedBy:)失敗パターン
    let indexLimitedFail = sub.index(start, offsetBy: 3, limitedBy: limit)
    XCTAssertNil(indexLimitedFail)  // 事後条件: 失敗時にnilを返すこと

    // formIndex(offsetBy:limitedBy:)成功パターン
    var formIndexSuccess = start
    let success = sub.formIndex(&formIndexSuccess, offsetBy: 1, limitedBy: limit)
    XCTAssertTrue(success)  // 事後条件: 成功時にtrueを返すこと
    XCTAssertEqual(formIndexSuccess, limit)  // 事後条件: インデックスがlimitを指すこと

    // formIndex(offsetBy:limitedBy:)失敗パターン
    var formIndexFail = start
    let fail = sub.formIndex(&formIndexFail, offsetBy: 3, limitedBy: limit)
    XCTAssertFalse(fail)  // 事後条件: 失敗時にfalseを返すこと
    XCTAssertEqual(formIndexFail, start)  // 事後条件: インデックスが変わらないこと
  }

  /// SubSequenceのformIndex(before:)が正しく動作すること
  func test_subSequence_formIndex_before() {
    // 事前条件: 集合に[1,2,3,4,5]を用意すること
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [2,3,4]

    // 実行: formIndex(before:)でendIndexの直前に移動できること
    var idx = sub.endIndex
    sub.formIndex(before: &idx)
    XCTAssertEqual(sub[idx], 4)  // 事後条件: 直前の要素(4)を指すこと
  }

  /// SubSequenceの範囲指定サブスクリプトが正しく動作すること
  func test_subSequence_subscript_range() {
    // 事前条件: 集合に[1,2,3,4,5,6,7]を用意すること
    let set = RedBlackTreeSet([1, 2, 3, 4, 5, 6, 7])
    let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [2,3,4,5,6]

    let rangeStart = sub.index(after: sub.startIndex)
    let rangeEnd = sub.index(before: sub.endIndex)
    let slicedSub = sub[rangeStart..<rangeEnd]  // [3,4,5]

    // 実行: forEachで要素を列挙すること
    var elements: [Int] = []
    slicedSub.forEach { elements.append($0) }

    // 事後条件:
    // - 列挙結果が[3,4,5]であること
    XCTAssertEqual(elements, [3, 4, 5])
    // - countが3であること
    XCTAssertEqual(slicedSub.count, 3)
    // - startIndexが3を指すこと
    XCTAssertEqual(slicedSub[slicedSub.startIndex], 3)
    // - index(before: endIndex)が5を指すこと
    XCTAssertEqual(slicedSub[slicedSub.index(before: slicedSub.endIndex)], 5)
  }
}

extension RedBlackTreeSetBidirectionalCollectionTests {

  /// SubSequenceのindices()で正しいインデックスを列挙できること
  func test_subSequence_indices() {
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])
    let sub = set[set.index(after: set.startIndex)..<set.index(before: set.endIndex)]  // [2,3,4]

    let indices = sub.indices.map { sub[$0] }

    XCTAssertEqual(indices, [2, 3, 4])
  }
}
