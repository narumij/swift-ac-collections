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

    func testEndIsInvalid() throws {
      XCTAssertFalse(a.isValid(end()))
    }

    func testLastIsValid() throws {
      XCTAssertTrue(a.isValid(.last))
    }

    func testLessThanAllKeysIsValid() throws {
      let cases: [(key: Int, valid: Bool)] = [
        (-1, false), (0, false), (1, true), (2, true), (3, true), (4, true),
      ]
      for (key, valid) in cases {
        XCTAssertEqual(a.isValid(.lessThan(key)), valid, "key=\(key)")
      }
    }

    /// 空のDictionaryに対するBound範囲のeraseは、無駄なCoW(共有される空シングルトン
    /// バッファからの退避)を発生させないこと。
    func testEraseBoundsOnEmptyDictionaryDoesNotCopy() throws {
      var b = RedBlackTreeDictionary<Int, String>()
      XCTAssertEqual(b._copyCount, 0)
      b.erase(lowerBound(0)..<upperBound(10))
      XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
      b.erase(lowerBound(0)..<upperBound(10)) { _ in true }
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
      XCTAssertEqual(b.erase(b.startIndex..<b.endIndex), b.endIndex)
      XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
      b.erase(b.startIndex..<b.endIndex) { _ in true }
      XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
      XCTAssertEqual(b.erase(...), b.endIndex)
      XCTAssertEqual(b._copyCount, 0, "空の削除はバッファのコピーを発生させないはず")
      XCTAssertTrue(b.isEmpty)
    }

    func testIsValidBoundsInvalidDoesNotCrash() throws {
      XCTAssertFalse(a.isValid(upperBound(10)..<lowerBound(-10)))
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  import XCTest
  import RedBlackTreeCollections

  /// Boundの公開動作。公開APIの結果だけで確かめるので、Releaseでも実行する（RBT-044 D5）。
  final class RedBlackTreeDictionaryBoundPublicBehaviorTests: RedBlackTreeTestCase {

    let a: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]

    private func pairs<S: Sequence>(_ elements: S) -> [String] where S.Element == (key: Int, value: String) {
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

    func testEndResolvesToNoElement() throws {
      XCTAssertNil(a[end()])
    }

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
      XCTAssertEqual(a[lowerBound(0)..<upperBound(2)].count, 3)
    }

    func testEraseBound() throws {
      var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]
      let removed = b.erase(find(1))
      XCTAssertEqual(removed?.key, 1)
      XCTAssertEqual(removed?.value, "b")
      XCTAssertEqual(pairs(b), ["0:a", "2:c"])
    }

    func testEraseBounds() throws {
      var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      b.erase(lowerBound(1)..<upperBound(3))
      XCTAssertEqual(pairs(b), ["0:a", "4:e"])
    }

    /// 下端が上端より後ろにある逆向きの範囲は空の範囲として扱い、何も削除しないこと。
    func testEraseReversedBoundsRemovesNothing() throws {
      var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      b.erase(upperBound(10)..<lowerBound(-10))
      XCTAssertEqual(pairs(b), ["0:a", "1:b", "2:c", "3:d", "4:e"])
      b.erase(lowerBound(3)..<lowerBound(1))
      XCTAssertEqual(pairs(b), ["0:a", "1:b", "2:c", "3:d", "4:e"])
    }

    /// 逆向きの範囲では、条件クロージャを一度も呼ばず、何も削除しないこと。
    func testEraseReversedBoundsWhereRemovesNothingAndSkipsPredicate() throws {
      var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      var calls = 0
      b.erase(lowerBound(3)..<lowerBound(1)) { _ in
        calls += 1
        return true
      }
      XCTAssertEqual(calls, 0)
      XCTAssertEqual(pairs(b), ["0:a", "1:b", "2:c", "3:d", "4:e"])
    }

    func testSubscriptBoundsView() throws {
      XCTAssertEqual(pairs(a[lowerBound(0)..<upperBound(2)]), ["0:a", "1:b", "2:c"])
    }

    func testSubscriptBoundsModifyPopFirst() throws {
      var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d"]
      let removed = b[lowerBound(0)..<upperBound(2)].popFirst()
      XCTAssertEqual(removed?.key, 0)
      XCTAssertEqual(removed?.value, "a")
      XCTAssertEqual(pairs(b), ["1:b", "2:c", "3:d"])
    }

    func testRemoveBoundsWhere() throws {
      var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      b.erase(lowerBound(0)..<upperBound(4)) { $0.key % 2 == 0 }
      XCTAssertEqual(pairs(b), ["1:b", "3:d"])
    }

    func testLessThanAllKeys() throws {
      let cases: [(key: Int, expected: String?)] = [
        (-1, nil),
        (0, nil),
        (1, "a"),
        (2, "b"),
        (3, "c"),
        (4, "c"),
      ]

      for (key, expected) in cases {
        XCTAssertEqual(a[.lessThan(key)]?.value, expected, "key=\(key)")
      }
    }

    func testLessGreaterHelpers() throws {
      XCTAssertEqual(a[.lessThan(1)]?.value, "a")
      XCTAssertEqual(a[.greaterThan(1)]?.value, "c")
      XCTAssertEqual(a[.lessThanOrEqual(1)]?.value, "b")
      XCTAssertEqual(a[.greaterThanOrEqual(1)]?.value, "b")
    }

    func testBoundRangeOperators() throws {
      XCTAssertEqual(pairs(a[lowerBound(0)..<upperBound(2)]), ["0:a", "1:b", "2:c"])
      XCTAssertEqual(pairs(a[lowerBound(0)...lowerBound(1)]), ["0:a", "1:b"])
      XCTAssertEqual(pairs(a[..<upperBound(1)]), ["0:a", "1:b"])
      XCTAssertEqual(pairs(a[...upperBound(1)]), ["0:a", "1:b", "2:c"])
      XCTAssertEqual(pairs(a[lowerBound(1)...]), ["1:b", "2:c"])
    }

    func testEqualRange() throws {
      XCTAssertEqual(pairs(a[equalRange(1)]), ["1:b"])
    }

    /// 逆向きのBound範囲のviewは空になり、列挙しても要素を返さないこと。
    func testReversedBoundsViewIsEmpty() throws {
      XCTAssertTrue(a[upperBound(10)..<lowerBound(-10)].isEmpty)
      XCTAssertEqual(pairs(a[upperBound(10)..<lowerBound(-10)]), [])
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeDictionaryBoundDistanceTests: RedBlackTreeTestCase {

    /// Bound式どうしの`distance(from:to:)`は、評価した2位置の間の要素数を返すこと。
    func testDistanceBetweenBoundExpressions() {
      let c = RedBlackTreeDictionary<Int, String>(uniqueKeysWithValues: (0..<10).map { ($0, "\($0)") })
      XCTAssertEqual(c.distance(from: lowerBound(2), to: lowerBound(7)), 5)
      XCTAssertEqual(c.distance(from: lowerBound(2), to: upperBound(7)), 6)
      XCTAssertEqual(c.distance(from: start(), to: end()), c.count)
      XCTAssertEqual(c.distance(from: lowerBound(4), to: lowerBound(4)), 0)
    }
  }
#endif
