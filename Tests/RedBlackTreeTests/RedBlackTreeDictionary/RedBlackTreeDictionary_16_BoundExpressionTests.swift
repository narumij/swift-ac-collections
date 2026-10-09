//
//  DictionaryBoundsExpressionTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

#if DEBUG
  import XCTest
  import RedBlackTreeCollections

  final class RedBlackTreeDictionaryBoundExpressionTests: RedBlackTreeTestCase {

    let a: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]

    func testAfter() throws {
      XCTAssertTrue(a.isValid(start()))
      XCTAssertEqual(a[start()]?.key, 0)

      XCTAssertTrue(a.isValid(start().after))
      XCTAssertEqual(a[start().after]?.key, 1)

      XCTAssertTrue(a.isValid(start().after.after))
      XCTAssertEqual(a[start().after.after]?.key, 2)

      XCTAssertFalse(a.isValid(start().after.after.after))
      XCTAssertNil(a[start().after.after.after])
    }

    func testEndIsInvalid() throws {
      XCTAssertFalse(a.isValid(end()))
      XCTAssertNil(a[end()])
    }

    func testLowerUpperBoundFind() throws {
      XCTAssertEqual(a[lowerBound(-1)]?.key, 0)
      XCTAssertEqual(a[lowerBound(0)]?.key, 0)
      XCTAssertEqual(a[lowerBound(1)]?.key, 1)
      XCTAssertEqual(a[lowerBound(2)]?.key, 2)
      XCTAssertEqual(a[lowerBound(3)]?.key, nil)

      XCTAssertEqual(a[upperBound(-1)]?.key, 0)
      XCTAssertEqual(a[upperBound(0)]?.key, 1)
      XCTAssertEqual(a[upperBound(1)]?.key, 2)
      XCTAssertEqual(a[upperBound(2)]?.key, nil)

      XCTAssertEqual(a[find(1)]?.key, 1)
      XCTAssertEqual(a[find(5)]?.key, nil)

      XCTAssertTrue(a.isValid(.last))
      XCTAssertEqual(a[.last]?.key, 2)
    }

    func testViewCount() throws {
      XCTAssertEqual(a[lowerBound(0)..<upperBound(2)].count, 3)
    }

    func testEraseBound() throws {
      var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c"]
      let removed = b.erase(find(1))
      XCTAssertEqual(removed?.key, 1)
      XCTAssertEqual(Array(b).map { $0.key }, [0, 2])
    }

    func testEraseBounds() throws {
      var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      b.erase(lowerBound(1)..<upperBound(3))
      XCTAssertEqual(Array(b).map { $0.key }, [0, 4])
    }

    /// 下端が上端より後ろにある逆向きの範囲は空の範囲として扱い、何も削除しないこと。
    func testEraseReversedBoundsRemovesNothing() throws {
      var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      b.erase(upperBound(10)..<lowerBound(-10))
      XCTAssertEqual(Array(b).map { $0.key }, [0, 1, 2, 3, 4])
      b.erase(lowerBound(3)..<lowerBound(1))
      XCTAssertEqual(Array(b).map { $0.key }, [0, 1, 2, 3, 4])
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
      XCTAssertEqual(Array(b).map { $0.key }, [0, 1, 2, 3, 4])
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

    func testSubscriptBoundsView() throws {
      let view = a[lowerBound(0)..<upperBound(2)]
      XCTAssertEqual(Array(view).map { $0.key }, [0, 1, 2])
    }

    func testSubscriptBoundsModifyPopFirst() throws {
      var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d"]
      let removed = b[lowerBound(0)..<upperBound(2)].popFirst()
      XCTAssertEqual(removed?.key, 0)
      XCTAssertEqual(Array(b).map { $0.key }, [1, 2, 3])
    }

    func testRemoveBoundsWhere() throws {
      var b: RedBlackTreeDictionary = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e"]
      b.erase(lowerBound(0)..<upperBound(4)) { $0.key % 2 == 0 }
      XCTAssertEqual(Array(b).map { $0.key }, [1, 3])
    }

    func testLessThanAllKeys() throws {
      let cases: [(key: Int, expected: Int?)] = [
        (-1, nil),
        (0, nil),
        (1, 0),
        (2, 1),
        (3, 2),
        (4, 2),
      ]

      for (key, expected) in cases {
        XCTAssertEqual(a[.lessThan(key)]?.key, expected, "key=\(key)")
        XCTAssertEqual(a.isValid(.lessThan(key)), expected != nil, "key=\(key)")
      }
    }

    func testLessGreaterHelpers() throws {
      XCTAssertEqual(a[.lessThan(1)]?.key, 0)
      XCTAssertEqual(a[.greaterThan(1)]?.key, 2)
      XCTAssertEqual(a[.lessThanOrEqual(1)]?.key, 1)
      XCTAssertEqual(a[.greaterThanOrEqual(1)]?.key, 1)
    }

    func testBoundRangeOperators() throws {
      let view1 = a[lowerBound(0)..<upperBound(2)]
      XCTAssertEqual(Array(view1).map { $0.key }, [0, 1, 2])

      let view2 = a[lowerBound(0)...lowerBound(1)]
      XCTAssertEqual(Array(view2).map { $0.key }, [0, 1])

      let view3 = a[..<upperBound(1)]
      XCTAssertEqual(Array(view3).map { $0.key }, [0, 1])

      let view4 = a[...upperBound(1)]
      XCTAssertEqual(Array(view4).map { $0.key }, [0, 1, 2])

      let view5 = a[lowerBound(1)...]
      XCTAssertEqual(Array(view5).map { $0.key }, [1, 2])
    }

    func testEqualRange() throws {
      let view = a[equalRange(1)]
      XCTAssertEqual(Array(view).map { $0.key }, [1])
    }

    func testIsValidBoundsInvalidDoesNotCrash() throws {
      XCTAssertFalse(a.isValid(upperBound(10)..<lowerBound(-10)))
      XCTAssertTrue(a[upperBound(10)..<lowerBound(-10)].isEmpty)
      XCTAssertEqual(Array(a[upperBound(10)..<lowerBound(-10)]).map { $0.key }, [])
    }
  }
#endif

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
