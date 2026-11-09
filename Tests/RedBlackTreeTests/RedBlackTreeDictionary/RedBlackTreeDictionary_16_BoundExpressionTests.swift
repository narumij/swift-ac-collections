//
//  DictionaryBoundsExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

// Debug専用の観察（test supportの`isValid`と内部のcopy count）は元の条件のまま残し、
// 公開結果だけで確かめられるBoundの動作は下の`RedBlackTreeDictionaryBoundPublicBehaviorTests`で
// Releaseでも実行する。公開側ではkeyに加えて対応するvalueも確かめる（RBT-044 D5）。

#if DEBUG && !COMPATIBLE_ATCODER_2025
import XCTest
import RedBlackTreeCollections

final class RedBlackTreeDictionaryBoundExpressionTests: RedBlackTreeTestCase {

  let a: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]

  func testAfter() throws {
    XCTAssertTrue(a.isValid(start()))
    XCTAssertTrue(a.isValid(start().after))
    XCTAssertTrue(a.isValid(start().after.after))
    XCTAssertFalse(a.isValid(start().after.after.after))
  }

  func testEndIsInvalid() throws { XCTAssertFalse(a.isValid(end())) }

  func testLastIsValid() throws { XCTAssertTrue(a.isValid(.last)) }

  #if ENABLE_EXPERIMENTAL_TREE_BOUND_COMPARISONS
  func testLessThanAllKeysIsValid() throws {
    let cases: [(key: Int, valid: Bool)] = [
      (-1, false), (0, false), (1, true), (2, true), (3, true), (4, true),
    ]
    for (key, valid) in cases {
      XCTAssertEqual(a.isValid(.lessThan(key)), valid, "key=\(key)")
    }
  }
  #endif

  #if _TREE_COPY_COUNTER
  /// 空のDictionaryに対するBound範囲のeraseは、無駄なCoW(共有される空シングルトン
  /// バッファからの退避)を発生させないこと。
  func testEraseBoundsOnEmptyDictionaryDoesNotCopy() throws {
    var b = RedBlackTreeDictionary<Int, String>()
    XCTAssertEqual(b._copyCount, 0)
    b.erase(lowerBound(0) ..< upperBound(10))
    XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
    b.erase(lowerBound(0) ..< upperBound(10)) { _ in true }
    XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
    XCTAssertTrue(b.isEmpty)
  }

  /// 空のDictionaryに対するIndex範囲・範囲式・全範囲のeraseは、無駄なCoW(共有される空シングルトン
  /// バッファからの退避)を発生させず、`endIndex`を返すこと。
  func testEraseIndexRangeOnEmptyDictionaryDoesNotCopy() throws {
    var b = RedBlackTreeDictionary<Int, String>()
    XCTAssertEqual(b._copyCount, 0)
    let range: RedBlackTreeIndexRange = b.equalRange(0)
    XCTAssertEqual(b.erase(range), b.endIndex)
    XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
    b.erase(range) { _ in true }
    XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
    XCTAssertEqual(b.erase(b.startIndex ..< b.endIndex), b.endIndex)
    XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
    b.erase(b.startIndex ..< b.endIndex) { _ in true }
    XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
    XCTAssertEqual(b.erase(...), b.endIndex)
    XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
    XCTAssertTrue(b.isEmpty)
  }
  #endif

  func testIsValidBoundsInvalidDoesNotCrash() throws {
    XCTAssertFalse(a.isValid(upperBound(10) ..< lowerBound(-10)))
  }
}
#endif

#if !COMPATIBLE_ATCODER_2025
import XCTest
import RedBlackTreeCollections

/// Boundの公開動作。公開APIの結果だけで確かめるので、Releaseでも実行する（RBT-044 D5）。
final class RedBlackTreeDictionaryBoundPublicBehaviorTests: RedBlackTreeTestCase
{

  let a: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]

  private func pairs<S: Sequence>(_ elements: S) -> [String]
  where S.Element == (key: Int, value: String) {
    elements.map { "\($0.key):\($0.value)" }
  }

  /// 解決できる`after`は要素を返し、末尾を越えた`after`は解決できず`nil`になること。
  func testAfterResolvesUntilTheEnd() throws {
    XCTAssertEqual(a[start()]?.key, 0)
    XCTAssertEqual(a[start()]?.value, "a")
    XCTAssertEqual(a[start().after]?.key, 1)
    XCTAssertEqual(a[start().after]?.value, "b")
    XCTAssertEqual(a[start().after.after]?.key, 2)
    XCTAssertEqual(a[start().after.after]?.value, "c")
    XCTAssertNil(a[start().after.after.after])
  }

  func testEndResolvesToNoElement() throws { XCTAssertNil(a[end()]) }

  func testLowerUpperBoundFind() throws {
    XCTAssertEqual(a[lowerBound(-1)]?.value, "a")
    XCTAssertEqual(a[lowerBound(0)]?.value, "a")
    XCTAssertEqual(a[lowerBound(1)]?.value, "b")
    XCTAssertEqual(a[lowerBound(2)]?.key, 2)
    XCTAssertEqual(a[lowerBound(2)]?.value, "c")
    XCTAssertNil(a[lowerBound(3)])

    XCTAssertEqual(a[upperBound(-1)]?.value, "a")
    XCTAssertEqual(a[upperBound(0)]?.value, "b")
    XCTAssertEqual(a[upperBound(1)]?.value, "c")
    XCTAssertNil(a[upperBound(2)])

    XCTAssertEqual(a[find(1)]?.key, 1)
    XCTAssertEqual(a[find(1)]?.value, "b")
    XCTAssertNil(a[find(5)])

    XCTAssertEqual(a[.last]?.key, 2)
    XCTAssertEqual(a[.last]?.value, "c")
  }

  func testViewCount() throws {
    XCTAssertEqual(a[lowerBound(0) ..< upperBound(2)].count, 3)
  }

  func testEraseBound() throws {
    var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]
    let removed = b.erase(find(1))
    XCTAssertEqual(removed?.key, 1)
    XCTAssertEqual(removed?.value, "b")
    XCTAssertEqual(pairs(b), ["0:a", "2:c"])
  }

  /// 共有中に削除対象のないBoundでeraseしても、木をコピーしないこと（RBT-087）
  func testEraseMissingBoundFromSharedDictionaryDoesNotCopy() {
    let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
    var shared = original

    XCTAssertNil(shared.erase(find(9)))
    XCTAssertNil(shared.erase(lowerBound(10)))

    XCTAssertEqual(shared.map(\.value), ["a", "b", "c"])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "削除対象のないerase(Bound)で木がコピーされた")
  }

  /// 共有中の空でない木から空のBound範囲をeraseしても、木をコピーしないこと（RBT-081）
  func testEraseEmptyBoundRangeFromSharedDictionaryDoesNotCopy() {
    let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c"]
    var shared = original

    shared.erase(lowerBound(2) ..< lowerBound(2))
    shared.erase(lowerBound(10) ..< upperBound(20))

    XCTAssertEqual(shared.map(\.value), ["a", "b", "c"])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のBound範囲のeraseで木がコピーされた")
  }

  /// 共有中の空でない木で、範囲内に何も一致しない述語の`erase(_:where:)`（BoundRangeExpression）をしても、木をコピーしないこと。述語は範囲内の各要素に1回ずつ順に呼ばれること（RBT-081）。
  func testEraseBoundRangeWhereNothingMatchesFromSharedDictionaryDoesNotCopy() {
    let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    var shared = original
    var visited: [Int] = []

    shared.erase(lowerBound(2) ..< upperBound(4)) { visited.append($0.key); return false }

    XCTAssertEqual(visited, [2, 3, 4])
    XCTAssertEqual(shared.map(\.key), [1, 2, 3, 4, 5])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(_:where:)で木がコピーされた")
  }

  /// `erase(_:where:)`（BoundRangeExpression）は述語のエラーをそのまま呼出元へ投げ、投げた後は述語を呼ばず、範囲外のkey/valueに触れないこと。
  /// 共有していた元の辞書は変わらないこと。変更側の途中状態は契約がないため、範囲外のエントリが残り、元のエントリだけをkey順に持つことだけを確かめる（RBT-094）。
  func testEraseBoundRangeWhereRethrowsPredicateErrorAndKeepsSharedOriginal() {
    struct StopError: Error, Equatable {}
    let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e", 6: "f"]
    var dictionary = original
    var visited: [Int] = []

    XCTAssertThrowsError(
      try dictionary.erase(lowerBound(2) ..< upperBound(5)) { element in
        visited.append(element.key)
        if element.key == 4 { throw StopError() }
        return element.key == 2
      }
    ) { error in
      XCTAssertEqual(error as? StopError, StopError())
    }
    XCTAssertEqual(visited, [2, 3, 4])
    XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d", "e", "f"])
    XCTAssertEqual(dictionary[1], "a")
    XCTAssertEqual(dictionary[6], "f")
    XCTAssertEqual(dictionary.map(\.key), dictionary.map(\.key).sorted())
    XCTAssertTrue(dictionary.allSatisfy { original[$0.key] == $0.value })
  }

  /// 共有中の木で`erase(_:where:)`（BoundRangeExpression）の述語が範囲内のすべての要素に一致するとき、範囲だけが消え、共有元は変わらないこと（RBT-094）。
  func testEraseBoundRangeWhereAllMatchRemovesOnlyTheRange() {
    let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    var dictionary = original
    var visited: [Int] = []

    dictionary.erase(lowerBound(2) ..< upperBound(4)) { visited.append($0.key); return true }

    XCTAssertEqual(visited, [2, 3, 4])
    XCTAssertEqual(dictionary.map(\.key), [1, 5])
    XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d", "e"])
  }

  func testEraseBounds() throws {
    var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
    b.erase(lowerBound(1) ..< upperBound(3))
    XCTAssertEqual(pairs(b), ["0:a", "4:e"])
  }

  /// 下端が上端より後ろにある逆向きの範囲は空の範囲として扱い、何も削除しないこと。
  func testEraseReversedBoundsRemovesNothing() throws {
    var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
    b.erase(upperBound(10) ..< lowerBound(-10))
    XCTAssertEqual(pairs(b), ["0:a", "1:b", "2:c", "3:d", "4:e"])
    b.erase(lowerBound(3) ..< lowerBound(1))
    XCTAssertEqual(pairs(b), ["0:a", "1:b", "2:c", "3:d", "4:e"])
  }

  /// 逆向きの範囲では、条件クロージャを一度も呼ばず、何も削除しないこと。
  func testEraseReversedBoundsWhereRemovesNothingAndSkipsPredicate() throws {
    var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
    var calls = 0
    b.erase(lowerBound(3) ..< lowerBound(1)) { _ in
      calls += 1
      return true
    }
    XCTAssertEqual(calls, 0)
    XCTAssertEqual(pairs(b), ["0:a", "1:b", "2:c", "3:d", "4:e"])
  }

  func testSubscriptBoundsView() throws {
    XCTAssertEqual(
      pairs(a[lowerBound(0) ..< upperBound(2)]),
      ["0:a", "1:b", "2:c"]
    )
  }

  func testSubscriptBoundsModifyPopFirst() throws {
    var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d"]
    let removed = b[lowerBound(0) ..< upperBound(2)].popFirst()
    XCTAssertEqual(removed?.key, 0)
    XCTAssertEqual(removed?.value, "a")
    XCTAssertEqual(pairs(b), ["1:b", "2:c", "3:d"])
  }

  func testRemoveBoundsWhere() throws {
    var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
    b.erase(lowerBound(0) ..< upperBound(4)) { $0.key % 2 == 0 }
    XCTAssertEqual(pairs(b), ["1:b", "3:d"])
  }

  #if ENABLE_EXPERIMENTAL_TREE_BOUND_COMPARISONS
  func testLessThanAllKeys() throws {
    let cases: [(key: Int, expected: String?)] = [
      (-1, nil), (0, nil), (1, "a"), (2, "b"), (3, "c"), (4, "c"),
    ]

    for (key, expected) in cases {
      XCTAssertEqual(a[.lessThan(key)]?.value, expected, "key=\(key)")
    }
  }
  #endif

  #if ENABLE_EXPERIMENTAL_TREE_BOUND_COMPARISONS
  func testLessGreaterHelpers() throws {
    XCTAssertEqual(a[.lessThan(1)]?.value, "a")
    XCTAssertEqual(a[.greaterThan(1)]?.value, "c")
    XCTAssertEqual(a[.lessThanOrEqual(1)]?.value, "b")
    XCTAssertEqual(a[.greaterThanOrEqual(1)]?.value, "b")
  }
  #endif

  func testBoundRangeOperators() throws {
    XCTAssertEqual(
      pairs(a[lowerBound(0) ..< upperBound(2)]),
      ["0:a", "1:b", "2:c"]
    )
    XCTAssertEqual(pairs(a[lowerBound(0) ... lowerBound(1)]), ["0:a", "1:b"])
    XCTAssertEqual(pairs(a[..<upperBound(1)]), ["0:a", "1:b"])
    XCTAssertEqual(pairs(a[...upperBound(1)]), ["0:a", "1:b", "2:c"])
    XCTAssertEqual(pairs(a[lowerBound(1)...]), ["1:b", "2:c"])
  }

  func testEqualRange() throws {
    XCTAssertEqual(pairs(a[equalRange(1)]), ["1:b"])
  }

  /// 逆向きのBound範囲のviewは空になり、列挙しても要素を返さないこと。
  func testReversedBoundsViewIsEmpty() throws {
    XCTAssertTrue(a[upperBound(10) ..< lowerBound(-10)].isEmpty)
    XCTAssertEqual(pairs(a[upperBound(10) ..< lowerBound(-10)]), [])
  }
}
#endif

#if !COMPATIBLE_ATCODER_2025
import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryBoundDistanceTests: RedBlackTreeTestCase {

  /// Bound式どうしの`distance(from:to:)`は、評価した2位置の間の要素数を返すこと。
  func testDistanceBetweenBoundExpressions() {
    let c = RedBlackTreeDictionary<Int, String>(
      uniqueKeysWithValues: (0 ..< 10).map { ($0, "\($0)") }
    )
    XCTAssertEqual(c.distance(from: lowerBound(2), to: lowerBound(7)), 5)
    XCTAssertEqual(c.distance(from: lowerBound(2), to: upperBound(7)), 6)
    XCTAssertEqual(c.distance(from: start(), to: end()), c.count)
    XCTAssertEqual(c.distance(from: lowerBound(4), to: lowerBound(4)), 0)
  }
}
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionaryBoundPublicBehaviorTests {
    /// 空の木の.lastは、docどおりpast-the-endに置き換わること。
    func testEmptyLastBoundIsEnd() {
      let empty = RedBlackTreeDictionary<Int, Int>()
      XCTAssertEqual(empty.distance(from: .start, to: .last), 0)
    }

    /// .start.advanced(by:)に要素数を超える距離を渡すと、終わらずにループせずnilになること。
    func testBoundAdvancedByHugeOffsetTerminates() {
      let c = RedBlackTreeDictionary(uniqueKeysWithValues: [(1, 1), (2, 2), (3, 3)])
      XCTAssertNil(c[.start.advanced(by: 4)])
      XCTAssertNil(c[.start.advanced(by: Int.max)])
    }
  }
#endif
