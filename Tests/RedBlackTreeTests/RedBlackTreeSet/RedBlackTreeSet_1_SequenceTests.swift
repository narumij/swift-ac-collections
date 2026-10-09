import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetSequenceTests: RedBlackTreeTestCase {

  // MARK: - map動作チェックと併せて、初期化内容のチェック

  /// 空のセットの内容が空であること
  func test_emptyInitialization() {
    // 事前条件: 空のマルチセットを初期化
    let set = RedBlackTreeSet<Int>()

    // 実行: mapで全要素取得
    let mappedElements = set + []

    // 事後条件:
    XCTAssertEqual(mappedElements, [], "要素が無いこと")
  }

  /// 最小容量指定初期化しても空のセットの内容が空であること
  func test_minimumCapacityInitialization() {
    // 事前条件: 最小容量10で初期化
    let set = RedBlackTreeSet<Int>(minimumCapacity: 10)

    // 実行: mapで全要素取得
    let mappedElements = set + []

    // 事後条件:
    XCTAssertEqual(mappedElements, [], "要素が無いこと")
  }

  /// 内容が重複なく昇順であること(Array)
  func test_sequenceInitialization() {
    // 事前条件: Sequence [3, 1, 2, 1, 3]
    let set = RedBlackTreeSet<Int>([3, 1, 2, 1, 3, 4, 4, 5])

    // 実行: mapで全要素取得
    let mappedElements = set + []

    // 事後条件:
    let expected = [1, 2, 3, 4, 5]
    XCTAssertEqual(mappedElements, expected, "要素が重複無くソート済みであること")
  }

  /// 内容が重複なく昇順であること(AnySequence)
  func test_anySequenceInitialization() {
    // 事前条件: Sequence [3, 1, 2, 1, 3]
    let set = RedBlackTreeSet<Int>(AnySequence([3, 1, 2, 1, 3, 4, 4, 5]))

    // 実行: mapで全要素取得
    let mappedElements = set + []

    // 事後条件:
    let expected = [1, 2, 3, 4, 5]
    XCTAssertEqual(mappedElements, expected, "要素が重複無くソート済みであること")
  }

  /// 内容が重複なく昇順であること(Range)
  func test_rangeInitialization() {
    // 事前条件: Range [1...3]
    let set = RedBlackTreeSet<Int>(1...4)

    // 実行: mapで全要素取得
    let mappedElements = set + []

    // 事後条件:
    let expected = [1, 2, 3, 4]
    XCTAssertEqual(mappedElements, expected, "要素が重複無くソート済みであること")
  }

  /// 内容が重複なく昇順であること(逆Range)
  func test_reverseRangeInitialization() {
    // 事前条件: for(i = 3; i >= 0; --i) { }
    let set = RedBlackTreeSet<Int>(stride(from: 3, through: 1, by: -1))

    // 実行: mapで全要素取得
    let mappedElements = set + []

    // 事後条件: ソート済み [1, 2, 3]
    let expected = [1, 2, 3]
    XCTAssertEqual(mappedElements, expected, "要素が重複無くソート済みであること")
  }

  /// 内容が重複なく昇順であること(Arrayを初期化)
  func test_sequence_iteratorYieldsSortedUniqueElements() {
    // 事前条件
    let elements = [10, 2, 8, 2, 6, 4]
    let set = RedBlackTreeSet<Int>(elements)

    // 実行: makeIteratorを使用
    let iteratedElements = Array(set)

    // 事後条件:
    let expected = Array(Set(elements)).sorted()
    XCTAssertEqual(iteratedElements, expected, "昇順かつ重複なしであること")
  }

  /// 内容が重複なく昇順であること(sorted()との比較)
  func test_sequence_mapMatchesSorted() {
    // 事前条件
    let elements = [7, 3, 9, 1, 5]
    let set = RedBlackTreeSet<Int>(elements)

    // 実行
    let mappedElements = set + []
    let sortedElements = set.sorted() + []

    // 事後条件:
    XCTAssertEqual(mappedElements, sortedElements, "一致すること")
  }

  // MARK: - map以外の動作チェック

  /// forでRedBlackTreeSetの要素を正しく列挙できること
  func test_empty_set_for() {
    // 事前条件: 集合に[]を用意すること
    let set = RedBlackTreeSet<Int>()

    // 実行: forで要素を列挙する
    var elements: [Int] = []
    for element in set {
      elements.append(element)
    }

    // 事後条件:
    XCTAssertEqual(elements, [], "空配列であること")
  }

  /// forでRedBlackTreeSetの要素を正しく列挙できること
  func test_set_for() {
    // 事前条件: 集合に[1, 2, 3, 4, 5]を用意すること
    let set = RedBlackTreeSet<Int>([1, 2, 3, 4, 5])

    // 実行: forで要素を列挙する
    var elements: [Int] = []
    for element in set {
      elements.append(element)
    }

    // 事後条件:
    XCTAssertEqual(elements, [1, 2, 3, 4, 5], "初期値通りであること")
  }

  /// forEachでRedBlackTreeSetの要素を正しく列挙できること
  func test_empty_set_forEach() {
    // 事前条件: 集合に[]を用意すること
    let set = RedBlackTreeSet<Int>()

    // 実行: forEachで要素を列挙すること
    var elements: [Int] = []
    set.forEach { elements.append($0) }

    // 事後条件:
    XCTAssertEqual(elements, [], "空配列であること")
  }

  /// forEachでRedBlackTreeSetの要素を正しく列挙できること
  func test_set_forEach() {
    // 事前条件: 集合に[1, 2, 3, 4, 5]を用意すること
    let set = RedBlackTreeSet<Int>([1, 2, 3, 4, 5])

    // 実行: forEachで要素を列挙すること
    var elements: [Int] = []
    set.forEach { elements.append($0) }

    // 事後条件:
    XCTAssertEqual(elements, [1, 2, 3, 4, 5], "初期値通りであること")
  }

  /// filterでRedBlackTreeSetの要素を正しく絞り込めること
  func test_empty_set_filter() {
    // 事前条件: 集合に[]を用意すること
    let set = RedBlackTreeSet<Int>()

    // 実行: filterで要素を偶数に絞り込む
    let elements: [Int] = set.filter { $0 % 2 == 0 }

    // 事後条件:
    XCTAssertEqual(elements, [], "空配列であること")
  }

  /// filterでRedBlackTreeSetの要素を正しく絞り込めること
  func test_set_filter() {
    // 事前条件: 集合に[1, 2, 3, 4, 5]を用意すること
    let set = RedBlackTreeSet<Int>([1, 2, 3, 4, 5])

    // 実行: filterで要素を偶数に絞り込む
    let elements: [Int] = set.filter { $0 % 2 == 0 }

    // 事後条件:
    XCTAssertEqual(elements, [2, 4], "偶数のみであること")
  }

    /// filter(_:) が型推論時にRedBlackTreeSetを返し、順序と一意性を維持すること
    func test_filterReturnsRedBlackTreeSet() {
      let set: RedBlackTreeSet = [1, 2, 3, 4, 5]
      let filtered = set.filter { $0 % 2 == 1 }

      XCTAssertEqual(filtered, RedBlackTreeSet([1, 3, 5]))
    }

  /// reduceでRedBlackTreeSetの要素を正しくたたみこめること
  func test_empty_set_reduce() {
    // 事前条件: 集合に[]を用意すること
    let set = RedBlackTreeSet<Int>()

    // 実行: reduceで要素を合算すると
    let element = set.reduce(0, +)

    // 事後条件:
    XCTAssertEqual(element, 0, "初期値であること")
  }

  /// reduceでRedBlackTreeSetの要素を正しくたたみこめること
  func test_set_reduce() {
    // 事前条件: 集合に[1, 2, 3, 4, 5]を用意すること
    let set = RedBlackTreeSet<Int>([1, 2, 3, 4, 5])

    // 実行: reduceで要素を合算すると
    let element = set.reduce(0, +)

    // 事後条件:
    XCTAssertEqual(element, 15, "合計値であること")
  }

    /// makeIterator()で作成したイテレータは、生成後に元の集合が変更されても取得済みのスナップショットを返し続けること(CoW挙動)
    func test_iterator_retainsSnapshotAfterBaseCollectionIsMutated() {
      // 事前条件: 集合に[0, 5, 10, ..., 45]を用意し、そこからイテレータを作成すること
      var set = RedBlackTreeSet((0..<10).map { $0 * 5 })
      var iterator = set[set.lowerBound(5)..<set.find(45)].makeIterator()

      // 実行: イテレータ作成後に該当範囲内の要素を削除すること
      set.remove(15)
      set.remove(35)

      // 事後条件: 削除前のスナップショット通りに列挙されること(45は範囲外なので含まない)
      XCTAssertEqual(iterator.next(), 5)
      XCTAssertEqual(iterator.next(), 10)
      XCTAssertEqual(iterator.next(), 15, "CoW挙動により、イテレータのスナップショットは変更されない")
      XCTAssertEqual(iterator.next(), 20)
      XCTAssertEqual(iterator.next(), 25)
      XCTAssertEqual(iterator.next(), 30)
      XCTAssertEqual(iterator.next(), 35, "CoW挙動により、イテレータのスナップショットは変更されない")
      XCTAssertEqual(iterator.next(), 40)
      XCTAssertNil(iterator.next())
    }
}

  /// 全走査と範囲走査がキー比較を行わないこと。走査が要素ごとの探索(O(N log N))に
  /// 落ちていないことを、利用者の`Comparable`から観測できる形で固定する。
  final class RedBlackTreeSetTraversalComparisonCountTests: RedBlackTreeTestCase {

    private struct CountingKey: Comparable {
      nonisolated(unsafe) static var count = 0
      let value: Int
      static func < (lhs: Self, rhs: Self) -> Bool {
        count += 1
        return lhs.value < rhs.value
      }
    }

    func testFullAndRangeTraversalDoNotCompareKeys() {
      let c = RedBlackTreeSet((0..<64).map(CountingKey.init(value:)))
      let lower = c.index(c.startIndex, offsetBy: 8)
      let upper = c.index(c.startIndex, offsetBy: 56)
      CountingKey.count = 0

      var visited = 0
      for _ in c { visited += 1 }
      XCTAssertEqual(visited, 64)
      XCTAssertEqual(CountingKey.count, 0, "全走査はキー比較を行わないはず")

      var i = c.startIndex
      while i != c.endIndex { c.formIndex(after: &i) }
      while i != c.startIndex { c.formIndex(before: &i) }
      XCTAssertEqual(CountingKey.count, 0, "Indexによる前後の走査はキー比較を行わないはず")

      let view = c[lower..<upper]
      let afterViewCreation = CountingKey.count
      XCTAssertLessThanOrEqual(afterViewCreation, 1, "範囲の作成は定数回の比較に収まるはず")

      visited = 0
      for _ in view { visited += 1 }
      XCTAssertEqual(visited, 48)
      XCTAssertEqual(CountingKey.count, afterViewCreation, "範囲走査はキー比較を行わないはず")
    }
  }

  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeSetReversedTests: RedBlackTreeTestCase {

    /// `reversed()`は要素を降順に並べた配列を返し、元のコレクションを変えないこと。
    func testReversedReturnsDescendingArray() {
      let c = RedBlackTreeSet<Int>([3, 1, 2])
      let r: [Int] = c.reversed()
      XCTAssertEqual(r, [3, 2, 1])
      XCTAssertEqual(Array(c), r.reversed())
      XCTAssertEqual(RedBlackTreeSet<Int>().reversed() as [Int], [])
    }
  }
