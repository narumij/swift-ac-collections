//
//  MultiMapBoundsExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

// Debug専用の観察（test supportの`isValid`と内部のcopy count）は元の条件のまま残し、
// 公開結果だけで確かめられるBoundの動作は下の`RedBlackTreeMultiMapBoundPublicBehaviorTests`で
// Releaseでも実行する。公開側では重複keyのvalue列と個数も確かめる（RBT-045 MM4）。

#if DEBUG && !COMPATIBLE_ATCODER_2025
import XCTest
import RedBlackTreeCollections

final class RedBlackTreeMultiMapBoundExpressionTests: RedBlackTreeTestCase {

  let a: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c"]

  func testAfter() throws {
    XCTAssertTrue(a.isValid(start()))
    XCTAssertTrue(a.isValid(start().after))
    XCTAssertTrue(a.isValid(start().after.after))
    XCTAssertFalse(a.isValid(start().after.after.after))
  }

  func testEndIsInvalid() throws { XCTAssertFalse(a.isValid(end())) }

  func testLastIsValid() throws { XCTAssertTrue(a.isValid(.last)) }

  #if _TREE_COPY_COUNTER
  /// 空のMultiMapに対するBound範囲のeraseは、無駄なCoW(共有される空シングルトン
  /// バッファからの退避)を発生させないこと。
  func testEraseBoundsOnEmptyMultiMapDoesNotCopy() throws {
    var b = RedBlackTreeMultiMap<Int, String>()
    XCTAssertEqual(b._copyCount, 0)
    b.erase(lowerBound(0) ..< upperBound(10))
    XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
    b.erase(lowerBound(0) ..< upperBound(10)) { _ in true }
    XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
    XCTAssertTrue(b.isEmpty)
  }

  /// 空のMultiMapに対するIndex範囲・範囲式・全範囲のeraseは、無駄なCoW(共有される空シングルトン
  /// バッファからの退避)を発生させず、`endIndex`を返すこと。
  func testEraseIndexRangeOnEmptyMultiMapDoesNotCopy() throws {
    var b = RedBlackTreeMultiMap<Int, String>()
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

/// Boundの公開動作。公開APIの結果だけで確かめるので、Releaseでも実行する（RBT-045 MM4）。
final class RedBlackTreeMultiMapBoundPublicBehaviorTests: RedBlackTreeTestCase {

  let a: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c"]

  /// 重複keyを持つ入力。同じkeyのvalueは挿入順に並ぶ。
  private func duplicates() -> RedBlackTreeMultiMap<Int, String> {
    var b = RedBlackTreeMultiMap<Int, String>()
    b.insert((0, "a"));
    b.insert((1, "b"));
    b.insert((1, "c"));
    b.insert((2, "d"))
    return b
  }

  private func pairs<S: Sequence>(_ elements: S) -> [String]
  where S.Element == (key: Int, value: String) {
    elements.map { "\($0.key):\($0.value)" }
  }

  /// 解決できる`after`は要素を返し、末尾を越えた`after`は解決できず`nil`になること。
  func testAfterResolvesUntilTheEnd() throws {
    XCTAssertEqual(a[start()]?.value, "a")
    XCTAssertEqual(a[start().after]?.value, "b")
    XCTAssertEqual(a[start().after.after]?.value, "c")
    XCTAssertNil(a[start().after.after.after])
  }

  func testEndResolvesToNoElement() throws { XCTAssertNil(a[end()]) }

  func testLowerUpperBoundFind() throws {
    XCTAssertEqual(a[lowerBound(-1)]?.key, 0)
    XCTAssertEqual(a[lowerBound(0)]?.key, 0)
    XCTAssertEqual(a[lowerBound(1)]?.key, 1)
    XCTAssertEqual(a[lowerBound(2)]?.key, 2)
    XCTAssertNil(a[lowerBound(3)])

    XCTAssertEqual(a[upperBound(-1)]?.key, 0)
    XCTAssertEqual(a[upperBound(0)]?.key, 1)
    XCTAssertEqual(a[upperBound(1)]?.key, 2)
    XCTAssertNil(a[upperBound(2)])

    XCTAssertEqual(a[find(1)]?.key, 1)
    XCTAssertNil(a[find(5)])

    XCTAssertEqual(a[.last]?.key, 2)
  }

  /// 重複keyの群では、lowerBoundは群の先頭、upperBoundは群の直後を指すこと。
  func testLowerUpperBoundOnDuplicateKeys() throws {
    let b = duplicates()
    XCTAssertEqual(b[lowerBound(1)]?.value, "b")
    XCTAssertEqual(b[upperBound(1)]?.value, "d")
  }

  func testViewCount() throws {
    XCTAssertEqual(a[lowerBound(0) ..< upperBound(2)].count, 3)
  }

  /// 重複keyの区間のviewは、同じkeyのvalueを挿入順にすべて含み、個数も一致すること。
  func testDuplicateKeyRangeViewsKeepValueOrderAndCount() throws {
    let b = duplicates()
    XCTAssertEqual(pairs(b[equalRange(1)]), ["1:b", "1:c"])
    XCTAssertEqual(b[equalRange(1)].count, 2)
    XCTAssertEqual(pairs(b[lowerBound(1) ..< upperBound(1)]), ["1:b", "1:c"])
    XCTAssertEqual(pairs(b[lowerBound(0) ... lowerBound(1)]), ["0:a", "1:b"])
    XCTAssertEqual(pairs(b[..<upperBound(1)]), ["0:a", "1:b", "1:c"])
    XCTAssertEqual(b[..<upperBound(1)].count, 3)
  }

  func testEraseBound() throws {
    var b: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c"]
    let removed = b.erase(find(1))
    XCTAssertEqual(removed?.key, 1)
    XCTAssertEqual(removed?.value, "b")
    XCTAssertEqual(pairs(b), ["0:a", "2:c"])
  }

  /// 共有中に削除対象のないBoundでeraseしても、木をコピーしないこと（RBT-087）
  func testEraseMissingBoundFromSharedMultiMapDoesNotCopy() {
    let original: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b"), (2, "c")]
    var shared = original

    XCTAssertNil(shared.erase(find(9)))
    XCTAssertNil(shared.erase(lowerBound(10)))

    XCTAssertEqual(shared.map(\.value), ["a", "b", "c"])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "削除対象のないerase(Bound)で木がコピーされた")
  }

  /// 共有中の空でない木から空のBound範囲をeraseしても、木をコピーしないこと（RBT-081）
  func testEraseEmptyBoundRangeFromSharedMultiMapDoesNotCopy() {
    let original: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b"), (2, "c")]
    var shared = original

    shared.erase(lowerBound(2) ..< lowerBound(2))
    shared.erase(lowerBound(10) ..< upperBound(20))

    XCTAssertEqual(shared.map(\.value), ["a", "b", "c"])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のBound範囲のeraseで木がコピーされた")
  }

  /// 共有中の空でない木で、範囲内に何も一致しない述語の`erase(_:where:)`（BoundRangeExpression）をしても、木をコピーしないこと。述語は範囲内の各要素に1回ずつ順に呼ばれること（RBT-081）。
  func testEraseBoundRangeWhereNothingMatchesFromSharedMultiMapDoesNotCopy() {
    let original: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b"), (2, "c"), (3, "d"), (4, "e")]
    var shared = original
    var visited: [Int] = []

    shared.erase(lowerBound(2) ..< upperBound(3)) { visited.append($0.key); return false }

    XCTAssertEqual(visited, [2, 2, 3])
    XCTAssertEqual(shared.map(\.key), [1, 2, 2, 3, 4])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないerase(_:where:)で木がコピーされた")
  }

  /// `erase(_:where:)`（BoundRangeExpression）は述語のエラーをそのまま呼出元へ投げ、投げた後は述語を呼ばず、範囲外のkey/valueに触れないこと。
  /// 共有していた元のmultimapは変わらないこと。変更側の途中状態は契約がないため、範囲外のエントリが残り、元のエントリだけをkey順に持つことだけを確かめる（RBT-094）。
  func testEraseBoundRangeWhereRethrowsPredicateErrorAndKeepsSharedOriginal() {
    struct StopError: Error, Equatable {}
    let original: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b"), (2, "c"), (3, "d"), (4, "e"), (5, "f")]
    var map = original
    var visited: [String] = []

    XCTAssertThrowsError(
      try map.erase(lowerBound(2) ..< upperBound(4)) { element in
        visited.append(element.value)
        if element.value == "d" { throw StopError() }
        return element.value == "b"
      }
    ) { error in
      XCTAssertEqual(error as? StopError, StopError())
    }
    XCTAssertEqual(visited, ["b", "c", "d"])
    XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d", "e", "f"])
    XCTAssertTrue(map.contains { $0.key == 1 })
    XCTAssertTrue(map.contains { $0.key == 5 })
    XCTAssertEqual(map.map(\.key), map.map(\.key).sorted())
    XCTAssertTrue(map.allSatisfy { element in original.contains { $0.key == element.key && $0.value == element.value } })
  }

  /// 共有中の木で`erase(_:where:)`（BoundRangeExpression）の述語が範囲内のすべての要素に一致するとき、範囲だけが消え、共有元は変わらないこと（RBT-094）。
  func testEraseBoundRangeWhereAllMatchRemovesOnlyTheRange() {
    let original: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b"), (2, "c"), (3, "d"), (4, "e")]
    var map = original
    var visited: [String] = []

    map.erase(lowerBound(2) ..< upperBound(3)) { visited.append($0.value); return true }

    XCTAssertEqual(visited, ["b", "c", "d"])
    XCTAssertEqual(map.map(\.key), [1, 4])
    XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d", "e"])
  }

  func testSubscriptBoundsView() throws {
    XCTAssertEqual(
      pairs(a[lowerBound(0) ..< upperBound(2)]),
      ["0:a", "1:b", "2:c"]
    )
  }

  func testSubscriptBoundsModifyPopFirst() throws {
    var b: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d"]
    let removed = b[lowerBound(0) ..< upperBound(1)].popFirst()
    XCTAssertEqual(removed?.key, 0)
    XCTAssertEqual(removed?.value, "a")
    XCTAssertEqual(pairs(b), ["1:b", "2:c", "3:d"])
  }

  func testEraseBounds() throws {
    var b: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
    b.erase(lowerBound(1) ..< upperBound(3))
    XCTAssertEqual(pairs(b), ["0:a", "4:e"])
  }

  /// 重複keyの区間のeraseは、その群のエントリだけをすべて削除すること。
  func testEraseDuplicateKeyBoundsRemovesTheWholeGroup() throws {
    var b = duplicates()
    b.erase(lowerBound(1) ..< upperBound(1))
    XCTAssertEqual(pairs(b), ["0:a", "2:d"])
    XCTAssertEqual(b.count(forKey: 1), 0)
  }

  /// 下端が上端より後ろにある逆向きの範囲は空の範囲として扱い、何も削除しないこと。
  /// 同値キーの区間を逆向きに指定した場合も同じであること。
  func testEraseReversedBoundsRemovesNothing() throws {
    var b = duplicates()
    b.erase(upperBound(10) ..< lowerBound(-10))
    XCTAssertEqual(pairs(b), ["0:a", "1:b", "1:c", "2:d"])
    b.erase(upperBound(1) ..< lowerBound(1))
    XCTAssertEqual(pairs(b), ["0:a", "1:b", "1:c", "2:d"])
    XCTAssertEqual(b.count(forKey: 1), 2)
  }

  /// 逆向きの範囲では、条件クロージャを一度も呼ばず、何も削除しないこと。
  func testEraseReversedBoundsWhereRemovesNothingAndSkipsPredicate() throws {
    var b = duplicates()
    var calls = 0
    b.erase(upperBound(1) ..< lowerBound(1)) { _ in
      calls += 1
      return true
    }
    XCTAssertEqual(calls, 0)
    XCTAssertEqual(pairs(b), ["0:a", "1:b", "1:c", "2:d"])
  }

  func testRemoveBoundsWhere() throws {
    var b: RedBlackTreeMultiMap = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
    b.erase(lowerBound(0) ..< upperBound(4)) { $0.key % 2 == 0 }
    XCTAssertEqual(pairs(b), ["1:b", "3:d"])
  }

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

final class RedBlackTreeMultiMapBoundDistanceTests: RedBlackTreeTestCase {

  /// Bound式どうしの`distance(from:to:)`は、評価した2位置の間の要素数を返すこと。
  func testDistanceBetweenBoundExpressions() {
    let c = RedBlackTreeMultiMap<Int, String>(keysWithValues: [
      (0, "a"), (1, "b"), (1, "c"), (2, "d"), (2, "e"), (2, "f"), (3, "g"),
    ])
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
  extension RedBlackTreeMultiMapBoundPublicBehaviorTests {
    /// 空の木の.lastは、docどおりpast-the-endに置き換わること。
    func testEmptyLastBoundIsEnd() {
      let empty = RedBlackTreeMultiMap<Int, Int>()
      XCTAssertEqual(empty.distance(from: .start, to: .last), 0)
    }

    /// .start.advanced(by:)に要素数を超える距離を渡すと、終わらずにループせずnilになること。
    func testBoundAdvancedByHugeOffsetTerminates() {
      let c = RedBlackTreeMultiMap(keysWithValues: [(1, 1), (2, 2), (3, 3)])
      XCTAssertNil(c[.start.advanced(by: 4)])
      XCTAssertNil(c[.start.advanced(by: Int.max)])
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMapBoundPublicBehaviorTests {

    /// `.first(k)`はkの要素のうち走査順（同じkeyでは挿入順）の先頭を指すこと。
    func testFirstResolvesToTheHeadOfTheEqualKeyRun() throws {
      var b = RedBlackTreeMultiMap<Int, Int>()
      b.insert((0, -1))
      for v in 0 ..< 100 { b.insert((1, v)) }
      b.insert((2, -2))
      XCTAssertEqual(b[.first(1)]?.value, 0)
      XCTAssertEqual(b[first(1)]?.value, 0, "トップレベルの`first(_:)`も群の先頭を指すこと")
      XCTAssertEqual(b[.first(1).before]?.key, 0)
      XCTAssertEqual(b[.first(1).after]?.value, 1)
      XCTAssertEqual(b[.first(1) ..< upperBound(1)].count, 100)
      XCTAssertNil(b[.first(-1)])
      XCTAssertNil(b[.first(3)])
      XCTAssertNil(RedBlackTreeMultiMap<Int, Int>()[.first(0)])
    }

    /// 重複keyの群でも、`.first(k)`は群の先頭（`lowerBound(k)`と同じ要素）を指すこと。
    func testFirstOnDuplicateKeys() throws {
      let b = duplicates()
      XCTAssertEqual(b[.first(1)]?.value, "b")
      XCTAssertEqual(b[.first(1)]?.value, b[lowerBound(1)]?.value)
      XCTAssertEqual(pairs(b[.first(1) ..< upperBound(1)]), ["1:b", "1:c"])
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMapBoundPublicBehaviorTests {

    /// トップレベル関数の境界式は、同名のstaticメンバーと同じ要素を指すこと。
    /// 重複keyでもvalueが異なるので、valueで位置を見分ける。
    func testTopLevelBoundsMatchStaticMembers() throws {
      var b = RedBlackTreeMultiMap<Int, String>()
      b.insert((0, "a"))
      b.insert((2, "b"))
      b.insert((2, "c"))
      b.insert((2, "d"))
      b.insert((4, "e"))
      XCTAssertEqual(b[start()]?.value, b[.start]?.value)
      XCTAssertEqual(b[last()]?.value, b[.last]?.value)
      XCTAssertEqual(b[last()]?.value, "e")
      XCTAssertNil(b[end()])
      for k in -1 ... 5 {
        XCTAssertEqual(b[lowerBound(k)]?.value, b[.lowerBound(k)]?.value, "lowerBound k=\(k)")
        XCTAssertEqual(b[upperBound(k)]?.value, b[.upperBound(k)]?.value, "upperBound k=\(k)")
        XCTAssertEqual(b[find(k)]?.key, b[.find(k)]?.key, "find k=\(k)")
        XCTAssertEqual(b[first(k)]?.value, b[.first(k)]?.value, "first k=\(k)")
      }
      XCTAssertEqual(b[first(2)]?.value, "b", "first(2)は2の群の先頭であること")
      XCTAssertNil(RedBlackTreeMultiMap<Int, String>()[last()])
    }
  }
#endif
