import XCTest
import RedBlackTreeModule

final class RedBlackTreeMultiSetSequenceTests: XCTestCase {

  // MARK: - map動作チェックと併せて、初期化内容のチェック

  /// 空の初期化が成功し、isEmptyがtrueであること
  func test_emptyInitialization() {
    // 事前条件: 空のマルチセットを初期化
    let multiset = RedBlackTreeMultiSet<Int>()

    // 実行: mapで全要素取得
    let mappedElements = multiset + []

    // 事後条件: 空であること
    XCTAssertEqual(mappedElements, [], "要素が無いこと")
  }

  /// 最小容量指定初期化が成功し、空であること
  func test_minimumCapacityInitialization() {
    // 事前条件: 最小容量10で初期化
    let multiset = RedBlackTreeMultiSet<Int>(minimumCapacity: 10)

    // 実行: mapで全要素取得
    let mappedElements = multiset + []

    // 事後条件: 空であること、容量が最低10以上
    XCTAssertEqual(mappedElements, [], "要素が無いこと")
  }

  /// Sequenceからの初期化が重複を含め順序通りの要素を正しく保持すること
  func test_sequenceInitialization() {
    // 事前条件: Sequence [3, 1, 2, 1, 3]
    let multiset = RedBlackTreeMultiSet<Int>([3, 1, 2, 1, 3])

    // 実行: mapで全要素取得
    let mappedElements = multiset + []

    // 事後条件: 重複含めソート済み [1, 1, 2, 3, 3]
    let expected = [1, 1, 2, 3, 3]
    XCTAssertEqual(mappedElements, expected, "要素がソート済みであること")
  }
  
  /// AnySequenceSequenceからの初期化が重複を含め順序通りの要素を正しく保持すること
  func test_anySequenceInitialization() {
    // 事前条件: Sequence [3, 1, 2, 1, 3]
    let multiset = RedBlackTreeMultiSet<Int>(AnySequence([3, 1, 2, 1, 3]))

    // 実行: mapで全要素取得
    let mappedElements = multiset + []

    // 事後条件: 重複含めソート済み [1, 1, 2, 3, 3]
    let expected = [1, 1, 2, 3, 3]
    XCTAssertEqual(mappedElements, expected, "要素がソート済みであること")
  }

  /// Rangeからの初期化が範囲通りの要素を正しく保持すること
  func test_rangeInitialization() {
    // 事前条件: Range [1...3]
    let multiset = RedBlackTreeMultiSet<Int>(1...3)

    // 実行: mapで全要素取得
    let mappedElements = multiset + []

    // 事後条件: ソート済み [1, 2, 3]
    let expected = [1, 2, 3]
    XCTAssertEqual(mappedElements, expected, "要素がソート済みであること")
  }
  
  /// Rangeからの初期化が範囲通りの要素を正しく保持すること
  func test_reverseRangeInitialization() {
    // 事前条件: Range [1...3]
    let multiset = RedBlackTreeMultiSet<Int>(stride(from: 3, through: 1, by: -1))

    // 実行: mapで全要素取得
    let mappedElements = multiset + []

    // 事後条件: ソート済み [1, 2, 3]
    let expected = [1, 2, 3]
    XCTAssertEqual(mappedElements, expected, "要素がソート済みであること")
  }
  
  // MARK: - map以外の動作チェック
  
  /// forでRedBlackTreeSetの要素を正しく列挙できること
  func test_empty_set_for() {
    // 事前条件: 集合に[]を用意すること
    let set = RedBlackTreeMultiSet<Int>()

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
    // 事前条件: 集合に[1, 2, 2, 3, 4, 5, 5]を用意すること
    let set = RedBlackTreeMultiSet<Int>([1, 2, 2, 3, 4, 5, 5])

    // 実行: forで要素を列挙する
    var elements: [Int] = []
    for element in set {
      elements.append(element)
    }

    // 事後条件:
    XCTAssertEqual(elements, [1, 2, 2, 3, 4, 5, 5], "初期値通りであること")
  }

  /// forEachでRedBlackTreeSetの要素を正しく列挙できること
  func test_empty_set_forEach() {
    // 事前条件: 集合に[]を用意すること
    let set = RedBlackTreeMultiSet<Int>()

    // 実行: forEachで要素を列挙すること
    var elements: [Int] = []
    set.forEach { elements.append($0) }

    // 事後条件:
    XCTAssertEqual(elements, [], "空配列であること")
  }

  /// forEachでRedBlackTreeSetの要素を正しく列挙できること
  func test_set_forEach() {
    // 事前条件: 集合に[1, 2, 2, 3, 4, 5, 5]を用意すること
    let set = RedBlackTreeMultiSet<Int>([1, 2, 2, 3, 4, 5, 5])

    // 実行: forEachで要素を列挙すること
    var elements: [Int] = []
    set.forEach { elements.append($0) }

    // 事後条件:
    XCTAssertEqual(elements, [1, 2, 2, 3, 4, 5, 5], "初期値通りであること")
  }
  
  /// filterでRedBlackTreeSetの要素を正しく絞り込めること
  func test_empty_set_filter() {
    // 事前条件: 集合に[]を用意すること
    let set = RedBlackTreeMultiSet<Int>()

    // 実行: filterで要素を偶数に絞り込む
    let elements: [Int] = set.filter{ $0 % 2 == 0 }

    // 事後条件:
    XCTAssertEqual(elements, [], "空配列であること")
  }

  /// filterでRedBlackTreeSetの要素を正しく絞り込めること
  func test_set_filter() {
    // 事前条件: 集合に[1, 2, 2, 3, 4, 5, 5]を用意すること
    let set = RedBlackTreeMultiSet<Int>([1, 2, 2, 3, 4, 5, 5])

    // 実行: filterで要素を偶数に絞り込む
    let elements: [Int] = set.filter{ $0 % 2 == 0 }

    // 事後条件:
    XCTAssertEqual(elements, [2, 2, 4], "偶数のみであること")
  }
  
  /// reduceでRedBlackTreeSetの要素を正しくたたみこめること
  func test_empty_set_reduce() {
    // 事前条件: 集合に[]を用意すること
    let set = RedBlackTreeMultiSet<Int>()

    // 実行: reduceで要素を合算すると
    let element = set.reduce(0, +)

    // 事後条件:
    XCTAssertEqual(element, 0, "初期値であること")
  }

  /// reduceでRedBlackTreeSetの要素を正しくたたみこめること
  func test_set_reduce() {
    // 事前条件: 集合に[1, 2, 2, 3, 4, 5, 5]を用意すること
    let set = RedBlackTreeMultiSet<Int>([1, 2, 2, 3, 4, 5, 5])

    // 実行: reduceで要素を合算すると
    let element = set.reduce(0, +)

    // 事後条件:
    XCTAssertEqual(element, 22, "合計値であること")
  }
}
