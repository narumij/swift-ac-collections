//
//  SetBoundsExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/08.
//

// Debug専用の観察（test supportの`isValid`、内部の`_withSealed`・`_error`・`_isEqual`・`.debug`、copy count）は
// 元の条件のまま残し、公開結果だけで確かめられるBoundの動作は下の`RedBlackTreeSetBoundPublicBehaviorTests`で
// Releaseでも実行する（RBT-046 X1）。

#if DEBUG && !COMPATIBLE_ATCODER_2025
import XCTest
import RedBlackTreeCollections

final class RedBlackTreeSetBoundExpressionTests: RedBlackTreeTestCase {

  let a = RedBlackTreeSet<Int>(0 ..< 3)

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try super.tearDownWithError()
  }

  func testAfter() throws {
    XCTAssertTrue(a.isValid(start()))

    XCTAssertTrue(a.isValid(start().after))

    XCTAssertTrue(a.isValid(start().after.after))

    XCTAssertFalse(a.isValid(start().after.after.after))

    a._withSealed(start().after.after.after, end()) { a, b in
      // 終端となる
      XCTAssertEqual(a, b)
      // 終端まではエラーが発生しない
      XCTAssertEqual(a.error, nil)
    }

    XCTAssertFalse(a.isValid(start().after.after.after.after))

    a._withSealed(start().after.after.after.after, end()) { a, b in
      // 終端の次はnull相当
      XCTAssertNotEqual(a, b)
      // 終端の次は内部エラーとなる
      XCTAssertEqual(a.error, .upperOutOfBounds)
    }
  }

  func testBefore() throws {

    XCTAssertFalse(a.isValid(end()))

    XCTAssertTrue(a.isValid(end().before))
    XCTAssertTrue(a.isValid(end().before.before))
    XCTAssertTrue(a.isValid(end().before.before.before))

    // エラーではない
    XCTAssertNil(a._error(end().before.before.before))
    XCTAssertFalse(a.isValid(end().before.before.before.before))

    // 内部エラー
    XCTAssertEqual(
      a._error(end().before.before.before.before),
      .lowerOutOfBounds
    )
  }

  func testAdvancePositive() throws {
    XCTAssertTrue(a.isValid(start()))
    XCTAssertTrue(a.isValid(start().advanced(by: 1)))
    XCTAssertTrue(a._isEqual(start().advanced(by: 1), start().after))
    XCTAssertTrue(a.isValid(start().advanced(by: 2)))
    XCTAssertTrue(a._isEqual(start().advanced(by: 2), start().after.after))

    XCTAssertFalse(a.isValid(start().advanced(by: 3)))
    XCTAssertTrue(
      a._isEqual(start().advanced(by: 3), start().after.after.after)
    )
    XCTAssertTrue(a._isEqual(start().advanced(by: 3), end()))
    XCTAssertNil(a._error(start().advanced(by: 3)))

    XCTAssertFalse(a.isValid(start().advanced(by: 4)))
    XCTAssertTrue(
      a._isEqual(start().advanced(by: 4), start().after.after.after.after)
    )
    XCTAssertEqual(a._error(start().advanced(by: 4)), .upperOutOfBounds)
    XCTAssertFalse(a._isEqual(start().advanced(by: 4), end()))
  }

  func testAdvanceNegative() throws {
    XCTAssertFalse(a.isValid(end()))
    XCTAssertTrue(a.isValid(end().advanced(by: -1)))
    XCTAssertTrue(a._isEqual(end().advanced(by: -1), end().before))
    XCTAssertTrue(a.isValid(end().advanced(by: -2)))
    XCTAssertTrue(a._isEqual(end().advanced(by: -2), end().before.before))
    XCTAssertTrue(a.isValid(end().advanced(by: -3)))
    XCTAssertTrue(
      a._isEqual(end().advanced(by: -3), end().before.before.before)
    )
    XCTAssertFalse(a.isValid(end().advanced(by: -4)))
    XCTAssertTrue(
      a._isEqual(end().advanced(by: -4), end().before.before.before.before)
    )
    XCTAssertFalse(a.isValid(end().advanced(by: -5)))
    XCTAssertTrue(
      a._isEqual(
        end().advanced(by: -5),
        end().before.before.before.before.before
      )
    )
    XCTAssertEqual(a._error(end().advanced(by: -5)), .lowerOutOfBounds)
  }

  func testAdvance() throws {
    // 内部的にエラー
    XCTAssertEqual(a._error(start().advanced(by: -1)), .lowerOutOfBounds)
    // 内部的にエラー
    XCTAssertEqual(a._error(end().advanced(by: 1)), .upperOutOfBounds)
  }

  func testLimitedAdvance() throws {
    // start()で止まる
    XCTAssertTrue(a._isEqual(start().advanced(by: -1, limit: start()), start()))
    // end()で止まる
    XCTAssertTrue(a._isEqual(end().advanced(by: 1, limit: end()), end()))
  }

  func testLimitedAdvance2() throws {
    XCTAssertTrue(a._isEqual(end().advanced(by: -5, limit: start()), start()))
    XCTAssertTrue(
      a._isEqual(
        end().advanced(by: -5, limit: start().advanced(by: 1)),
        start().advanced(by: 1)
      )
    )
    XCTAssertTrue(
      a._isEqual(
        end().advanced(by: -5, limit: start().advanced(by: 2)),
        start().advanced(by: 2)
      )
    )
    XCTAssertTrue(
      a._isEqual(
        end().advanced(by: -5, limit: start().advanced(by: 3)),
        start().advanced(by: 3)
      )
    )
    XCTAssertEqual(
      a._error(end().advanced(by: -5, limit: start().advanced(by: 4))),
      .upperOutOfBounds
    )
  }

  func testLimitedAdvance3() throws {
    XCTAssertTrue(a._isEqual(start().advanced(by: 5, limit: start()), start()))
    XCTAssertTrue(
      a._isEqual(
        start().advanced(by: 5, limit: start().advanced(by: 1)),
        start().advanced(by: 1)
      )
    )
    XCTAssertTrue(
      a._isEqual(
        start().advanced(by: 5, limit: start().advanced(by: 2)),
        start().advanced(by: 2)
      )
    )
    XCTAssertTrue(
      a._isEqual(
        start().advanced(by: 5, limit: start().advanced(by: 3)),
        start().advanced(by: 3)
      )
    )
    XCTAssertEqual(
      a._error(start().advanced(by: 5, limit: start().advanced(by: 4))),
      .upperOutOfBounds
    )
  }

  func testLimitedAdvance4() throws {

    XCTAssertTrue(
      a._isEqual(
        start().advanced(by: 1)
          .advanced(by: -5, limit: start().advanced(by: 1)),
        start().advanced(by: 1)
      )
    )
    XCTAssertTrue(
      a._isEqual(
        start().advanced(by: 2)
          .advanced(by: -5, limit: start().advanced(by: 2)),
        start().advanced(by: 2)
      )
    )
    XCTAssertTrue(
      a._isEqual(
        start().advanced(by: 3)
          .advanced(by: -5, limit: start().advanced(by: 3)),
        start().advanced(by: 3)
      )
    )
    XCTAssertTrue(
      a._isEqual(
        start().advanced(by: 4)
          .advanced(by: -5, limit: start().advanced(by: 4)),
        start().advanced(by: 4)
      )
    )
  }

  func testLimitedAdvance5() throws {
    XCTAssertEqual(
      a._error(
        start().advanced(by: 1).advanced(by: -5, limit: start().advanced(by: 2))
      ),
      .lowerOutOfBounds
    )

    XCTAssertEqual(
      a._error(
        start().advanced(by: 2).advanced(by: -5, limit: start().advanced(by: 3))
      ),
      .lowerOutOfBounds
    )

    XCTAssertEqual(
      a._error(
        start().advanced(by: 3).advanced(by: -5, limit: start().advanced(by: 4))
      ),
      .upperOutOfBounds
    )
  }

  func testLimitedAdvance6() throws {
    XCTAssertEqual(
      a._error(start().advanced(by: 1).advanced(by: -5, limit: .debug(.null))),
      .null
    )

    XCTAssertEqual(
      a._error(start().advanced(by: 2).advanced(by: -5, limit: .debug(.null))),
      .null
    )

    XCTAssertEqual(
      a._error(start().advanced(by: 3).advanced(by: -5, limit: .debug(.null))),
      .null
    )

    XCTAssertEqual(
      a._error(.debug(.null).advanced(by: -5, limit: .debug(.null))),
      .null
    )
  }

  func testLowerBound() throws {
    XCTAssertTrue(a._isEqual(lowerBound(-2), start().advanced(by: 0)))
    XCTAssertTrue(a._isEqual(lowerBound(-1), start().advanced(by: 0)))
    XCTAssertTrue(a._isEqual(lowerBound(0), start().advanced(by: 0)))
    XCTAssertTrue(a._isEqual(lowerBound(1), start().advanced(by: 1)))
    XCTAssertTrue(a._isEqual(lowerBound(2), start().advanced(by: 2)))
    XCTAssertTrue(a._isEqual(lowerBound(3), start().advanced(by: 3)))
    XCTAssertTrue(a._isEqual(lowerBound(4), end()))
    XCTAssertTrue(a._isEqual(lowerBound(5), end()))
  }

  func testUpperBound() throws {
    XCTAssertTrue(a._isEqual(upperBound(-2), start().advanced(by: 0)))
    XCTAssertTrue(a._isEqual(upperBound(-1), start().advanced(by: 0)))
    XCTAssertTrue(a._isEqual(upperBound(0), start().advanced(by: 1)))
    XCTAssertTrue(a._isEqual(upperBound(1), start().advanced(by: 2)))
    XCTAssertTrue(a._isEqual(upperBound(2), start().advanced(by: 3)))
    XCTAssertTrue(a._isEqual(upperBound(3), end()))
    XCTAssertTrue(a._isEqual(upperBound(4), end()))
  }

  func testFind() throws {
    XCTAssertTrue(a._isEqual(find(-1), end()))
    XCTAssertTrue(a._isEqual(find(0), start().advanced(by: 0)))
    XCTAssertTrue(a._isEqual(find(1), start().advanced(by: 1)))
    XCTAssertTrue(a._isEqual(find(2), start().advanced(by: 2)))
    XCTAssertTrue(a._isEqual(find(3), start().advanced(by: 3)))
    XCTAssertTrue(a._isEqual(find(4), end()))
    XCTAssertTrue(a._isEqual(find(5), end()))
  }

  func testLast() throws { XCTAssertTrue(a._isEqual(.last, end().before)) }

  #if _TREE_COPY_COUNTER
  /// 空のSetに対するBound範囲のeraseは、無駄なCoW(共有される空シングルトン
  /// バッファからの退避)を発生させないこと。
  func testEraseBoundsOnEmptySetDoesNotCopy() throws {
    var b = RedBlackTreeSet<Int>()
    XCTAssertEqual(b._copyCount, 0)
    b.erase(lowerBound(0) ..< upperBound(10))
    XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
    b.erase(lowerBound(0) ..< upperBound(10)) { _ in true }
    XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
    XCTAssertTrue(b.isEmpty)
  }

  /// 空のSetに対するIndex範囲・範囲式・全範囲のeraseは、無駄なCoW(共有される空シングルトン
  /// バッファからの退避)を発生させず、`endIndex`を返すこと。
  func testEraseIndexRangeOnEmptySetDoesNotCopy() throws {
    var b = RedBlackTreeSet<Int>()
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

  #if ENABLE_EXPERIMENTAL_TREE_BOUND_COMPARISONS
  func testLessThanAllKeys() throws {
    let cases: [(key: Int, expected: Int?)] = [
      (-1, nil), (0, nil), (1, 0), (2, 1), (3, 2), (4, 2),
    ]

    for (key, expected) in cases {
      XCTAssertEqual(a.isValid(.lessThan(key)), expected != nil, "key=\(key)")
    }
  }
  #endif

  #if ENABLE_EXPERIMENTAL_TREE_BOUND_COMPARISONS
  func testLessThanOrEqualAllKeys() throws {
    let cases: [(key: Int, expected: Int?)] = [
      (-1, nil), (0, 0), (1, 1), (2, 2), (3, 2),
    ]

    for (key, expected) in cases {
      XCTAssertEqual(
        a.isValid(.lessThanOrEqual(key)),
        expected != nil,
        "key=\(key)"
      )
    }
  }
  #endif

  /// `.find(_:)`は等しい要素がある場合だけ有効な位置になること（解決した値はPublicBehavior側）
  func testFindAllKeys() throws {
    let cases: [(key: Int, expected: Int?)] = [
      (-1, nil), (0, 0), (1, 1), (2, 2), (3, nil),
    ]

    for (key, expected) in cases {
      XCTAssertEqual(a.isValid(.find(key)), expected != nil, "key=\(key)")
    }
  }

  #if DEBUG
  /// 別の木由来のindexを内包したBoundExpressionが、ALLOW_CROSS_TREE_INDEXの設定通りに解決されること
  func
    testBoundExpressionFromAnotherTreeResolvesAccordingToCrossTreeIndexTrait()
    throws
  {
    let other = RedBlackTreeSet<Int>(0 ..< 3)

    for i in 0 ..< 3 {
      let otherBound = RedBlackTreeBoundExpression<Int>
        .index(other.index(other.startIndex, offsetBy: i))

      #if ALLOW_CROSS_TREE_INDEX
      XCTAssertNotNil(a[otherBound])
      #else
      XCTAssertNil(a[otherBound])
      #endif
    }
  }
  #endif
}
#endif

#if !COMPATIBLE_ATCODER_2025
import XCTest
import RedBlackTreeCollections

/// Boundの公開動作。公開APIの結果だけで確かめるので、Releaseでも実行する（RBT-046 X1）。
final class RedBlackTreeSetBoundPublicBehaviorTests: RedBlackTreeTestCase {

  let a = RedBlackTreeSet<Int>(0 ..< 3)

  /// 解決できる`after`は要素を返し、末尾以降の`after`は解決できず`nil`になること。
  func testAfterResolvesUntilTheEnd() throws {
    XCTAssertEqual(a[start()], 0)
    XCTAssertEqual(a[start().after], 1)
    XCTAssertEqual(a[start().after.after], 2)
    XCTAssertNil(a[start().after.after.after])
    XCTAssertNil(a[start().after.after.after.after])
  }

  func testEndAndLastResolve() throws {
    XCTAssertNil(a[end()])
    XCTAssertEqual(a[last()], 2)
  }

  #if ENABLE_EXPERIMENTAL_TREE_BOUND_COMPARISONS
  /// `lessThan`・`lessThanOrEqual`・`find`は、各keyで対応する要素を返し、無ければ`nil`になること。
  func testLessThanLessThanOrEqualAndFindAllKeys() throws {
    let lessThan: [(key: Int, expected: Int?)] = [
      (-1, nil), (0, nil), (1, 0), (2, 1), (3, 2), (4, 2),
    ]
    for (key, expected) in lessThan {
      XCTAssertEqual(a[.lessThan(key)], expected, "lessThan key=\(key)")
    }
    let lessThanOrEqual: [(key: Int, expected: Int?)] = [
      (-1, nil), (0, 0), (1, 1), (2, 2), (3, 2),
    ]
    for (key, expected) in lessThanOrEqual {
      XCTAssertEqual(
        a[.lessThanOrEqual(key)],
        expected,
        "lessThanOrEqual key=\(key)"
      )
    }
    let find: [(key: Int, expected: Int?)] = [
      (-1, nil), (0, 0), (1, 1), (2, 2), (3, nil),
    ]
    for (key, expected) in find {
      XCTAssertEqual(a[.find(key)], expected, "find key=\(key)")
    }
  }
  #endif

  /// 逆向きのBound範囲のviewは空になり、列挙しても要素を返さないこと。
  func testReversedBoundsViewIsEmpty() throws {
    XCTAssertTrue(a[upperBound(10) ..< lowerBound(-10)].isEmpty)
    XCTAssertEqual(Array(a[upperBound(10) ..< lowerBound(-10)]), [])
  }

  func testViewCountAndEraseBound() throws {
    var b = RedBlackTreeSet<Int>(0 ..< 3)
    XCTAssertEqual(b[lowerBound(0) ..< upperBound(2)].count, 3)

    let removed = b.erase(find(1))
    XCTAssertEqual(removed, 1)
    XCTAssertEqual(Array(b), [0, 2])
  }

  /// 共有中に削除対象のないBoundでeraseしても、木をコピーしないこと（RBT-087）
  func testEraseMissingBoundFromSharedSetDoesNotCopy() {
    let original: RedBlackTreeSet<Int> = [1, 2, 3]
    var shared = original

    XCTAssertNil(shared.erase(find(9)))
    XCTAssertNil(shared.erase(lowerBound(10)))

    XCTAssertEqual(Array(shared), [1, 2, 3])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "削除対象のないerase(Bound)で木がコピーされた")
  }

  /// 共有中の空でない木から空のBound範囲をeraseしても、木をコピーしないこと（RBT-081）
  func testEraseEmptyBoundRangeFromSharedSetDoesNotCopy() {
    let original: RedBlackTreeSet<Int> = [1, 2, 3]
    var shared = original

    shared.erase(lowerBound(2) ..< lowerBound(2))
    shared.erase(lowerBound(10) ..< upperBound(20))

    XCTAssertEqual(Array(shared), [1, 2, 3])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のBound範囲のeraseで木がコピーされた")
  }

  /// 共有中の空でない木で、範囲内に何も一致しない述語の`erase(_:where:)`（BoundRangeExpression）をしても、木をコピーしないこと。述語は範囲内の各要素に1回ずつ順に呼ばれること（RBT-081）。
  func testEraseBoundRangeWhereNothingMatchesFromSharedSetDoesNotCopy() {
    let original: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    var shared = original
    var visited: [Int] = []

    shared.erase(lowerBound(2) ..< upperBound(4)) { visited.append($0); return false }

    XCTAssertEqual(visited, [2, 3, 4])
    XCTAssertEqual(Array(shared), [1, 2, 3, 4, 5])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(_:where:)で木がコピーされた")
  }

  /// 共有中の木で`erase(_:where:)`（BoundRangeExpression）が要素を消すときも、述語は範囲内の各要素に1回ずつ順に呼ばれ、共有元は変わらないこと（RBT-081）。
  func testEraseBoundRangeWhereSomeMatchFromSharedSetCallsPredicateOncePerElement() {
    let original: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    var shared = original
    var visited: [Int] = []

    shared.erase(lowerBound(2) ..< upperBound(4)) { visited.append($0); return $0 % 2 == 0 }

    XCTAssertEqual(visited, [2, 3, 4])
    XCTAssertEqual(Array(shared), [1, 3, 5])
    XCTAssertEqual(Array(original), [1, 2, 3, 4, 5])
  }

  /// `erase(_:where:)`（BoundRangeExpression）は述語のエラーをそのまま呼出元へ投げ、投げた後は述語を呼ばず、範囲外の要素に触れないこと。
  /// 共有していた元の集合は変わらないこと。変更側の途中状態は契約がないため、範囲外の要素が残り、元の要素だけを昇順で持つことだけを確かめる（RBT-094）。
  func testEraseBoundRangeWhereRethrowsPredicateErrorAndKeepsSharedOriginal() {
    struct StopError: Error, Equatable {}
    let original: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    var set = original
    var visited: [Int] = []

    XCTAssertThrowsError(
      try set.erase(lowerBound(2) ..< upperBound(5)) { element in
        visited.append(element)
        if element == 4 { throw StopError() }
        return element == 2
      }
    ) { error in
      XCTAssertEqual(error as? StopError, StopError())
    }
    XCTAssertEqual(visited, [2, 3, 4])
    XCTAssertEqual(Array(original), [1, 2, 3, 4, 5, 6])
    XCTAssertTrue(set.contains(1))
    XCTAssertTrue(set.contains(6))
    XCTAssertEqual(Array(set), Array(set).sorted())
    XCTAssertTrue(set.isSubset(of: original))
  }

  /// 共有中の木で`erase(_:where:)`（BoundRangeExpression）の述語が範囲内のすべての要素に一致するとき、範囲だけが消え、共有元は変わらないこと（RBT-094）。
  func testEraseBoundRangeWhereAllMatchRemovesOnlyTheRange() {
    let original: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    var set = original
    var visited: [Int] = []

    set.erase(lowerBound(2) ..< upperBound(4)) { visited.append($0); return true }

    XCTAssertEqual(visited, [2, 3, 4])
    XCTAssertEqual(Array(set), [1, 5])
    XCTAssertEqual(Array(original), [1, 2, 3, 4, 5])
  }

  func testSubscriptBoundsModifyPopFirst() throws {
    var b = RedBlackTreeSet<Int>(0 ..< 4)
    let removed = b[lowerBound(0) ..< upperBound(2)].popFirst()
    XCTAssertEqual(removed, 0)
    XCTAssertEqual(Array(b), [1, 2, 3])
  }

  func testEraseBounds() throws {
    var b = RedBlackTreeSet<Int>(0 ..< 5)
    b.erase(lowerBound(1) ..< upperBound(3))
    XCTAssertEqual(Array(b), [0, 4])
  }

  func testEraseBoundsWhere() throws {
    var b = RedBlackTreeSet<Int>(0 ..< 5)
    b.erase(lowerBound(0) ..< upperBound(4)) { $0 % 2 == 0 }
    XCTAssertEqual(Array(b), [1, 3])
  }

  /// 下端が上端より後ろにある逆向きの範囲は空の範囲として扱い、何も削除しないこと。
  func testEraseReversedBoundsRemovesNothing() throws {
    var b = RedBlackTreeSet<Int>(0 ..< 5)
    b.erase(upperBound(10) ..< lowerBound(-10))
    XCTAssertEqual(Array(b), [0, 1, 2, 3, 4])
    b.erase(lowerBound(3) ..< lowerBound(1))
    XCTAssertEqual(Array(b), [0, 1, 2, 3, 4])
  }

  /// 逆向きの範囲では、条件クロージャを一度も呼ばず、何も削除しないこと。
  func testEraseReversedBoundsWhereRemovesNothingAndSkipsPredicate() throws {
    var b = RedBlackTreeSet<Int>(0 ..< 5)
    var calls = 0
    b.erase(lowerBound(3) ..< lowerBound(1)) { _ in
      calls += 1
      return true
    }
    XCTAssertEqual(calls, 0)
    XCTAssertEqual(Array(b), [0, 1, 2, 3, 4])
  }

  #if ENABLE_EXPERIMENTAL_TREE_BOUND_COMPARISONS
  func testLessGreaterHelpers() throws {
    XCTAssertEqual(a[.lessThan(1)], 0)
    XCTAssertEqual(a[.greaterThan(1)], 2)
    XCTAssertEqual(a[.lessThanOrEqual(1)], 1)
    XCTAssertEqual(a[.greaterThanOrEqual(1)], 1)
  }
  #endif

  func testBoundRangeOperators() throws {
    let view1 = a[lowerBound(0) ..< upperBound(2)]
    XCTAssertEqual(Array(view1), [0, 1, 2])

    let view2 = a[lowerBound(0) ... lowerBound(1)]
    XCTAssertEqual(Array(view2), [0, 1])

    let view3 = a[..<upperBound(1)]
    XCTAssertEqual(Array(view3), [0, 1])

    let view4 = a[...upperBound(1)]
    XCTAssertEqual(Array(view4), [0, 1, 2])

    let view5 = a[lowerBound(1)...]
    XCTAssertEqual(Array(view5), [1, 2])
  }

  func testEqualRange() throws {
    let view = a[equalRange(1)]
    XCTAssertEqual(Array(view), [1])
  }

  /// 単一のBoundExpressionによる添字アクセスが対応する要素(またはendではnil)を返すこと
  func testSingleBoundSubscriptReturnsElementOrNilAtEnd() throws {
    let multiplesOfFive = RedBlackTreeSet<Int>(
      (0 ..< 100).filter { $0 % 5 == 0 }
    )

    XCTAssertEqual(multiplesOfFive[.start], 0)
    XCTAssertEqual(multiplesOfFive[.lowerBound(0)], 0)
    XCTAssertEqual(multiplesOfFive[.lowerBound(3)], 5)
    XCTAssertEqual(multiplesOfFive[.upperBound(5)], 10)
    XCTAssertNil(multiplesOfFive[.end])
  }

}
#endif

#if !COMPATIBLE_ATCODER_2025
import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetBoundDistanceTests: RedBlackTreeTestCase {

  /// Bound式どうしの`distance(from:to:)`は、評価した2位置の間の要素数を返すこと。
  func testDistanceBetweenBoundExpressions() {
    let c = RedBlackTreeSet<Int>(0 ..< 10)
    XCTAssertEqual(c.distance(from: lowerBound(2), to: lowerBound(7)), 5)
    XCTAssertEqual(c.distance(from: lowerBound(2), to: upperBound(7)), 6)
    XCTAssertEqual(c.distance(from: start(), to: end()), c.count)
    XCTAssertEqual(c.distance(from: lowerBound(4), to: lowerBound(4)), 0)
  }
}
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSetBoundPublicBehaviorTests {
    /// 空の木の.lastは、docどおりpast-the-endに置き換わること。
    func testEmptyLastBoundIsEnd() {
      let empty: RedBlackTreeSet<Int> = []
      XCTAssertEqual(empty.distance(from: .start, to: .last), 0)
    }

    /// .start.advanced(by:)に要素数を超える距離を渡すと、終わらずにループせずnilになること。
    func testBoundAdvancedByHugeOffsetTerminates() {
      let set: RedBlackTreeSet<Int> = [1, 2, 3]
      XCTAssertNil(set[.start.advanced(by: 4)])
      XCTAssertNil(set[.start.advanced(by: Int.max)])
    }
  }
#endif
