import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeSetSequenceTests: XCTestCase {
  
  // Sequenceのmap { $0 }が全要素を昇順で返す
  func test_sequence_mapYieldsAllElementsInSortedOrder() {
    // 事前条件: 初期化
    let elements = [3, 1, 4, 1, 5, 9]
    let set = RedBlackTreeSet(elements)
    
    // 実行: mapで全要素取得
    let mappedElements = set.map { $0 }
    
    // 事後条件: mappedElementsは昇順かつ重複なし
    let expected = Array(Set(elements)).sorted()
    XCTAssertEqual(mappedElements, expected)
  }
  
  // makeIteratorでも全要素が昇順で取得できる
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
  
  // map { $0 } と sorted() の結果は完全一致（昇順＆同一要素）
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
  
  // 空のセットのmap { $0 } は空
  func test_sequence_emptySetMapIsEmpty() {
    // 事前条件
    let set = RedBlackTreeSet<Int>()
    
    // 実行
    let mappedElements = set.map { $0 }
    
    // 事後条件: 空
    XCTAssertTrue(mappedElements.isEmpty)
  }
}

extension RedBlackTreeSetBidirectionalCollectionTests {

  /// RedBlackTreeSetのforEachで要素を正しく列挙できること
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
}
