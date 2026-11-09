import RedBlackTreeCollections
import XCTest

/// `RedBlackTreeKeyValueRangeView`(`Dictionary`/`MultiMap`のRangeViewが返す型)の仕様。
/// ジェネリックな共有Viewのため、代表としてDictionaryのインスタンスで検証する。
#if !COMPATIBLE_ATCODER_2025
  final class RedBlackTreeKeyValueRangeViewTests: RedBlackTreeTestCase {

    func test_sorted_returnsElementsAlreadyInKeyOrder() {
      let dictionary: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]
      let view = dictionary[...]

      XCTAssertEqual(view.sorted().map(\.key), [1, 2, 3])
    }

    func test_keys_returnsJustTheKeysInOrder() {
      let dictionary: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]
      let view = dictionary[...]

      XCTAssertEqual(Array(view.keys), [1, 2, 3])
    }

    func test_values_returnsJustTheValuesInKeyOrder() {
      let dictionary: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]
      let view = dictionary[...]

      XCTAssertEqual(Array(view.values), ["a", "b", "c"])
    }

    func test_isElementAndIsEnd_respectViewBounds() {
      let dictionary = RedBlackTreeDictionary<Int, String>(
        uniqueKeysWithValues: (0..<5).map { ($0, "\($0)") })
      let lower = dictionary.index(after: dictionary.startIndex)
      let inside = dictionary.index(after: lower)
      let upper = dictionary.index(before: dictionary.endIndex)
      let view = dictionary[lower..<upper]

      XCTAssertFalse(view.isElement(at: dictionary.startIndex))
      XCTAssertTrue(view.isElement(at: lower))
      XCTAssertTrue(view.isElement(at: inside))
      XCTAssertFalse(view.isElement(at: upper))
      XCTAssertFalse(view.isElement(at: dictionary.endIndex))

      XCTAssertFalse(view.isEnd(lower))
      XCTAssertTrue(view.isEnd(upper))
      XCTAssertFalse(view.isEnd(dictionary.endIndex))
    }

    func test_removeFirstAndRemoveLast_removeEndpointsAndReturnRemovedElement() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]

      XCTAssertEqual(dictionary[...].removeFirst().key, 1)
      XCTAssertEqual(dictionary.map(\.key), [2, 3])

      XCTAssertEqual(dictionary[...].removeLast().key, 3)
      XCTAssertEqual(dictionary.map(\.key), [2])
    }

    /// 空のビューに対する削除系操作は、トラップしない以上、無駄なCoW
    /// (共有される空シングルトンバッファからの退避)も発生させないこと。
    func test_removalMethods_onEmptyView_doNotTriggerCopyOnWrite() {
      #if _TREE_COPY_COUNTER
        var empty = RedBlackTreeDictionary<Int, String>()
        XCTAssertEqual(empty._copyCount, 0)

        XCTAssertNil(empty[...].popFirst())
        XCTAssertEqual(empty._copyCount, 0)

        XCTAssertNil(empty[...].popLast())
        XCTAssertEqual(empty._copyCount, 0)

        empty[...].erase()
        XCTAssertEqual(empty._copyCount, 0)

        empty[...].erase(where: { _ in true })
        XCTAssertEqual(empty._copyCount, 0)
      #endif
    }

    func test_eraseWhere_onStandaloneViewRemovesOnlyMatchingElements() {
      var dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c", 4: "d"]

      dictionary[...].erase(where: { $0.key.isMultiple(of: 2) })

      XCTAssertEqual(dictionary.map(\.key), [1, 3])
    }

    /// 部分範囲のViewの`erase(where:)`は、述語のエラーをそのまま呼出元へ投げ、投げた後は述語を呼ばず、
    /// 範囲外のkey/valueに触れないこと。共有していた元の辞書のkey/valueは変わらないこと。変更側の途中状態は
    /// 契約がないため、範囲外のエントリが残り、元のエントリだけをkey順に持つことだけを確かめる（RBT-046 X2）
    func test_eraseWhere_onPartialViewRethrowsPredicateErrorAndKeepsSharedOriginal() {
      struct StopError: Error, Equatable {}
      var dictionary: RedBlackTreeDictionary<Int, String> = [
        1: "outside-before", 2: "b", 3: "c", 4: "d", 5: "outside-after",
      ]
      let lower = dictionary.index(after: dictionary.startIndex)
      let upper = dictionary.index(dictionary.startIndex, offsetBy: 4)
      let original = dictionary
      var visited: [String] = []

      XCTAssertThrowsError(
        try dictionary[lower..<upper].erase(where: { element in
          visited.append("\(element.key):\(element.value)")
          if element.key == 3 { throw StopError() }
          return element.key == 2
        })
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(visited, ["2:b", "3:c"], "範囲内の先頭から順に呼ばれ、エラーの後は呼ばれないこと")
      XCTAssertEqual(original.map(\.key), [1, 2, 3, 4, 5])
      XCTAssertEqual(original.map(\.value), ["outside-before", "b", "c", "d", "outside-after"])
      XCTAssertEqual(dictionary[1], "outside-before", "範囲より前のエントリは残ること")
      XCTAssertEqual(dictionary[5], "outside-after", "範囲より後のエントリは残ること")
      XCTAssertEqual(dictionary.map(\.key), dictionary.map(\.key).sorted())
      XCTAssertTrue(dictionary.allSatisfy { original[$0.key] == $0.value })
    }

    func test_elementsEqual_trueForSameKeyValuePairsInKeyOrder() {
      let a: RedBlackTreeDictionary = [1: "a", 2: "b"]
      let b: RedBlackTreeDictionary = [2: "b", 1: "a"]

      XCTAssertTrue(a[...].elementsEqual(b[...], by: ==))
    }

    func test_lexicographicallyPrecedes_comparesLengthAfterCommonPrefix() {
      let shorter: RedBlackTreeDictionary = [1: "a"]
      let longer: RedBlackTreeDictionary = [1: "a", 2: "b"]

      XCTAssertTrue(shorter[...].lexicographicallyPrecedes(longer[...], by: <))
      XCTAssertFalse(longer[...].lexicographicallyPrecedes(shorter[...], by: <))
    }

    /// popFirst/popLast/erase()/erase(where:)が、保持していた参照型の値を
    /// 正しく解放すること(二重解放やリークがないこと)
    func test_variousRemovalMethods_releaseRetainedReferenceValuesExactlyOnce() {
      final class DeinitializeCounter {
        nonisolated(unsafe) static var count = 0
        init() { Self.count += 1 }
        deinit { Self.count -= 1 }
      }

      var dictionary = RedBlackTreeDictionary<Int, DeinitializeCounter>(
        uniqueKeysWithValues: (0..<4).map { ($0, DeinitializeCounter()) })
      XCTAssertEqual(DeinitializeCounter.count, 4)

      _ = dictionary[...].popFirst()
      XCTAssertEqual(DeinitializeCounter.count, 3)

      _ = dictionary[...].popLast()
      XCTAssertEqual(DeinitializeCounter.count, 2)

      dictionary[...].erase(where: { $0.key == 1 })
      XCTAssertEqual(DeinitializeCounter.count, 1)

      _ = dictionary[...].erase()
      XCTAssertEqual(DeinitializeCounter.count, 0)
    }

    /// `elementsEqual(_:)`はキーと値の組を順に比べ、`lexicographicallyPrecedes(_:)`は辞書順で比べること。
    func test_elementsEqualAndLexicographicallyPrecedes_compareKeyValuePairsInOrder() {
      let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
      let view = dictionary[...]
      XCTAssertTrue(view.elementsEqual([(key: 1, value: "a"), (key: 2, value: "b"), (key: 3, value: "c")]))
      XCTAssertFalse(view.elementsEqual([(key: 1, value: "a"), (key: 2, value: "x"), (key: 3, value: "c")]))
      XCTAssertFalse(view.elementsEqual([(key: 1, value: "a")]))
      XCTAssertTrue(view.lexicographicallyPrecedes([(key: 1, value: "a"), (key: 2, value: "c")]))
      XCTAssertFalse(view.lexicographicallyPrecedes([(key: 1, value: "a"), (key: 2, value: "b"), (key: 3, value: "c")]))
      XCTAssertTrue(view.lexicographicallyPrecedes([(key: 1, value: "a"), (key: 2, value: "b"), (key: 3, value: "c"), (key: 4, value: "d")]))
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeKeyValueRangeViewTests {
    /// 範囲ビューのerase(where:)でビューの先頭要素を消しても、残りの要素はビューに残ること。
    func test_eraseWhere_removingFirstElement_keepsRest() {
      let dictionary = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 10) })
      var keyValue = dictionary[dictionary.lowerBound(3)..<dictionary.lowerBound(8)]
      keyValue.erase(where: { $0.key == 3 })
      XCTAssertEqual(keyValue.map(\.key), [4, 5, 6, 7])
    }

    /// 共有中の空でない木で、範囲ビューの`erase(where:)`が何も消さないとき、木をコピーしないこと。述語は範囲内の各要素に1回ずつ順に呼ばれること（RBT-081）。
    func test_eraseWhere_nothingMatches_keepsSharedStorage() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      var shared = original
      let lo = shared.index(after: shared.startIndex)
      let hi = shared.index(lo, offsetBy: 3)
      var visited: [Int] = []

      shared[lo ..< hi].erase { visited.append($0.key); return false }

      XCTAssertEqual(visited, [2, 3, 4])
      XCTAssertEqual(shared.map(\.key), [1, 2, 3, 4, 5])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "何も消さないViewのerase(where:)で木がコピーされた")
    }

    /// 部分範囲のViewの`erase(where:)`が最初の一致より前で投げても、エラーをそのまま呼出元へ投げ、投げた後は述語を呼ばず、
    /// 範囲外のkey/valueに触れないこと。共有していた元の辞書のkey/valueは変わらないこと。変更側の途中状態は
    /// 契約がないため、範囲外のエントリが残り、元のエントリだけをkey順に持つことだけを確かめる（RBT-094）
    func test_eraseWhere_onPartialViewThrowsBeforeFirstMatchAndKeepsSharedOriginal() {
      struct StopError: Error, Equatable {}
      var dictionary: RedBlackTreeDictionary<Int, String> = [
        1: "outside-before", 2: "b", 3: "c", 4: "d", 5: "outside-after",
      ]
      let lower = dictionary.index(after: dictionary.startIndex)
      let upper = dictionary.index(dictionary.startIndex, offsetBy: 4)
      let original = dictionary
      var visited: [String] = []

      XCTAssertThrowsError(
        try dictionary[lower..<upper].erase(where: { element in
          visited.append("\(element.key):\(element.value)")
          if element.key == 3 { throw StopError() }
          return false
        })
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(visited, ["2:b", "3:c"])
      XCTAssertEqual(original.map(\.key), [1, 2, 3, 4, 5])
      XCTAssertEqual(original.map(\.value), ["outside-before", "b", "c", "d", "outside-after"])
      XCTAssertEqual(dictionary[1], "outside-before")
      XCTAssertEqual(dictionary[5], "outside-after")
      XCTAssertEqual(dictionary.map(\.key), dictionary.map(\.key).sorted())
      XCTAssertTrue(dictionary.allSatisfy { original[$0.key] == $0.value })
    }

    /// 共有中の木から取り出した範囲ビューで、`erase(where:)`がビューの先頭を含めて要素を消すとき、
    /// 述語は範囲内の各要素に1回ずつ順に呼ばれ、ビューには残りの要素が残り、元の辞書は変わらないこと（RBT-094）。
    func test_eraseWhere_onStandaloneViewOfSharedTree_keepsRestAndOriginal() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      var view = original[original.lowerBound(2)..<original.lowerBound(5)]
      var visited: [Int] = []

      view.erase { visited.append($0.key); return $0.key != 3 }

      XCTAssertEqual(visited, [2, 3, 4])
      XCTAssertEqual(view.map(\.key), [3])
      XCTAssertEqual(view.count, 1)
      XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d", "e"])
    }

    /// 共有中の木から取り出した範囲ビューで、`erase(where:)`の述語がすべての要素に一致するとき、
    /// ビューは空になってstartIndexとendIndexが一致し、元の辞書は変わらないこと（RBT-094）。
    func test_eraseWhere_allMatchOnStandaloneViewOfSharedTree_emptiesView() {
      let original: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
      var view = original[original.lowerBound(2)..<original.lowerBound(5)]
      var visited: [Int] = []

      view.erase { visited.append($0.key); return true }

      XCTAssertEqual(visited, [2, 3, 4])
      XCTAssertTrue(view.isEmpty)
      XCTAssertEqual(view.startIndex, view.endIndex)
      XCTAssertEqual(original.map(\.value), ["a", "b", "c", "d", "e"])
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeKeyValueRangeViewTests {
    /// MultiMapでも、範囲ビューのerase(where:)で先頭要素を消して残りが残ること。
    func test_eraseWhere_removingFirstElement_keepsRest_multiMap() {
      let multiMap = RedBlackTreeMultiMap(keysWithValues: (0..<10).map { ($0, $0 * 10) })
      var keyValue = multiMap[multiMap.lowerBound(3)..<multiMap.lowerBound(8)]
      keyValue.erase(where: { $0.key == 3 })
      XCTAssertEqual(keyValue.map(\.key), [4, 5, 6, 7])
    }

    /// erase()やpopLast()で空にしたキーと値の範囲ビューは、startIndexとendIndexが一致すること。
    func test_viewEmptiedByEraseOrPopLast_hasEqualBounds() {
      let dictionary = RedBlackTreeDictionary(uniqueKeysWithValues: (0..<10).map { ($0, $0) })
      var erased = dictionary[dictionary.lowerBound(3)..<dictionary.lowerBound(8)]
      _ = erased.erase()
      XCTAssertTrue(erased.isEmpty)
      XCTAssertEqual(erased.startIndex, erased.endIndex)
      var popped = dictionary[dictionary.lowerBound(3)..<dictionary.lowerBound(4)]
      _ = popped.popLast()
      XCTAssertTrue(popped.isEmpty)
      XCTAssertEqual(popped.startIndex, popped.endIndex)

      let multiMap = RedBlackTreeMultiMap(keysWithValues: (0..<10).map { ($0, $0) })
      var multiErased = multiMap[multiMap.lowerBound(3)..<multiMap.lowerBound(8)]
      _ = multiErased.erase()
      XCTAssertTrue(multiErased.isEmpty)
      XCTAssertEqual(multiErased.startIndex, multiErased.endIndex)
      var multiPopped = multiMap[multiMap.lowerBound(3)..<multiMap.lowerBound(4)]
      _ = multiPopped.popLast()
      XCTAssertTrue(multiPopped.isEmpty)
      XCTAssertEqual(multiPopped.startIndex, multiPopped.endIndex)
    }
  }
#endif
