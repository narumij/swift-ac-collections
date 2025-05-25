import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeSetUtilityTests: XCTestCase {

  /// isEmptyが空であることを正しく示すこと
  func test_isEmpty_true_whenEmpty() {
    let set = RedBlackTreeSet<Int>()
    XCTAssertTrue(set.isEmpty)
  }

  /// isEmptyが空でないことを正しく示すこと
  func test_isEmpty_false_whenNotEmpty() {
    let set = RedBlackTreeSet([1, 2, 3])
    XCTAssertFalse(set.isEmpty)
  }

  /// capacityが初期容量以上を返すこと
  func test_capacity() {
    let set = RedBlackTreeSet<Int>(minimumCapacity: 10)
    XCTAssertGreaterThanOrEqual(set.capacity, 10)
  }

  /// isValid(index:) が有効インデックスを正しく判定すること
  func test_isValid_index_valid() {
    let set = RedBlackTreeSet([1, 2, 3])
    let index = set.startIndex
    XCTAssertTrue(set.isValid(index: index))
  }

  /// isValid(index:) が無効インデックスを正しく判定すること
  func test_isValid_index_invalid() {
    let set = RedBlackTreeSet([1, 2, 3])
    let invalidIndex = set.endIndex
    XCTAssertTrue(set.isValid(index: invalidIndex))
  }

  #if DEBUG
    /// isValid(rawIndex:) が有効インデックスを正しく判定すること
    func test_isValid_rawIndex_valid() {
      let set = RedBlackTreeSet([1, 2, 3])
      let rawValue = set.startIndex.rawValue
      XCTAssertTrue(set.isValid(index: RedBlackTreeSet<Int>.RawIndex.unsafe(rawValue)))
    }

    /// isValid(rawIndex:) が無効インデックスを正しく判定すること
    func test_isValid_rawIndex_invalid() {
      let set = RedBlackTreeSet([1, 2, 3])
      let rawValue = set.endIndex.rawValue
      XCTAssertTrue(set.isValid(index: RedBlackTreeSet<Int>.RawIndex.unsafe(rawValue)))
    }
  #endif
}
