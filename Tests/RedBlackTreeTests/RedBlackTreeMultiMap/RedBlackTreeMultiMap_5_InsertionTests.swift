import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapInsertionTests: RedBlackTreeTestCase {

  func test_insert_preservesInsertionOrderForEquivalentKeys() {
    var map = RedBlackTreeMultiMap<Int, String>()

    map.insert((1, "a"))
    map.insert((2, "x"))
    map.insert((1, "b"))
    map.insert((1, "c"))

    XCTAssertEqual(map.map(\.key), [1, 1, 1, 2])
    XCTAssertEqual(map.filter { $0.key == 1 }.map(\.value), ["a", "b", "c"])
  }

  func test_insertContentsOf_preservesEveryKeyValuePair() {
    var map: RedBlackTreeMultiMap<Int, String> = [(1, "a")]

    map.insert(contentsOf: [(1, "b"), (2, "c"), (2, "d")])

    XCTAssertEqual(map.map(\.key), [1, 1, 2, 2])
    XCTAssertEqual(map.map(\.value), ["a", "b", "c", "d"])
  }

  func test_reinsertingEquivalentKey_appendsAfterRemainingEquivalentEntries() {
    var map: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (1, "b"), (1, "c")]

    _ = map.remove(at: map.startIndex)
    map.insert((1, "d"))

    XCTAssertEqual(map.map(\.value), ["b", "c", "d"])
  }

    func test_insertWithHint_handlesEquivalentGoodAndBadHints() {
      var map: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (1, "c"), (3, "x")]

      let duplicate = map.insert((1, "b"), hint: map.index(after: map.startIndex))
      XCTAssertEqual(map[duplicate].value, "b")

      let goodHint = map.firstIndex(of: 3)!
      let insertedWithGoodHint = map.insert((2, "good"), hint: goodHint)
      XCTAssertEqual(map[insertedWithGoodHint].value, "good")

      let insertedWithBadHint = map.insert((4, "bad"), hint: map.startIndex)
      XCTAssertEqual(map[insertedWithBadHint].value, "bad")
      XCTAssertEqual(map.map(\.key), [1, 1, 1, 2, 3, 4])
    }

    /// `insert(_:hint:)`は、std::multimapと同様にhintが示す位置そのものへ挿入する。
    /// hintが同値キー群の途中を指す場合、新しいpairは末尾ではなくその途中へ入る
    /// (通常の`insert(_:)`が常に同値キー群の末尾へ追加するのとは異なる)。
    /// 2026-10-03にユーザー確認: C++の`std::multimap::insert(hint, value)`に倣う。
    func test_insertWithHint_placesNewPairAtHintPositionWithinEquivalentKeyGroup() {
      var map: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (1, "b"), (1, "c")]
      let hint = map.index(after: map.startIndex)  // "b"を指す

      map.insert((1, "X"), hint: hint)

      XCTAssertEqual(map.map(\.value), ["a", "X", "b", "c"])
    }

    func test_updateValue_replacesOnlyTheSpecifiedDuplicatePosition() {
      var map: RedBlackTreeMultiMap<Int, String> = [(1, "first"), (1, "middle"), (1, "last")]
      let index = map.index(after: map.startIndex)

      let oldValue = map.updateValue("new", at: index)

      XCTAssertEqual(oldValue, "middle")
      XCTAssertEqual(map.map(\.value), ["first", "new", "last"])
    }

    func test_updateValue_rejectsEndIndex() {
      var map: RedBlackTreeMultiMap<Int, String> = [(1, "value")]

      XCTAssertNil(map.updateValue("new", at: map.endIndex))
      XCTAssertEqual(map.map(\.value), ["value"])
    }

    func test_updateValue_preservesValueSemanticsAfterCopy() {
      var map: RedBlackTreeMultiMap<Int, String> = [(1, "old")]
      let copy = map

      XCTAssertEqual(map.updateValue("new", at: map.startIndex), "old")

      XCTAssertEqual(map.first?.value, "new")
      XCTAssertEqual(copy.first?.value, "old")
    }

  #if ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
    /// MultiMapはキー重複を許容するため、既存キーへの`index(inserting:)`も
    /// (Setのような一意挿入ではなく)常に新しいエントリとして挿入されること。
    func test_indexInserting_allowsDuplicateKeysAndErasesByIndex() {
      var map = RedBlackTreeMultiMap<Int, String>()

      let first = map.index(inserting: (1, "a"))
      XCTAssertTrue(first.inserted)

      let second = map.index(inserting: (1, "b"))
      XCTAssertTrue(second.inserted, "MultiMapなので同じキーでも挿入されるはず")
      XCTAssertNotEqual(first.index, second.index)

      XCTAssertEqual(map.map(\.key), [1, 1])
      XCTAssertEqual(map.map(\.value), ["a", "b"])

      XCTAssertNotNil(map.erase(exactly: first.index))
      XCTAssertEqual(map.map(\.value), ["b"])
    }

    /// 空のMultiMapに対して`erase(exactly:)`を呼んでもトラップせず、`nil`を返すこと。
    /// トラップしない以上、無駄なCoW(共有される空シングルトンバッファからの退避)も
    /// 発生しないこと。
    func test_eraseExactly_onEmptyMapReturnsNilWithoutTrapping() {
      var map = RedBlackTreeMultiMap<Int, String>()

      #if AC_COLLECTIONS_INTERNAL_CHECKS
        XCTAssertEqual(map._copyCount, 0)
      #endif
      XCTAssertNil(map.erase(exactly: map.startIndex))
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        XCTAssertEqual(map._copyCount, 0, "空の削除はnilを返すだけで、バッファのコピーを発生させないはず")
      #endif
      XCTAssertNil(map.erase(exactly: map.endIndex))
    }
  #endif
}

  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeMultiMapInsertContentsOfTests: RedBlackTreeTestCase {

    /// `insert(contentsOf:)`と`inserting(contentsOf:)`は、同値キーも含め全ての組を加えること。
    func testInsertAndInsertingContentsOfMultiMap() {
      let other = RedBlackTreeMultiMap<Int, String>(keysWithValues: [(1, "x"), (3, "c")])
      var m = RedBlackTreeMultiMap<Int, String>(keysWithValues: [(1, "a"), (2, "b")])
      let combined = m.inserting(contentsOf: other)
      XCTAssertEqual(combined.map(\.key), [1, 1, 2, 3])
      XCTAssertEqual(m.map(\.key), [1, 2], "insertingは元を変えない")
      m.insert(contentsOf: other)
      XCTAssertEqual(m.map(\.key), [1, 1, 2, 3])
      XCTAssertEqual(m.map(\.value), ["a", "x", "b", "c"], "同値キーは既存の後ろに入る")
    }
  }
