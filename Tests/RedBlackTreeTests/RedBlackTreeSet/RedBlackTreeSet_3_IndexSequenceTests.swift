import XCTest
import RedBlackTreeModule

final class RedBlackTreeSetIndexRangeTests: XCTestCase {

  /// indices() がすべてのインデックスを列挙すること
  func test_indices_forEach() {
    // 事前条件: 集合に[10,20,30]
    let set = RedBlackTreeSet([10, 20, 30])

    // 実行: indices() を取得して forEach
    var elements: [Int] = []
    set.indices.forEach { rawIndex in
      // RawIndexを使用して要素取得
      elements.append(set[rawIndex])
    }

    // 事後条件:
    // - elementsに全要素が含まれていること（順序保証あり）
    XCTAssertEqual(elements, [10, 20, 30])
  }

  /// indices().makeIterator() で正しく列挙できること
  func test_indices_makeIterator() {
    // 事前条件: 集合に[1,2,3,4]
    let set = RedBlackTreeSet([1, 2, 3, 4])
    var iter = set.indices.makeIterator()

    var collected: [Int] = []
    while let rawIndex = iter.next() {
      collected.append(set[rawIndex])
    }

    // 事後条件:
    // - collectedに全要素が含まれていること
    XCTAssertEqual(collected, [1, 2, 3, 4])
  }
}
