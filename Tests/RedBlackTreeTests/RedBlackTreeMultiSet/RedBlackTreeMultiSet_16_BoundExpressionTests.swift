//
//  MultiSetBoundsExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

// Debug専用の観察（test supportの`isValid`と内部のcopy count）は元の条件のまま残し、
// 公開結果だけで確かめられるBoundの動作は下の`RedBlackTreeMultiSetBoundPublicBehaviorTests`で
// Releaseでも実行する（RBT-043 M3）。

#if DEBUG && !COMPATIBLE_ATCODER_2025
import XCTest
import RedBlackTreeCollections

final class RedBlackTreeMultiSetBoundExpressionTests: RedBlackTreeTestCase {

  let a = RedBlackTreeMultiSet<Int>([0, 1, 2])

  func testAfter() throws {
    XCTAssertTrue(a.isValid(start()))
    XCTAssertTrue(a.isValid(start().after))
    XCTAssertTrue(a.isValid(start().after.after))
    XCTAssertFalse(a.isValid(start().after.after.after))
  }

  func testEndIsInvalid() throws { XCTAssertFalse(a.isValid(end())) }

  func testLastIsValid() throws { XCTAssertTrue(a.isValid(.last)) }

  #if _TREE_COPY_COUNTER
  /// 空のMultiSetに対するBound範囲のeraseは、無駄なCoW(共有される空シングルトン
  /// バッファからの退避)を発生させないこと。
  func testEraseBoundsOnEmptyMultiSetDoesNotCopy() throws {
    var b = RedBlackTreeMultiSet<Int>()
    XCTAssertEqual(b._copyCount, 0)
    b.erase(lowerBound(0) ..< upperBound(10))
    XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
    b.erase(lowerBound(0) ..< upperBound(10)) { _ in true }
    XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
    XCTAssertTrue(b.isEmpty)
  }

  /// 空のMultiSetに対するIndex範囲・範囲式・全範囲のeraseは、無駄なCoW(共有される空シングルトン
  /// バッファからの退避)を発生させず、`endIndex`を返すこと。
  func testEraseIndexRangeOnEmptyMultiSetDoesNotCopy() throws {
    var b = RedBlackTreeMultiSet<Int>()
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

/// Boundの公開動作。公開APIの結果だけで確かめるので、Releaseでも実行する（RBT-043 M3）。
final class RedBlackTreeMultiSetBoundPublicBehaviorTests: RedBlackTreeTestCase {

  let a = RedBlackTreeMultiSet<Int>([0, 1, 2])

  /// 解決できる`after`は要素を返し、末尾を越えた`after`は解決できず`nil`になること。
  func testAfterResolvesUntilTheEnd() throws {
    XCTAssertEqual(a[start()], 0)
    XCTAssertEqual(a[start().after], 1)
    XCTAssertEqual(a[start().after.after], 2)
    XCTAssertNil(a[start().after.after.after])
  }

  func testEndResolvesToNoElement() throws { XCTAssertNil(a[end()]) }

  func testLowerUpperBoundFind() throws {
    XCTAssertEqual(a[lowerBound(-1)], 0)
    XCTAssertEqual(a[lowerBound(0)], 0)
    XCTAssertEqual(a[lowerBound(1)], 1)
    XCTAssertEqual(a[lowerBound(2)], 2)
    XCTAssertEqual(a[lowerBound(3)], nil)

    XCTAssertEqual(a[upperBound(-1)], 0)
    XCTAssertEqual(a[upperBound(0)], 1)
    XCTAssertEqual(a[upperBound(1)], 2)
    XCTAssertEqual(a[upperBound(2)], nil)

    XCTAssertEqual(a[find(1)], 1)
    XCTAssertEqual(a[find(5)], nil)

    XCTAssertEqual(a[.last], 2)
  }

  func testViewCount() throws {
    XCTAssertEqual(a[lowerBound(0) ..< upperBound(2)].count, 3)
  }

  func testEraseBound() throws {
    var b = a
    let removed = b.erase(find(1))
    XCTAssertEqual(removed, 1)
    XCTAssertEqual(Array(b), [0, 2])
  }

  /// 共有中に削除対象のないBoundでeraseしても、木をコピーしないこと（RBT-087）
  func testEraseMissingBoundFromSharedMultiSetDoesNotCopy() {
    let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3]
    var shared = original

    XCTAssertNil(shared.erase(find(9)))
    XCTAssertNil(shared.erase(lowerBound(10)))

    XCTAssertEqual(Array(shared), [1, 2, 2, 3])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "削除対象のないerase(Bound)で木がコピーされた")
  }

  /// 共有中の空でない木から空のBound範囲をeraseしても、木をコピーしないこと（RBT-081）
  func testEraseEmptyBoundRangeFromSharedMultiSetDoesNotCopy() {
    let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3]
    var shared = original

    shared.erase(lowerBound(2) ..< lowerBound(2))
    shared.erase(lowerBound(10) ..< upperBound(20))

    XCTAssertEqual(Array(shared), [1, 2, 2, 3])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のBound範囲のeraseで木がコピーされた")
  }

  /// 共有中の空でない木で、範囲内に何も一致しない述語の`erase(_:where:)`（BoundRangeExpression）をしても、木をコピーしないこと。述語は範囲内の各要素に1回ずつ順に呼ばれること（RBT-081）。
  func testEraseBoundRangeWhereNothingMatchesFromSharedMultiSetDoesNotCopy() {
    let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 4]
    var shared = original
    var visited: [Int] = []

    shared.erase(lowerBound(2) ..< upperBound(3)) { visited.append($0); return false }

    XCTAssertEqual(visited, [2, 2, 3])
    XCTAssertEqual(Array(shared), [1, 2, 2, 3, 4])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(_:where:)で木がコピーされた")
  }

  /// `erase(_:where:)`（BoundRangeExpression）は述語のエラーをそのまま呼出元へ投げ、投げた後は述語を呼ばず、範囲外の要素に触れないこと。
  /// 共有していた元のMultiSetは変わらないこと。変更側の途中状態は契約がないため、範囲外の要素が残り、元の要素だけを昇順で持つことだけを確かめる（RBT-094）。
  func testEraseBoundRangeWhereRethrowsPredicateErrorAndKeepsSharedOriginal() {
    struct StopError: Error, Equatable {}
    let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 4, 5]
    var multiset = original
    var visited: [Int] = []

    XCTAssertThrowsError(
      try multiset.erase(lowerBound(2) ..< upperBound(4)) { element in
        visited.append(element)
        if element == 3 { throw StopError() }
        return element == 2
      }
    ) { error in
      XCTAssertEqual(error as? StopError, StopError())
    }
    XCTAssertEqual(visited, [2, 2, 3])
    XCTAssertEqual(Array(original), [1, 2, 2, 3, 4, 5])
    XCTAssertTrue(multiset.contains(1))
    XCTAssertTrue(multiset.contains(5))
    XCTAssertEqual(Array(multiset), Array(multiset).sorted())
    XCTAssertTrue(multiset.allSatisfy { original.contains($0) })
  }

  /// 共有中の木で`erase(_:where:)`（BoundRangeExpression）の述語が範囲内のすべての要素に一致するとき、範囲だけが消え、共有元は変わらないこと（RBT-094）。
  func testEraseBoundRangeWhereAllMatchRemovesOnlyTheRange() {
    let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 4]
    var multiset = original
    var visited: [Int] = []

    multiset.erase(lowerBound(2) ..< upperBound(3)) { visited.append($0); return true }

    XCTAssertEqual(visited, [2, 2, 3])
    XCTAssertEqual(Array(multiset), [1, 4])
    XCTAssertEqual(Array(original), [1, 2, 2, 3, 4])
  }

  func testSubscriptBoundsView() throws {
    let view = a[lowerBound(0) ..< upperBound(2)]
    XCTAssertEqual(Array(view), [0, 1, 2])
  }

  func testSubscriptBoundsModifyPopFirst() throws {
    var b = RedBlackTreeMultiSet<Int>([0, 1, 1, 2])
    let removed = b[lowerBound(0) ..< upperBound(1)].popFirst()
    XCTAssertEqual(removed, 0)
    XCTAssertEqual(Array(b), [1, 1, 2])
  }

  func testEqualRangeMulti() throws {
    let view = a[equalRange(1)]
    XCTAssertEqual(Array(view), [1])

    let b = RedBlackTreeMultiSet<Int>([0, 1, 1, 2])
    let view2 = b[equalRange(1)]
    XCTAssertEqual(Array(view2), [1, 1])
  }

  func testEraseRangeWhere() throws {
    var b = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
    b.erase(lowerBound(0) ..< upperBound(4)) { $0 % 2 == 0 }
    XCTAssertEqual(Array(b), [1, 3])
  }

  func testEraesBounds() throws {
    var b = RedBlackTreeMultiSet<Int>([0, 1, 1, 2, 3])
    b.erase(lowerBound(1) ..< upperBound(2))
    XCTAssertEqual(Array(b), [0, 3])
  }

  /// 下端が上端より後ろにある逆向きの範囲は空の範囲として扱い、何も削除しないこと。
  /// 同値要素の区間を逆向きに指定した場合も同じであること。
  func testEraseReversedBoundsRemovesNothing() throws {
    var b = RedBlackTreeMultiSet<Int>([0, 1, 1, 2, 3])
    b.erase(upperBound(10) ..< lowerBound(-10))
    XCTAssertEqual(Array(b), [0, 1, 1, 2, 3])
    b.erase(upperBound(1) ..< lowerBound(1))
    XCTAssertEqual(Array(b), [0, 1, 1, 2, 3])
  }

  /// 逆向きの範囲では、条件クロージャを一度も呼ばず、何も削除しないこと。
  func testEraseReversedBoundsWhereRemovesNothingAndSkipsPredicate() throws {
    var b = RedBlackTreeMultiSet<Int>([0, 1, 1, 2, 3])
    var calls = 0
    b.erase(upperBound(1) ..< lowerBound(1)) { _ in
      calls += 1
      return true
    }
    XCTAssertEqual(calls, 0)
    XCTAssertEqual(Array(b), [0, 1, 1, 2, 3])
  }

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

  /// 逆向きのBound範囲のviewは空になり、列挙しても要素を返さないこと。
  func testReversedBoundsViewIsEmpty() throws {
    XCTAssertTrue(a[upperBound(10) ..< lowerBound(-10)].isEmpty)
    XCTAssertEqual(Array(a[upperBound(10) ..< lowerBound(-10)]), [])
  }
}
#endif

#if !COMPATIBLE_ATCODER_2025
import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetBoundDistanceTests: RedBlackTreeTestCase {

  /// Bound式どうしの`distance(from:to:)`は、評価した2位置の間の要素数を返すこと。
  func testDistanceBetweenBoundExpressions() {
    let c = RedBlackTreeMultiSet<Int>([0, 1, 1, 2, 2, 2, 3])
    XCTAssertEqual(
      c.distance(from: lowerBound(1), to: upperBound(2)),
      5,
      "同値キーをすべて含む"
    )
    XCTAssertEqual(
      c.distance(from: lowerBound(2), to: upperBound(2)),
      3,
      "同値キーの区間"
    )
    XCTAssertEqual(c.distance(from: start(), to: end()), c.count)
    XCTAssertEqual(c.distance(from: lowerBound(2), to: lowerBound(2)), 0)
  }
}
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSetBoundPublicBehaviorTests {
    /// 空の木の.lastは、docどおりpast-the-endに置き換わること。
    func testEmptyLastBoundIsEnd() {
      let empty = RedBlackTreeMultiSet<Int>()
      XCTAssertEqual(empty.distance(from: .start, to: .last), 0)
    }

    /// .start.advanced(by:)に要素数を超える距離を渡すと、終わらずにループせずnilになること。
    func testBoundAdvancedByHugeOffsetTerminates() {
      let c = RedBlackTreeMultiSet([1, 2, 3])
      XCTAssertNil(c[.start.advanced(by: 4)])
      XCTAssertNil(c[.start.advanced(by: Int.max)])
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSetBoundPublicBehaviorTests {

    /// `.first(k)`はkと等しい要素のうち走査順の先頭を指し、無い場合や空の木では`nil`になること。
    func testFirstResolvesToTheHeadOfTheEqualRun() throws {
      let b = RedBlackTreeMultiSet<Int>([0] + Array(repeating: 1, count: 100) + [2])
      XCTAssertEqual(b[.first(1)], 1)
      XCTAssertEqual(b[.first(1).before], 0, "先頭の1の直前は0であること")
      XCTAssertEqual(b[first(1).before], 0, "トップレベルの`first(_:)`も群の先頭を指すこと")
      XCTAssertEqual(b[.first(1) ..< upperBound(1)].count, 100)
      XCTAssertEqual(Array(b[.first(1)...]), Array(repeating: 1, count: 100) + [2])
      XCTAssertEqual(b[.first(0)], 0)
      XCTAssertEqual(b[.first(2)], 2)
      XCTAssertNil(b[.first(-1)])
      XCTAssertNil(b[.first(3)])
      XCTAssertNil(RedBlackTreeMultiSet<Int>()[.first(0)])
    }

    /// 重複が無い木では、`.first(k)`はkと等しい唯一の要素を指すこと。
    func testFirstWithoutDuplicates() throws {
      XCTAssertEqual(a[.first(1)], 1)
      XCTAssertEqual(a[.first(1).before], 0)
      XCTAssertEqual(a[.first(1).after], 2)
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSetBoundPublicBehaviorTests {

    /// トップレベル関数の境界式は、同名のstaticメンバーと同じ位置を指すこと。
    /// 位置は、木の先頭からその位置までの要素数で比べる（終端なら要素数全体）。
    func testTopLevelBoundsMatchStaticMembers() throws {
      let b = RedBlackTreeMultiSet<Int>([0, 2, 2, 2, 4])
      func position(_ bound: RedBlackTreeMultiSet<Int>.Bound) -> Int {
        b[.start ..< bound].count
      }
      XCTAssertEqual(position(start()), position(.start))
      XCTAssertEqual(position(last()), position(.last))
      XCTAssertEqual(position(end()), position(.end))
      for k in -1 ... 5 {
        XCTAssertEqual(position(lowerBound(k)), position(.lowerBound(k)), "lowerBound k=\(k)")
        XCTAssertEqual(position(upperBound(k)), position(.upperBound(k)), "upperBound k=\(k)")
        XCTAssertEqual(position(find(k)), position(.find(k)), "find k=\(k)")
        XCTAssertEqual(position(first(k)), position(.first(k)), "first k=\(k)")
      }
      XCTAssertEqual(position(first(2)), 1, "first(2)は2の群の先頭であること")
      XCTAssertEqual(b[last()], 4)
      XCTAssertNil(RedBlackTreeMultiSet<Int>()[last()])
    }
  }
#endif
