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

  func test_insertContentsOf_emptyMultiMapIntoSharedMultiMapDoesNotCopy() {
    let original: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b"), (2, "c")]
    var shared = original

    shared.insert(contentsOf: RedBlackTreeMultiMap<Int, String>())

    XCTAssertEqual(shared.map(\.key), [1, 2, 2])
    XCTAssertEqual(shared.map(\.value), ["a", "b", "c"])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のMultiMapのinsert(contentsOf:)で木がコピーされた")
  }

  func test_insertContentsOf_emptySequenceIntoSharedMultiMapDoesNotCopy() {
    let original: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b"), (2, "c")]
    var shared = original

    shared.insert(contentsOf: [(Int, String)]())

    XCTAssertEqual(shared.map(\.key), [1, 2, 2])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のSequenceのinsert(contentsOf:)で木がコピーされた")
  }

  func test_insertContentsOf_singlePassSequenceConsumesEveryElementOnce() {
    let original: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (3, "c")]
    var map = original
    let source = SinglePassSequence([(0, "x"), (3, "y")])

    map.insert(contentsOf: source)

    XCTAssertEqual(map.map(\.key), [0, 1, 3, 3])
    XCTAssertEqual(map.map(\.value), ["x", "a", "c", "y"])
    XCTAssertEqual(original.map(\.value), ["a", "c"])
    XCTAssertEqual(source.makeIteratorCount, 1)
    XCTAssertTrue(source.isExhausted)
  }

  func test_reinsertingEquivalentKey_appendsAfterRemainingEquivalentEntries() {
    var map: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (1, "b"), (1, "c")]

    _ = map.remove(at: map.startIndex)
    map.insert((1, "d"))

    XCTAssertEqual(map.map(\.value), ["b", "c", "d"])
  }

  // MARK: - 同値キーの並び（RBT-074）

  /// キーと値の列からの初期化は、同値キーの値を入力の順に並べること（RBT-074）
  func test_initFromPairs_keepsInputOrderOfEquivalentKeys() {
    let pairs = [(2, "b1"), (1, "a1"), (2, "b2"), (1, "a2"), (2, "b3")]
    let expected = ["a1", "a2", "b1", "b2", "b3"]

    XCTAssertEqual(RedBlackTreeMultiMap<Int, String>(keysWithValues: pairs).map(\.value), expected)
    XCTAssertEqual(
      RedBlackTreeMultiMap<Int, String>(keysWithValues: AnySequence(pairs)).map(\.value), expected)
  }

  /// insert(contentsOf:)・inserting(contentsOf:)は、既存の同値キーの後ろに、
  /// 入力側の同値キーの値を入力の順で置くこと（RBT-074）
  func test_insertContentsOf_appendsEquivalentKeyPairsAfterExistingOnes() {
    let map = RedBlackTreeMultiMap<Int, String>(
      keysWithValues: [(1, "a0"), (5, "a1"), (5, "a2"), (9, "a9")])
    let other = [(5, "b1"), (5, "b2"), (5, "b3"), (7, "b7")]
    let expected = ["a0", "a1", "a2", "b1", "b2", "b3", "b7", "a9"]

    var fromMultiMap = map
    fromMultiMap.insert(contentsOf: RedBlackTreeMultiMap<Int, String>(keysWithValues: other))
    XCTAssertEqual(fromMultiMap.map(\.value), expected)

    var fromSequence = map
    fromSequence.insert(contentsOf: other)
    XCTAssertEqual(fromSequence.map(\.value), expected)

    XCTAssertEqual(
      map.inserting(contentsOf: RedBlackTreeMultiMap<Int, String>(keysWithValues: other)).map(\.value),
      expected)
    XCTAssertEqual(map.inserting(contentsOf: other).map(\.value), expected)
  }

  /// 固定シードの乱択入力でも、初期化とinsert(contentsOf:)の結果が、
  /// キーごとに「既存の並び→入力の並び」（安定なmerge）と一致すること（RBT-074）
  func test_insertContentsOf_matchesStableMergeForSeededInputs() {
    var random = InsertionOrderRandom(seed: 0x5EED_0074)

    for trial in 0..<200 {
      let lhs = (0..<Int.random(in: 0...40, using: &random)).map {
        (Int.random(in: 0...5, using: &random), "a\($0)")
      }
      let rhs = (0..<Int.random(in: 0...40, using: &random)).map {
        (Int.random(in: 0...5, using: &random), "b\($0)")
      }
      let expected = (lhs + rhs).enumerated()
        .sorted { ($0.element.0, $0.offset) < ($1.element.0, $1.offset) }
        .map(\.element.1)

      var fromMultiMap = RedBlackTreeMultiMap<Int, String>(keysWithValues: lhs)
      fromMultiMap.insert(contentsOf: RedBlackTreeMultiMap<Int, String>(keysWithValues: rhs))
      XCTAssertEqual(fromMultiMap.map(\.value), expected, "trial \(trial)")

      var fromSequence = RedBlackTreeMultiMap<Int, String>(keysWithValues: lhs)
      fromSequence.insert(contentsOf: rhs)
      XCTAssertEqual(fromSequence.map(\.value), expected, "trial \(trial)")
    }
  }

  #if !COMPATIBLE_ATCODER_2025
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

    #if false
    // RBT-048: Previous nil-returning contract; retained for API review.
    func test_updateValue_rejectsEndIndex() {
      var map: RedBlackTreeMultiMap<Int, String> = [(1, "value")]

      XCTAssertNil(map.updateValue("new", at: map.endIndex))
      XCTAssertEqual(map.map(\.value), ["value"])
    }
    #endif

    func test_updateValue_preservesValueSemanticsAfterCopy() {
      var map: RedBlackTreeMultiMap<Int, String> = [(1, "old")]
      let copy = map

      XCTAssertEqual(map.updateValue("new", at: map.startIndex), "old")

      XCTAssertEqual(map.first?.value, "new")
      XCTAssertEqual(copy.first?.value, "old")
    }

    /// 同じkeyの群から中央を削除した後、保存していたIndexへのupdateValueはnilを返し、
    /// 残っているkey/valueを変えないこと（RBT-045 MM1）
    #if false
    // RBT-048: Previous nil-returning contract; retained for API review.
    func test_updateValue_atRemovedIndexReturnsNilAndKeepsSurvivors() {
      var map: RedBlackTreeMultiMap<Int, String> = [(1, "first"), (1, "middle"), (1, "last"), (2, "other")]
      let removedIndex = map.index(after: map.startIndex)
      XCTAssertEqual(map.remove(at: removedIndex).value, "middle")
      XCTAssertFalse(map.isElement(at: removedIndex), "削除した位置のIndexは無効になっていること")

      XCTAssertNil(map.updateValue("new", at: removedIndex))

      XCTAssertEqual(map.map(\.key), [1, 1, 2])
      XCTAssertEqual(map.map(\.value), ["first", "last", "other"])
      XCTAssertEqual(map.count(forKey: 1), 2)
    }
    #endif
  #endif

  #if !COMPATIBLE_ATCODER_2025 && ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
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

      #if _TREE_COPY_COUNTER
        XCTAssertEqual(map._copyCount, 0)
      #endif
      XCTAssertNil(map.erase(exactly: map.startIndex))
      #if _TREE_COPY_COUNTER
        XCTAssertEqual(map._copyCount, 0, "空の削除はnilを返すだけで、バッファのコピーを発生させないはず")
      #endif
      XCTAssertNil(map.erase(exactly: map.endIndex))
    }

    /// 共有中の空でない木に`endIndex`で`erase(exactly:)`しても、`nil`を返し木をコピーしないこと（RBT-081）。
    func test_eraseExactly_endIndexKeepsSharedStorage() {
      let original: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b"), (2, "c")]
      var shared = original

      XCTAssertNil(shared.erase(exactly: shared.endIndex))

      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "endIndexのerase(exactly:)で木がコピーされた")
    }

    /// 共有中の空でない木に失効したIndexで`erase(exactly:)`しても、`nil`を返し木をコピーしないこと（RBT-081）。
    func test_eraseExactly_staleIndexKeepsSharedStorage() {
      var shared: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b"), (2, "c")]
      let i = shared.startIndex
      XCTAssertNotNil(shared.erase(exactly: i))
      let original = shared

      XCTAssertNil(shared.erase(exactly: i))

      XCTAssertEqual(shared.map(\.value), ["b", "c"])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "失効したIndexのerase(exactly:)で木がコピーされた")
    }
  #endif
}

#if !COMPATIBLE_ATCODER_2025
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
#endif

/// SplitMix64. 並びのテストで、再現できる乱択入力を作る
private struct InsertionOrderRandom: RandomNumberGenerator {
  var state: UInt64
  init(seed: UInt64) { state = seed }
  mutating func next() -> UInt64 {
    state &+= 0x9E37_79B9_7F4A_7C15
    var z = state
    z = (z ^ (z &>> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z &>> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z &>> 31)
  }
}
