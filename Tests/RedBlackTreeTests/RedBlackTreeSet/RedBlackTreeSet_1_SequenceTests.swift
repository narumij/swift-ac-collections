import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeSetSequenceTests: XCTestCase {

  /// 空のセットの内容が空であること
  func test_emptyInitialization() {
    // 事前条件: 空のマルチセットを初期化
    let set = RedBlackTreeSet<Int>()

    let mappedElements = set.map { $0 }

    // 事後条件: 空のものは空をかえすこと
    XCTAssertEqual(mappedElements, [], "空の配列をかえすこと")
  }

  /// 最小容量指定初期化しても空のセットの内容が空であること
  func test_minimumCapacityInitialization() {
    // 事前条件: 最小容量10で初期化
    let set = RedBlackTreeSet<Int>(minimumCapacity: 10)

    let mappedElements = set.map { $0 }

    // 事後条件: 空のものは空をかえすこと
    XCTAssertEqual(mappedElements, [], "空をかえすこと")
  }

  /// 内容が重複なく昇順であること(Array)
  func test_sequenceInitialization() {
    // 事前条件: Sequence [3, 1, 2, 1, 3]
    let set = RedBlackTreeSet([3, 1, 2, 1, 3, 4, 4, 5])

    let mappedElements = set.map { $0 }

    // 事後条件: 重複含めソート済み [1, 2, 3, 4, 5]
    let expected = [1, 2, 3, 4, 5]
    XCTAssertEqual(mappedElements, expected, "要素が重複無くソート済みであること")
  }

  /// 内容が重複なく昇順であること(Range)
  func test_rangeInitialization() {
    // 事前条件: Range [1...3]
    let set = RedBlackTreeSet(1...4)

    let mappedElements = set.map { $0 }

    // 事後条件: ソート済み [1, 2, 3, 4]
    let expected = [1, 2, 3, 4]
    XCTAssertEqual(mappedElements, expected, "要素が重複無くソート済みであること")
  }
  
  /// 内容が重複なく昇順であること(AnySequence)
  func test_sequence_mapYieldsAllElementsInSortedOrder() {
    // 事前条件: 初期化
    let elements = [3, 1, 4, 1, 5, 9]
    let set = RedBlackTreeSet(AnySequence(elements))

    // 実行: mapで全要素取得
    let mappedElements = set.map { $0 }

    // 事後条件: mappedElementsは昇順かつ重複なし
    let expected = Array(Set(elements)).sorted()
    XCTAssertEqual(mappedElements, expected)
  }

  /// 内容が重複なく昇順であること(Arrayを初期化)
  func test_sequence_iteratorYieldsSortedUniqueElements() {
    // 事前条件
    let elements = [10, 2, 8, 2, 6, 4]
    let set = RedBlackTreeSet(elements)

    // 実行: makeIteratorを使用
    let iteratedElements = Array(set)

    // 事後条件: 昇順かつ重複なし
    let expected = Array(Set(elements)).sorted()
    XCTAssertEqual(iteratedElements, expected)
  }

  /// 内容が重複なく昇順であること(sorted()との比較)
  func test_sequence_mapMatchesSorted() {
    // 事前条件
    let elements = [7, 3, 9, 1, 5]
    let set = RedBlackTreeSet(elements)

    // 実行
    let mappedElements = set.map { $0 }
    let sortedElements = set.sorted()

    // 事後条件: 順序も含めて一致
    XCTAssertEqual(mappedElements, sortedElements)
  }
}

extension RedBlackTreeSetSequenceTests {
  
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
    // - 列挙結果が[]であること
    XCTAssertEqual(elements, [])
  }
  
  /// forでRedBlackTreeSetの要素を正しく列挙できること
  func test_set_for() {
    // 事前条件: 集合に[1, 2, 3, 4, 5]を用意すること
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])

    // 実行: forで要素を列挙する
    var elements: [Int] = []
    for element in set {
      elements.append(element)
    }

    // 事後条件:
    // - 列挙結果が[1, 2, 3, 4, 5]であること
    XCTAssertEqual(elements, [1, 2, 3, 4, 5])
  }

  /// forEachでRedBlackTreeSetの要素を正しく列挙できること
  func test_empty_set_forEach() {
    // 事前条件: 集合に[]を用意すること
    let set = RedBlackTreeSet<Int>()

    // 実行: forEachで要素を列挙すること
    var elements: [Int] = []
    set.forEach { elements.append($0) }

    // 事後条件:
    // - 列挙結果が[1, 2, 3, 4, 5]であること
    XCTAssertEqual(elements, [])
  }

  /// forEachでRedBlackTreeSetの要素を正しく列挙できること
  func test_set_forEach() {
    // 事前条件: 集合に[1, 2, 3, 4, 5]を用意すること
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])

    // 実行: forEachで要素を列挙すること
    var elements: [Int] = []
    set.forEach { elements.append($0) }

    // 事後条件:
    // - 列挙結果が[1, 2, 3, 4, 5]であること
    XCTAssertEqual(elements, [1, 2, 3, 4, 5])
  }
  
  /// filterでRedBlackTreeSetの要素を正しく絞り込めること
  func test_empty_set_filter() {
    // 事前条件: 集合に[]を用意すること
    let set = RedBlackTreeSet<Int>()

    // 実行: forEachで要素を列挙すること
    let elements: [Int] = set.filter{ $0 % 2 == 0 }

    // 事後条件:
    // - 列挙結果が[1, 2, 3, 4, 5]であること
    XCTAssertEqual(elements, [])
  }

  /// filterでRedBlackTreeSetの要素を正しく絞り込めること
  func test_set_filter() {
    // 事前条件: 集合に[1, 2, 3, 4, 5]を用意すること
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])

    // 実行: forEachで要素を列挙すること
    let elements: [Int] = set.filter{ $0 % 2 == 0 }

    // 事後条件:
    // - 列挙結果が[2, 4]であること
    XCTAssertEqual(elements, [2, 4])
  }
  
  /// reduceでRedBlackTreeSetの要素を正しくたたみこめること
  func test_empty_set_reduce() {
    // 事前条件: 集合に[]を用意すること
    let set = RedBlackTreeSet<Int>()

    // 実行: reduceで要素を合算すると
    let element = set.reduce(0, +)

    // 事後条件:
    // - 列挙結果が0であること
    XCTAssertEqual(element, 0)
  }

  /// reduceでRedBlackTreeSetの要素を正しくたたみこめること
  func test_set_reduce() {
    // 事前条件: 集合に[1, 2, 3, 4, 5]を用意すること
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])

    // 実行: reduceで要素を合算すると
    let element = set.reduce(0, +)

    // 事後条件:
    // - 結果が15であること
    XCTAssertEqual(element, 15)
  }
}
